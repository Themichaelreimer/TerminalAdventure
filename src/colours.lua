nord = {
    black = {0.180, 0.204, 0.251 },
    white = {0.925, 0.937, 0.957 },
    green = {0.639, 0.745, 0.549 }
}

japanesque = {
    black = { 0.117, 0.117, 0.117},
    darkGray = { 0.203, 0.223, 0.207 },
    gray = { 0.349, 0.356, 0.349 },
    lightGray = { 0.698, 0.709, 0.682 },
    white = { 0.980, 0.980, 0.964 },
    green = { 0.482, 0.717, 0.356 },
    red = { 0.811, 0.247, 0.380 },
    yellow = { 0.913, 0.701, 0.164 },
    blue = { 0.298, 0.603, 0.831 },
    purple = { 0.647, 0.498, 0.768 },
    brown = { 0.470, 0.349, 0.184 },
    pink = { 0.819, 0.560, 0.650 }

}

function alphaBlendColour(colour, alpha)
  return colour[1], colour[2], colour[3], alpha
end
