package;

import flash.events.Event;
import flash.display.Sprite;

class AI4 extends Player
{
	private var allValidMoves:Array<Array<Array<Position>>>;
	private var nodes:Array<Array<Position>>;
	private var commands:Array<String>;
	private var backup:Array<Position>;
	private var path:Array<Position>;
	
	override public function myTurn ():Int
	{
		if (allValidMoves == null)
		{
			commands = [];
			backup = [];
			path = [];
			
			createVaildMoves ();
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
				nodes [x][y] = null;
		}
		
		bfs (nodes, myPosition);
	}
	
	private function dfs (data:Array<Array<Position>>, current:Position):Void
	{
		for (near in allValidMoves [current.x][current.y])
		{
			if (board [near.x][near.y] != Value.BLOCK_EMPTY) continue;
			if (data [near.x][near.y] == null)
			{
				data [near.x][near.y] = current;
				dfs (data, near);
			}
		}
	}
	
	private function bfs (data:Array<Array<Position>>, current:Position):Void
	{
		var queue:Array<Position> = [current];
		var length:Int = -1;
		
		trace ("bfs");
		while (queue.length != 0)
		{
			length = queue.length;
			trace ("length: " + length);
			for (id in 0 ... length)
			{
				current = queue.pop ();
				for (near in allValidMoves [current.x][current.y])
				{
					if (board [near.x][near.y] != Value.BLOCK_EMPTY) continue;
					if (data [near.x][near.y] == null)
					{
						data [near.x][near.y] = current;
						queue.push (near);
					}
				}
			}
		}
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
				if (x > 0 && board [x - 1][y] == Value.BLOCK_EMPTY) 					allValidMoves [x][y].push (new Position (x - 1, y));
				if (y > 0 && board [x][y - 1] == Value.BLOCK_EMPTY) 					allValidMoves [x][y].push (new Position (x, y - 1));
				if (x < Value.MAP_SIZE - 1 && board [x + 1][y] == Value.BLOCK_EMPTY)	allValidMoves [x][y].push (new Position (x + 1, y));
				if (y < Value.MAP_SIZE - 1 && board [x][y + 1] == Value.BLOCK_EMPTY)	allValidMoves [x][y].push (new Position (x, y + 1));
			}
		}
	}
	
	override public function debug (canvas:Board):Void
	{
		var cv:Sprite = canvas.canvas1;
		cv.graphics.clear ();
		cv.graphics.lineStyle (2, 0x000000, 1);
		
		for (x in 0 ... board.length)
		{
			for (y in 0 ... board [x].length)
			{
				var parent:Position = nodes [x][y];
				if (parent == null) continue;
				
				var blockParent:Block = canvas.getBlock (parent.x, parent.y);
				var blockNode:Block = canvas.getBlock (x, y);
				
				if (blockParent == null || blockNode == null) continue;
				cv.graphics.moveTo (blockParent.x, blockParent.y);
				cv.graphics.lineTo (blockNode.x, blockNode.y);
			}
		}
	}
}