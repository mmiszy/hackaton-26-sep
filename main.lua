local common = require"common"
require"logic"

--test
local tiles = {}
local size = { x = 5, y = 6 }
local tileSize = {};
tileSize.width = math.min(display.contentWidth/size.x, display.contentHeight/size.y)
tileSize.height = tileSize.width

-- wrapper for beetle including display
displayBeetle = {
}

function displayBeetle:new(o)
	o = o or { }
	setmetatable(o, self)
	self.__index = self
	o.logic = beetle:new{
		board = {
			getData = function (position)
				for k,v in pairs(position) do print(k,v) end
				print ("xy "..position.x.." "..position.y)
				return tiles[position.x][position.y].routes
			end,
			getSize = function () return size end
		}
	}
	o.bg = display.newRect((o.logic.position.x-0.5)*tileSize.width, (o.logic.position.y-0.5)*tileSize.height, tileSize.width*0.330, tileSize.height*0.330)
	o.bg.strokeWidth = 0
	--o.bg:setReferencePoint(display.CenterReferencePoint)
	o.bg:setReferencePoint(display.TopCenterReferencePoint)
	o.bg:setFillColor(0,0,255)
	return o 
end

function displayBeetle:run() 
	return self.logic:run() 
end

function displayBeetle:draw ()
	local x = (self.logic.position.x + DIRECTION_MODS[self.logic.direction].x * self.logic.moveInterp - 0.5) * tileSize.width
	local y = (self.logic.position.y + DIRECTION_MODS[self.logic.direction].y * self.logic.moveInterp - 0.5) * tileSize.height
	
	self.bg.x = x
	self.bg.y = y
	self.bg:toFront()
	-- size is temporary!
end

ladyBug = displayBeetle:new()
-----------------

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

		local group = display.newGroup()
		
		local normalColor = {150, 0, 0}
		local bonusColor = {250, 10, 10}		
		
		local color = { 0, 255, 0}
		local bgColor = self.routes.special == "bonus" and bonusColor or normalColor
		
		local bg = display.newRect(self.left, self.top, self.width, self.height)
		bg.strokeWidth = 1
		bg:setFillColor(bgColor[1], bgColor[2], bgColor[3])
		container:insert(bg)

		if (self.routes.t) then
			local tile = display.newRect(self.left+miniTileWidth, self.top, miniTileWidth, miniTileHeight)
			tile:setFillColor(color[1], color[2], color[3])
			group:insert(tile)
		end
		if (self.routes.b) then
			local tile = display.newRect(self.left+miniTileWidth, self.top+self.height-miniTileHeight, miniTileWidth, miniTileHeight)
			tile:setFillColor(color[1], color[2], color[3])
			group:insert(tile)
		end
		if (self.routes.l) then
			local tile = display.newRect(self.left, self.top+miniTileHeight, miniTileWidth, miniTileHeight)
			tile:setFillColor(color[1], color[2], color[3])
			group:insert(tile)
		end
		if (self.routes.r) then
			local tile = display.newRect(self.left+self.width-miniTileWidth, self.top+miniTileHeight, miniTileWidth, miniTileHeight)
			tile:setFillColor(color[1], color[2], color[3])
			group:insert(tile)
		end

		local centerTile = display.newRect(self.left+miniTileWidth, self.top+miniTileHeight, miniTileWidth, miniTileHeight)
		centerTile:setFillColor(color[1], color[2], color[3])
		group:insert(centerTile)

		container:insert(group)
	end

	drawRoutes()

	self.rect = container

	return container
end

local prevTime = system.getTimer()
local function enterFrame (event)
	local curTime = event.time	
	
	if ( (curTime - prevTime ) > (16) ) then	
		result, reason = ladyBug:run()
		if not result then
			os.execute("pause")
		end
		prevTime = curTime
	end
	
	ladyBug:draw()
end

function tile:touch (e)
	if (e.phase == "began") then
		self.routes:tap()
		self:draw()
	end
end

local function initGame (settings)

	for x=1, size.x do
		tiles[x] = { }
		for y=1, size.y do
			
			tiles[x][y] = tile:new(
				routes:newRandom(),
				(x-1)*tileSize.width,
				(y-1)*tileSize.height+25,
				tileSize.width,
				tileSize.height
			)
			tiles[x][y]:draw()
			tiles[x][y].rect:addEventListener("touch", tiles[x][y])
		end
	end
	
	Runtime:addEventListener( "enterFrame", enterFrame )
end

-- windows emulator workaround
os.execute("cls")

initGame()
