local gameDisplay = require"gameDisplay"
local mainMenu = require"menu"


local enterFrame = function () return end
local gameStates = {}
local currentState = ""
local changeState

local function getFrame ()
	local prevTime = system.getTimer()
	if curFun and curFun.clear then curFun.clear() end
	if not curFun then local curFun = nil else curFun = nil end
	return function (event)
		local curTime = event.time

		if not curFun then
			curFun = gameStates[currentState]()
		end
		
		if ( (curTime - prevTime ) > (16) ) then
			local state = curFun.run()

			if (state) then
				changeState(state)
			end
			prevTime = curTime
		end
	end
end

changeState = function (name)
	if not gameStates[name] then print "no such game state" return end
	if currentState == name then return end
	currentState = name
	enterFrame = getFrame()
end

gameStates.menu = function ()
	mainMenu.initMenu({
		start = {
			x = display.contentWidth/2,
			y = display.contentHeight/3 - 30,
			onEvent = function (e)
				if (e.phase == "release") then
					changeState("game")
				end
			end
		},
		exit = {
			x = display.contentWidth/2,
			y = 2*display.contentHeight/3 - 30,
			onEvent = function (e)
				if (e.phase == "release") then
					os.exit()
				end
			end
		}
	})
	return {
		run = function () return end,
		clear = function () mainMenu.clear() return end
	}
end

gameStates.game = function ()
	gameDisplay:initGame()
	return {
		run = function () return gameDisplay:update() end,
		clear = function () return gameDisplay:clear() end
	}
end

changeState("menu")

Runtime:addEventListener( "enterFrame", enterFrame )