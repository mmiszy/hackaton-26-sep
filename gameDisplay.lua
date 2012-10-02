local common = require"common"
require"logic"

local displayBeetle = require"displayBeetle"
local tile = require"tile"

local gameConfig = require"gameConfig"

local gameDisplay = {
	tiles = {},
	ladyBug = nil,
}

local prevTime = system.getTimer()
local function enterFrame (event)
	local curTime = event.time	
	
	if ( (curTime - prevTime ) > (16) ) then	
		result, reason = gameDisplay.ladyBug:run()
		if not result then
			os.execute("pause")
		end
		prevTime = curTime
	end
	
	gameDisplay.ladyBug:draw()
end

function gameDisplay:initGame (settings)
	-- randomize the start location
	local startPosition = { x = math.random(2, gameConfig.size.x-1),
							y = math.random(2, gameConfig.size.y-1) }

	-- randomize the board
	for x=1, gameConfig.size.x do
		self.tiles[x] = { }
		for y=1, gameConfig.size.y do
			self.tiles[x][y] = tile:new(
				routes:newRandom(),
				(x-1)*gameConfig.tileSize.width,
				(y-1)*gameConfig.tileSize.height+25,
				gameConfig.tileSize.width,
				gameConfig.tileSize.height
			)
		end
	end
	
	-- update the start tile
	self.tiles[startPosition.x][startPosition.y].routes.special = "start"
	self.tiles[startPosition.x][startPosition.y].routes.canRotate = false
	
	-- all the data members are set correctly now
	for x=1, gameConfig.size.x do
		for y=1, gameConfig.size.y do
			self.tiles[x][y]:draw()
			self.tiles[x][y].rect:addEventListener("touch", self.tiles[x][y])
		end
	end

	-- put the beetle at start
	self.ladyBug = displayBeetle:new({}, self.tiles)
	self.ladyBug.logic.position = startPosition
	
	Runtime:addEventListener( "enterFrame", enterFrame )
end


return gameDisplay
