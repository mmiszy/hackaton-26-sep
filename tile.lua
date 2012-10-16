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
		local startColor = {180, 0, 180}
		
		local color = { 0, 255, 255}
		
		local bgColor = normalColor
		if not self.routes.canRotate then
			bgColor = {255, 255, 255}
		end
		
		if self.routes.special == "bonus" then
			bgColor = bonusColor
		elseif self.routes.special == "start" then
			bgColor = startColor
		end
		
		-- sequence data about background tiles
		local sequenceData = {
			{ 
				name = "normal",  --name of animation sequence
				start = 1,  --starting frame index
				count = 1,  --total number of frames to animate consecutively before stopping or looping
				--time = 800,
			},  --if defining more sequences, place a comma here and proceed to the next sequence sub-table
			{
				name = "closed",
				start = 2,
				count = 1,
			}
		}
		-- image description
		local sheetData = { 
		  width = 128,  --the width of each frame
		  height = 128,  --the height of each frame
		  numFrames = 2,  --the total number of frames on the sheet
		  sheetContentWidth = 128,  --the total width of the image sheet (see note below)?
		  sheetContentHeight = 256  --the total height of the image sheet (see note below)?
		}
		local imageSheet = graphics.newImageSheet( "grass3.jpg", sheetData )
	
		local bg = display.newSprite( imageSheet, sequenceData )
		bg:setSequence("normal")
		bg:setReferencePoint(display.TopLeftReferencePoint)
		bg.x = self.left
		bg.y = self.top
		bg.width = self.width
		bg.height = self.height
		--[[local bg = display.newRect(self.left, self.top, self.width, self.height)
		bg.strokeWidth = 1
		bg:setFillColor(bgColor[1], bgColor[2], bgColor[3])]]
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

function tile:update ()
	-- change here for background update
	if not self.routes.canRotate then self.rect[1]:setFillColor(255, 255, 255) end
	--if self.routes.special == "closed" then self.rect[1]:setFillColor(0,0,0) end
	if self.routes.special == "closed" then
		self.rect[1]:setSequence("closed")
		self.rect[1].width = self.width
		self.rect[1].height = self.height
	end
end

function tile:touch (e)
	if (e.phase == "began") then
		self.routes:tap()
		self:draw()
	end
end

return tile