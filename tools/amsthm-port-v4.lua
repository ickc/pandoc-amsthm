--[[
amsthm-port-v4.lua — a Pandoc Lua filter that rewrites a document from
pandoc-amsthm v3's syntax for a note to v4's.

v3 took the note of a theorem or proof from the div's `info` attribute,
and read it as markdown itself. v4 takes it from a span with class
`info` that starts the div's first paragraph, which pandoc has read with
the rest of the document:

    ::: {.Theorem info="*Lagrange*"}      ::: Theorem
    The order of a subgroup ...      ->   [*Lagrange*]{.info} The order of a subgroup ...
    :::                                   :::

Usage, with -s to keep the metadata block, and the reader extensions
and writer options you format the document with:

    pandoc old.md -s -f markdown -t markdown -L amsthm-port-v4.lua -o new.md

Environments declared in a metadata file rather than the document: name
the file (or several) with -M amsthm-port-metadata=FILE; the filter
reads it for the names only, and does not copy it into the document.

Each note ported is listed on stderr, with the span to write, so that
documents pandoc's markdown writer would damage, such as Quarto's with
shortcodes or executable cells, can be ported by hand from the list
(-o /dev/null).

Porting guide: https://ickc.github.io/pandoc-amsthm/porting.html
License: BSD-3-Clause
]]

local stringify = pandoc.utils.stringify
local utype = pandoc.utils.type

-- Keys of the amsthm metadata that are options, not styles, as in
-- amsthm.lua.
local OPTION_KEYS = {
  styles = true, name_to_text = true, parent_counter = true,
  counter_depth = true, counter_ignore_headings = true, css = true,
  swapnumbers = true, qed_symbol = true,
}
local METADATA_FILE_KEY = "amsthm-port-metadata"

local function warn(message)
  io.stderr:write("[amsthm-port] warning: " .. message .. "\n")
end

local function as_list(node)
  if node == nil then return {} end
  if utype(node) == "List" then return node end
  return { node }
end

-- The class of an environment, from its name as amsthm.lua makes it: a
-- key's backslash before punctuation dropped (a list's is markdown's to
-- drop), the trailing * of an unnumbered one dropped, spaces as _.
local function class_of(name, is_key)
  if is_key then name = name:gsub("\\(%p)", "%1") end
  name = name:gsub("%*$", "")
  return (name:gsub(" ", "_"))
end

-- Add the classes of the environments that an `amsthm` metadata map
-- declares, as amsthm.lua reads it: under amsthm's styles, and under
-- the user's own, named by the keys of `styles`.
local function add_classes(classes, amsthm)
  if utype(amsthm) ~= "table" then return end
  local styles = { plain = true, definition = true, remark = true }
  if utype(amsthm.styles) == "table" then
    for name, spec in pairs(amsthm.styles) do
      if not OPTION_KEYS[name] and name ~= "proof" and utype(spec) == "table" then
        styles[name] = true
      end
    end
  end
  for style in pairs(styles) do
    for _, entry in ipairs(as_list(amsthm[style])) do
      if utype(entry) == "table" then
        for key, value in pairs(entry) do
          classes[class_of(key, true)] = true
          for _, v in ipairs(as_list(value)) do
            classes[class_of(stringify(v))] = true
          end
        end
      else
        classes[class_of(stringify(entry))] = true
      end
    end
  end
end

-- The metadata of a YAML file, such as a --metadata-file or Quarto's
-- _quarto.yml, read as pandoc reads a metadata block.
local function read_metadata_file(path)
  local f, err = io.open(path, "r")
  if not f then
    warn("cannot read " .. path .. " (" .. tostring(err) .. "); ignoring it")
    return nil
  end
  local text = f:read("a")
  f:close()
  -- A file may itself start with ---, as a metadata block does.
  text = text:gsub("^%-%-%-[ \t]*\n", "")
  return pandoc.read("---\n" .. text .. "\n---\n", "markdown").meta
end

-- The note of an `info` attribute, read as amsthm v3 read it: the
-- inlines of its paragraphs, joined. nil if it holds any other block, a
-- list or a heading, on which v3 stopped with an error.
local function read_note(info)
  local out = pandoc.Inlines({})
  for _, block in ipairs(pandoc.read(info, "markdown").blocks) do
    if block.t ~= "Para" and block.t ~= "Plain" then return nil end
    out:extend(block.content)
  end
  return out
end

-- A div's opening, as it would be written, to name it in a message.
local function describe(div, info)
  local parts = {}
  if div.identifier ~= "" then parts[#parts + 1] = "#" .. div.identifier end
  for _, cls in ipairs(div.classes) do parts[#parts + 1] = "." .. cls end
  parts[#parts + 1] = 'info="' .. info .. '"'
  return "{" .. table.concat(parts, " ") .. "}"
end

-- The span as markdown, for the list on stderr.
local function span_markdown(span)
  local md = pandoc.write(pandoc.Pandoc({ pandoc.Plain({ span }) }), "markdown")
  return (md:gsub("%s+$", ""):gsub("\n", " "))
end

local function is_note_span(inline)
  return inline ~= nil and inline.t == "Span" and inline.classes:includes("info")
end

local function port_div(div, classes)
  local info = div.attributes.info
  if info == nil then return nil end
  -- The environment, as amsthm.lua finds it: a div naming two different
  -- environments is left alone by amsthm, so it is here too.
  local found = {}
  for _, cls in ipairs(div.classes) do
    if classes[cls] and not found[cls] then
      found[cls] = true
      found[#found + 1] = cls
    end
  end
  if #found == 0 then
    warn(describe(div, info) .. " is not a declared environment; left alone. " ..
      "If its environment is declared in a metadata file, pass -M " ..
      METADATA_FILE_KEY .. "=FILE")
    return nil
  elseif #found > 1 then
    warn(describe(div, info) .. " names two environments, so amsthm leaves " ..
      "it alone; left alone")
    return nil
  end
  local first = div.content[1]
  local paragraph = first and (first.t == "Para" or first.t == "Plain")
  if paragraph and is_note_span(first.content[1]) then
    warn(describe(div, info) .. " already starts with a note span; left alone")
    return nil
  end
  -- An empty note is no note, in v3 and v4 alike.
  if info:match("^%s*$") then
    div.attributes.info = nil
    return div
  end
  local note = read_note(info)
  if note == nil then
    warn(describe(div, info) .. ": the note is not text (amsthm v3 stopped " ..
      "with an error on it); left alone")
    return nil
  end
  local span = pandoc.Span(note, pandoc.Attr("", { "info" }))
  div.attributes.info = nil
  if paragraph then
    local inlines = first.content
    inlines:insert(1, pandoc.Space())
    inlines:insert(1, span)
    first.content = inlines
    div.content[1] = first
  else
    -- A note in a paragraph of its own, before the list, display or
    -- code that starts the body.
    div.content:insert(1, pandoc.Para({ span }))
  end
  io.stderr:write("[amsthm-port] ported " .. describe(div, info) ..
    ": " .. span_markdown(span) .. "\n")
  return div
end

function Pandoc(doc)
  local classes = { proof = true }
  add_classes(classes, doc.meta.amsthm)
  for _, path in ipairs(as_list(doc.meta[METADATA_FILE_KEY])) do
    local meta = read_metadata_file(stringify(path))
    if meta then add_classes(classes, meta.amsthm) end
  end
  -- An option of this filter, not part of the document.
  doc.meta[METADATA_FILE_KEY] = nil
  doc.blocks = doc.blocks:walk({
    Div = function(div) return port_div(div, classes) end,
  })
  return doc
end
