-- For the pages under examples/: append, in tabs, the Markdown the page
-- is made from, and the LaTeX that amsthm.lua writes for it, so that each
-- example shows its input, its LaTeX and its result together. HTML only;
-- the PDF of the page is amsthm's own rendering.

-- The directory of a path, with a trailing slash.
local function dirname(path)
  return path:match("^(.*[/\\])") or "./"
end

local function read(path)
  local f = io.open(path, "r")
  if not f then return nil end
  local text = f:read("a")
  f:close()
  return (text:gsub("%s+$", ""))
end

-- The filter's LaTeX for the input: its preamble and the body, through the
-- same minimal template as the golden tests.
local function latex_of(input)
  local root = dirname(input) .. "../../"
  local ok, out = pcall(pandoc.pipe, "pandoc", {
    "-L", root .. "_extensions/amsthm/amsthm.lua",
    "--template", root .. "tests/template.latex",
    "-s", "-N", "-t", "latex", input,
  }, "")
  if not ok then
    io.stderr:write("example-source.lua: could not run pandoc for " ..
      input .. "; leaving out the LaTeX\n")
    return nil
  end
  return (out:gsub("%s+$", ""))
end

function Pandoc(doc)
  if not quarto.doc.is_format("html") then return nil end
  local input = quarto.doc.input_file
  -- The examples are .md; the overview page is not one.
  if not input:match("%.md$") then return nil end
  local source = read(input)
  if not source then return nil end

  local tabs = pandoc.Blocks({
    pandoc.Header(3, "Markdown", pandoc.Attr("", { "unnumbered" })),
    pandoc.CodeBlock(source, pandoc.Attr("", { "markdown" })),
  })
  local latex = latex_of(input)
  if latex then
    tabs:insert(pandoc.Header(3, "LaTeX", pandoc.Attr("", { "unnumbered" })))
    tabs:insert(pandoc.CodeBlock(latex, pandoc.Attr("", { "latex" })))
  end

  doc.blocks:insert(pandoc.Header(2, "Source", pandoc.Attr("source", { "unnumbered" })))
  doc.blocks:insert(pandoc.Para({ pandoc.Str(
    "This page is made from the Markdown below, and LaTeX output gets the " ..
    "LaTeX beside it. The PDF under Other Formats is that LaTeX, typeset " ..
    "by amsthm.") }))
  doc.blocks:insert(pandoc.Div(tabs, pandoc.Attr("", { "panel-tabset" })))
  return doc
end
