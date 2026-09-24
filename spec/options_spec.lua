-- Unit tests for reading the amsthm metadata block.

local amsthm = require("amsthm")

local function meta(yaml)
  return pandoc.read("---\n" .. yaml .. "\n---\n", "markdown").meta
end

describe("counter_depth", function()
  it("defaults to 0 without parent_counter", function()
    local opts = amsthm.from_meta(meta("amsthm:\n  plain: [Theorem]"))
    assert.are.equal(0, opts.counter_depth)
  end)

  it("follows parent_counter, with sections at level 1 by default", function()
    local opts = amsthm.from_meta(meta("amsthm:\n  plain: [Theorem]\n  parent_counter: section"))
    assert.are.equal(1, opts.counter_depth)
  end)

  it("follows parent_counter, with chapters at level 1 in a book", function()
    local opts = amsthm.from_meta(meta(
      "documentclass: book\namsthm:\n  plain: [Theorem]\n  parent_counter: section"))
    assert.are.equal(2, opts.counter_depth)
  end)

  it("is 0 when parent_counter is above the top level", function()
    local opts = amsthm.from_meta(meta("amsthm:\n  plain: [Theorem]\n  parent_counter: part"))
    assert.are.equal(0, opts.counter_depth)
  end)

  it("is taken as given when set", function()
    local opts = amsthm.from_meta(meta(
      "amsthm:\n  parent_counter: section\n  counter_depth: 3"))
    assert.are.equal(3, opts.counter_depth)
  end)
end)

describe("an empty amsthm key", function()
  it("defines only the proof", function()
    local opts = amsthm.from_meta(meta("amsthm:"))
    assert.are.equal(1, #opts.theorems_order)
    assert.is_not_nil(opts.theorems_map.proof)
  end)
end)
