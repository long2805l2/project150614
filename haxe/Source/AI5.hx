package;

import flash.events.Event;
import flash.display.Sprite;

class AI5 extends Player
{
	private var nodes:Array<Array<Node>>;
	private var path:Node;
	
	private var allValidMoves:Array<Array<Array<Node>>>;
	
	override public function myTurn ():Int
	{
		if (allValidMoves == null)
		{
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
		
		// for (x in 0 ... board.length)
		// {
			// for (y in 0 ... board [x].length)
			// {
				// if (board [x][y] != Value.BLOCK_EMPTY) continue;
				
				// for (x2 in 0 ... board.length)
				// {
					// for (y2 in 0 ... board [x2].length)
					// {
						// var node:Node = nodes [x2][y2];
						// node.low = node.num = 0;
						// node.parent = null;
						// node.visited = false;
					// }
				// }
				
				Node.ID = 0;
				// art (nodes [x][y]);
				art (nodes [x][y]);
			// }
		// }
	}
	
	private function dfs (current:Node):Int
	{
		var sum:Int = 1;
		
		// for (near in allValidMoves [current.x][current.y])
		// {
			// if (near.parent != null) continue;
			
			// near.parent = current;
			// sum += dfs (near);
		// }
		
		// current.index = sum;
		return sum;
	}
	
	private function art (current:Node):Void//Int
	{
		current.visited = true;
		current.low = current.num = Node.ID ++;
		
		for (near in allValidMoves [current.x][current.y])
		{
			if (!near.visited)
			{
				near.parent = current;
				// current.index +=
				art (near);
				
				if (near.low >= current.num) current.isArticulation = true;
				// if (near.low >= current.num) current.index += 1;
				if (current.low > near.low) current.low = near.low;
			}
			else if (current.parent != near)
				if (current.low > near.num) current.low = near.num;
		}
		
		// return current.index;
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
				if (current.parent == null) continue;
				
				var blockCurrent:Block = canvas.getBlock (current.x, current.y);
				var blockParent:Block = canvas.getBlock (current.parent.x, current.parent.y);
				
				if (blockCurrent == null) continue;
				if (blockParent == null) continue;
				
				// if (current.index > 0) blockCurrent.text = current.index + "";
				// blockCurrent.text = current.num + "\n" + current.low;
				if (current.isArticulation)
					blockCurrent.color = 0xCCCCCC;
				
				cv.graphics.moveTo (blockCurrent.x, blockCurrent.y);
				cv.graphics.lineTo (blockParent.x, blockParent.y);
			}
		}
	}
}

class Node extends Position
{
	public static var ID:Int = 0;
	
	public var parent:Node = null;
	public var child:Node = null;
	public var index:Int = 0;
	public var low:Int = -1;
	public var num:Int = -1;
	public var visited:Bool = false;
	public var isArticulation:Bool = false;
	public var use:Bool = false;
}