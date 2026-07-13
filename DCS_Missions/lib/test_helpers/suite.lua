-- suite.lua
-- Minimal test framework for DCS module unit tests.
-- Compatible with Lua 5.1 / LuaJIT.
--
-- dofile this file after dcs_shim.lua (and after loading MOOSE / code under test).
--
-- Globals set: suite(name, fn), it(name, fn), runTests()
--   assertEq, assertNil, assertNotNil, assertNear, assertMatch, assertTrue
-- Internal state in globals prefixed _test* to avoid collisions.

_testTotalPass   = 0
_testTotalFail   = 0
_testFailures    = {}
_testCurrentSuite = ""

function suite(name, fn)
  _testCurrentSuite = name
  print("== " .. name)
  fn()
end

function it(name, fn)
  local ok, err = pcall(fn)
  if ok then
    _testTotalPass = _testTotalPass + 1
    print("  PASS " .. name)
  else
    _testTotalFail = _testTotalFail + 1
    local label = _testCurrentSuite ~= "" and (_testCurrentSuite .. " / " .. name) or name
    table.insert(_testFailures, label .. " : " .. tostring(err))
    print("  FAIL " .. name .. " : " .. tostring(err))
  end
end

function assertEq(actual, expected, msg)
  if actual ~= expected then
    error((msg or "eq") .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual), 2)
  end
end

function assertNil(v, msg)
  if v ~= nil then
    error((msg or "nil") .. ": expected nil, got " .. tostring(v), 2)
  end
end

function assertNotNil(v, msg)
  if v == nil then
    error((msg or "notNil") .. ": expected non-nil", 2)
  end
end

function assertNear(actual, expected, epsilon, msg)
  epsilon = epsilon or 1e-6
  if math.abs(actual - expected) > epsilon then
    error((msg or "near") .. ": expected " .. tostring(expected) ..
          " +/- " .. tostring(epsilon) .. ", got " .. tostring(actual), 2)
  end
end

function assertMatch(s, pattern, msg)
  if not string.find(s, pattern) then
    error((msg or "match") .. ": '" .. tostring(s) .. "' does not match '" .. pattern .. "'", 2)
  end
end

function assertTrue(v, msg)
  if not v then error((msg or "true") .. ": expected truthy", 2) end
end

function runTests()
  print("")
  print("========================================")
  print(string.format("Total: %d PASS, %d FAIL", _testTotalPass, _testTotalFail))
  if _testTotalFail > 0 then
    print("")
    print("Failures:")
    for _, f in ipairs(_testFailures) do print("  " .. f) end
    os.exit(1)
  end
  os.exit(0)
end
