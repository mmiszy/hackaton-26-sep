local gameDisplay = require"gameDisplay"


local currentState = "game"
local enterFrame = function () return end

local gameStates = {
	menu = function ()
		return function () end
	end,
	game = function ()
		gameDisplay:initGame()
		return function () gameDisplay:update() end
	end,
}

local function getFrame ()
	local prevTime = system.getTimer()
	local curFun = nil
	return function (event)
		local curTime = event.time	
		
		if ( (curTime - prevTime ) > (16) ) then	
			if not curFun then
				curFun = gameStates[currentState]()
			else
				curFun()
			end
			prevTime = curTime
		end
	end
end

local function changeState (name)
	if not gameStates[name] then print"chuj" return end
	enterFrame = getFrame()
end

changeState("game")

Runtime:addEventListener( "enterFrame", enterFrame )