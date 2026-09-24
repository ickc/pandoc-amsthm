-- End-to-end regression tests: run the `pandoc` binary with the filter on
-- the small inputs in tests/cases/ and check the parts of the output that
-- each one is about.

local FILTER = "_extensions/amsthm/amsthm.lua"

-- Run pandoc on a case; return stdout and stderr.
local function run(case, args)
  local err_path = os.tmpname()
  local p = assert(io.popen(
    "pandoc -L " .. FILTER .. " tests/cases/" .. case .. " --wrap=none " ..
    args .. " 2>" .. err_path, "r"))
  local out = p:read("*a")
  p:close()
  local f = assert(io.open(err_path, "r"))
  local err = f:read("*a")
  f:close()
  os.remove(err_path)
  return out, err
end

local function has(s, sub)
  if not s:find(sub, 1, true) then
    error(("expected to find %q in:\n%s"):format(sub, s), 2)
  end
end

local function lacks(s, sub)
  if s:find(sub, 1, true) then
    error(("expected not to find %q in:\n%s"):format(sub, s), 2)
  end
end

local function count(s, sub)
  local n, i = 0, 1
  while true do
    local j = s:find(sub, i, true)
    if not j then return n end
    n, i = n + 1, j + 1
  end
end

local LATEX = "-t latex -s --template tests/template.latex"

describe("nested theorems", function()
  it("keep their own environments in LaTeX", function()
    local out = run("nested.md", LATEX)
    has(out, "\\begin{Theorem}\\label{thm-outer}")
    has(out, "\\begin{Theorem}\\label{thm-inner}")
    has(out, "\\begin{Definition}")
    has(out, "\\begin{Theorem}\\label{thm-in-proof}")
    assert.are.equal(4, count(out, "\\end{Theorem}") + count(out, "\\end{Definition}"))
    -- Each label once: no second one from the LaTeX writer.
    lacks(out, "phantomsection")
    has(out, "See \\eqref{thm-inner} and \\eqref{thm-in-proof}.")
  end)

  it("are numbered in document order, as in LaTeX", function()
    local out = run("nested.md", "-t markdown")
    has(out, "[**Theorem 1.**]{.amsthm-title} *Outer statement.*")
    has(out, "[**Theorem 2.**]{.amsthm-title} *Inner statement.*")
    has(out, "[**Theorem 3.**]{.amsthm-title} *A theorem inside a proof.*")
    has(out, "See ([2](#thm-inner)) and ([3](#thm-in-proof)).")
  end)

  it("keep their own style inside a plain theorem", function()
    local out = run("nested.md", "-t markdown")
    has(out, "[**Definition 1.**]{.amsthm-title} A definition inside a theorem.")
  end)
end)

describe("theorem bodies in LaTeX", function()
  it("go through the writer with the user's options", function()
    local out = run("natbib.md", "-t latex --natbib")
    has(out, "Outside a theorem, see \\citet{knuth}.")
    has(out, "\\begin{Theorem}[as in \\citet{knuth}]")
    has(out, "Inside a theorem, see \\citet{knuth}.")
    lacks(out, "@knuth")
  end)
end)

describe("heading counters", function()
  it("skip unnumbered headings", function()
    local out = run("unnumbered.md", "-t markdown")
    has(out, "**Theorem 2.1.**")
  end)

  it("start from --number-offset", function()
    local out = run("number-offset.md", "-t html -N --number-offset=4")
    has(out, "Theorem 5.1.")
  end)
end)

describe("metadata", function()
  it("takes a single value as a list of one", function()
    local out = run("scalar-meta.md", LATEX)
    has(out, "\\newtheorem{Main Theorem}{Main Theorem}\n")
    lacks(out, "\\newtheorem{ }")
    out = run("scalar-meta.md", "-t markdown")
    has(out, "**Main Theorem 1.1.**")
  end)

  it("drops an unsupported parent_counter", function()
    local out, err = run("bad-parent-counter.md", LATEX)
    has(err, "unsupported parent_counter foo")
    has(out, "\\newtheorem{Theorem}{Theorem}\n")
    lacks(out, "[foo]")
  end)

  it("defines the environments of a map in a fixed order", function()
    local out = run("map-order.md", LATEX)
    has(out, table.concat({
      "\\newtheorem{Axiom}{Axiom}",
      "\\newtheorem{Rule}[Axiom]{Rule}",
      "\\newtheorem{Claim}{Claim}",
      "\\newtheorem{Fact}[Claim]{Fact}",
      "\\newtheorem{Theorem}{Theorem}",
      "\\newtheorem{Lemma}[Theorem]{Lemma}",
      "\\newtheorem{Zed}{Zed}",
      "\\newtheorem{Why}[Zed]{Why}",
    }, "\n"))
  end)
end)

describe("classes", function()
  it("may repeat an environment", function()
    local out = run("duplicate-class.md", "-t markdown")
    has(out, "[**Theorem 1.**]{.amsthm-title} *The same class twice is still a theorem.*")
    out = run("duplicate-class.md", "-t latex")
    has(out, "\\begin{Theorem}\nThe same class twice is still a theorem.\n\\end{Theorem}")
  end)

  it("naming two environments are left alone, with one warning", function()
    for _, fmt in ipairs({ "markdown", "latex" }) do
      local out, err = run("duplicate-class.md", "-t " .. fmt)
      assert.are.equal(1, count(err, "multiple environments found: Theorem, Lemma"))
      has(out, "Two environments: left alone, with a warning.")
      lacks(out, "\\begin{Theorem}\nTwo")
      lacks(out, "\\begin{Lemma}")
      lacks(out, "Lemma 1")
    end
  end)
end)

describe("a reference to an unnumbered environment", function()
  it("is left to citeproc in LaTeX, as in other output", function()
    local out = run("unnumbered-ref.md", LATEX)
    has(out, "\\begin{Main Theorem}\\label{main}")
    has(out, "See \\ref{euler} and @main.")
    out = run("unnumbered-ref.md", "-t markdown")
    has(out, "See [1](#euler) and @main.")
  end)
end)
