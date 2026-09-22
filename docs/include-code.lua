-- Fill a code block that has an `include` attribute with that file's content.
function CodeBlock(el)
  local path = el.attributes.include
  if not path then return nil end
  local f = assert(io.open(path, "r"))
  el.text = f:read("a"):gsub("%s+$", "")
  f:close()
  el.attributes.include = nil
  return el
end
