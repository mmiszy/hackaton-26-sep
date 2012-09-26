local common = require"common"
local logic = require"logic"

--test
math.randomseed(7)

B = board:new()
B:randomize()
B:dump()

bug = beetle:new(B)

--[[for i = 0, 20 * 10 do
	result, reason = bug:run()
	if not result then
		print(reason)
		break
	end
end]]

tile = {
	t = {
		t = true, --top
		b = true, --bottom
		l = true, --left
		r = true, --right
	},
	left = 0,
	top = 0,
	width = 0,
	height = 0
}

function tile:new (t, left, top, width, height)
	o = {
		t = {
			t = t.t, --top
			b = t.b, --bottom
			l = t.l, --left
			r = t.r, --right
		},
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

		if (self.t.t) then
			local tile = display.newRect(self.left+miniTileWidth, self.top, miniTileWidth, miniTileHeight)
			tile:setFillColor(0,255,0)
			routes:insert(tile)
		end
		if (self.t.b) then
			local tile = display.newRect(self.left+miniTileWidth, self.top+self.height-miniTileHeight, miniTileWidth, miniTileHeight)
			tile:setFillColor(0,255,0)
			routes:insert(tile)
		end
		if (self.t.l) then
			local tile = display.newRect(self.left, self.top+miniTileHeight, miniTileWidth, miniTileHeight)
			tile:setFillColor(0,255,0)
			routes:insert(tile)
		end
		if (self.t.r) then
			local tile = display.newRect(self.left+self.width-miniTileWidth, self.top+miniTileHeight, miniTileWidth, miniTileHeight)
			tile:setFillColor(0,255,0)
			routes:insert(tile)
		end

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
		self.t = {
			t = common.randTrueFalse(), b = common.randTrueFalse(), l = common.randTrueFalse(), r = common.randTrueFalse()
		}
		self:draw()
	end
end

local function initGame (settings)

	local tileWidth = display.contentWidth/settings.tilesX
	local tileHeight = tileWidth


	for x=1, settings.tilesX do
		B.data[x] = { }
		for y=1, settings.tilesY do
			
			B.data[x][y] = tile:new(
				{
					t = common.randTrueFalse(),
					b = common.randTrueFalse(),
					l = common.randTrueFalse(),
					r = common.randTrueFalse()
				},
				(x-1)*tileWidth,
				(y-1)*tileHeight+25,
				tileWidth,
				tileHeight
			)
			B.data[x][y]:draw()
			B.data[x][y].rect:addEventListener("touch", B.data[x][y])
		end
	end
	
	--Runtime:addEventListener( "enterFrame", enterFrame )
end

initGame({tilesX = 4, tilesY = 5})
