package;

class AI1 extends Player
{
	private var zone:Array<Array<Int>>;
	override public function myTurn ():Int
	{
		if (allValidMoves == null) createVaildMoves ();
		
		zone = [];
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
		floodfill (zone, x, y);
		
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
	
	public function floodfill (data:Array<Array<Int>>, x:Int, y:Int):Void
	{
		var q:Array<Position> = [new Position (x, y)];
		var q2:Array<Position> = [];
		data [x][y] = 1;
		var dist:Int = 1;
		
		while (q.length > 0)
		{
			dist++;
			for (position in q)
			{
				var validMoves:Array<Position> = allValidMoves [position.x][position.y];
				trace ("position: " + position + " >> " + validMoves);
				for (move in validMoves)
				{
					trace ("--move (" + move.x + ", " + move.y + "): " + data [move.x][move.y]);
					if (data [move.x][move.y] != 0) continue;
					data [move.x][move.y] = dist;
					q2.push (move);
				}
			}
			q = q2; q2 = [];
		}
	}
	
	private var allValidMoves:Array<Array<Array<Position>>>;
	private function createVaildMoves ():Void
	{
		allValidMoves = [];
		for (x in 0 ... board.length)
		{
			allValidMoves [x] = [];
			for (y in 0 ... board [x].length)
			{
				allValidMoves [x][y] = [];
				if (board [x][y] == Value.BLOCK_OBSTACLE) continue;
				if (x > 0 && board [x - 1][y] == Value.BLOCK_EMPTY) 					allValidMoves [x][y].push (new Position (x - 1, y));
				if (y > 0 && board [x][y - 1] == Value.BLOCK_EMPTY) 					allValidMoves [x][y].push (new Position (x, y - 1));
				if (x < Value.MAP_SIZE - 1 && board [x + 1][y] == Value.BLOCK_EMPTY)	allValidMoves [x][y].push (new Position (x + 1, y));
				if (y < Value.MAP_SIZE - 1 && board [x][y + 1] == Value.BLOCK_EMPTY)	allValidMoves [x][y].push (new Position (x, y + 1));
			}
		}
	}
	
	override public function debug (board:Board):Void
	{
		for (x in 0 ... zone.length)
			for (y in 0 ... zone [x].length)
				board.block (x, y, -1, "" + zone [x][y]);
	}
}