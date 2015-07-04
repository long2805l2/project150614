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
	}
	
	private function expandPath (path:Node):Void
	{
	}
	
	private function dfsPath (path:Array<Position>, current:Position):Void
	{
	}
	
	private function dfs (current:Node):Int
	{
		var sum:Int = 1;
		var max:Int = 0;
		var maxChild:Node = null;
		
		for (near in allValidMoves [current.x][current.y])
		{
			if (board [near.x][near.y] != Value.BLOCK_EMPTY) continue;
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
		sum = max + 1;
		
		return sum;
	}
	
	private function clear_dfs (current:Node):Void
	{
		for (near in allValidMoves [current.x][current.y])
		{
			if (board [near.x][near.y] != Value.BLOCK_EMPTY) continue;
			if (nodes [near.x][near.y].parent == current)
				clear_dfs (near);
		}
		nodes [current.x][current.y].parent = null;
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
		
		var current:Node = path;
		while (current != null)
		{
			if (current.child == null) break;
			
			var blockCurrent:Block = canvas.getBlock (current.x, current.y);
			var blockChild:Block = canvas.getBlock (current.child.x, current.child.y);
			
			current = current.child;
			
			if (blockCurrent == null) continue;
			if (blockChild == null) continue;
			
			cv.graphics.moveTo (blockCurrent.x, blockCurrent.y);
			cv.graphics.lineTo (blockChild.x, blockChild.y);
		}
	}
}

class Node extends Position
{
	public var parent:Node = null;
	public var child:Node = null;
}