package;

class AI extends Player
{
	override public function myTurn ():Int
	{
		if (path == null)
		{
			path = extendPath (clone (), myPosition);
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
	private function extendPath (data:Array<Array<Int>>, start:Position):Array<Position>
	{
		var valids:Array<Position> = getMoves (data, start.x, start.y);		
		var path:Array<Position> = [];
		while (valids.length < 2)
		{
			path.push (start);			
			if (valids.length == 0) return path;
			
			data [start.x][start.y] = Value.BLOCK_OBSTACLE;
			data [start.x][start.y] = Value.BLOCK_OBSTACLE;//Value.BLOCK_EMPTY;
			
			start = valids [0];
			valids = getMoves (data, start.x, start.y);
		}
		path.push (start);
		trace ("path: " + path);
		trace ("valids: " + valids);
		
		var validPaths:Array<Position> = [];
		for (i in 0 ... valids.length - 1)
		{
			for (j in i + 1 ... valids.length)
			{
				var newPaths:Array<Position> = createPath (data, valids [i], valids [j]);
				newPaths.unshift (valids [i]);
				if (newPaths.length > validPaths.length)
					validPaths = newPaths;
			}
		}
		
		while (validPaths.length > 0)
		{
			for (move in validPaths)
			{
				path.push (move);
				data [move.x][move.y] = Value.BLOCK_OBSTACLE;
			}
			
			
		}
		return path;
	}
	
	private function clone ():Array<Array<Int>>
	{
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
		return zone;
	}
	
	private function heuristic (x1:Int, y1:Int, x2:Int, y2:Int):Float
	{
		return Math.abs (x2 - x1) + Math.abs (y2 - y1);
	}
	
	private function getMoves (data:Array<Array<Int>>, x:Int, y:Int):Array<Position>
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
	
	private function createPath (zone:Array<Array<Int>>, start:Position, goal:Position):Array<Position>
	{
		var newNode = function (p:Position, g:Float, h:Float, parent:Position):Dynamic
		{
			return { p:p, g:g, h:h, parent:parent, closed:false, opened:false };
		};
		
		var pathFinding = function (zone:Array<Array<Int>>, start:Position, goal:Position):Array<Position>
		{
			var sign:Map<String, Dynamic> = new Map<String, Dynamic> ();
			var startNode:Dynamic = newNode (start, 0, heuristic (start.x, start.y, goal.x, goal.y), null);
			startNode.opened = true;
			sign.set (start.toString (), startNode);
			
			var openList:Array<Dynamic> = [startNode];
			while (openList.length > 0)
			{
				var node:Dynamic = openList.shift ();
				node.closed = true;
				
				if (node.p.x == goal.x && node.p.y == goal.y) break;
				
				for (neighbor in getMoves (zone, node.p.x, node.p.y))
				{
					var nNode:Dynamic = sign.get (neighbor.toString ());
					if (nNode == null)
					{
						nNode = newNode (neighbor, node.g + 1, heuristic (node.p.x, node.p.y, goal.x, goal.y), node.p);
						sign.set (neighbor.toString (), nNode);
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
						nNode.parent = node.p;
					}
				}
			}
			
			var goalNode:Dynamic = sign.get (goal.toString ());
			if (goalNode == null) return [start];
			
			var path:Array<Position> = [];
			var current:Dynamic = goalNode;
			while (current != null && current.parent != null)
			{
				path.unshift (current.p);
				current = sign.get (current.parent.toString ());
			}
			
			return path;
		};
		
		return pathFinding (zone, start, goal);
	}
	
	// private function backTrace ():Array<Position>
	// {
		
	// }
}