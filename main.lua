local gameDisplay = require"gameDisplay"
local mainMenu = require"menu"


local enterFrame = function () return end
local gameStates = {}
local currentState = ""

local function getFrame ()
	local prevTime = system.getTimer()
	if not curFun then local curFun = nil else curFun = nil end
	return function (event)
		local curTime = event.time	
		
		if ( (curTime - prevTime ) > (16) ) then
			if not curFun then
				curFun = gameStates[currentState]()
			end
			
			curFun()
			prevTime = curTime
		end
	end
end

local function changeState (name)
	if not gameStates[name] then print "no such game state" return end
	if currentState == name then return end
	currentState = name
	print "co jest kurwa"
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
	return function () end
end

gameStates.game = function ()
	print "gra?"
	gameDisplay:initGame()
	return function () gameDisplay:update() end
end

changeState("menu")

Runtime:addEventListener( "enterFrame", enterFrame )