--[[
amsthm.lua — a Pandoc Lua filter implementing the LaTeX amsthm
theorem / proof environments for any output format.

Usage: pandoc -L amsthm.lua input.md -N -o output.<ext>
   or, in Quarto, `filters: [amsthm]` after `quarto add ickc/pandoc-amsthm`

Documentation: https://ickc.github.io/pandoc-amsthm
License: BSD-3-Clause
]]

local M = {}

---------------------------------------------------------------------
-- Constants and module locals
---------------------------------------------------------------------

local stringify = pandoc.utils.stringify

-- LaTeX sectioning units, by depth. Also the valid values of parent_counter.
local PARENT_COUNTERS = {
  part = 0, chapter = 1, section = 2, subsection = 3,
  subsubsection = 4, paragraph = 5, subparagraph = 6,
}
-- Document classes for which pandoc's LaTeX writer makes level-1 headings
-- chapters when --top-level-division is not given.
local CHAPTER_CLASSES = {
  memoir = true, book = true, report = true, scrreprt = true,
  scrreport = true, scrbook = true, extreport = true, extbook = true,
  ["tufte-book"] = true,
}
local STYLES = { "plain", "definition", "remark" }
-- amsthm's built-in styles, in the terms of \newtheoremstyle: the fonts of
-- the heading and the body (lists of FONT_TYPES keys), the punctuation
-- after the heading, and the space after that (" " or "newline").
local BUILTIN_STYLES = {
  plain = { headfont = { "bold" }, bodyfont = { "italic" },
    headpunct = ".", headspace = " " },
  definition = { headfont = { "bold" }, bodyfont = {},
    headpunct = ".", headspace = " " },
  remark = { headfont = { "italic" }, bodyfont = {},
    headpunct = ".", headspace = " " },
}
local FONT_TYPES = { bold = "Strong", italic = "Emph", smallcaps = "SmallCaps" }
local METADATA_KEY = "amsthm"
local LATEX_LIKE = { latex = true, beamer = true }
local COUNTER_DEPTH_DEFAULT = 0
local QUARTO_PROOF_CLASSES = { proof = true, remark = true, solution = true }

local function is_latex_like(format)
  return LATEX_LIKE[format or FORMAT] == true
end
M.is_latex_like = is_latex_like

-- Formats whose header-includes are HTML, so the filter can ship its CSS.
local HTML_LIKE = {
  html = true, html4 = true, html5 = true, chunkedhtml = true,
  epub = true, epub2 = true, epub3 = true, revealjs = true, slidy = true,
  slideous = true, dzslides = true, s5 = true,
}
-- :where() keeps the specificity at zero, so a rule of the user's own wins
-- wherever their stylesheet sits relative to this one.
local CSS = [[
<style>
:where(.amsthm-qed) { float: right; }
</style>]]

-- Append a block to header-includes, whatever form the user gave it in.
local function add_header_include(meta, block, at_start)
  local hi = meta["header-includes"]
  if hi == nil then
    hi = pandoc.MetaList({})
  elseif pandoc.utils.type(hi) ~= "List" then
    hi = pandoc.MetaList({ hi })
  end
  hi:insert(at_start and 1 or #hi + 1, pandoc.MetaBlocks({ block }))
  meta["header-includes"] = hi
end

---------------------------------------------------------------------
-- Emph / Strong helpers
---------------------------------------------------------------------

-- Recognise the inline element constructors we wrap with.
local INLINE_TYPES = {
  Emph = pandoc.Emph, Underline = pandoc.Underline, Strong = pandoc.Strong,
  Strikeout = pandoc.Strikeout, Superscript = pandoc.Superscript,
  Subscript = pandoc.Subscript, SmallCaps = pandoc.SmallCaps,
  Quoted = pandoc.Quoted, Cite = pandoc.Cite, Link = pandoc.Link,
  Image = pandoc.Image, Span = pandoc.Span,
}

-- Convert every Str into ElementType(Str). Used as a walk callback.
local function to_type(elem_type)
  elem_type = elem_type or "Emph"
  local ctor = INLINE_TYPES[elem_type]
  return function(el)
    if el.t == "Str" then return ctor({ el }) end
    return nil
  end
end
M.to_type = to_type
M.to_emph = to_type("Emph")

-- Spaces look the same in any style, so they are never wrapped on their own.
local BLANK = { Space = true, SoftBreak = true, LineBreak = true }

-- Cancel a double-wrap of the same type (LaTeX: \emph{\emph{x}} == x).
local function cancel_repeated_type(elem_type)
  elem_type = elem_type or "Emph"
  local ctor = INLINE_TYPES[elem_type]
  return function(el)
    if el.t == elem_type then
      local res = {}
      for _, child in ipairs(el.content) do
        if child.t == elem_type then
          for _, c in ipairs(child.content) do res[#res + 1] = c end
        elseif BLANK[child.t] then
          res[#res + 1] = child
        else
          res[#res + 1] = ctor({ child })
        end
      end
      return res
    end
    return nil
  end
end
M.cancel_repeated_type = cancel_repeated_type
M.cancel_emph = cancel_repeated_type("Emph")

-- Merge consecutive same-type wraps, with an optional Space between, in
-- the inline content of a block. One pass, so linear in the content length.
local function merge_consecutive_type(elem_type)
  elem_type = elem_type or "Emph"
  local ctor = INLINE_TYPES[elem_type]
  return function(el)
    local content = el.content
    if content == nil or #content < 2 then return nil end
    local out = {}
    -- `run` collects the children of the wrapper being built; it is flushed
    -- into `out` when something other than a mergeable wrapper follows.
    local run
    local mutated = false
    local function flush()
      if run then
        out[#out + 1] = ctor(run)
        run = nil
      end
    end
    local n = #content
    for i = 1, n do
      local cur = content[i]
      if cur.t == elem_type then
        if run then
          mutated = true
        else
          run = {}
        end
        for _, c in ipairs(cur.content) do run[#run + 1] = c end
      elseif run and cur.t == "Space" and i < n and content[i + 1].t == elem_type then
        run[#run + 1] = pandoc.Space()
      else
        flush()
        out[#out + 1] = cur
      end
    end
    flush()
    if mutated then
      el.content = out
      return el
    end
    return nil
  end
end
M.merge_consecutive_type = merge_consecutive_type
M.merge_emph = merge_consecutive_type("Emph")

---------------------------------------------------------------------
-- Cite / ref helpers
---------------------------------------------------------------------

local function cite_to_id_mode(elem)
  if #elem.citations ~= 1 then return nil end
  local c = elem.citations[1]
  return c.id, c.mode
end
M.cite_to_id_mode = cite_to_id_mode

-- The environment a cited id refers to, among the keys of `ids`, and
-- whether to name it: `@Euler` is `@euler` with the name of its
-- environment before the number, as \Cref would write it. An id that is
-- itself a key always wins.
local function ref_target(id, ids)
  if ids[id] then return id, false end
  local lower = id:gsub("^%u", string.lower)
  if lower ~= id and ids[lower] then return lower, true end
  return nil
end
M.ref_target = ref_target

-- `name`, a no-break space, then `number`: "Theorem 1".
local function named(name, number)
  local out = pandoc.Inlines(name)
  out:insert(pandoc.Str("\u{a0}"))
  out:insert(number)
  return out
end

-- Convert pf.Cite to a raw LaTeX \ref{} / \eqref{}.
-- @param check_id  optional table; transform only if the cite id is a key.
-- @param names     optional table from id to environment name, so that
--                  `@Id` becomes `Name~\ref{id}` and `[@Id]` `(Name~\ref{id})`.
local function cite_to_ref(elem, check_id, names)
  if elem.t ~= "Cite" then return nil end
  local id, mode = cite_to_id_mode(elem)
  if id == nil then return nil end
  if mode ~= "NormalCitation" and mode ~= "AuthorInText" then return nil end
  local paren = mode == "NormalCitation"
  local name
  if check_id ~= nil then
    local is_named
    id, is_named = ref_target(id, check_id)
    if id == nil then return nil end
    name = is_named and names and names[id]
  end
  if not name then
    return pandoc.RawInline("latex", (paren and "\\eqref{" or "\\ref{") .. id .. "}")
  end
  local out = named(name, pandoc.RawInline("latex", "\\ref{" .. id .. "}"))
  if paren then
    out:insert(1, pandoc.Str("("))
    out:insert(pandoc.Str(")"))
  end
  return out
end
M.cite_to_ref = cite_to_ref

-- In LaTeX, italic text such as the body of a plain theorem or the
-- heading of a proof makes what \ref and an in-text citation print
-- italic too, while \eqref is upright. Wrap the former before they are
-- resolved, so other output matches.
local function italic_ref(el)
  if el.t == "Cite" then
    local _, mode = cite_to_id_mode(el)
    if mode ~= "AuthorInText" then return nil end
  elseif el.format ~= "tex" or not el.text:match("^\\ref%{.-%}$") then
    return nil
  end
  return pandoc.Emph({ el })
end

-- Parse a markdown string to an Inlines list, unwrapping the leading Para.
local function parse_markdown_as_inline(md)
  local doc = pandoc.read(md, "markdown")
  local out = {}
  for _, blk in ipairs(doc.blocks) do
    if blk.t == "Para" or blk.t == "Plain" then
      for _, inl in ipairs(blk.content) do out[#out + 1] = inl end
    else
      out[#out + 1] = blk
    end
  end
  return out
end
M.parse_markdown_as_inline = parse_markdown_as_inline

local function parse_info(info)
  if info == nil or info == "" then return {} end
  local res = { pandoc.Str("(") }
  for _, e in ipairs(parse_markdown_as_inline(info)) do res[#res + 1] = e end
  res[#res + 1] = pandoc.Str(")")
  return res
end
M.parse_info = parse_info

---------------------------------------------------------------------
-- NewTheorem / Proof
---------------------------------------------------------------------

local NewTheorem = {}
NewTheorem.__index = NewTheorem

function NewTheorem.new(args)
  local self = setmetatable({}, NewTheorem)
  self.style = args.style
  self.env_name = args.env_name
  self.text = args.text or ""
  self.parent_counter = args.parent_counter
  self.shared_counter = args.shared_counter
  self.numbered = (args.numbered ~= false)
  -- post-init normalisation
  if self.env_name:sub(-1) == "*" then
    self.env_name = self.env_name:sub(1, -2)
    self.numbered = false
  end
  if self.text == nil or self.text == "" then self.text = self.env_name end
  if self.parent_counter ~= nil and not PARENT_COUNTERS[self.parent_counter] then
    io.stderr:write("[amsthm] warning: unsupported parent_counter " ..
      tostring(self.parent_counter) .. ", ignoring\n")
    self.parent_counter = nil
  end
  if self.numbered and self.parent_counter ~= nil and self.shared_counter ~= nil then
    self.shared_counter = nil
  end
  return self
end

function NewTheorem:latex()
  local parts = { "\\newtheorem" }
  if not self.numbered then
    parts[#parts + 1] = "*{" .. self.env_name .. "}{" .. self.text .. "}"
  elseif self.shared_counter == nil then
    if self.parent_counter == nil then
      parts[#parts + 1] = "{" .. self.env_name .. "}{" .. self.text .. "}"
    else
      parts[#parts + 1] = "{" .. self.env_name .. "}{" .. self.text .. "}[" ..
        self.parent_counter .. "]"
    end
  else
    parts[#parts + 1] = "{" .. self.env_name .. "}[" .. self.shared_counter ..
      "]{" .. self.text .. "}"
  end
  return table.concat(parts)
end

function NewTheorem:class_name()
  return (self.env_name:gsub(" ", "_"))
end

function NewTheorem:counter_name()
  return self.shared_counter or self.env_name
end

-- Wrap inlines in the elements of a font, such as { "bold", "italic" }.
local function in_font(inlines, font)
  local out = inlines
  for i = #font, 1, -1 do out = { INLINE_TYPES[FONT_TYPES[font[i]]](out) } end
  return out
end

-- A font without italics, as amsthm's \@upn sets the number in a heading.
local function upright(font)
  local out = {}
  for _, f in ipairs(font) do
    if f ~= "italic" then out[#out + 1] = f end
  end
  return out
end

-- Join runs of inlines, each { inlines, font }, wrapping each stretch of
-- one font once, so that "Theorem 1." is one Strong rather than three.
local function join_runs(runs)
  local out, content, key, font = {}, nil, nil, nil
  local function flush()
    if content then
      for _, e in ipairs(in_font(content, font)) do out[#out + 1] = e end
    end
  end
  for _, run in ipairs(runs) do
    local k = table.concat(run[2], ",")
    if k ~= key then
      flush()
      content, key, font = {}, k, run[2]
    end
    for _, e in ipairs(run[1]) do content[#content + 1] = e end
  end
  flush()
  return out
end

-- The heading of the environment, as amsthm's \thmhead writes it: the
-- name and the number in the style's heading font, the number upright,
-- the note in parentheses in the note font (medium, upright), and the
-- punctuation, followed by the space after the heading.
function NewTheorem:to_header(options, id, info)
  local style = options.styles[self.style]
  local head = style.headfont

  local theorem_number
  if self.numbered then
    local cname = self:counter_name()
    options.theorem_counters[cname] = (options.theorem_counters[cname] or 0) + 1
    local parts = {}
    for i = options.counter_first, options.counter_depth do
      local n = options.header_counters[i]
      if i == options.part_level then
        -- \thepart is a Roman numeral, and empty before the first part.
        parts[#parts + 1] = n > 0 and pandoc.utils.to_roman_numeral(n) or ""
      else
        parts[#parts + 1] = tostring(n)
      end
    end
    parts[#parts + 1] = tostring(options.theorem_counters[cname])
    theorem_number = table.concat(parts, ".")
    if id and id ~= "" then
      options.identifiers[id] = theorem_number
      options.names[id] = self.text
    end
  end

  local runs = { { pandoc.Inlines(self.text), head } }
  if theorem_number and options.swapnumbers then
    -- \swappedhead: the number first, in the heading font, then a tie.
    table.insert(runs, 1,
      { { pandoc.Str(theorem_number), pandoc.Str("\u{a0}") }, head })
  elseif theorem_number then
    local number = upright(head)
    runs[#runs + 1] = { { pandoc.Space(), pandoc.Str(theorem_number) }, number }
  end
  local note = parse_info(info)
  if #note > 0 then
    table.insert(note, 1, pandoc.Space())
    runs[#runs + 1] = { note, {} }
  end
  runs[#runs + 1] = { { pandoc.Str(style.headpunct) }, head }

  local out = join_runs(runs)
  out[#out + 1] = style.headspace == "newline" and pandoc.LineBreak() or pandoc.Space()
  return out
end

M.NewTheorem = NewTheorem

local Proof = setmetatable({}, { __index = NewTheorem })
Proof.__index = Proof

-- `text` is the name shown, \proofname in LaTeX.
function Proof.new(text)
  local self = NewTheorem.new({
    style = "proof", env_name = "proof", text = text or "Proof", numbered = false,
  })
  return setmetatable(self, Proof)
end

-- Proof gets a markdown-parsed info that's emph-normalised.
function Proof:to_header(_options, _id, info)
  if info == nil or info == "" then
    return { pandoc.Emph(pandoc.Inlines(self.text .. ".")), pandoc.Space() }
  end
  local ast = parse_markdown_as_inline(info)
  -- Wrap into a Para so we can walk + apply emph transforms over a block.
  local para = pandoc.Para(ast)
  para = para:walk({
    Str = M.to_emph, Emph = M.cancel_emph,
    Cite = italic_ref, RawInline = italic_ref,
  })
  -- merge_consecutive_type operates on the block itself, and `:walk`
  -- visits descendants only, so call it directly.
  M.merge_emph(para)
  local out = {}
  for _, e in ipairs(para.content) do out[#out + 1] = e end
  out[#out + 1] = pandoc.Emph({ pandoc.Str(".") })
  out[#out + 1] = pandoc.Space()
  return out
end

M.Proof = Proof

---------------------------------------------------------------------
-- DocOptions
--
-- The Python version relies on dict insertion order; Lua string-keyed
-- tables have no order, so we maintain BOTH an ordered array of theorem
-- objects (`order`) and a lookup map keyed by class_name (`map`).
---------------------------------------------------------------------

local utype = pandoc.utils.type

-- In pandoc ≥ 3, Meta values are exposed via pandoc.utils.type as
-- "table"   for MetaMap   (plain Lua table with string keys),
-- "List"    for MetaList,
-- "Inlines" for MetaInlines (string-like leaves).
local function is_meta_map(v)  return utype(v) == "table" end
local function is_meta_list(v) return utype(v) == "List" end

-- A metadata value as a list: a single value (`plain: Main Theorem`)
-- becomes a list of one, rather than being iterated token by token.
local function meta_list(node)
  if node == nil then return {} end
  if is_meta_list(node) then return node end
  return { node }
end

-- The LaTeX unit that level-1 headings map to, as pandoc decides it.
local function top_level_division(meta)
  local tld = PANDOC_WRITER_OPTIONS and PANDOC_WRITER_OPTIONS.top_level_division
  tld = tld and tld:gsub("^top%-level%-", "") or "default"
  if PARENT_COUNTERS[tld] then return tld end
  local class = meta and meta.documentclass and stringify(meta.documentclass)
  return CHAPTER_CLASSES[class] and "chapter" or "section"
end
M.top_level_division = top_level_division

-- How many heading levels step their LaTeX counters. Pandoc's LaTeX
-- writer numbers sections by setting secnumdepth, and a sectioning
-- command deeper than secnumdepth, or any at all without -N, steps no
-- counter.
local function numbered_depth(meta, top)
  local wo = PANDOC_WRITER_OPTIONS
  -- Quarto numbers HTML sections itself, and does not tell a filter
  -- whether it does; take it that it does.
  local quarto_html = quarto ~= nil and not is_latex_like()
  if not (wo and wo.number_sections) and not quarto_html then return 0 end
  -- From the metadata, or a variable (-V), which is a layout Doc.
  local s = meta and meta.secnumdepth and stringify(meta.secnumdepth)
  local var = wo and wo.variables and wo.variables.secnumdepth
  if s == nil and var ~= nil then s = tostring(var) end
  local secnumdepth = s and tonumber(s) or 5
  -- Heading level L is the LaTeX level PARENT_COUNTERS[top] + L - 2.
  return secnumdepth - PARENT_COUNTERS[top] + 2
end

local function from_meta(meta)
  local opt_node = meta and meta[METADATA_KEY] or nil
  local opt = {}
  -- An empty `amsthm:` is a string, not a map, and defines nothing.
  if is_meta_map(opt_node) then
    -- MetaMap behaves as a table with string keys.
    for k, v in pairs(opt_node) do opt[k] = v end
  end

  local name_to_text = {}
  if opt.name_to_text ~= nil then
    for k, v in pairs(opt.name_to_text) do name_to_text[k] = stringify(v) end
  end
  local parent_counter = opt.parent_counter and stringify(opt.parent_counter) or nil

  local theorems_order = {}
  local theorems_map = {}

  local function add(t)
    theorems_order[#theorems_order + 1] = t
    theorems_map[t:class_name()] = t
  end

  for _, style in ipairs(STYLES) do
    local entries = meta_list(opt[style])
    for _, entry in ipairs(entries) do
      -- Each entry is either a MetaInlines (string) or a MetaMap (single-key).
      if is_meta_map(entry) then
        -- pandoc hands over a YAML map with its keys sorted, not in the
        -- order written, and pairs() has no order at all; sort, so the
        -- output is reproducible and the same as with the Python filter.
        local keys = {}
        for key in pairs(entry) do keys[#keys + 1] = key end
        table.sort(keys)
        for _, key in ipairs(keys) do
          local value = entry[key]
          local key_s = stringify(key)
          add(NewTheorem.new({
            style = style, env_name = key_s,
            text = name_to_text[key_s] or "",
            parent_counter = parent_counter,
          }))
          -- value: MetaList of names OR single name
          if is_meta_list(value) then
            for _, v in ipairs(value) do
              local v_s = stringify(v)
              add(NewTheorem.new({
                style = style, env_name = v_s,
                text = name_to_text[v_s] or "",
                shared_counter = key_s,
              }))
            end
          else
            local v_s = stringify(value)
            add(NewTheorem.new({
              style = style, env_name = v_s,
              text = name_to_text[v_s] or "",
              shared_counter = key_s,
            }))
          end
        end
      else
        local key_s = stringify(entry)
        add(NewTheorem.new({
          style = style, env_name = key_s,
          text = name_to_text[key_s] or "",
          parent_counter = parent_counter,
        }))
      end
    end
  end

  -- Proof is predefined.
  local proof = Proof.new(name_to_text.proof)
  theorems_order[#theorems_order + 1] = proof
  theorems_map[proof:class_name()] = proof

  local top = top_level_division(meta)
  -- With parts at level 1: a part steps no other counter, and appears in
  -- a theorem's number only when theorems are numbered within parts.
  local part_level = (top == "part") and 1 or nil
  local counter_first = 1
  local counter_depth = COUNTER_DEPTH_DEFAULT
  if opt.counter_depth then
    local s = stringify(opt.counter_depth)
    counter_depth = tonumber(s) or COUNTER_DEPTH_DEFAULT
  elseif parent_counter and PARENT_COUNTERS[parent_counter] then
    -- Number within the heading level that LaTeX would number within.
    counter_depth = math.max(0,
      PARENT_COUNTERS[parent_counter] - PARENT_COUNTERS[top] + 1)
    if part_level and parent_counter ~= "part" then counter_first = 2 end
  end

  local ignore = {}
  if opt.counter_ignore_headings then
    for _, e in ipairs(meta_list(opt.counter_ignore_headings)) do
      ignore[stringify(e)] = true
    end
  end

  -- Start where pandoc starts numbering sections, so --number-offset
  -- moves the theorem numbers along with the section numbers.
  local offset = PANDOC_WRITER_OPTIONS and PANDOC_WRITER_OPTIONS.number_offset or {}
  local header_counters = {}
  for i = 1, counter_depth do header_counters[i] = offset[i] or 0 end

  local css = true
  if opt.css ~= nil then css = (stringify(opt.css) ~= "false") end
  -- The end-of-proof symbol, as TeX math: `$\blacksquare$` in the metadata
  -- is math, and a bare `\blacksquare` raw TeX.
  local qed_symbol = "\\Box"
  if opt.qed_symbol ~= nil then
    local parts = {}
    pandoc.Inlines(opt.qed_symbol):walk({
      Math = function(m) parts[#parts + 1] = m.text end,
      RawInline = function(r) parts[#parts + 1] = r.text end,
      Str = function(t) parts[#parts + 1] = t.text end,
    })
    if #parts > 0 then qed_symbol = table.concat(parts, " ") end
  end
  local swapnumbers = opt.swapnumbers ~= nil and stringify(opt.swapnumbers) == "true"

  return {
    css = css,
    styles = BUILTIN_STYLES,
    swapnumbers = swapnumbers,
    qed_symbol = qed_symbol,
    counter_first = counter_first,
    numbered_depth = numbered_depth(meta, top),
    part_level = part_level,
    proof_name = name_to_text.proof,
    theorems_order = theorems_order,
    theorems_map = theorems_map,
    counter_depth = counter_depth,
    counter_ignore_headings = ignore,
    header_counters = header_counters,
    theorem_counters = {},
    identifiers = {},
    names = {},
    unnumbered = {},
    warned = {},
  }
end

local function options_to_latex(options)
  local cur_style = ""
  local lines = {}
  if options.qed_symbol ~= "\\Box" then
    lines[#lines + 1] = "\\renewcommand{\\qedsymbol}{\\ensuremath{" ..
      options.qed_symbol .. "}}"
  end
  -- Before \newtheorem, which takes the order from it.
  if options.swapnumbers then lines[#lines + 1] = "\\swapnumbers" end
  if options.proof_name then
    -- At the start of the document, after babel sets the name for the
    -- document's language.
    lines[#lines + 1] = "\\AtBeginDocument{\\renewcommand{\\proofname}{" ..
      options.proof_name .. "}}"
  end
  for _, theorem in ipairs(options.theorems_order) do
    if getmetatable(theorem) ~= Proof then
      if theorem.style ~= cur_style then
        cur_style = theorem.style
        lines[#lines + 1] = "\\theoremstyle{" .. cur_style .. "}"
      end
      lines[#lines + 1] = theorem:latex()
    end
  end
  return table.concat(lines, "\n")
end
M.options_to_latex = options_to_latex
M.from_meta = from_meta

---------------------------------------------------------------------
-- Filter passes
---------------------------------------------------------------------

-- The theorem a div is, from its classes. A div that names two different
-- environments is left alone, with a warning when `warn` is set.
local function find_theorem(options, classes, warn)
  local found, names = nil, {}
  for _, cls in ipairs(classes) do
    local theorem = options.theorems_map[cls]
    if theorem and theorem ~= found then
      if found == nil then
        found = theorem
      elseif not names[cls] then
        names[#names + 1] = cls
        names[cls] = true
      end
    end
  end
  if #names > 0 then
    if warn then
      io.stderr:write("[amsthm] warning: multiple environments found: " ..
        found:class_name() .. ", " .. table.concat(names, ", ") .. "; skipping\n")
    end
    return nil
  end
  return found
end

-- Apply the plain style's italic body to a theorem's content. Theorems
-- nested inside are held out of the walk, as each has a style of its own.
local function emph_body(div, options)
  local held = {}
  local body = pandoc.Div(div.content):walk({
    traverse = "topdown",
    Div = function(d)
      if find_theorem(options, d.classes) then
        held[#held + 1] = d
        return pandoc.Div({}, pandoc.Attr("", {}, { ["amsthm-held"] = tostring(#held) })), false
      end
      return nil
    end,
  })
  body = body:walk({
    Str = M.to_emph, Emph = M.cancel_emph,
    Cite = italic_ref, RawInline = italic_ref,
    Para = M.merge_emph, Plain = M.merge_emph, Header = M.merge_emph,
  })
  if #held > 0 then
    body = body:walk({
      Div = function(d)
        local i = d.attributes["amsthm-held"]
        if i then return held[tonumber(i)] end
        return nil
      end,
    })
  end
  div.content = body.content
  return div
end

-- amsthm's \mathqed, \quad\qedsymbol, as TeX math.
local function qed_math(options)
  local symbol = options.qed_symbol
  -- A space keeps \quad apart from a symbol that starts with a letter.
  return "\\quad" .. (symbol:match("^%a") and " " or "") .. symbol
end

-- The end-of-proof symbol, as a span that the CSS pushes to the right.
local function qed_span(options)
  return pandoc.Span({ pandoc.Math("InlineMath", qed_math(options)) },
    pandoc.Attr("", { "amsthm-qed" }))
end

-- amsthm's \qedhere, which puts the symbol where it is instead of at the
-- end of the proof. In math it is \mathqed, \quad\qedsymbol, in place; in
-- text it is \qed. Theorems and proofs nested in this one are left to
-- their own. Returns whether there was a \qedhere.
local function place_qedhere(div, options)
  local placed = false
  local symbol = qed_math(options):gsub("%%", "%%%%")
  div.content = pandoc.Blocks(div.content):walk({
    traverse = "topdown",
    Div = function(d)
      if find_theorem(options, d.classes) then return nil, false end
      return nil
    end,
    Math = function(m)
      local text, n = m.text:gsub("\\qedhere%f[^%a]", symbol)
      if n == 0 then return nil end
      placed = true
      m.text = text
      return m
    end,
    Inlines = function(inlines)
      local out, changed = pandoc.Inlines({}), false
      for _, e in ipairs(inlines) do
        if e.t == "RawInline" and (e.format == "tex" or e.format == "latex")
            and e.text:match("^%s*\\qedhere%s*$") then
          -- \qed starts with \unskip.
          while #out > 0 and BLANK[out[#out].t] do out:remove() end
          out:insert(qed_span(options))
          placed, changed = true, true
        else
          out:insert(e)
        end
      end
      if changed then return out end
      return nil
    end,
  })
  return placed
end

-- non-LaTeX transform: prepend the theorem header, do plain-style emph,
-- track counters and identifiers.
local function amsthm_block(div, options)
  local theorem = find_theorem(options, div.classes, true)
  if not theorem then return nil end

  local info = div.attributes.info
  local id = div.identifier
  if not theorem.numbered and id ~= "" then options.unnumbered[id] = true end
  local header = theorem:to_header(options, id, info)
  -- to_header ends with a Space; keep it outside the title span.
  local title = {}
  for i = 1, #header - 1 do title[i] = header[i] end
  header = { pandoc.Span(title, pandoc.Attr("", { "amsthm-title" })), header[#header] }

  if theorem.style == "plain" then div = emph_body(div, options) end

  -- Prepend header to the first block's inline list when possible,
  -- otherwise wrap into a fresh Para.
  if #div.content >= 1 and div.content[1].content
      and (div.content[1].t == "Para" or div.content[1].t == "Plain"
           or div.content[1].t == "Header") then
    local first = div.content[1]
    local new_inlines = {}
    for _, e in ipairs(header) do new_inlines[#new_inlines + 1] = e end
    for _, e in ipairs(first.content) do new_inlines[#new_inlines + 1] = e end
    first.content = new_inlines
    div.content[1] = first
  else
    table.insert(div.content, 1, pandoc.Para(header))
  end

  if theorem.style == "proof" and not place_qedhere(div, options) then
    -- amsthm's \qed is \nobreak\hfill\quad\openbox. As math, \quad\Box
    -- renders in every format: \Box is amssymb's \openbox, and TeX does not
    -- break a line inside a formula, which stands in for \nobreak. Only
    -- \hfill is left out, for the CSS to do in HTML.
    local qed = qed_span(options)
    local last = div.content[#div.content]
    if last and last.content
       and (last.t == "Para" or last.t == "Plain" or last.t == "Header") then
      local ic = last.content
      ic[#ic + 1] = qed
      last.content = ic
      div.content[#div.content] = last
    else
      div.content[#div.content + 1] = pandoc.Para({ qed })
    end
  end

  -- Quarto renders divs with these classes as its own proof environments,
  -- which would add a second header on top of this one. Drop them once
  -- handled; the amsthm-<style> class below says what the div is.
  if quarto then
    div.classes = div.classes:filter(function(cls)
      return not QUARTO_PROOF_CLASSES[cls]
    end)
  end
  div.classes:insert("amsthm")
  if not div.classes:includes("amsthm-" .. theorem.style) then
    div.classes:insert("amsthm-" .. theorem.style)
  end

  return div
end

-- Warn, once per id, about a reference to an unnumbered environment. LaTeX
-- prints the number of whatever was numbered last before it, usually the
-- section, which other output cannot follow, so it leaves it unresolved.
local function warn_unnumbered(elem, options)
  local id
  if elem.t == "Cite" then
    id = cite_to_id_mode(elem)
  elseif elem.format == "tex" then
    local kind
    kind, id = elem.text:match("^\\(%a+)%{(.-)%}$")
    if kind ~= "ref" and kind ~= "eqref" then id = nil end
  end
  if id then id = ref_target(id, options.unnumbered) end
  if id and not options.warned[id] then
    options.warned[id] = true
    io.stderr:write("[amsthm] warning: reference to the unnumbered " ..
      "environment " .. id .. "; LaTeX prints the last number before it, " ..
      "other output leaves it unresolved\n")
  end
end
M.warn_unnumbered = warn_unnumbered

-- A reference to the environment `id`, numbered `n`: the number as a link
-- to it, led by the environment's name when `name` is given, and in
-- parentheses when `paren` is set. Only the number is linked, as hyperref
-- links what \ref and \eqref print.
local function ref_link(id, n, paren, name)
  local link = pandoc.Link({ pandoc.Str(n) }, "#" .. id)
  if not name and not paren then return link end
  local out = name and named(name, link) or pandoc.Inlines({ link })
  if paren then
    out:insert(1, pandoc.Str("("))
    out:insert(pandoc.Str(")"))
  end
  return out
end

-- Resolve [@id] / @id citations and \ref{}/\eqref{} raw tex to numbers.
local function resolve_inline(elem, options)
  if elem.t == "Cite" then
    local id, mode = cite_to_id_mode(elem)
    local is_named
    if id then id, is_named = ref_target(id, options.identifiers) end
    if id then
      local n = options.identifiers[id]
      local name = is_named and options.names and options.names[id] or nil
      if mode == "NormalCitation" then return ref_link(id, n, true, name) end
      if mode == "AuthorInText" then return ref_link(id, n, false, name) end
    end
  elseif elem.t == "RawInline" and elem.format == "tex" then
    local kind, id = elem.text:match("^\\(%a+)%{(.-)%}$")
    if kind and id and (kind == "ref" or kind == "eqref")
       and options.identifiers[id] then
      return ref_link(id, options.identifiers[id], kind == "eqref")
    end
  end
  return nil
end
M.resolve_inline = resolve_inline

-- LaTeX: collect ids (pass 1) and emit \begin{env}…\end{env} (pass 2).
local function collect_ref_id(div, options)
  local theorem = find_theorem(options, div.classes, true)
  if not theorem then return nil end
  if div.identifier and div.identifier ~= "" then
    options.identifiers[div.identifier] = ""
    options.names[div.identifier] = theorem.text
    if not theorem.numbered then options.unnumbered[div.identifier] = true end
  end
  return nil
end

-- Wrap the div's own blocks in \begin{env}…\end{env}, rather than render
-- them to a string here: the blocks stay in the document, so theorems
-- nested inside, citations, the user's writer options and anything run
-- after this filter (citeproc, Quarto's crossrefs) still get to them.
local function amsthm_latex_block(div, options)
  local theorem = find_theorem(options, div.classes)
  if not theorem then return nil end
  local open = { pandoc.RawInline("latex", "\\begin{" .. theorem.env_name .. "}") }
  local info = div.attributes.info
  if info and info ~= "" then
    local note = parse_markdown_as_inline(info)
    -- The writer escapes brackets in text, but not in math, citations,
    -- images (\includegraphics[width=...]) or raw TeX, where a ] would end
    -- the optional argument early.
    local brace = false
    local function unsafe() brace = true end
    local scan = { Math = unsafe, Cite = unsafe, Image = unsafe, RawInline = unsafe }
    for _, e in ipairs(note) do
      if scan[e.t] then brace = true else e:walk(scan) end
    end
    open[#open + 1] = pandoc.RawInline("latex", brace and "[{" or "[")
    for _, e in ipairs(note) do open[#open + 1] = e end
    open[#open + 1] = pandoc.RawInline("latex", brace and "}]" or "]")
  end
  if div.identifier ~= "" then
    open[#open + 1] = pandoc.RawInline("latex", "\\label{" .. div.identifier .. "}")
  end
  local close = pandoc.RawInline("latex", "\\end{" .. theorem.env_name .. "}")

  -- Share a line with the first and last paragraphs where there are some,
  -- as the environment would be written by hand.
  local content = div.content
  local first = content[1]
  if first and (first.t == "Para" or first.t == "Plain") then
    open[#open + 1] = pandoc.RawInline("latex", "\n")
    for _, e in ipairs(first.content) do open[#open + 1] = e end
    first.content = open
    content[1] = first
  else
    content:insert(1, pandoc.Plain(open))
  end
  local last = content[#content]
  if last.t == "Para" or last.t == "Plain" then
    local inlines = {}
    for _, e in ipairs(last.content) do inlines[#inlines + 1] = e end
    inlines[#inlines + 1] = pandoc.RawInline("latex", "\n")
    inlines[#inlines + 1] = close
    last.content = inlines
    content[#content] = last
  else
    content:insert(pandoc.Plain({ close }))
  end
  -- A bare Div, so the LaTeX writer adds no \label of its own and Quarto
  -- does not take it for one of its own proof environments.
  return pandoc.Div(content)
end

---------------------------------------------------------------------
-- Filter entry point
---------------------------------------------------------------------

-- The filter is structured as two passes, mirroring the Python
-- `run_filters((action1, action2))` flow. State lives on the upvalue
-- `options`, populated in pass-1's `Pandoc` walker before any blocks.
local function build_filters()
  local options
  local latex_like = is_latex_like()

  local pass1 = {
    traverse = "topdown",
    Pandoc = function(doc)
      options = from_meta(doc.meta)
      if options.counter_depth >= options.counter_first
          and options.numbered_depth < options.counter_first then
        io.stderr:write("[amsthm] warning: theorems are numbered within " ..
          "sections that are not numbered, so their numbers start with 0 " ..
          "as in LaTeX; pass -N (--number-sections)\n")
      end
      if latex_like then
        -- Load amsthm first, so \newtheoremstyle in the user's own
        -- header-includes works; define the environments last, so they can
        -- use those styles.
        add_header_include(doc.meta,
          pandoc.RawBlock("latex", "\\usepackage{amsthm}"), true)
        add_header_include(doc.meta,
          pandoc.RawBlock("latex", options_to_latex(options)))
      elseif HTML_LIKE[FORMAT] and options.css then
        add_header_include(doc.meta, pandoc.RawBlock("html", CSS))
      end
      return doc
    end,
    Header = function(h)
      if latex_like then return nil end
      -- \section* and the like do not step LaTeX's counters, and neither
      -- do headings that LaTeX does not number.
      local level = h.level
      if level <= options.counter_depth and level <= options.numbered_depth
          and not h.classes:includes("unnumbered") then
        local s = stringify(h)
        if not options.counter_ignore_headings[s] then
          options.header_counters[level] =
            (options.header_counters[level] or 0) + 1
          if level ~= options.part_level then
            for i = level + 1, options.counter_depth do
              options.header_counters[i] = 0
            end
          end
          if level >= options.counter_first then
            options.theorem_counters = {}
          end
        end
      end
      return nil
    end,
    Div = function(d)
      if latex_like then
        return collect_ref_id(d, options)
      else
        return amsthm_block(d, options)
      end
    end,
  }

  local pass2 = {
    traverse = "topdown",
    Div = function(d)
      if latex_like then return amsthm_latex_block(d, options) end
      return nil
    end,
    Cite = function(c)
      warn_unnumbered(c, options)
      if latex_like then return cite_to_ref(c, options.identifiers, options.names) end
      return resolve_inline(c, options)
    end,
    RawInline = function(r)
      warn_unnumbered(r, options)
      if latex_like then return nil end
      return resolve_inline(r, options)
    end,
  }

  return { pass1, pass2 }
end

M._build_filters = build_filters

-- When loaded as a pandoc Lua filter, return the filter list directly.
-- When `require`d (e.g. from spec/run.lua) return the module table.
if pandoc and FORMAT then
  return build_filters()
else
  return M
end
