
common = { }

function common.randTrueFalse ()
	return (math.random(0,1) == 0) and true or false;
end

return common