package;

import flash.events.Event;
import flash.display.Sprite;

class AI6 extends Player
{
	public static inline var INIT:Int = 0;
	public static inline var COPY:Int = 1;
	public static inline var ATTACK:Int = 2;
	public static inline var CONFLICT:Int = 3;
	public static inline var FINAL:Int = 4;
	public var phrase:Int = 0;
	
	public var nodes:Array<Array<Node>>;
	public var firstMove:Bool = false;
	public var minManhattan:Int = 0;
	public var turnId:Int = 0;
	public var obstacle:Int = 0;
	public var available:Int = 0;
	
	override public function myTurn ():Int
	{
		var nextMove:Node = null;
		
		switch (phrase)
		{
			case INIT:
			init ();
			if (firstMove)
			{
				phrase = ATTACK;
			}
			else
			{
				phrase = COPY;
				nextMove = copy ();
			}

			case COPY:
			updateBoard ();
			nextMove = copy ();
			
			case ATTACK:
			updateBoard ();
			nextMove = attack ();
			
			case CONFLICT:
			updateBoard ();
			
			case FINAL:
			updateBoard ();
		}
		
		return direction (nextMove);
	}
	
	private function direction (node:Node):Int
	{
		if (node == null) return -1;
		
		var dir:Int = -1;
		if (this.x - 1 == node.x)			dir = Value.DIRECTION_LEFT;
		else if (this.x + 1 == node.x)		dir = Value.DIRECTION_RIGHT;
		else if (this.y - 1 == node.y)		dir = Value.DIRECTION_UP;
		else if (this.y + 1 == node.y)		dir = Value.DIRECTION_DOWN;
		
		return dir;
	}
	
	private function attack ():Node
	{
		return null;
	}
	
	private function evaluate_pos (my:Position, enemy:Position):Int
	{
		evaluateMark ++;
		
		var myValue:Int = 1;
		var myZone:Array<Position> = [my];
		
		var enemyValue:Int = 1;
		var enemyZone:Array<Position> = [enemy];
		
		var current:Position = null;
		var temp:Array<Position> = null;
		while (myZone.length != 0 || enemyZone.length != 0)
		{
			temp = [];
			while (myZone.length > 0)
			{
				current = myZone.pop ();
				for (move in allValidMoves [current.x][current.y])
				{
					if (board [move.x][move.y] == Value.BLOCK_EMPTY)
					if (evaluateData [move.x][move.y] != evaluateMark)
					{
						evaluateData [move.x][move.y] = evaluateMark;
						temp.push (move);
						myValue ++;
					}
				}
			}
			myZone = temp;

			temp = [];
			while (enemyZone.length > 0)
			{
				current = enemyZone.pop ();
				for (move in allValidMoves [current.x][current.y])
				{
					if (board [move.x][move.y] == Value.BLOCK_EMPTY)
					if (evaluateData [move.x][move.y] != evaluateMark)
					{
						evaluateData [move.x][move.y] = evaluateMark;
						temp.push (move);
						enemyValue ++;
					}
				}
			}
			enemyZone = temp;
		}
		
		return myValue - enemyValue;
	}
	
	private function negamax (my:Node, enemy:Node, depth:Int, a:Float, b:Float):Float
	{
		if (depth == 0 || my.connects.length == 0)
			return evaluate_pos (my, enemy);
		
		var bestMove:Node = null;
		for (move in my.connects)
		{
			if (move.use) continue;
			
			move.use = true;
			var score = -negamax (enemy, move, depth - 1, -b, -a);
			move.use = false;
			
			if (bestMove == null) bestMove = my;
			if (score > a)
			{
				a = score;
				bestMove = move;
				if (a >= b) break;
			}
		}
		
		nextMove = bestMove;
		return a;
	}
	
	private function copy ():Node
	{
		if (Math.abs (enemyPosition.x - myPosition.x) <= minManhattan
		&&	Math.abs (enemyPosition.y - myPosition.y) <= minManhattan)
			return attack ();
		
		if (nodes [Value.MAP_SIZE - enemyPosition.x - 1] != null)
			return nodes [Value.MAP_SIZE - enemyPosition.x - 1][Value.MAP_SIZE - enemyPosition.y - 1];
		
		return null;
	}
	
	private function updateBoard ():Void
	{
		for (x in 0 ... nodes.length)
		for (y in 0 ... nodes [x].length)
		for (node in nodes [x][y].connects)
			if (board [node.x][node.y] != Value.BLOCK_EMPTY)
				nodes [x][y].connects.remove (node);
				
		turnId += 2;
		available -= 2;
	}
	
	private function init ():Void
	{
		var index:Int = 0;
		
		nodes = [];
		for (x in 0 ... board.length)
		{
			nodes [x] = [];
			for (y in 0 ... board [x].length)
			{
				var node:Node = new Node (x, y);
				node.index = index ++;
				nodes [x][y] = node;
				
				switch (board [x][y])
				{
					case Value.BLOCK_OBSTACLE:	obstacle += 1;
					case Value.BLOCK_EMPTY:		available += 1;
				}
			}
		}
		
		firstMove = (index - obstacle - available) == 2;
		if (firstMove) turnId = 0;
		else
		{
			turnId = 1;
			minManhattan = (Value.MAP_SIZE % 2 != 0) ? 5 : 0;
		}
		
		for (x in 0 ... board.length)
		{
			for (y in 0 ... board [x].length)
			{
				var nears:Array<Node> = [];
				var connects:Array<Node> = [];
				
				if (x > 0)
				{
					if (board [x - 1][y] != Value.BLOCK_OBSTACLE) nears.push (nodes [x - 1][y]);
					if (board [x - 1][y] != Value.BLOCK_EMPTY) connects.push (nodes [x - 1][y]);
				}
				
				if (y > 0 && board [x][y - 1] == Value.BLOCK_EMPTY)
				{
					if (board [x][y - 1] != Value.BLOCK_OBSTACLE) nears.push (nodes [x][y - 1]);
					if (board [x][y - 1] != Value.BLOCK_EMPTY) connects.push (nodes [x][y - 1]);
				}
				
				if (x < Value.MAP_SIZE - 1 && board [x + 1][y] == Value.BLOCK_EMPTY)
				{
					if (board [x + 1][y] != Value.BLOCK_OBSTACLE) nears.push (nodes [x + 1][y]);
					if (board [x + 1][y] != Value.BLOCK_EMPTY) connects.push (nodes [x + 1][y]);
				}
				
				if (y < Value.MAP_SIZE - 1 && board [x][y + 1] == Value.BLOCK_EMPTY)
				{
					if (board [x][y + 1] != Value.BLOCK_OBSTACLE) nears.push (nodes [x][y + 1]);
					if (board [x][y + 1] != Value.BLOCK_EMPTY) connects.push (nodes [x][y + 1]);
				}
				
				var node:Node = nodes [x][y];
				node.nears = nears;
				node.connects = connects;
			}
		}
	}
}

class Node extends Position
{
	// public var x:Int;
	// public var y:Int;
	public var index:Int;
	
	public var nears:Array<Node>;
	public var connects:Array<Node>;
	
	public var use:Bool = false;
	public var component:Int;
	
	public function new (x:Int, y:Int)
	{
		super (x, y);
		// this.x = x;
		// this.y = y;
	}
}