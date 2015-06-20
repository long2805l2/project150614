package;

class AI extends Player
{
	override public function myTurn ():Int
	{
		if (path == null)
		{
			path = createPath ();
			// path.shift ();
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
	private var debugSign:Array<Dynamic>;
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
			if (a.g < b.g) return -1;
			if (a.g > b.g) return 1;
			if (a.h < b.h) return -1;
			if (a.h > b.h) return 1;
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
					if (v.f > g + h)
					{
						v.g = g;
						v.h = h;
						v.f = g + h;
					}
					break;
				}
			}
		}
		
		var getMoves = function (data:Array<Array<Int>>, x:Int, y:Int):Array<Position>
		{
			var suitableDir:Array<Position> = [];
			if (y < Value.MAP_SIZE - 1 && data [x][y + 1] == Value.BLOCK_EMPTY)
				suitableDir.push (new Position (x, y + 1));
				
			if (x < Value.MAP_SIZE - 1 && data [x + 1][y] == Value.BLOCK_EMPTY)
				suitableDir.push (new Position (x + 1, y));
			
			if (x > 0 && data [x - 1][y] == Value.BLOCK_EMPTY)
				suitableDir.push (new Position (x - 1, y));
			
			if (y > 0 && data [x][y - 1] == Value.BLOCK_EMPTY)
				suitableDir.push (new Position (x, y - 1));
			
			return suitableDir;
		}
		
		var sign:Array<Array<Dynamic>> = [];
		var newNode = function (p:Position, g:Float, h:Float, parent:Position):Dynamic
		{
			return { p:p, g:g, h:h, f:g + h, parent:parent, closed:false, opened:false };
		};
		
		var addNode = function (node:Dynamic):Void
		{
			if (sign [node.p.x] == null) sign [node.p.x] = [];
			sign [node.p.x][node.p.y] = node;
			if (node.parent == null)
				trace (haxe.CallStack.toString (haxe.CallStack.callStack ()));
		};
		
		var getNode = function (p:Position):Dynamic
		{
			if (sign [p.x] == null) return null;
			return sign [p.x][p.y];
		};
		
		var pathFinding = function (zone:Array<Array<Int>>, start:Position, goal:Position):Void
		{
			var startNode:Dynamic = newNode (start, 0, heuristic (start.x, start.y, goal.x, goal.y), null);
			startNode.opened = true;
			addNode (startNode);
			
			var openList:Array<Dynamic> = [startNode];
			while (openList.length > 0)
			{
				openList.sort (sort);
				var node:Dynamic = openList.shift ();
				node.closed = true;
				
				if (node.p.x == goal.x && node.p.y == goal.y) break;
				
				var nears:Array<Position> = getMoves (zone, node.p.x, node.p.y);
				for (neighbor in nears)
				{
					var nNode:Dynamic = getNode (neighbor);
					if (nNode == null)
					{
						nNode = newNode (neighbor, node.g + 1, heuristic (node.p.x, node.p.y, goal.x, goal.y), node.p);
						addNode (nNode);
					}
					
					if (nNode.closed) continue;
					if (!nNode.opened)
					{
						openList.push(nNode);
						nNode.opened = true;
					}
					else if (node.g + 1 < nNode.g)
					{
						nNode.g = node.g + 1;
						nNode.h = heuristic (node.p.x, node.p.y, goal.x, goal.y);
						nNode.f = nNode.g + nNode.h;
						nNode.parent = node.p;
					}
				}
			}
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
		zone [enemyPosition.x][enemyPosition.y] = Value.BLOCK_EMPTY;
		pathFinding (zone, myPosition, enemyPosition);
		
		var goalNode:Dynamic = getNode (enemyPosition);
		debugSign = sign;
		
		if (goalNode == null)
			return [myPosition];
		
		var path:Array<Position> = [];
		var current:Dynamic = goalNode;
		while (current != null && current.parent != null)
		{
			path.unshift (current.p);
			current = getNode (current.parent);
		}
		
		return path;
	}
	
	private function backTrace ():Array<Position>
	{
		
	}
}