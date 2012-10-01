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
	for x=1, gameConfig.size.x do
		self.tiles[x] = { }
		for y=1, gameConfig.size.y do
			
			self.tiles[x][y] = tile:new(
				routes:new(common.randTrueFalse(),
							common.randTrueFalse(),
							common.randTrueFalse(),
							common.randTrueFalse()
							),
				(x-1)*gameConfig.tileSize.width,
				(y-1)*gameConfig.tileSize.height+25,
				gameConfig.tileSize.width,
				gameConfig.tileSize.height
			)
			self.tiles[x][y]:draw()
			self.tiles[x][y].rect:addEventListener("touch", self.tiles[x][y])
		end
	end

	self.ladyBug = displayBeetle:new({}, self.tiles)
	
	Runtime:addEventListener( "enterFrame", enterFrame )
end


return gameDisplay
