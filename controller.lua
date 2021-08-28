function _getEmptyKeyboardState()
  return {
    up = false,
    down = false,
    right = false,
    left = false,
    a = false,
    x = false,
    z = false,
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

  if love.keyboard.isDown("x") then
    nextPreviousState.x = true
    if _previousKeyboardState.x == false then
      keyboard.x = true
    else
      keyboard.x = false
    end
  else
    keyboard.x = false
    nextPreviousState.x = false
  end

  _previousKeyboardState = nextPreviousState
end
