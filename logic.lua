

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
	moveInterp = 0.0, -- how far from center of the block are we?
	passedBorder = true, -- if we are running "in" or "out" of the block
	speed = 0.01, -- per frame. 1.0 = tile size
	board = nil, -- board structure "pointer"
	points = 0, -- points gathered by the given beetle
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
	special = "", -- bonus, start, end
	canRotate = true, -- you can't rotate some special tiles and the tile beetle is at
}

function routes:new (t, b, l, r, special)
	o = { 
		t = t,
		b = b,
		l = l,
		r = r,
		special = special,
	}
	setmetatable(o, self)
	self.__index = self
	return o
end

function routes:newRandom()
	-- it was actually simpler than do it procedurally
	local possibleTiles = {
		{ false, false, true, true },
		{ false, true, false, true },
		{ false, true, true, false },
		{ false, true, true, true },
		{ true, false, false, true },
		{ true, false, true, false },
		{ true, false, true, true },
		{ true, true, false, false },
		{ true, true, false, true },
		{ true, true, true, false },
		{ true, true, true, true }
	}
	
	local number = math.random(1,11)

	local temp = routes:new(possibleTiles[number][1],
							possibleTiles[number][2],
							possibleTiles[number][3],
							possibleTiles[number][4],
							"")
							
	-- randomize the bonus
	if math.random(1,15) == 1 then
		temp.special = "bonus"
	end
	
	return temp
end

function routes:tap() -- rotation of the block
	if self.canRotate then
		local off = self.t
		self.t = self.r
		self.r = self.b
		self.b = self.l
		self.l = off
	end
end

-- implementation
-----------------------

function beetle:run ()
	-- bounds of the array
	function goingOutOfBounds(position, direction, size)
		if direction=="left" and position.x < 1 then return true
		elseif direction=="right" and position.x > size.x then return true
		elseif direction=="up" and position.y < 1 then return true
		elseif direction=="down" and position.y > size.y then return true
		end

		return false
	end	
	
	-- border of the next tile
	function canRunIntoTile(direction, routes) 
		if direction == "up" then return routes.b
		elseif direction == "down" then return routes.t
		elseif direction == "left" then return routes.r
		elseif direction == "right" then return routes.l
		end
	end
	
	-- T-section dispatcher
	function updateDirectionAtTSection(direction, routes)
		print ("updateDirectionAtWall : ", direction, routes.t, routes.r, routes.b, routes.l)
		if (direction == "up" and not routes.t) or
				(direction == "down" and not routes.b) then
			print ("Turning Beetle!")
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
			print ("Turning Beetle!")
			if routes.t and routes.b then -- randomize
				return common.randTrueFalse() and "up" or "down"
			elseif routes.t then
				return "up"
			else
				return "down"
			end
		end
		return direction
	end

	-- end tile dispatcher
	function checkIfEnd(routes)
		return routes.special == "end"
	end

	-- advance the beetle
	self.moveInterp = self.moveInterp + self.speed
	-- two cases, when we are unclear
	-- 1. beetle leaves current square - maybe there isn't a connection?
	if self.moveInterp >= 0.5 and not self.passedBorder then
		local currentTile = self.board.getData(self.position)
		currentTile.special = "closed"

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
		
		print ("Beetle went into ["..self.position.x..","..self.position.y.."]")
		
		nextTile.canRotate = false
		
		self.passedBorder = true
		self.moveInterp = self.moveInterp - 1.0
		-- move is ok - add some points to the score?
	end
	-- 2. beetle gets to the center of the square - maybe there is an ambiguity, or the track is over
	-- points are awarded at this moment
	if self.moveInterp >= 0.0 and self.passedBorder then
		self.moveInterp = .0
		self.passedBorder = false
		print ("Beetle in middle of ["..self.position.x..","..self.position.y.."], checking turns")
		
		local tempRoutes = self.board.getData(self.position)
		
		-- check for end tile
		if checkIfEnd(tempRoutes) then
			return "end"
		end
		
		-- check ambiguity
		self.direction = updateDirectionAtTSection(self.direction, tempRoutes)
		
		-- check for bonus tile
		if tempRoutes.special == "bonus" then
			self.points = self.points + 50
		else
			self.points = self.points + 10
		end
	end
	
	return "ok"
end

