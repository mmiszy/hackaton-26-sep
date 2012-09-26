

-- beetle run logic component

-- block is given in 4-bit number; each bit means connection
-- with sides, in order: top, right, bottom, left

-- beetle can go from block A to B if their corresponding bits are set,
-- i.e. 1-3, 3-1, 2-4, 4-2

-- beetle automatically turns at 'L' shaped intersections
-- it chooses random way at 'T' shaped intersection, but
-- only in ambigious case.

beetle = {
	position = { 0, 0 },
	direction = "up", -- "left", "right", "down"
	moveInterp = .0, -- how far from center of the block are we?
	speed = 0.05,
}

board = {
	data = { },
	size = { x = 5, y = 5 },
}

DIRECTION_MODS = {
	up = { x = 0, y = -1 },
	down = { x = 0, y = +1 },
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

function beetle.run ()
	function goingOutOfBounds(position, direction, size)
		if direction=="left" and position.x < 1 then return true end
		if direction=="right" and position.x > size.x then return true end
		if direction=="up" and position.y < 1 then return true end
		if direction=="down" and position.y > size.y then return true end

		return false
	end	
	
	function canRunIntoTile(direction, tile) 
		if direction = "up" then return tile.b end
		if direction = "down" then return tile.t end
		if direction = "left" then return tile.r end
		if direction = "right" then return tile.l end
	end

	-- advance the beetle
	self.moveInterp = self.moveInterp + self.speed
	-- two cases, when we are unclear
	-- 1. beetle leaves current square - maybe there isn't a connection?
	if self.moveInterp == .5 then
		local directionMod = DIRECTION_MODS[self.direction]
		self.position.x = self.position.x + directionMod.x
		self.position.y = self.position.y + directionMod.y
		local nextTile = B.data[self.position.x][self.position.y]
		
		if goingOutOfBounds(self.position, self.direction, B.size) then
			return "game_over"
		end
		
		if not canRunIntoTile(self.direction, nextTile) then
			return "game_over"
		end
		
		-- move is ok - add some points to the score?
	end
	-- 2. beetle gets to the center of the square - maybe there is an ambiguity, or the track is over
	if self.moveInterp == 1.0 then
		self.moveInterp = .0
	end
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
			local t = (math.random(0,1) == 0) and true or false;
			local b = (math.random(0,1) == 0) and true or false;
			local l = (math.random(0,1) == 0) and true or false;
			local r = (math.random(0,1) == 0) and true or false;
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


--test
math.randomseed(4)

B = board:new()
B:randomize()
B:dump()








