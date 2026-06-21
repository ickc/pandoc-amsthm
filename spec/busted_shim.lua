--[[
Minimal busted-compatible test shim — provides describe / it / before_each /
after_each and an `assert` table with `are.same`, `are.equal`, `is_true`,
`is_false`, `is_nil`, `is_not_nil`, `has_error`, `has_no_error`.

The spec files are standard busted syntax; when a real busted is on the
Lua path (`require("busted")` succeeds), spec/run.lua uses it instead.
Otherwise this shim runs the same files with zero external deps.
]]

local M = {}

local tests = {}
local context_stack = {}
local before_each_stack = {{}}
local after_each_stack = {{}}

local function describe(name, fn)
  table.insert(context_stack, name)
  table.insert(before_each_stack, {})
  table.insert(after_each_stack, {})
  fn()
  table.remove(context_stack)
  table.remove(before_each_stack)
  table.remove(after_each_stack)
end

local function it(name, fn)
  local full = table.concat(context_stack, " ") .. " " .. name
  local befores, afters = {}, {}
  for _, list in ipairs(before_each_stack) do
    for _, b in ipairs(list) do befores[#befores + 1] = b end
  end
  for _, list in ipairs(after_each_stack) do
    for _, a in ipairs(list) do afters[#afters + 1] = a end
  end
  tests[#tests + 1] = { name = full, fn = fn, befores = befores, afters = afters }
end

local function before_each(fn)
  table.insert(before_each_stack[#before_each_stack], fn)
end

local function after_each(fn)
  table.insert(after_each_stack[#after_each_stack], fn)
end

-- Deep equality on AST-ish tables, falling back to == for primitives.
local function deep_equal(a, b, seen)
  if a == b then return true end
  if type(a) ~= "table" or type(b) ~= "table" then return false end
  seen = seen or {}
  if seen[a] then return seen[a] == b end
  seen[a] = b
  local count_a, count_b = 0, 0
  for k, v in pairs(a) do
    count_a = count_a + 1
    if not deep_equal(v, b[k], seen) then return false end
  end
  for _ in pairs(b) do count_b = count_b + 1 end
  return count_a == count_b
end
M.deep_equal = deep_equal

local function fmt(v, depth)
  depth = depth or 0
  if depth > 4 then return "{…}" end
  local t = type(v)
  if t == "string" then return string.format("%q", v) end
  if t ~= "table" then return tostring(v) end
  local parts = {}
  for k, vv in pairs(v) do
    parts[#parts + 1] = tostring(k) .. "=" .. fmt(vv, depth + 1)
  end
  return "{" .. table.concat(parts, ", ") .. "}"
end

local assert_ns = {}
assert_ns.are = {
  same = function(expected, actual)
    if not deep_equal(expected, actual) then
      error("expected " .. fmt(expected) .. "\n     got " .. fmt(actual), 2)
    end
  end,
  equal = function(expected, actual)
    if expected ~= actual then
      error("expected " .. tostring(expected) .. ", got " .. tostring(actual), 2)
    end
  end,
}
assert_ns.is_true     = function(v) if v ~= true then error("expected true, got " .. tostring(v), 2) end end
assert_ns.is_false    = function(v) if v ~= false then error("expected false, got " .. tostring(v), 2) end end
assert_ns.is_nil      = function(v) if v ~= nil then error("expected nil, got " .. tostring(v), 2) end end
assert_ns.is_not_nil  = function(v) if v == nil then error("expected non-nil", 2) end end
assert_ns.has_error    = function(fn) local ok = pcall(fn); if ok then error("expected error", 2) end end
assert_ns.has_no_error = function(fn) local ok, e = pcall(fn); if not ok then error("unexpected error: " .. tostring(e), 2) end end

-- Make `assert(x)` (the call form) still work as the Lua builtin would,
-- via __call on the wrapper table.
local builtin_assert = assert
local wrapper = setmetatable({}, {
  __index = assert_ns,
  __call = function(_, ...) return builtin_assert(...) end,
})

function M.install_globals(env)
  env = env or _G
  env.describe = describe
  env.it = it
  env.before_each = before_each
  env.after_each = after_each
  env.assert = wrapper
end

function M.run(opts)
  opts = opts or {}
  local passed, failed = 0, 0
  local failures = {}
  for _, t in ipairs(tests) do
    for _, b in ipairs(t.befores) do b() end
    local ok, err = pcall(t.fn)
    for _, a in ipairs(t.afters) do pcall(a) end
    if ok then
      passed = passed + 1
      if opts.verbose then io.write("  ok  ", t.name, "\n") end
    else
      failed = failed + 1
      failures[#failures + 1] = { name = t.name, err = err }
      io.write("FAIL  ", t.name, "\n      ", tostring(err), "\n")
    end
  end
  io.write(string.format("\n%d passed, %d failed (total %d)\n",
    passed, failed, passed + failed))
  return failed == 0
end

function M.reset()
  tests = {}
  context_stack = {}
  before_each_stack = {{}}
  after_each_stack = {{}}
end

return M
