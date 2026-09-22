-- End-to-end golden tests: drive the actual `pandoc` binary with the
-- Lua filter on tests/model-source.md and diff the output against the
-- committed golden files.

-- Pandoc < 3.2 wraps headers as \hypertarget{id}{%\n\chapter{..}\label{id}}.
-- That is writer drift unrelated to the filter, so unwrap it before
-- comparing; this keeps one set of goldens across the supported range.
local function normalize(s)
  return (s:gsub("\\hypertarget%b{}{%%\n(\\%a+%b{}\\label%b{})}", "%1"))
end

local function read(path)
  local f = assert(io.open(path, "r"))
  local s = f:read("*a")
  f:close()
  return (s:gsub("%s+$", ""))
end

local function run(cmd)
  local p = assert(io.popen(cmd, "r"))
  local out = p:read("*a")
  local ok = p:close()
  return ok, normalize((out or ""):gsub("%s+$", ""))
end

local SRC    = "tests/model-source.md"
local TARGET = "tests/model-target.md"
local LATEX  = "tests/model-latex.tex"

describe("golden", function()
  it("latex output matches model-latex.tex", function()
    local ok, out = run(
      "pandoc -L _extensions/amsthm/amsthm.lua " .. SRC ..
      " --top-level-division=chapter --toc -N -t latex")
    assert.is_true(ok ~= nil and ok ~= false)
    local want = read(LATEX)
    if out ~= want then
      -- emit a unified-ish diff hint
      io.write("\n--- expected (first 600) ---\n", want:sub(1, 600),
               "\n--- got (first 600) ---\n", out:sub(1, 600), "\n")
    end
    assert.are.equal(want, out)
  end)

  it("markdown output matches model-target.md", function()
    local ok, out = run("pandoc -L _extensions/amsthm/amsthm.lua " .. SRC .. " -t markdown")
    assert.is_true(ok ~= nil and ok ~= false)
    local want = read(TARGET)
    if out ~= want then
      io.write("\n--- expected (first 600) ---\n", want:sub(1, 600),
               "\n--- got (first 600) ---\n", out:sub(1, 600), "\n")
    end
    assert.are.equal(want, out)
  end)
end)
