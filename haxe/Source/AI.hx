package;

class AI
{
	public static function expand (map:Array<Array<Int>>, path:Array<Position>):Array<Position>
	{
		if (path.length <= 2) return path;
		
		var newPath:Array<Position> = [];
		var current:Position = path.shift ();
		var next:Position = path.shift ();
		while (path.length > 0)
		{
			var validMoves:Array<Position> = getvalidMoves (current);
			var nextPath:Array<Position> = null;
			for (move in validMoves)
			{
				nextPath = pathfinding (map, move, next);
				if (nextPath != null && nextPath.length > 0) break;
			}
			
			newPath.push (current);
			if (nextPath != null)
			{
				newPath = expand (map, newPath);
				for (move in nextPath) newPath.push (move);
			}
			
			if (path.length == 0)
			{
				newPath.push (next);
				break;
			}
			
			current = next;
			next = path.shift ();
		}
		return newPath;
	}
	
	public static function heuristic (x1:Int, y1:Int, x2:Int, y2:Int):Int
	{
		return Math.abs (x2 - x1) + Math.abs (y2 - y1);
	}
	
	public static function pathfinding (map:Array<Array<Int>>, start:Position, goal:Position):Array<Position>
	{
		var openList:Array<Dynamic> = [];
		
		openList.push(startNode);
		startNode.opened = true;
		
		while (openList.length > 0)
		{
			var node = openList.pop ();
			node.closed = true;
			
			if (node == goal)
				return;
				
			var neighbors = getNeighbors (node);
			for (neighbor in neighbors)
			{
				if (neighbor.closed) continue;
				
				ng = node.g + ((neighbor.x - node.x === 0 || neighbor.y - node.y === 0) ? 1 : SQRT2);
				
				if (!neighbor.opened || ng < neighbor.g)
				{
					neighbor.g = ng;
					neighbor.h = neighbor.h || weight * heuristic(abs(x - endX), abs(y - endY));
					neighbor.f = neighbor.g + neighbor.h;
					neighbor.parent = node;

					if (!neighbor.opened)
					{
						openList.push(neighbor);
						neighbor.opened = true;
					}
					else
					{
						// the neighbor can be reached with smaller cost.
						// Since its f value has been updated, we have to
						// update its position in the open list
						openList.updateItem(neighbor);
					}
				}
            }
		}
	}
}