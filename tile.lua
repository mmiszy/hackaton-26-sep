tile = {
	left = 0,
	top = 0,
}

function tile:new (routes, left, top)
	o = {
		routes = routes,
		left = left,
		top = top,
	}

	setmetatable(o, self)
	self.__index = self
	return o
end

-- sequence data about background tiles
local sequenceData = {
	{ 
		name = "normal",  --name of animation sequence
		start = 1,  --starting frame index
		count = 15,  --total number of frames to animate consecutively before stopping or looping
		--time = 800,
	},  --if defining more sequences, place a comma here and proceed to the next sequence sub-table
	{
		name = "closed",
		start = 16,
		count = 1,
	}
}
-- image description
local sheetData = { 
  width = 128,  --the width of each frame
  height = 128,  --the height of each frame
  numFrames = 16,  --the total number of frames on the sheet
  sheetContentWidth = 512,  --the total width of the image sheet (see note below)?
  sheetContentHeight = 512  --the total height of the image sheet (see note below)?
}
imageSheet = graphics.newImageSheet( "tiles.png", sheetData )

function tile:draw ()
	if self.routes.special == "bonus" then
		bgColor = bonusColor
	elseif self.routes.special == "start" then
		bgColor = startColor
	end

	-- create new sprite for every display tile
	local bg = display.newSprite( imageSheet, sequenceData )
	bg:setSequence("normal")
	bg:setReferencePoint(display.TopLeftReferencePoint)
	bg.x = self.left
	bg.y = self.top
	bg.width = gameConfig.tileSize.width
	bg.height = gameConfig.tileSize.height
	self.bg = bg
	
	self:update()
end

function tile:update ()
	-- change here for background update
	--if not self.routes.canRotate then self.rect[1]:setFillColor(255, 255, 255) end
	--if self.routes.special == "closed" then self.rect[1]:setFillColor(0,0,0) end
	if self.routes.special == "closed" then
		self.bg:setSequence("closed")
		self.bg:setFrame(1)
	else	
		local tileident = 0 + 8*(self.routes.t and 1 or 0) 
							+ 4*(self.routes.r and 1 or 0)
							+ 2*(self.routes.b and 1 or 0)
							+ 1*(self.routes.l and 1 or 0)
		
		self.bg:setFrame(tileident)
	end
end

function tile:touch (e)
	if (e.phase == "began") then
		self.routes:tap()
		self:update()
	end
end

return tile