-- spec/run.lua — run all spec files under spec/.
--
-- Tries real `busted` first; falls back to spec/busted_shim.lua so the
-- suite runs under `pandoc lua spec/run.lua` with zero extra deps.
-- Usage:
--   pandoc lua spec/run.lua [spec/foo_spec.lua ...]

local script_path = arg[0] or "spec/run.lua"
local script_dir = script_path:match("(.*/)") or "./"
package.path = script_dir .. "?.lua;" ..
               script_dir .. "../_extensions/amsthm/?.lua;" .. package.path

-- Try real busted first.
local have_busted, busted = pcall(require, "busted.runner")
if have_busted then
  io.write("[run.lua] using busted\n")
  busted({ standalone = false })
  return
end

io.write("[run.lua] using built-in busted shim (real busted not on Lua path)\n")
local shim = require("busted_shim")
shim.install_globals()

local specs = {}
if #arg > 0 then
  for _, a in ipairs(arg) do specs[#specs + 1] = a end
else
  -- Discover spec/*_spec.lua via `ls`. We avoid lfs to stay stdlib-only.
  local p = io.popen("ls " .. script_dir .. "*_spec.lua 2>/dev/null")
  if p then
    for line in p:lines() do specs[#specs + 1] = line end
    p:close()
  end
end

for _, s in ipairs(specs) do
  io.write("\n--- ", s, " ---\n")
  local ok, err = pcall(dofile, s)
  if not ok then
    io.write("FAILED to load ", s, ": ", tostring(err), "\n")
    os.exit(1)
  end
end

if not shim.run({ verbose = os.getenv("VERBOSE") == "1" }) then os.exit(1) end
