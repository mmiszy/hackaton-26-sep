local common = require("common")

local function drawTile (t, left, top, width, height)
	local container = display.newGroup()
	local bg = display.newRect(left, top, width, height)
	bg.strokeWidth = 1
	bg:setFillColor(255,0,0)

	container:insert(bg)


	local miniTileWidth = width/3
	local miniTileHeight = height/3

	if (t.t) then
		local tile = display.newRect(left+miniTileWidth, top, miniTileWidth, miniTileHeight)
		tile:setFillColor(0,255,0)
		container:insert(tile)
	end
	if (t.b) then
		local tile = display.newRect(left+miniTileWidth, top+height-miniTileHeight, miniTileWidth, miniTileHeight)
		tile:setFillColor(0,255,0)
		container:insert(tile)
	end
	if (t.l) then
		local tile = display.newRect(left, top+miniTileHeight, miniTileWidth, miniTileHeight)
		tile:setFillColor(0,255,0)
		container:insert(tile)
	end
	if (t.r) then
		local tile = display.newRect(left+width-miniTileWidth, top+miniTileHeight, miniTileWidth, miniTileHeight)
		tile:setFillColor(0,255,0)
		container:insert(tile)
	end

	return container
end

local function initGame (settings)
	local tiles = {}


	local tileWidth = display.contentWidth/settings.tilesX
	local tileHeight = tileWidth


	for y=1, settings.tilesY, 1 do
		for x=1, settings.tilesX, 1 do
			if (tiles[x] == nil) then tiles[x] = {} end
			tiles[x][y] = drawTile({t = common.randTrueFalse(), b = common.randTrueFalse(), l = common.randTrueFalse(), r = common.randTrueFalse()}, (x-1)*tileWidth, (y-1)*tileHeight+25, tileWidth, tileHeight);
			tiles[x][y]:addEventListener("touch", function (event)
				if (event.phase == "began") then
					print(event.target)
				end
			end)
		end
	end
end

initGame({tilesX = 4, tilesY = 5})