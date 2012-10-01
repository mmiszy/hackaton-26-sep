local gameConfig = { }


local size = { x = 5, y = 6 }
gameConfig.size = size

local tileSize = {
	width = math.min(display.contentWidth/size.x, display.contentHeight/size.y),
	height = nil
}
tileSize.height = tileSize.width

gameConfig.tileSize = tileSize

return gameConfig