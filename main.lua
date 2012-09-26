local common = require"common"
require"logic"

--test
math.randomseed(7)
local tiles = {}
local size = { x = 5, y = 4 }

bug = beetle:new({
	getData = function (x,y) return tiles[x][y].routes end,
	getSize = function () return size end
})

--[[for i = 0, 20 * 10 do
	result, reason = bug:run()
	if not result then
		print(reason)
		break
	end
end]]

tile = {
	left = 0,
	top = 0,
	width = 0,
	height = 0
}

function tile:new (routes, left, top, width, height)
	o = {
		routes = routes,
		left = left,
		top = top,
		width = width,
		height = height
	}

	setmetatable(o, self)
	self.__index = self
	return o
end

function tile:draw ()
	local container = display.newGroup()

	local miniTileWidth = self.width/3
	local miniTileHeight = self.height/3

	local function drawRoutes ()
		for i=container.numChildren,1,-1 do
			container[i].parent:remove(container[i])
		end

		local bg = display.newRect(self.left, self.top, self.width, self.height)
		bg.strokeWidth = 1
		bg:setFillColor(255,0,0)
		container:insert(bg)

		local routes = display.newGroup()

		if (self.routes.t) then
			local tile = display.newRect(self.left+miniTileWidth, self.top, miniTileWidth, miniTileHeight)
			tile:setFillColor(0,255,0)
			routes:insert(tile)
		end
		if (self.routes.b) then
			local tile = display.newRect(self.left+miniTileWidth, self.top+self.height-miniTileHeight, miniTileWidth, miniTileHeight)
			tile:setFillColor(0,255,0)
			routes:insert(tile)
		end
		if (self.routes.l) then
			local tile = display.newRect(self.left, self.top+miniTileHeight, miniTileWidth, miniTileHeight)
			tile:setFillColor(0,255,0)
			routes:insert(tile)
		end
		if (self.routes.r) then
			local tile = display.newRect(self.left+self.width-miniTileWidth, self.top+miniTileHeight, miniTileWidth, miniTileHeight)
			tile:setFillColor(0,255,0)
			routes:insert(tile)
		end

		local centerTile = display.newRect(self.left+miniTileWidth, self.top+miniTileHeight, miniTileWidth, miniTileHeight)
		centerTile:setFillColor(0,255,0)
		routes:insert(centerTile)

		container:insert(routes)
	end

	drawRoutes()

	self.rect = container

	return container
end

local prevTime = system.getTimer()
local function enterFrame (event)
	local curTime = event.time
	local dt = curTime - prevTime
	prevTime = curTime
	
	if ( (curTime - prevTime ) > (1./60.) ) then
		-- limit how often fps updates
		-- fps.text = string.format( '%.2f', 1000 / dt )
	end
end

function tile:touch (e)
	if (e.phase == "began") then
		self.routes:tap()
		self:draw()
	end
end

local function initGame (settings)

	local tileWidth = display.contentWidth/size.x
	local tileHeight = tileWidth

	for x=1, size.x do
		tiles[x] = { }
		for y=1, size.y do
			
			tiles[x][y] = tile:new(
				routes:new(common.randTrueFalse(),
							common.randTrueFalse(),
							common.randTrueFalse(),
							common.randTrueFalse()
							),
				(x-1)*tileWidth,
				(y-1)*tileHeight+25,
				tileWidth,
				tileHeight
			)
			tiles[x][y]:draw()
			tiles[x][y].rect:addEventListener("touch", tiles[x][y])
		end
	end
	
	--Runtime:addEventListener( "enterFrame", enterFrame )
end

initGame()
