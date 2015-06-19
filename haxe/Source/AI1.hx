package;

class AI1 extends Player
{
	override public function myTurn ():Int
	{
		var zone:Array<Array<Int>> = [];
		for (x in 0 ... board.length)
		{
			zone [x] = [];
			for (y in 0 ... board [x].length)
			{
				if (board [x][y] == Value.BLOCK_EMPTY)
					zone [x][y] = 0;
				else
					zone [x][y] = -1;
			}
		}
		zone [this.x][this.y] = 0;
		
		var func = null;
		func = function (data:Array<Array<Int>>, x:Int, y:Int, move:Int)
		{
			if (data [x][y] != 0 && data [x][y] < move) return;
			
			data [x][y] = move;
			
			if (x > 0) func (data, x - 1, y, move + 1);
			if (y > 0) func (data, x, y - 1, move + 1);
			if (x < Value.MAP_SIZE - 1) func (data, x + 1, y, move + 1);
			if (y < Value.MAP_SIZE - 1) func (data, x, y + 1, move + 1);
		};
		func (zone, x, y, 1);
		
		var max:Int = -1;
		var maxX:Int = -1;
		var maxY:Int = -1;
		for (x in 0 ... Value.MAP_SIZE) for (y in 0 ... Value.MAP_SIZE)
			if (zone [x][y] > max) { max = zone [x][y]; maxX = x; maxY = y; }
		
		func = function (data:Array<Array<Int>>, x:Int, y:Int, move:Int)
		{
			if (move == 1) { maxX = x; maxY = y; return; }
	
			var suitableDir = [];
			if (x > 0 && data [x - 1][y] == move) 					suitableDir.push (Value.DIRECTION_LEFT);
			if (y > 0 && data [x][y - 1] == move) 					suitableDir.push (Value.DIRECTION_UP);
			if (x < Value.MAP_SIZE - 1 && data [x + 1][y] == move)	suitableDir.push (Value.DIRECTION_RIGHT);
			if (y < Value.MAP_SIZE - 1 && data [x][y + 1] == move)	suitableDir.push (Value.DIRECTION_DOWN);
			
			var selection = Std.random (suitableDir.length);
			var dir = suitableDir[selection];
			
			if (dir == Value.DIRECTION_LEFT)			func (data, x - 1, y, move - 1);
			else if (dir == Value.DIRECTION_UP)			func (data, x, y - 1, move - 1);
			else if (dir == Value.DIRECTION_RIGHT)		func (data, x + 1, y, move - 1);
			else if (dir == Value.DIRECTION_DOWN)		func (data, x, y + 1, move - 1);
		};
		
		func (zone, maxX, maxY, max - 1);
		
		var dir:Int = -1;
		if (this.x - 1 == maxX)				dir = Value.DIRECTION_LEFT;
		else if (this.x + 1 == maxX)		dir = Value.DIRECTION_RIGHT;
		else if (this.y - 1 == maxY)		dir = Value.DIRECTION_UP;
		else if (this.y + 1 == maxY)		dir = Value.DIRECTION_DOWN;
		
		return dir;
	}
}