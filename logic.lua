

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
	position = { x = 2, y = 2 },
	direction = "down", -- "left", "right", "up"
	moveInterp = .0, -- how far from center of the block are we?
	passedBorder = false,
	speed = 0.05,
	board = nil,
}

function beetle:new(o) 
	o = o or { }
	setmetatable(o, self)
	self.__index = self
	return o
end

DIRECTION_MODS = {
	up = { x = 0, y = -1 },
	down = { x = 0, y = 1 },
	left = { x = -1, y = 0 },
	right = { x = 1, y = 0}
}		

-- routes definition
routes = {
	t = true, --top
	b = true, --bottom
	l = true, --left
	r = true, --right
}

function routes:new (t, b, l, r)
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

function routes:tap()
	local off = self.t
	self.t = self.r
	self.r = self.b
	self.b = self.l
	self.l = off
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
	
	function canRunIntoTile(direction, routes) 
		if direction == "up" then return routes.b
		elseif direction == "down" then return routes.t
		elseif direction == "left" then return routes.r
		elseif direction == "right" then return routes.l
		end
	end
	
	function updateDirectionAtWall(direction, routes)
		if (direction == "up" and not routes.t) or
				(direction == "down" and not routes.b) then
			if routes.l and routes.r then -- randomize
				return common.randTrueFalse() and "left" or "right"
			elseif routes.l then
				return "left"
			else
				return "right"
			end
		end
		if (direction == "left" and not routes.l) or
				(direction == "right" and not routes.r) then
			if routes.t and routes.b then -- randomize
				return common.randTrueFalse() and "up" or "down"
			elseif routes.t then
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
		
		print ("xy "..self.position.x.." "..self.position.y)
		local nextTile = self.board.getData(self.position)
		
		if goingOutOfBounds(self.position, self.direction, self.board.getSize()) then
			return nil, "game_over - out of bounds"
		end
		
		print ("Checking next routes, direction = "..self.direction)
		
		if not canRunIntoTile(self.direction, nextTile) then
			return nil, "game_over - routes error"
		end
		
		self.passedBorder = true
		-- move is ok - add some points to the score?
	end
	-- 2. beetle gets to the center of the square - maybe there is an ambiguity, or the track is over
	if self.moveInterp >= 1.0 then
		self.moveInterp = .0
		self.passedBorder = false
		print ("Beetle advanced to routes ["..self.position.x..","..self.position.y.."]")
		
		-- check ambiguity
		direction = updateDirectionAtWall(direction, self.board.getData(self.position))
	end
	
	print ("Beetle interp = "..self.moveInterp)
	
	return "ok"
end

