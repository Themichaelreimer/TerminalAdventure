function _getEmptyKeyboardState()
  r = {
    up = false,
    down = false,
    right = false,
    left = false,
    a = false,
    x = false,
    z = false,
    q = false,
    w = false,
    m1 = false,
    m2 = false,
  }
  r["/"] = false
  r["return"] = false
  return r
end

-- Use this to know whether to respond to a keypress
keyboard = _getEmptyKeyboardState()

-- Used for keeping track of buttons that act only on down
_previousKeyboardState = _getEmptyKeyboardState()

function keyboardUpdate(dt)

  -- This will be the previous state of the next frame
  -- We currently need the current previous state, so this has to be
  -- a seperate variable
  local nextPreviousState = _getEmptyKeyboardState()

  updateKeyDown("x", nextPreviousState)
  updateKeyDown("z", nextPreviousState)
  updateKeyDown("a", nextPreviousState)
  updateKeyDown("q", nextPreviousState)
  updateKeyDown("w", nextPreviousState)
  updateKeyDown("up", nextPreviousState)
  updateKeyDown("down", nextPreviousState)
  updateKeyDown("left", nextPreviousState)
  updateKeyDown("right", nextPreviousState)
  updateKeyDown("return", nextPreviousState)
  updateKeyDown("/", nextPreviousState)
  updateMouseDown("m1", nextPreviousState)
  updateMouseDown("m2", nextPreviousState)

  -- TODO: When in menu, we want direction keys to behave like keyDown.
  -- TODO: When in game, we want direction keys to fire every frame

  _previousKeyboardState = nextPreviousState
end

function updateKeyDown(key, nextPreviousState)
  if love.keyboard.isDown(key) then
    nextPreviousState[key] = true
    if _previousKeyboardState[key] == false then
      keyboard[key] = true
    else
      keyboard[key] = false
    end
  else
    keyboard[key] = false
    nextPreviousState[key] = false
  end
end

function updateMouseDown(key, nextPreviousState)
  local code = 0
  if key == "m1" then code = 1 else code = 2 end

  if love.mouse.isDown(code) then
    nextPreviousState[key] = true
    if _previousKeyboardState[key] == false then
      keyboard[key] = true
    else
      keyboard[key] = false
    end
  else
    keyboard[key] = false
    nextPreviousState[key] = false
  end
end

function keyIsHeld(key)
  if key == "m1" or key == 'm2' then
    local code = ternary(key == "m1", 1, 2)
    return love.mouse.isDown(code) and not keyboard[x]
  end
  return love.keyboard.isDown(key) and not keyboard[x]
end
