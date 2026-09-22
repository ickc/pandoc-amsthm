-- Unit tests for the cite/ref helpers.

local amsthm = require("amsthm")

local function citation(id, mode)
  return pandoc.Citation(id, mode or "NormalCitation")
end

describe("cite_to_id_mode", function()
  it("returns id, mode for a single-citation Cite", function()
    local c = pandoc.Cite({ pandoc.Str("@x") }, { citation("foo", "AuthorInText") })
    local id, mode = amsthm.cite_to_id_mode(c)
    assert.are.equal("foo", id)
    assert.are.equal("AuthorInText", mode)
  end)

  it("returns nil for multi-citation Cites", function()
    local c = pandoc.Cite(
      { pandoc.Str("@x;@y") },
      { citation("a"), citation("b") }
    )
    local id = amsthm.cite_to_id_mode(c)
    assert.is_nil(id)
  end)
end)

describe("cite_to_ref", function()
  it("NormalCitation -> \\eqref{id}", function()
    local c = pandoc.Cite({ pandoc.Str("[@x]") }, { citation("x", "NormalCitation") })
    local r = amsthm.cite_to_ref(c)
    assert.are.equal("RawInline", r.t)
    assert.are.equal("latex", r.format)
    assert.are.equal("\\eqref{x}", r.text)
  end)

  it("AuthorInText -> \\ref{id}", function()
    local c = pandoc.Cite({ pandoc.Str("@x") }, { citation("x", "AuthorInText") })
    local r = amsthm.cite_to_ref(c)
    assert.are.equal("\\ref{x}", r.text)
  end)

  it("respects the check_id allow-list", function()
    local c = pandoc.Cite({ pandoc.Str("@x") }, { citation("x", "AuthorInText") })
    assert.is_nil(amsthm.cite_to_ref(c, { other = true }))
    assert.is_not_nil(amsthm.cite_to_ref(c, { x = true }))
  end)
end)

describe("resolve_inline (non-LaTeX)", function()
  local options = { identifiers = { ["thm1"] = "1.2.3" } }

  it("[@id] cite -> (number)", function()
    local c = pandoc.Cite({ pandoc.Str("[@thm1]") },
                          { citation("thm1", "NormalCitation") })
    local r = amsthm.resolve_inline(c, options)
    assert.are.equal("Str", r.t)
    assert.are.equal("(1.2.3)", r.text)
  end)

  it("@id cite -> number", function()
    local c = pandoc.Cite({ pandoc.Str("@thm1") },
                          { citation("thm1", "AuthorInText") })
    local r = amsthm.resolve_inline(c, options)
    assert.are.equal("1.2.3", r.text)
  end)

  it("\\ref{id} raw tex -> number", function()
    local r = amsthm.resolve_inline(
      pandoc.RawInline("tex", "\\ref{thm1}"), options)
    assert.are.equal("1.2.3", r.text)
  end)

  it("\\eqref{id} raw tex -> (number)", function()
    local r = amsthm.resolve_inline(
      pandoc.RawInline("tex", "\\eqref{thm1}"), options)
    assert.are.equal("(1.2.3)", r.text)
  end)

  it("ignores unknown ids", function()
    local r = amsthm.resolve_inline(
      pandoc.RawInline("tex", "\\ref{nope}"), options)
    assert.is_nil(r)
  end)
end)
