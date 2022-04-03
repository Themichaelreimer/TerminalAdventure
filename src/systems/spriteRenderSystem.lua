local spriteRenderSystem = tiny.processingSystem(class "spriteRenderSystem")

spriteRenderSystem.filter = tiny.filter("sprite&body&!draw")

function spriteRenderSystem:process(e, dt)
	if not e.deleted then
		local x = e.body:getX()
		local y = e.body:getY()
		local size = e.size or screen.tileSize
		local sx = size / e.sprite:getWidth()
		local sy = size / e.sprite:getHeight()
		local tileSize = screen.tileSize

		local lightness = level:getLightnessAtTile(math.floor(x/size), math.floor(y/size))
		local col = colours.white
		if e.colour then col = e.colour end

		-- Actual render block
		local c1, c2, c3, c4 = alphaBlendColour(col, lightness)
		if e.alpha then c4 = c4 * e.alpha end
		love.graphics.setColor(c1, c2, c3, c4)

		love.graphics.draw(e.sprite, x - size, y, 0, sx, sy)
	end
end

return spriteRenderSystem
