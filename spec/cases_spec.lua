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
