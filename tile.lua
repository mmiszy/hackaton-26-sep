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
		name = "alive",  --name of animation sequence
		start = 1,  	  --starting frame index
		count = 7,  	  --total number of frames to animate consecutively before stopping or looping
		loopParam = -2,	  --will bounce back and forth forever
		time = 800,
	},  --if defining more sequences, place a comma here and proceed to the next sequence sub-table
	{ 
		name = "current",
		start = 9,
		count = 7,
		loopParam = -2,
		time = 800,
	},	
	{
		name = "dead",
		start = 16,
		count = 1,
	}
}
-- image description
local sheetData = { 
	width = 128,  			  --the width of each frame
	height = 128,  			  --the height of each frame
	numFrames = 16,  		  --the total number of frames on the sheet
	sheetContentWidth = 512,  --the total width of the image sheet (see note below)?
	sheetContentHeight = 512  --the total height of the image sheet (see note below)?
}
imageSheet = {
	graphics.newImageSheet( "s11.png", sheetData ),	--end
	graphics.newImageSheet( "s21.png", sheetData ), --turn
	graphics.newImageSheet( "s22.png", sheetData ), --straight road
	graphics.newImageSheet( "s31.png", sheetData ), --T-section
	graphics.newImageSheet( "s41.png", sheetData )  --X-section
}

local tileData = {
	{	ident = 1, rotation =   0}, -- 1,  b
	{	ident = 1, rotation =  90}, -- 2,  l
	{	ident = 2, rotation =   0}, -- 3,  bl
	{	ident = 1, rotation = 180}, -- 4,  t
	{	ident = 3, rotation =   0}, -- 5,  bt
	{	ident = 2, rotation =  90}, -- 6,  lt
	{	ident = 4, rotation =   0}, -- 7,  blt
	{	ident = 1, rotation = -90}, -- 8,  r
	{	ident = 2, rotation = -90}, -- 9,  br
	{	ident = 3, rotation =  90}, -- 10, lr
	{	ident = 4, rotation = -90}, -- 11, blr
	{	ident = 2, rotation = 180}, -- 12, tr
	{	ident = 4, rotation = 180}, -- 13, btr
	{	ident = 4, rotation =  90}, -- 14, ltr
	{	ident = 5, rotation =   0}, -- 15, bltr
}

function tile:draw ()
	if self.routes.special == "bonus" then
		bgColor = bonusColor
	elseif self.routes.special == "start" then
		bgColor = startColor
	end
	
-- calculate, which imageSheet to use and later how to rotate the tile		
	local tileident = 0 + 8*(self.routes.r and 1 or 0)
						+ 4*(self.routes.t and 1 or 0)
						+ 2*(self.routes.l and 1 or 0)
						+ 1*(self.routes.b and 1 or 0)
						
-- create new sprite for every display tile	
	local bg = display.newSprite(imageSheet[tileData[tileident].ident], sequenceData)
	bg:setSequence("alive")
	bg:setReferencePoint(display.TopLeftReferencePoint)
	bg.x = self.left
	bg.y = self.top
	bg.x = bg.x + (gameConfig.tileSize.width - 128) / 2
	bg.y = bg.y + (gameConfig.tileSize.height - 128) / 2
	
	self.bg = bg	
	self:update()
end

function tile:update ()
	if self.routes.canRotate == false then
		if self.routes.special == "closed" then
			self.bg:setSequence("dead")
		else
			self.bg:setSequence("current")
		end
	end
local tileident = 0 + 8*(self.routes.r and 1 or 0)
						+ 4*(self.routes.t and 1 or 0)
						+ 2*(self.routes.l and 1 or 0)
						+ 1*(self.routes.b and 1 or 0)	
	self.bg:setReferencePoint(CenterReferencePoint)
	self.bg.rotation = tileData[tileident].rotation	
	self.bg:play()
end

function tile:touch (e)
	if (e.phase == "began") then
		self.routes:tap()
		self:update()
	end
end

return tile