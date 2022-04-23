local UpStairs = class("UpStairs")

UpStairs.deleted = false
UpStairs.size = screen.tileSize
UpStairs.ignorePhysics = true
UpStairs.physicsable = false
UpStairs.ld = 500
UpStairs.isUp = true  -- This looks weird, reason I did it this was
-- because I originally intended to have a stairs class with isUp as
-- a parameter, except the inconsistent number of args for restoring
-- entities was a headache, so it was easier to just subtype 
-- downstairs from upstairs. Bad design, but free-hobby code.
-- what are you gonna do

function UpStairs:init(x, y)
	if self.isUp then
		self.char = '<'
		self.sprite = imageTiles.up
	else
		self.char = '>'
		self.sprite = imageTiles.down
	end

	self.body = love.physics.newBody(world, x, y, "dynamic")
	self.shape = love.physics.newRectangleShape(-5, -5, 22, 22)
	self.fixture = love.physics.newFixture(self.body, self.shape, 1)
	self.fixture:setSensor(true)
	self.fixture:setUserData(self)

	self.permX = x
	self.permY = y
	self.body:setLinearDamping(self.ld)
	self.colour = colours.lightGray
end

function UpStairs:getSaveData()
	return {
		name = self.class.name,
		x = self.body:getX(),
		y = self.body:getY(),
	}
end

function UpStairs:onContactStart(otherEntity)
	if otherEntity == player then
		if self.isUp then
			gameState.canGoUp = true
		else
			gameState.canGoDown = true
		end
	end
end

function UpStairs:onContactEnd(otherEntity)
	if otherEntity == player then
		if self.isUp then
			gameState.canGoUp = false
		else
			gameState.canGoDown = false
		end

	end
end

function UpStairs:update(dt)
	self.body:setPosition(self.permX, self.permY)
	self.body:setLinearVelocity(0,0)
end

return UpStairs
