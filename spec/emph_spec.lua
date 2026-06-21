-- Unit tests for the Emph/Strong helpers (port of tests/test_emph.py).
-- Parameterised over the inline element types the original test exercises.

local amsthm = require("amsthm")

-- Strip Pandoc-specific metatables before comparing structures so
-- assert.are.same compares structurally.
local function plain(v, seen)
  if type(v) ~= "table" then return v end
  seen = seen or {}
  if seen[v] then return seen[v] end
  local out = {}
  seen[v] = out
  if v.t then out.t = v.t end
  if v.text then out.text = v.text end
  if v.content then
    out.content = {}
    for i, c in ipairs(v.content) do out.content[i] = plain(c, seen) end
  end
  -- For top-level Block (Para/Plain), iterate ipairs to capture Inlines.
  for i, c in ipairs(v) do out[i] = plain(c, seen) end
  return out
end

local function para(...) return pandoc.Para({ ... }) end
local function S(s) return pandoc.Str(s) end
local SP = pandoc.Space

local CASES = {
  { name = "Emph",        ctor = pandoc.Emph },
  { name = "Underline",   ctor = pandoc.Underline },
  { name = "Strong",      ctor = pandoc.Strong },
  { name = "Strikeout",   ctor = pandoc.Strikeout },
  { name = "Superscript", ctor = pandoc.Superscript },
  { name = "Subscript",   ctor = pandoc.Subscript },
  { name = "SmallCaps",   ctor = pandoc.SmallCaps },
}

for _, case in ipairs(CASES) do
  describe(case.name, function()
    local T = case.name
    local C = case.ctor
    local to   = amsthm.to_type(T)
    local cncl = amsthm.cancel_repeated_type(T)
    local mrg  = amsthm.merge_consecutive_type(T)

    it("to_type wraps every Str", function()
      local p = para(S("a"), SP(), S("b"))
      p = p:walk({ Str = to })
      local want = para(C({ S("a") }), SP(), C({ S("b") }))
      assert.are.same(plain(want), plain(p))
    end)

    it("cancel_repeated_type unwraps double-nested wrappers", function()
      local p = para(C({ C({ S("a") }) }), SP(), C({ S("b") }))
      p = p:walk({ [T] = cncl })
      local want = para(S("a"), SP(), C({ S("b") }))
      assert.are.same(plain(want), plain(p))
    end)

    -- merge_consecutive_type operates on a Block as a whole, so we call
    -- it directly. (`:walk` on a Para visits descendants, not the Para
    -- itself; the filter pipeline embeds the block under a Div, where
    -- walk does descend to it.)
    it("merge_consecutive_type merges adjacent wrappers", function()
      local p = para(C({ S("a") }), C({ S("b") }))
      mrg(p)
      local want = para(C({ S("a"), S("b") }))
      assert.are.same(plain(want), plain(p))
    end)

    it("merge_consecutive_type merges across a single Space", function()
      local p = para(C({ S("a") }), SP(), C({ S("b") }))
      mrg(p)
      local want = para(C({ S("a"), SP(), S("b") }))
      assert.are.same(plain(want), plain(p))
    end)

    it("to + cancel + merge composes correctly", function()
      local p = para(C({ S("a") }), C({ S("b") }), SP(), S("c"), S("d"))
      p = p:walk({ Str = to })
      p = p:walk({ [T] = cncl })
      mrg(p)
      -- Applying to_type wraps c and d as C; cancel undoes
      -- the now-double wrapping around the original C(S("a")) / C(S("b"))
      -- (they became C(C(Str))); merge then joins the two resulting Cs.
      local want = para(S("a"), S("b"), SP(), C({ S("c"), S("d") }))
      assert.are.same(plain(want), plain(p))
    end)
  end)
end
