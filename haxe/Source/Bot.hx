package;

class Bot extends Player
{
	override public function myTurn ():Int
	{
		var suitableDir:Array<Int> = [];
		
		if (x > 0 && board [x - 1][y] == Value.BLOCK_EMPTY)
			suitableDir.push (Value.DIRECTION_LEFT);
		
		if (y > 0 && board [x][y - 1] == Value.BLOCK_EMPTY)
			suitableDir.push (Value.DIRECTION_UP);
		
		if (x < Value.MAP_SIZE - 1 && board [x + 1][y] == Value.BLOCK_EMPTY)
			suitableDir.push (Value.DIRECTION_RIGHT);
		
		if (y < Value.MAP_SIZE - 1 && board [x][y + 1] == Value.BLOCK_EMPTY)
			suitableDir.push (Value.DIRECTION_DOWN);
		
		return suitableDir [Std.random (suitableDir.length)];
	}
}