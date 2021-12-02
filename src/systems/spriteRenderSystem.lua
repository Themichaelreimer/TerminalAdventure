local spriteRenderSystem = tiny.processingSystem(class "spriteRenderSystem")

spriteRenderSystem.filter = tiny.filter("sprite&body&!draw")

function spriteRenderSystem:process(e, dt)
	if not e.deleted then
		local x = e.body:getX()
		local y = e.body:getY()
		local size = e.size or screen.tileSize
		local sx = size / e.sprite:getWidth()
		local sy = size / e.sprite:getHeight()

		love.graphics.draw(e.sprite, x - size, y, 0, sx, sy)
	end
end

return spriteRenderSystem
