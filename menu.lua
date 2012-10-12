local widget = require"widget"

return {
	initMenu = function (options)
		local start = widget.newButton{
			default = "buttonRed.png",
			over = "buttonRedOver.png",
			id = "startButton",
			label = "Start Game",
			emboss = true,
			onEvent = options.start.onEvent or function () return end,
		}
		start.x = options.start.x or 160
		start.y = options.start.y or 160

		local exit = widget.newButton{
			default = "buttonRed.png",
			over = "buttonRedOver.png",
			id = "exitButton",
			label = "Exit Game",
			emboss = true,
			onEvent = options.exit.onEvent or function () return end,
		}
		exit.x = options.exit.x or 160
		exit.y = options.exit.y or 160
	end
}