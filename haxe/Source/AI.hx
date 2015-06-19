package;

class AI extends Player
{
	override public function myTurn ():Int
	{
		if (path == null)
		{
			path = createPath ();
			path.shift ();
		}
		
		if (path.length == 0) return -1;
		
		var next:Position = path.shift ();
		var dir:Int = -1;
		if (x - 1 == next.x)			dir = Value.DIRECTION_LEFT;
		else if (x + 1 == next.x)		dir = Value.DIRECTION_RIGHT;
		else if (y - 1 == next.y)		dir = Value.DIRECTION_UP;
		else if (y + 1 == next.y)		dir = Value.DIRECTION_DOWN;
		
		trace (myPosition + " >> " + next + " >> " + dir);
		return dir;
	}
	
	private var path:Array<Position>;
	private function createPath ():Array<Position>
	{
		var heuristic = function (x1:Int, y1:Int, x2:Int, y2:Int):Float
		{
			return Math.abs (x2 - x1) + Math.abs (y2 - y1);
		};
		
		var sort = function (a:Dynamic, b:Dynamic):Int
		{
			if (a.f < b.f) return -1;
			if (a.f > b.f) return 1;
			return 0;
		}
		
		var find = function (list:Array<Dynamic>, p:Position):Bool
		{
			for (v in list)
				if (v.p.x == p.x && v.p.y == p.y)
					return true;
			return false;
		}
		
		var updatePoint = function (list:Array<Dynamic>, p:Position, g:Float, h:Float):Void
		{
			for (v in list)
			{
				if (v.p.x == p.x && v.p.y == p.y)
				{
					v.g = g;
					v.h = h;
					v.f = g + h;
				}
			}
		}
		
		var getMoves = function (data:Array<Array<Int>>, x:Int, y:Int):Array<Position>
		{
			var suitableDir:Array<Position> = [];
			// trace ("getMoves: " + x + ", " + y);
			// trace ("data [" + (x - 1) + "][" + y + "]: " + (data[x - 1] != null ? data [x - 1][y] : -1));
			// trace ("data [" + x + "][" + (y - 1) + "]: " + (data[x] != null ? data [x][y - 1] : -1));
			// trace ("data [" + (x + 1) + "][" + y + "]: " + (data[x + 1] != null ? data [x + 1][y] : -1));
			// trace ("data [" + x + "][" + (y + 1) + "]: " + (data[x] != null ? data [x][y + 1] : -1));
			if (x > 0 && data [x - 1][y] == Value.BLOCK_EMPTY) 					suitableDir.push (new Position (x - 1, y));
			if (y > 0 && data [x][y - 1] == Value.BLOCK_EMPTY) 					suitableDir.push (new Position (x, y - 1));
			if (x < Value.MAP_SIZE - 1 && data [x + 1][y] == Value.BLOCK_EMPTY)	suitableDir.push (new Position (x + 1, y));
			if (y < Value.MAP_SIZE - 1 && data [x][y + 1] == Value.BLOCK_EMPTY)	suitableDir.push (new Position (x, y + 1));
			// trace ("suitableDir: " + suitableDir);
			return suitableDir;
		}
		
		var sign:Array<Array<Bool>> = [];
		var pathFinding = function (zone:Array<Array<Int>>, start:Position, goal:Position):Array<Position>
		{
			var openList:Array<Dynamic> = [];
			var closeList:Array<Dynamic> = [];
			
			openList.push ({p:start, f:0, g:0, h:0});
			do
			{
				openList.sort (sort);
				var current:Dynamic = openList.shift ();
				trace ("current: " + current);
				
				closeList.push (current);
				trace ("find (closeList, goal): " + find (closeList, goal));
				if (find (closeList, goal)) break;
				
				var moves:Array<Position> = getMoves (zone, current.p.x, current.p.y);
				trace ("moves: " + moves);
				for (move in moves)
				{
					trace ("-find (closeList, " + move + "): " + find (closeList, move));
					if (find (closeList, move)) continue;

					var g:Float = current.g + 1;
					var h:Float = heuristic (move.x, move.y, goal.x, goal.y);
					trace ("--g: " + g);
					trace ("--h: " + h);
					if (!find (openList, move))
						openList.push ({p:move, f:g + h, g:g, h:h});
					else
						updatePoint (openList, move, g, h);
				}
			}
			while (openList.length > 0);
			
			// trace ("closeList: " + closeList.length);
			var temp:Array<Position> = [for (m in closeList) m.p];
			return temp;
		};
		
		var zone:Array<Array<Int>> = [];
		for (x in 0 ... board.length)
		{
			zone [x] = [];
			for (y in 0 ... board [x].length)
			{
				if (board [x][y] == Value.BLOCK_EMPTY)
					zone [x][y] = Value.BLOCK_EMPTY;
				else
					zone [x][y] = Value.BLOCK_OBSTACLE;
			}
		}
		zone [this.x][this.y] = Value.BLOCK_EMPTY;
		return pathFinding (zone, myPosition, enemyPosition);
	}
}