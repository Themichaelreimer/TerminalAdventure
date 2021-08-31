function _getEmptyKeyboardState()
  return {
    up = false,
    down = false,
    right = false,
    left = false,
    a = false,
    x = false,
    z = false,
    -- Used for debug commands
    q = false,
    w = false
  }
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
