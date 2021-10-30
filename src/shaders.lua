function loadShaders()
  shaders = {
    lighting = love.graphics.newShader([[
    extern number tl;
    extern number tr;
    extern number bl;
    extern number br;
    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
    {
      vec4 pixel = Texel(texture, texture_coords);
      pixel[3] = ( tr*texture_coords[0] + tl*(1-texture_coords[0]) + bl*texture_coords[1] + br*(1-texture_coords[1]))/2;
      return pixel;
    }]]),
    perPixelRayTrace = love.graphics.newShader([[
    extern number px;
    extern number py;
    extern number maxDistance;

    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
    {
      vec4 pixel = Texel(texture, texture_coords);
      number dx = pixel_coords[0] - px;
      number dy = pixel_coords[1] - py;
      number dist = (dx*dx + dy*dy);
      number light = dist / maxDistance;
      //pixel[3] = max(min(1.0, light), 1.0);
      pixel[3] = 1;
      return pixel;
    }]])
  }
end
