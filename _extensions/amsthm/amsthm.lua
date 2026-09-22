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
local METADATA_KEY = "amsthm"
local LATEX_LIKE = { latex = true, beamer = true }
local PLAIN_OR_DEF = { plain = true, definition = true }
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

-- Convert pf.Cite to a raw LaTeX \ref{} / \eqref{}.
-- @param check_id  optional table; transform only if the cite id is a key.
local function cite_to_ref(elem, check_id)
  if elem.t ~= "Cite" then return nil end
  local id, mode = cite_to_id_mode(elem)
  if id == nil then return nil end
  if check_id ~= nil and check_id[id] == nil then return nil end
  if mode == "NormalCitation" then
    return pandoc.RawInline("latex", "\\eqref{" .. id .. "}")
  elseif mode == "AuthorInText" then
    return pandoc.RawInline("latex", "\\ref{" .. id .. "}")
  end
  return nil
end
M.cite_to_ref = cite_to_ref

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

-- Build the theorem header inline list, keeping Strong/Emph boundaries clean.
function NewTheorem:to_header(options, id, info)
  local TextType, NumberType
  if PLAIN_OR_DEF[self.style] then
    TextType, NumberType = "Strong", "Strong"
  else
    TextType, NumberType = "Emph", "Str"
  end
  local TextCtor = INLINE_TYPES[TextType] or pandoc.Str
  local NumberCtor = (NumberType == "Str") and pandoc.Str or INLINE_TYPES[NumberType]

  local theorem_number
  if self.numbered then
    local cname = self:counter_name()
    options.theorem_counters[cname] = (options.theorem_counters[cname] or 0) + 1
    local parts = {}
    for _, n in ipairs(options.header_counters) do parts[#parts + 1] = tostring(n) end
    parts[#parts + 1] = tostring(options.theorem_counters[cname])
    theorem_number = table.concat(parts, ".")
    if id and id ~= "" then options.identifiers[id] = theorem_number end
  end

  local info_list = parse_info(info)
  local has_info = (#info_list > 0)

  local function S(s) return pandoc.Str(s) end
  local function wrapText(s) return TextCtor({ S(s) }) end

  if theorem_number == nil then
    if has_info then
      local res = { wrapText(self.text), pandoc.Space() }
      for _, e in ipairs(info_list) do res[#res + 1] = e end
      res[#res + 1] = wrapText(".")
      res[#res + 1] = pandoc.Space()
      return res
    else
      return { wrapText(self.text .. "."), pandoc.Space() }
    end
  else
    if TextType == NumberType then
      if has_info then
        local res = { wrapText(self.text .. " " .. theorem_number), pandoc.Space() }
        for _, e in ipairs(info_list) do res[#res + 1] = e end
        res[#res + 1] = wrapText(".")
        res[#res + 1] = pandoc.Space()
        return res
      else
        return { wrapText(self.text .. " " .. theorem_number .. "."), pandoc.Space() }
      end
    else
      if has_info then
        local res = { wrapText(self.text), pandoc.Space(),
          NumberCtor(theorem_number), pandoc.Space() }
        for _, e in ipairs(info_list) do res[#res + 1] = e end
        res[#res + 1] = wrapText(".")
        res[#res + 1] = pandoc.Space()
        return res
      else
        return { wrapText(self.text), pandoc.Space(),
          NumberCtor(theorem_number), wrapText("."), pandoc.Space() }
      end
    end
  end
end

M.NewTheorem = NewTheorem

local Proof = setmetatable({}, { __index = NewTheorem })
Proof.__index = Proof

function Proof.new()
  local self = NewTheorem.new({
    style = "proof", env_name = "proof", text = "proof", numbered = false,
  })
  return setmetatable(self, Proof)
end

-- Proof gets a markdown-parsed info that's emph-normalised.
function Proof:to_header(_options, _id, info)
  if info == nil or info == "" then
    return { pandoc.Emph({ pandoc.Str("Proof.") }), pandoc.Space() }
  end
  local ast = parse_markdown_as_inline(info)
  -- Wrap into a Para so we can walk + apply emph transforms over a block.
  local para = pandoc.Para(ast)
  para = para:walk({ Str = M.to_emph, Emph = M.cancel_emph })
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

local function from_meta(meta)
  local opt_node = meta and meta[METADATA_KEY] or nil
  local opt = {}
  if opt_node ~= nil then
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
        for key, value in pairs(entry) do
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
  local proof = Proof.new()
  theorems_order[#theorems_order + 1] = proof
  theorems_map[proof:class_name()] = proof

  local counter_depth = COUNTER_DEPTH_DEFAULT
  if opt.counter_depth then
    local s = stringify(opt.counter_depth)
    counter_depth = tonumber(s) or COUNTER_DEPTH_DEFAULT
  elseif parent_counter and PARENT_COUNTERS[parent_counter] then
    -- Number within the heading level that LaTeX would number within.
    local top = top_level_division(meta)
    counter_depth = math.max(0,
      PARENT_COUNTERS[parent_counter] - PARENT_COUNTERS[top] + 1)
  end

  local ignore = {}
  if opt.counter_ignore_headings then
    for _, e in ipairs(meta_list(opt.counter_ignore_headings)) do
      ignore[stringify(e)] = true
    end
  end

  local header_counters = {}
  for i = 1, counter_depth do header_counters[i] = 0 end

  local css = true
  if opt.css ~= nil then css = (stringify(opt.css) ~= "false") end

  return {
    css = css,
    theorems_order = theorems_order,
    theorems_map = theorems_map,
    counter_depth = counter_depth,
    counter_ignore_headings = ignore,
    header_counters = header_counters,
    theorem_counters = {},
    identifiers = {},
  }
end

local function options_to_latex(options)
  local cur_style = ""
  local lines = {}
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

local function find_theorem(options, classes)
  local found
  for _, cls in ipairs(classes) do
    if options.theorems_map[cls] then
      if found then return nil end  -- multiple matches => skip
      found = options.theorems_map[cls]
    end
  end
  return found
end

-- non-LaTeX transform: prepend the theorem header, do plain-style emph,
-- track counters and identifiers.
local function amsthm_block(div, options)
  local theorem = find_theorem(options, div.classes)
  if not theorem then return nil end

  local info = div.attributes.info
  local id = div.identifier
  local header = theorem:to_header(options, id, info)
  -- to_header ends with a Space; keep it outside the title span.
  local title = {}
  for i = 1, #header - 1 do title[i] = header[i] end
  header = { pandoc.Span(title, pandoc.Attr("", { "amsthm-title" })), header[#header] }

  if theorem.style == "plain" then
    div = div:walk({ Str = M.to_emph })
    div = div:walk({ Emph = M.cancel_emph })
    div = div:walk({
      Para = M.merge_emph, Plain = M.merge_emph, Header = M.merge_emph,
    })
  end

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

  if theorem.style == "proof" then
    local qed = pandoc.Span({ pandoc.Str("\xe2\x97\xbb") },
      pandoc.Attr("", { "amsthm-qed" }))
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

-- Resolve [@id] / @id citations and \ref{}/\eqref{} raw tex to numbers.
local function resolve_inline(elem, options)
  if elem.t == "Cite" then
    local id, mode = cite_to_id_mode(elem)
    if id and options.identifiers[id] then
      local n = options.identifiers[id]
      if mode == "NormalCitation" then return pandoc.Str("(" .. n .. ")") end
      if mode == "AuthorInText" then return pandoc.Str(n) end
    end
  elseif elem.t == "RawInline" and elem.format == "tex" then
    local kind, id = elem.text:match("^\\(%a+)%{(.-)%}$")
    if kind and id and (kind == "ref" or kind == "eqref")
       and options.identifiers[id] then
      local n = options.identifiers[id]
      if kind == "eqref" then return pandoc.Str("(" .. n .. ")") end
      return pandoc.Str(n)
    end
  end
  return nil
end
M.resolve_inline = resolve_inline

-- LaTeX: collect ids (pass 1) and emit \begin{env}…\end{env} (pass 2).
local function collect_ref_id(div, options)
  local theorem = find_theorem(options, div.classes)
  if not theorem then return nil end
  if div.identifier and div.identifier ~= "" then
    options.identifiers[div.identifier] = ""
  end
  return nil
end

local function amsthm_latex_block(div, options)
  local theorem = find_theorem(options, div.classes)
  if not theorem then return nil end
  -- Replace Cites inside the body with \ref{}/\eqref{} BEFORE rendering
  -- to LaTeX; our topdown pass 2 has already consumed this Div, so the
  -- Cite filter won't otherwise visit them.
  local body = pandoc.Pandoc(div.content):walk({
    Cite = function(c) return cite_to_ref(c, options.identifiers) end,
  })
  local div_content = pandoc.write(body, "latex")
  local info = div.attributes.info
  local id = div.identifier
  local parts = { "\\begin{" .. theorem.env_name .. "}" }
  if info and info ~= "" then
    local ast = pandoc.Para(parse_markdown_as_inline(info))
    ast = ast:walk({
      Cite = function(c) return cite_to_ref(c, options.identifiers) end,
    })
    local rendered = pandoc.write(pandoc.Pandoc({ ast }), "latex")
    rendered = rendered:gsub("%s+$", "")
    parts[#parts + 1] = "[" .. rendered .. "]"
  end
  if id and id ~= "" then
    parts[#parts + 1] = "\\label{" .. id .. "}"
  end
  parts[#parts + 1] = "\n" .. div_content .. "\n\\end{" .. theorem.env_name .. "}"
  return pandoc.RawBlock("latex", table.concat(parts))
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
      if h.level <= options.counter_depth then
        local s = stringify(h)
        if not options.counter_ignore_headings[s] then
          options.header_counters[h.level] =
            (options.header_counters[h.level] or 0) + 1
          for i = h.level + 1, options.counter_depth do
            options.header_counters[i] = 0
          end
          options.theorem_counters = {}
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
      if latex_like then return cite_to_ref(c, options.identifiers) end
      return resolve_inline(c, options)
    end,
    RawInline = function(r)
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
