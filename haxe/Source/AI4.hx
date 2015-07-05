package;

import flash.events.Event;
import flash.display.Sprite;

class AI4 extends Player
{
	private var nodes:Array<Array<Node>>;
	private var path:Node;
	
	private var allValidMoves:Array<Array<Array<Node>>>;
	
	override public function myTurn ():Int
	{
		if (allValidMoves == null)
		{
			// commands = [];
			// backup = [];
			// path = [];
			
			
			calculator ();
		}
		
		return 0;
	}
	
	private function calculator ():Void
	{
		nodes = [];
		for (x in 0 ... board.length)
		{
			nodes [x] = [];
			for (y in 0 ... board [x].length)
				nodes [x][y] = new Node (x, y);
		}
		
		createVaildMoves ();
		
		path = nodes [myPosition.x][myPosition.y];
		var val:Int = dfs (path);
		
		updatePath ();
		expandPath ();
	}
	
	private function expandPath ():Void
	{
		var current:Node = path;
		while (current != null)
		{
			if (current.child == null) break;
			var oldLength:Int = 0;
			var newLength:Int = 0;
			var start:Node = null;
			var end:Node = null;
			
			var debug:Bool = current.x == 4 && current.y == 1;
			var newPath:Array<Node> = dfsPath (current, debug);
			if (debug) trace ("newPath: " + newPath);
			if (newPath.length > 3 && newPath [0].index > -1 && newPath [newPath.length - 1].index > -1)
			{
				newLength = newPath.length;
				if (newPath [0].index < newPath [newPath.length - 1].index)
				{
					start = newPath.shift ();
					end = newPath.pop ();
					oldLength = releasePath (start, end);
					newLength = addPath (start, end, newPath, true);
					updatePath (start);
				}
				else if (newPath [0].index > newPath [newPath.length - 1].index)
				{
					start = newPath.pop ();
					end = newPath.shift ();
					oldLength = releasePath (start, end);
					newLength = addPath (start, end, newPath, false);
					updatePath (start);
				}
			}
			current = current.child;
		}
	}
	
	private function releasePath (start:Node, end:Node):Int
	{
		var count:Int = 1;
		var next:Node = start;
		var current:Node = start.child;
		while (current != null)
		{
			if (current == end) break;
			count ++;
			next = current.child;
			current.index = -1;
			current.parent = null;
			current.child = null;
			current = next;
		}
		start.child = null;
		end.parent = null;
		return count;
	}
	
	private function addPath (start:Node, end:Node, newPath:Array<Node>, left:Bool):Int
	{
		var count:Int = newPath.length + 2;
		var next:Node = null;
		var current:Node = null;
		while (newPath.length > 0)
		{
			next = left ? newPath.shift () : newPath.pop ();
			if (current != null)
			{
				next.parent = current;
				current.child = next;
			}
			else
			{
				start.child = next;
				next.parent = start;
			}
			current = next;
		}
		
		current.child = end;
		end.parent = current;
		
		return count;
	}
	
	private function updatePath (start:Node = null):Void
	{
		var current:Node = path;
		
		while (current != null)
		{
			if (current.parent == null)
				current.index = 0;
			else
				current.index = current.parent.index + 1;
			current = current.child;
		}
	}
	
	private function dfsPath (current:Node, debug:Bool = false):Array<Node>
	{
		var newLength:Int = 0;
		var newPath:Array<Node> = [];
		var checkPath:Array<Node> = null;
		var inPath:Bool = current.parent != null || current.child != null;
		
		current.use = true;
		if (debug) trace (current + " >> " + allValidMoves [current.x][current.y]);
		for (near in allValidMoves [current.x][current.y])
		{
			if (debug) trace ("check " + nodes [near.x][near.y] + ", " + nodes [near.x][near.y].use + ", " + nodes [near.x][near.y].parent);
			if (nodes [near.x][near.y].use) continue;
			
			if (nodes [near.x][near.y].parent != null || nodes [near.x][near.y].child != null)
			{
				if (inPath) continue;
				checkPath = [near];
			}
			else
			{
				checkPath = dfsPath (near, debug);
			}
			
			if (debug) trace ("--checkPath: " + checkPath);
			
			if (newPath.length < checkPath.length)
			{
				if (checkPath.length < 3)
					newPath = checkPath;
				else
				{
					var pathLength:Int = count (current, checkPath [checkPath.length - 1]);
					if (checkPath.length > pathLength && checkPath.length > newLength)
					{
						newLength = pathLength;
						newPath = checkPath;
					}
				}
			}
		}
		current.use = false;
		
		newPath.unshift (current);
		return newPath;
	}
	
	private function count (start:Node, end:Node):Int
	{
		if (start.index == -1 || end.index == -1) return -1;
		return 1 + Std.int (Math.abs (start.index - end.index));
	}
	
	private function dfs (current:Node):Int
	{
		var sum:Int = 1;
		var max:Int = 0;
		var maxChild:Node = null;
		
		for (near in allValidMoves [current.x][current.y])
		{
			if (nodes [near.x][near.y].parent != null) continue;
			
			nodes [near.x][near.y].parent = current;
			var val:Int = dfs (near);
			if (max < val)
			{
				max = val;
				if (maxChild != null) clear_dfs (maxChild);
				maxChild = near;
			}
			else
			{
				clear_dfs (near);
			}
		}
		
		current.child = maxChild;
		current.index = max + 1;
		sum = max + 1;
		
		return sum;
	}
	
	private function clear_dfs (current:Node):Void
	{
		for (near in allValidMoves [current.x][current.y])
		{
			if (board [near.x][near.y] != Value.BLOCK_EMPTY) continue;
			if (nodes [near.x][near.y].parent == current)
			{
				clear_dfs (near);
			}
		}
		current.child = null;
		current.parent = null;
		current.index = -1;
	}
	
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
				if (x > 0 && board [x - 1][y] == Value.BLOCK_EMPTY) 					allValidMoves [x][y].push (nodes [x - 1][y]);
				if (y > 0 && board [x][y - 1] == Value.BLOCK_EMPTY) 					allValidMoves [x][y].push (nodes [x][y - 1]);
				if (x < Value.MAP_SIZE - 1 && board [x + 1][y] == Value.BLOCK_EMPTY)	allValidMoves [x][y].push (nodes [x + 1][y]);
				if (y < Value.MAP_SIZE - 1 && board [x][y + 1] == Value.BLOCK_EMPTY)	allValidMoves [x][y].push (nodes [x][y + 1]);
			}
		}
	}
	
	override public function debug (canvas:Board):Void
	{
		// canvas.path (path, Value.BLOCK_PLAYER_1);
		
		var cv:Sprite = canvas.canvas2;
		cv.graphics.clear ();
		cv.graphics.lineStyle (2, 0x000000, 1);
		
		var current:Node = null;
		for (x in 0 ... board.length)
		{
			for (y in 0 ... board [x].length)
			{
				current = nodes [x][y];
				if (current == null) continue;
				if (current.child == null) continue;
				
				var blockCurrent:Block = canvas.getBlock (current.x, current.y);
				var blockChild:Block = canvas.getBlock (current.child.x, current.child.y);
				
				if (blockCurrent == null) continue;
				if (blockChild == null) continue;
				
				blockCurrent.text = "" + current.index;
				cv.graphics.moveTo (blockCurrent.x, blockCurrent.y);
				cv.graphics.lineTo (blockChild.x, blockChild.y);
			}
		}
	}
}

class Node extends Position
{
	public var parent:Node = null;
	public var child:Node = null;
	public var index:Int = -1;
	public var use:Bool = false;
}