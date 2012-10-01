require"logic"
gameConfig = require"gameConfig"

-- wrapper for beetle including display
displayBeetle = {
}

function displayBeetle:new(o, tiles)
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
			getSize = function () return gameConfig.size end
		}
	}
	o.bg = display.newRect((o.logic.position.x-0.5)*gameConfig.tileSize.width, (o.logic.position.y-0.5)*gameConfig.tileSize.height, gameConfig.tileSize.width*0.330, gameConfig.tileSize.height*0.330)
	o.bg.strokeWidth = 0
	--o.bg:setReferencePoint(display.CenterReferencePoint)
	o.bg:setReferencePoint(display.TopCenterReferencePoint)
	o.bg:setFillColor(0,0,255)

	o.scoreText = display.newText( "", 0, 0, native.systemFont, 40 )
	o.scoreText.x = display.contentWidth / 2
	o.scoreText.y = display.contentHeight - 30
	o.scoreText:setTextColor( 255,110,110 )
	return o
end

function displayBeetle:run() 
	return self.logic:run() 
end

function displayBeetle:drawScore()
	self.scoreText.text = self.logic.points
end

function displayBeetle:draw ()
	local x = (self.logic.position.x + DIRECTION_MODS[self.logic.direction].x * self.logic.moveInterp - 0.5) * gameConfig.tileSize.width
	local y = (self.logic.position.y + DIRECTION_MODS[self.logic.direction].y * self.logic.moveInterp - 0.5) * gameConfig.tileSize.height
	
	self.bg.x = x
	self.bg.y = y
	self.bg:toFront()
	-- size is temporary!

	self:drawScore()
	self.scoreText:toFront()
end

return displayBeetle