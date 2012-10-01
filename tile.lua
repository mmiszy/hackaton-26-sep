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

function tile:touch (e)
	if (e.phase == "began") then
		self.routes:tap()
		self:draw()
	end
end

return tile