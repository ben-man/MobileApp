local function showScore()
 
	local count = 0
	local score = 0
	local highScore = 0
	local scoreDisplay = display.newText( "0", 160, 10, native.systemFont, 16 )
 
	local function addToScore( count, score )
 
		local newScore = score + count
		scoreDisplay.text = newScore
 
		if ( newScore > highScore ) then
			highScore = newScore
		end
 
		return newScore
	end
 
	addToScore( count, score )
	print( newScore )
end
 
showScore()