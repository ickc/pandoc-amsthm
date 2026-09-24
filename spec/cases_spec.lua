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
    has(out, "\\begin{Theorem}[{as in \\citet{knuth}}]")
    has(out, "Inside a theorem, see \\citet{knuth}.")
    lacks(out, "@knuth")
  end)

  it("brace a note that may hold a ], so it does not end the note early", function()
    local out = run("natbib.md", "-t latex --natbib")
    has(out, "\\begin{Theorem}[{as in \\citet[p.~3]{knuth}}]")
    has(out, "\\begin{Theorem}[{on \\([0,1]\\)}]")
    -- The writer escapes brackets in text already.
    has(out, "\\begin{Theorem}[see {[}1{]}]")
    has(out, "\\begin{Theorem}[{with")
    has(out, "{x.png}}]")
  end)
end)

describe("heading counters", function()
  it("skip unnumbered headings", function()
    local out = run("unnumbered.md", "-t markdown -N")
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
    out = run("scalar-meta.md", "-t markdown -N")
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

describe("a reference with a capitalised id", function()
  it("names the environment in LaTeX", function()
    local out = run("named-ref.md", LATEX)
    has(out, "By Theorem~\\ref{euler}, (Lemma~\\ref{nz}), Klein's Lemma~\\ref{kl}")
    -- An id that is capitalised itself is an ordinary reference.
    has(out, "and \\ref{Cap}, \\ref{euler}, @Unknown.")
  end)

  it("names the environment in other output", function()
    local out = run("named-ref.md", "-t html")
    has(out, 'By Theorem\u{a0}<a href="#euler">1</a>, (Lemma\u{a0}<a href="#nz">2</a>)')
    has(out, '<a href="#Cap">3</a>, <a href="#euler">1</a>')
  end)
end)

describe("name_to_text for proof", function()
  it("sets \\proofname in LaTeX, after babel", function()
    local out = run("proof-name.md", LATEX)
    has(out, "\\AtBeginDocument{\\renewcommand{\\proofname}{Beweis}}")
  end)

  it("names the proof in other output", function()
    local out = run("proof-name.md", "-t markdown")
    has(out, "[*Beweis.*]{.amsthm-title} Klar.")
  end)
end)

describe("a reference in the italic body of a plain theorem", function()
  it("is italic like \\ref, or upright like \\eqref", function()
    local out = run("italic-ref.md", "-t markdown")
    has(out, "*By [1](#a), Theorem\u{a0}[1](#a),* ([1](#a))*, [1](#a) and* ([1](#a))*;*")
    -- Upright inside emphasis, as \\emph makes it in LaTeX.
    has(out, "by [1](#a)*.*")
    -- The body of other styles is upright.
    has(out, "By [1](#a).")
  end)
end)

describe("a reference to an unnumbered environment", function()
  it("is written as \\ref in LaTeX, as a LaTeX author would, with a warning", function()
    local out, err = run("unnumbered-ref.md", LATEX)
    has(out, "See \\ref{euler}, \\ref{main}, \\eqref{main} and \\ref{main}.")
    has(err, "unnumbered environment main")
    assert.are.equal(1, count(err, "[amsthm] warning"))
  end)

  it("is left unresolved in other output, with a warning", function()
    local out, err = run("unnumbered-ref.md", "-t markdown")
    has(out, "See [1](#euler), @main, [@main] and `\\ref{main}`{=tex}.")
    has(err, "unnumbered environment main")
  end)
end)

describe("a reference in the note of a proof", function()
  it("is italic like the note, or upright like \\eqref", function()
    local out = run("proof-note.md", "-t markdown")
    has(out, "[*Proof of Theorem\u{a0}[1](#euler), see* ([1](#euler))*.*]{.amsthm-title}")
  end)
end)

describe("the end-of-proof symbol", function()
  it("is math, so that it renders in every format, LaTeX included", function()
    local out = run("proof-note.md", "-t markdown")
    has(out, "Obvious.[$\\quad\\Box$]{.amsthm-qed}")
  end)
end)

-- Each expectation below is what amsthm prints for the same document in
-- LaTeX, with the same options.
describe("theorem numbers follow LaTeX's section numbering", function()
  local function numbers(out)
    local found = {}
    for n in out:gmatch("Theorem ([%dIVX.]+)%.") do found[#found + 1] = n end
    return table.concat(found, " ")
  end

  it("without -N: sections step no counter", function()
    local out, err = run("section-numbering.md", "-t plain")
    assert.are.equal("0.1 0.2 0.3", numbers(out))
    has(err, "sections that are not numbered")
  end)

  it("with -N", function()
    local out, err = run("section-numbering.md", "-t plain -N")
    assert.are.equal("1.1 2.1 2.2", numbers(out))
    lacks(err, "warning")
  end)

  it("below secnumdepth: those headings step no counter", function()
    local out = run("section-numbering.md", "-t plain -N -V secnumdepth=0 " ..
      "-M documentclass=book --top-level-division=chapter")
    assert.are.equal("1.0.1 2.0.1 2.0.2", numbers(out))
  end)

  it("with parts: a part is not in a chapter's number, nor resets it", function()
    local out = run("part-chapter.md", "-t plain -N --top-level-division=part")
    assert.are.equal("0.1 1.1 1.2", numbers(out))
  end)

  it("within parts: a part is numbered in Roman numerals", function()
    local out = run("part-part.md", "-t plain -N --top-level-division=part")
    assert.are.equal("I.1 II.1 II.2", numbers(out))
  end)
end)

describe("swapnumbers", function()
  it("is \\swapnumbers before the environments in LaTeX", function()
    local out = run("swapnumbers.md", LATEX)
    has(out, "\\swapnumbers\n\\theoremstyle{plain}")
  end)

  it("puts the number first, in the heading font, in other output", function()
    local out = run("swapnumbers.md", "-t markdown")
    has(out, "[**1\u{a0}Theorem** (Euler)**.**]{.amsthm-title} *First.*")
    -- Unlike after the name, the number is not upright in an italic heading.
    has(out, "[*1\u{a0}Case.*]{.amsthm-title} Second.")
    has(out, "[*Note.*]{.amsthm-title} Third.")
  end)
end)

describe("qed_symbol", function()
  it("sets \\qedsymbol in LaTeX", function()
    local out = run("qed-symbol.md", LATEX)
    has(out, "\\renewcommand{\\qedsymbol}{\\ensuremath{\\blacksquare}}")
  end)

  it("ends a proof in other output", function()
    local out = run("qed-symbol.md", "-t markdown")
    has(out, "Obvious.[$\\quad\\blacksquare$]{.amsthm-qed}")
  end)

  it("may be given as raw TeX", function()
    local out = run("qed-symbol-raw.md", "-t markdown")
    has(out, "Obvious.[$\\quad\\blacksquare$]{.amsthm-qed}")
  end)
end)

describe("\\qedhere", function()
  it("passes through to amsthm in LaTeX", function()
    local out = run("qedhere.md", LATEX)
    has(out, "x = 1. \\qedhere")
    has(out, "two \\qedhere")
  end)

  it("puts the symbol there, and not at the end, in other output", function()
    local out = run("qedhere.md", "-t markdown")
    -- In math, amsthm's \mathqed: \quad\qedsymbol in place.
    has(out, "$$x = 1. \\quad\\Box$$\n:::")
    -- In text, \qed, which takes the space before it away.
    has(out, " two[$\\quad\\Box$]{.amsthm-qed}\n:::")
    -- A nested proof has a \qedhere of its own; the outer one still ends.
    has(out, "Inner.[$\\quad\\Box$]{.amsthm-qed}")
    has(out, "Outer.[$\\quad\\Box$]{.amsthm-qed}")
    assert.are.equal(4, count(out, "\\Box"))
  end)
end)

describe("parent_counter per environment", function()
  local ARGS = " -N --top-level-division=chapter"

  it("gives each \\newtheorem its own parent in LaTeX", function()
    local out, err = run("parent-counter-map.md", LATEX .. ARGS)
    has(out, "\\newtheorem{Theorem}{Theorem}[section]")
    has(out, "\\newtheorem{Lemma}[Theorem]{Lemma}")
    has(out, "\\newtheorem{Conjecture}{Conjecture}\n")
    has(out, "\\newtheorem{Remark}{Remark}[chapter]")
    has(err, "Lemma shares the counter of Theorem")
  end)

  it("numbers each within its own parent in other output, as amsthm does", function()
    local out = run("parent-counter-map.md", "-t plain" .. ARGS)
    local found = {}
    for n in out:gmatch("%u%l+ ([%d.]+)%.") do found[#found + 1] = n end
    -- The numbers amsthm prints for this document.
    assert.are.equal("1.1.1 1.1.2 1 1.1 1.2.1 2 1.2 2.0.1 3 2.1",
      table.concat(found, " "))
  end)
end)
