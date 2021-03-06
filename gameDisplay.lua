local common = require"common"
require"logic"

local displayBeetle = require"displayBeetle"
local tile = require"tile"

local gameConfig = require"gameConfig"

local weirdDisplayOffsetY = 25

local gameDisplay = {
	tiles = {},
	ladyBug = nil,
}

function gameDisplay:clear ()
	for x=1, gameConfig.size.x do
		for y=1, gameConfig.size.y do
			self.tiles[x][y].bg:removeEventListener("touch", self.tiles[x][y])
			local stage = display.getCurrentStage()
			while stage.numChildren > 0 do
				local obj = stage[1]
				obj:removeSelf()
				obj = nil
			end
			self.tiles[x][y] = nil
		end
	end
end

function gameDisplay:update ()
	result, reason = gameDisplay.ladyBug:run()
	
	-- check for game over
	if not result then
		return "menu" -- next state that game is being put into
	end
	
	for x=1, gameConfig.size.x do
		for y=1, gameConfig.size.y do
			self.tiles[x][y]:update()
		end
	end
	gameDisplay.ladyBug:draw()
end

function gameDisplay:initGame (settings)
	local bg = display.newImageRect( "bg.png", 1536, 2048 )
	bg:toBack();
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
				(y-1)*gameConfig.tileSize.height + weirdDisplayOffsetY
			)
			io.write (""..(self.tiles[x][y].routes.t and "1" or "0")
					..(self.tiles[x][y].routes.r and "1" or "0")
					..(self.tiles[x][y].routes.b and "1" or "0")
					..(self.tiles[x][y].routes.l and "1" or "0").. " ")
		end
		print (" ")
	end
	
	-- update the start tile
	self.tiles[startPosition.x][startPosition.y].routes.special = "start"
	self.tiles[startPosition.x][startPosition.y].routes.canRotate = false
	
	-- all the data members are set correctly now
	for x=1, gameConfig.size.x do
		for y=1, gameConfig.size.y do
			self.tiles[x][y]:draw()
			self.tiles[x][y].bg:addEventListener("touch", self.tiles[x][y])
		end
	end

	-- put the beetle at start
	self.ladyBug = displayBeetle:new({}, self.tiles)
	self.ladyBug.logic.position = startPosition
end


return gameDisplay
