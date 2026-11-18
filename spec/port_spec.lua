-- The porting filter, tools/amsthm-port-v4.lua: run the `pandoc` binary
-- with it on the documents in tests/port/, and compare the document it
-- makes with the one expected, as pandoc reads both, so that the writer's
-- layout, which changes between pandoc versions, does not matter.

local PORT = "tools/amsthm-port-v4.lua"

-- Run pandoc; return stdout and stderr.
local function run(args)
  local err_path = os.tmpname()
  local p = assert(io.popen("pandoc " .. args .. " 2>" .. err_path, "r"))
  local out = p:read("*a")
  p:close()
  local f = assert(io.open(err_path, "r"))
  local err = f:read("*a")
  f:close()
  os.remove(err_path)
  return out, err
end

-- A document as pandoc reads it. A citation's note number counts the
-- citations before it, which a note read on its own does not have.
local function native(out)
  return (out:gsub("citationNoteNum = %d+", "citationNoteNum = _"))
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

describe("the porting filter", function()
  it("writes each environment's note as a leading span", function()
    local ported = run("tests/port/v3.md -s -L " .. PORT .. " -t native")
    local want = run("tests/port/v4.md -s -t native")
    assert.are.equal(native(want), native(ported))
  end)

  it("says what it ported, and what it left alone and why", function()
    local _, err = run("tests/port/v3.md -s -L " .. PORT .. " -t markdown")
    has(err, '[amsthm-port] ported {#lagrange .Theorem info="Lagrange"}: [Lagrange]{.info}')
    has(err, '{.Theorem info="- a list"}: the note is not text')
    has(err, '{.Callout info="not ours"} is not a declared environment; left alone')
    has(err, '{.Theorem .Lemma info="two"} names two environments')
    has(err, '{.Theorem info="Lagrange"} already starts with a note span; left alone')
  end)

  it("reads the environments of a metadata file it is given", function()
    local out, err = run("tests/port/metadata-file.md -s -L " .. PORT .. " -t markdown")
    has(err, "is not a declared environment")
    has(out, '{.Claim info="*with* emphasis"}')
    out = run("tests/port/metadata-file.md -s -L " .. PORT .. " -t markdown" ..
      " -M amsthm-port-metadata=tests/port/metadata-file.yml")
    has(out, "::: Claim\n[*with* emphasis]{.info} Text.\n:::")
    -- The file is read for the names; neither it nor the option is
    -- written into the document.
    lacks(out, "amsthm")
    has(out, "title: Environments declared in a metadata file")
  end)
end)
