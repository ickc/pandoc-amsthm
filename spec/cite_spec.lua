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

describe("ref_target", function()
  local ids = { euler = "1", Cap = "2" }

  it("returns an id that is a key, unnamed", function()
    local id, is_named = amsthm.ref_target("euler", ids)
    assert.are.equal("euler", id)
    assert.is_false(is_named)
  end)

  it("names the environment when the first letter is capitalised", function()
    local id, is_named = amsthm.ref_target("Euler", ids)
    assert.are.equal("euler", id)
    assert.is_true(is_named)
  end)

  it("prefers an id that is itself a key", function()
    local id, is_named = amsthm.ref_target("Cap", ids)
    assert.are.equal("Cap", id)
    assert.is_false(is_named)
  end)

  it("returns nil for unknown ids", function()
    assert.is_nil(amsthm.ref_target("Nope", ids))
    assert.is_nil(amsthm.ref_target("1abc", ids))
  end)
end)

describe("cite_to_ref with names", function()
  local ids, names = { x = "" }, { x = "Main Theorem" }

  it("@Id -> Name~\\ref{id}", function()
    local c = pandoc.Cite({ pandoc.Str("@X") }, { citation("X", "AuthorInText") })
    local r = amsthm.cite_to_ref(c, ids, names)
    assert.are.equal("Main Theorem~\\ref{x}",
      pandoc.write(pandoc.Pandoc({ pandoc.Plain(r) }), "latex"))
  end)

  it("[@Id] -> (Name~\\ref{id})", function()
    local c = pandoc.Cite({ pandoc.Str("[@X]") }, { citation("X", "NormalCitation") })
    local r = amsthm.cite_to_ref(c, ids, names)
    assert.are.equal("(Main Theorem~\\ref{x})",
      pandoc.write(pandoc.Pandoc({ pandoc.Plain(r) }), "latex"))
  end)
end)

describe("resolve_inline (non-LaTeX)", function()
  local options = { identifiers = { ["thm1"] = "1.2.3" } }

  -- A link to #thm1 reading 1.2.3.
  local function assert_link(r)
    assert.are.equal("Link", r.t)
    assert.are.equal("#thm1", r.target)
    assert.are.equal("1.2.3", pandoc.utils.stringify(r))
  end

  -- "(", a link to #thm1, ")".
  local function assert_paren_link(r)
    assert.are.equal(3, #r)
    assert.are.equal("(", r[1].text)
    assert_link(r[2])
    assert.are.equal(")", r[3].text)
  end

  it("[@id] cite -> (linked number)", function()
    local c = pandoc.Cite({ pandoc.Str("[@thm1]") },
                          { citation("thm1", "NormalCitation") })
    assert_paren_link(amsthm.resolve_inline(c, options))
  end)

  it("@id cite -> linked number", function()
    local c = pandoc.Cite({ pandoc.Str("@thm1") },
                          { citation("thm1", "AuthorInText") })
    assert_link(amsthm.resolve_inline(c, options))
  end)

  it("\\ref{id} raw tex -> linked number", function()
    assert_link(amsthm.resolve_inline(
      pandoc.RawInline("tex", "\\ref{thm1}"), options))
  end)

  it("\\eqref{id} raw tex -> (linked number)", function()
    assert_paren_link(amsthm.resolve_inline(
      pandoc.RawInline("tex", "\\eqref{thm1}"), options))
  end)

  it("@Id cite -> linked name and number", function()
    local c = pandoc.Cite({ pandoc.Str("@Thm1") },
                          { citation("Thm1", "AuthorInText") })
    local r = amsthm.resolve_inline(c,
      { identifiers = options.identifiers, names = { thm1 = "Main Theorem" } })
    assert.are.equal("Link", r.t)
    assert.are.equal("#thm1", r.target)
    assert.are.equal("Main Theorem\u{a0}1.2.3", pandoc.utils.stringify(r))
  end)

  it("ignores unknown ids", function()
    local r = amsthm.resolve_inline(
      pandoc.RawInline("tex", "\\ref{nope}"), options)
    assert.is_nil(r)
  end)
end)
