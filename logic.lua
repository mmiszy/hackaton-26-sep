

-- beetle run logic component

-- block is given in 4-bit number; each bit means connection
-- with sides, in order: top, right, bottom, left

-- beetle can go from block A to B if their corresponding bits are set,
-- i.e. 1-3, 3-1, 2-4, 4-2

-- beetle automatically turns at 'L' shaped intersections
-- it chooses random way at 'T' shaped intersection, but
-- only in ambigious case.

require"common"

beetle = {
	position = { x = 1, y = 1 },
	direction = "down", -- "left", "right", "up"
	moveInterp = .0, -- how far from center of the block are we?
	passedBorder = false,
	speed = 0.05,
	board = nil,
}
function beetle:new(board) 
	o = o or { }
	o.board = board
	setmetatable(o, self)
	self.__index = self
	return o
end

board = {
	data = { },
	size = { x = 5, y = 5 },
}

DIRECTION_MODS = {
	up = { x = 0, y = -1 },
	down = { x = 0, y = 1 },
	left = { x = -1, y = 0 },
	right = { x = 1, y = 0}
}		

-- tile definition
tile = {
	t = true, --top
	b = true, --bottom
	l = true, --left
	r = true, --right
}

function tile:new (t, b, l, r)
	o = { 
		t = t,
		b = b,
		l = l,
		r = r
	}
	setmetatable(o, self)
	self.__index = self
	return o
end

-- implementation
-----------------------

function beetle:run ()
	function goingOutOfBounds(position, direction, size)
		if direction=="left" and position.x < 1 then return true
		elseif direction=="right" and position.x > size.x then return true
		elseif direction=="up" and position.y < 1 then return true
		elseif direction=="down" and position.y > size.y then return true
		end

		return false
	end	
	
	function canRunIntoTile(direction, tile) 
		if direction == "up" then return tile.b
		elseif direction == "down" then return tile.t
		elseif direction == "left" then return tile.r
		elseif direction == "right" then return tile.l
		end
	end
	
	function updateDirectionAtWall(direction, tile)
		if (direction == "up" and not tile.t) or
				(direction == "down" and not tile.b) then
			if tile.l and tile.r then -- randomize
				return common.randTrueFalse() and "left" or "right"
			elseif tile.l then
				return "left"
			else
				return "right"
			end
		end
		if (direction == "left" and not tile.l) or
				(direction == "right" and not tile.r) then
			if tile.t and tile.b then -- randomize
				return common.randTrueFalse() and "up" or "down"
			elseif tile.t then
				return "up"
			else
				return "down"
			end
		end
	end

	-- advance the beetle
	self.moveInterp = self.moveInterp + self.speed
	-- two cases, when we are unclear
	-- 1. beetle leaves current square - maybe there isn't a connection?
	if self.moveInterp >= 0.5 and not self.passedBorder then
		local directionMod = DIRECTION_MODS[self.direction]
		self.position.x = self.position.x + directionMod.x
		self.position.y = self.position.y + directionMod.y
		local nextTile = self.board.data[self.position.x][self.position.y]
		
		if goingOutOfBounds(self.position, self.direction, self.board.size) then
			return nil, "game_over - out of bounds"
		end
		
		print ("Checking next tile, direction = "..self.direction)
		
		if not canRunIntoTile(self.direction, nextTile) then
			return nil, "game_over - tile error"
		end
		
		self.passedBorder = true
		-- move is ok - add some points to the score?
	end
	-- 2. beetle gets to the center of the square - maybe there is an ambiguity, or the track is over
	if self.moveInterp >= 1.0 then
		self.moveInterp = .0
		self.passedBorder = false
		print ("Beetle advanced to tile ["..self.position.x..","..self.position.y.."]")
		
		-- check ambiguity
		direction = updateDirectionAtWall(direction, self.board.data[self.position.x][self.position.y])
	end
	
	print ("Beetle interp = "..self.moveInterp)
	
	return "ok"
end

-- board
function board:new(o)
	o = o or { }
	setmetatable(o, self)
	self.__index = self
	return o
end

function board:randomize(size)
	self.size = size or { x = 5, y = 5 }
	self.data = { }
	for x = 1, self.size.x do
		self.data[x] = { }
		for y = 1, self.size.y do
			local t = common.randTrueFalse()
			local b = common.randTrueFalse()
			local l = common.randTrueFalse()
			local r = common.randTrueFalse()
			self.data[x][y] = tile:new(t,b,l,r)
		end
	end
end

function board:dump()
	for y = 1, self.size.y do
		for x = 1, self.size.x do
			local tile = self.data[x][y]
			s = "["..(tile.t and "X" or ".")
				..(tile.b and "X" or ".")
				..(tile.l and "X" or ".")
				..(tile.r and "X" or ".") .. "]"
			io.write(s)
		end
		io.write("\n")
	end
end

function board:tapTile(position)
    -- t, r, b, l
	local tile = self.data[position.x][position.y]
	local off = tile.t
	tile.t = tile.r
	tile.r = tile.b
	tile.b = tile.l
	tile.l = off
	self.data[position.x][position.y] = tile
end

--[[
local function enterFrame( event )
	local curTime = event.time
	local dt = curTime - prevTime
	prevTime = curTime
	if ( (curTime - fps.prevTime ) > 100 ) then
		-- limit how often fps updates
		fps.text = string.format( '%.2f', 1000 / dt )
	end
end
]]

return logic

