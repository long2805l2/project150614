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
		
		Node.ID = 0;
		art (nodes [x][y]);
		// chamber (art (nodes [x][y]));
		room ();
	}
	
	private function chamber (gateways:Array<Node>):Void
	{
		var currentColor:Int = 1;
		gateways.sort (function (a:Node, b:Node):Int
		{
			if (a.num > b.num) return 1;
			if (a.num < b.num) return -1;
			return 0;
		});
		for (gateway in gateways) gateway.index = gateway.color = currentColor ++;
		
		currentColor = 1;
		for (gateway in gateways)
		{
			for (node in allValidMoves [gateway.x][gateway.y])
			{
				if (node.color > 0) continue;
				node.size = floodFill (node, currentColor);
				
				currentColor ++;
			}
		}
	}
	
	private function floodFill (start:Node, color:Int):Int
	{
		var queue:Array<Node> = [start];
		var current:Node = null;
		var length:Int = queue.length;
		var size:Int = 1;
		
		start.color = color;
		while (queue.length > 0)
		{
			for (index in 0 ... length)
			{
				current = queue.shift ();
				for (near in allValidMoves [current.x][current.y])
				{
					if (near.color > 0) continue;
					near.color = color;
					queue.push (near);
					size += 1;
				}
			}
			length = queue.length;
		}
		
		return size;
	}
	
	private function refill (start:Node, newColor:Int):Void
	{
		var queue:Array<Node> = [start];
		var current:Node = null;
		var length:Int = queue.length;
		
		var oldColor:Int = start.color;
		start.color = newColor;
		while (queue.length > 0)
		{
			for (index in 0 ... length)
			{
				current = queue.shift ();
				for (near in allValidMoves [current.x][current.y])
				{
					if (near.color != oldColor) continue;
					near.color = newColor;
					queue.push (near);
				}
			}
			length = queue.length;
		}
	}
	
	private function art (current:Node):Array<Node>
	{
		current.visited = true;
		current.low = current.num = Node.ID ++;
		var arts:Array<Node> = [];
		
		for (near in allValidMoves [current.x][current.y])
		{
			if (!near.visited)
			{
				near.parent = current;
				// current.index +=
				var a:Array<Node> = art (near);
				for (n in a) arts.push (n);
				
				if (near.low >= current.num)
				{
					current.isArticulation = true;
					arts.push (current);
				}
				
				if (near.low < current.low) current.low = near.low;
			}
			else if (current.parent != near)
				if (current.low > near.num) current.low = near.num;
		}
		
		return arts;
	}
	
	private function room ():Void
	{
		var nextclass:Int = 1;
		
		for (y in 0 ... Value.MAP_SIZE)
		{
			for (x in 0 ... Value.MAP_SIZE)
			{
				if (board [x][y] != Value.BLOCK_EMPTY) continue;
				
				var current:Node = nodes [x][y];
				var top:Int = y > 0 ? nodes [x][y - 1].color : 0;
				var left:Int = x > 0 ? nodes [x - 1][y].color : 0;
				
				if (top < 1 && left < 1) // new component
				{
					current.color = nextclass ++;
				}
				else if (top == left) // existing component
				{
					current.color = top;
				}
				else // join components
				{
					// deprecate the higher-numbered component in favor of the lower
					if(left < 1 || (top > 0 && top < left))
					{
						current.color = top;
						// if (left > 0) refill (nodes [x - 1][y], top);
					}
					else
					{
						current.color = left;
						// if (top > 0) refill (nodes [x][y - 1], left);
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
				if (x > 0 && board [x - 1][y] == Value.BLOCK_EMPTY) 					allValidMoves [x][y].push (nodes [x - 1][y]);
				if (y > 0 && board [x][y - 1] == Value.BLOCK_EMPTY) 					allValidMoves [x][y].push (nodes [x][y - 1]);
				if (x < Value.MAP_SIZE - 1 && board [x + 1][y] == Value.BLOCK_EMPTY)	allValidMoves [x][y].push (nodes [x + 1][y]);
				if (y < Value.MAP_SIZE - 1 && board [x][y + 1] == Value.BLOCK_EMPTY)	allValidMoves [x][y].push (nodes [x][y + 1]);
			}
		}
	}
	
	private function isOpen (n:Int, min:Int, max:Int):Bool
	{
		var i:Int = min;
		while (i <= max)
		{
			if (n & (1 << (i & 7)) != 0) return false;
			i ++;
		}
		return true;
	}
	
	private function potential_articulation (n:Int):Int
	{
		var i:Int = 1;
		while (i < 7)
		{
			if (n & (1 << i) != 0) continue;
			
			var j:Int = i + 2;
			while (j <= 7)
			{
				if (n & (1 << j) != 0)
				{
					j += 2;
					continue;
				}
				
				if (!is_open (n, i + 1, j - 1) && !is_open (n, j + 1, i + 7))
					return 1;
				
				j += 2;
			}
			i += 2;
		}
		return 0;
	}
	
	int main()
	{
		for(int n=0;n<256;n++)
			potential_articulation(n));
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
				// if (current.parent == null) continue;
				
				var blockCurrent:Block = canvas.getBlock (current.x, current.y);
				// var blockParent:Block = canvas.getBlock (current.parent.x, current.parent.y);
				
				if (blockCurrent == null) continue;
				// if (blockParent == null) continue;
				
				// if (current.parent.isArticulation)
				// {
					// blockCurrent.text = current.size + "";
					// blockCurrent.color = 0xEEEEEE;
				// }
				// else if (current.isArticulation)
					// blockCurrent.color = 0xBBBBBB;				
				// else
				if (current.color > 0)
					blockCurrent.text = current.color + "";
				
				// cv.graphics.moveTo (blockCurrent.x, blockCurrent.y);
				// cv.graphics.lineTo (blockParent.x, blockParent.y);
				
				// if (board [x][y] == Value.BLOCK_EMPTY)
				// {
					// if ((current.x ^ current.y) & 1 == 1)
						// blockCurrent.color = 0xFF5555;
					// else
						// blockCurrent.color = 0x555555;
				// }
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
	public var size:Int = 0;
	public var color:Int = 0;
	public var low:Int = -1;
	public var num:Int = -1;
	public var visited:Bool = false;
	public var isArticulation:Bool = false;
	public var use:Bool = false;
}