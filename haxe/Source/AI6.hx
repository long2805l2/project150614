package;

import flash.events.Event;
import flash.display.Sprite;

class AI6 extends Player
{
	public static inline var INIT:Int = 0;
	public static inline var COPY:Int = 1;
	public static inline var CENTER:Int = 2;
	public static inline var ATTACK:Int = 3;
	public static inline var CONFLICT:Int = 4;
	public static inline var FINAL:Int = 5;
	public var phrase:Int = 0;
	
	public var nodes:Array<Array<Node>>;
	public var firstMove:Bool = false;
	public var minManhattan:Int = 0;
	public var centerNode:Node = null;
	public var turnId:Int = 0;
	public var obstacle:Int = 0;
	public var available:Int = 0;
	
	public var nextMove:Node = null;
	
	override public function myTurn ():Int
	{
		var nextMove:Node = null;
		
		// trace ("turn: " + turnId + "/" + phrase);
		switch (phrase)
		{
			case INIT:
			init ();
			if (firstMove)
			{
				if (centerNode != null)
				{
					phrase = CENTER;
					nextMove = center ();
				}
				else
				{
					phrase = ATTACK;
					nextMove = attack ();
				}
			}
			else
			{
				phrase = COPY;
				nextMove = copy ();
			}

			case COPY:
			updateBoard ();
			nextMove = copy ();

			case CENTER:
			updateBoard ();
			nextMove = center ();
			
			case ATTACK:
			updateBoard ();
			nextMove = attack ();
			
			case CONFLICT:
			updateBoard ();
			
			case FINAL:
			updateBoard ();
			nextMove = final ();
		}
		
		if (nextMove == null) return -1;
		
		var dir:Int = -1;
		if (this.x - 1 == nextMove.x)			dir = Value.DIRECTION_LEFT;
		else if (this.x + 1 == nextMove.x)		dir = Value.DIRECTION_RIGHT;
		else if (this.y - 1 == nextMove.y)		dir = Value.DIRECTION_UP;
		else if (this.y + 1 == nextMove.y)		dir = Value.DIRECTION_DOWN;
		
		return dir;
	}
	
	private function final ():Node
	{
		return null;
	}
	
	private function attack ():Node
	{
		if (isFinal ()) return final ();
		
		nextMove = null;
		
		var deep:Int = available;
		// if (deep > 12)
			deep = 12;
		// trace ("	" + nodes [myPosition.x][myPosition.y].connects);
		// trace ("	" + nodes [enemyPosition.x][enemyPosition.y].connects);
		
		nodes [myPosition.x][myPosition.y].use = true;
		nodes [enemyPosition.x][enemyPosition.y].use = true;
		negamax (nodes [myPosition.x][myPosition.y], nodes [enemyPosition.x][enemyPosition.y], deep, -1e6, 1e6);
		nodes [enemyPosition.x][enemyPosition.y].use = false;
		nodes [myPosition.x][myPosition.y].use = false;
		
		// trace ("turn: " + turnId + " move: " + nextMove + " << " + nodes [myPosition.x][myPosition.y].connects);
		return nextMove;
	}
	
	private function isFinal ():Bool
	{
		return false;
	}
	
	private function evaluate_pos (my:Node, enemy:Node):Int
	{
		var myQueue:Array<Node> = [my];
		var enemyQueue:Array<Node> = [enemy];
		var sign:Array<Int> = [];
		
		var current:Node = null;
		var length:Int = 0;
		var score:Int = 0;
		
		while (myQueue.length > 0 || enemyQueue.length > 0)
		{
			length = myQueue.length;
			for (i in 0 ... length)
			{
				current = myQueue.pop ();
				for (move in current.connects)
				{
					if (move.use) continue;
					if (sign [move.index] > 0) continue;
					
					sign [move.index] = 1;
					score += 1;
					myQueue.push (move);
				}
			}

			length = enemyQueue.length;
			for (i in 0 ... length)
			{
				current = enemyQueue.pop ();
				for (move in current.connects)
				{
					if (move.use) continue;
					if (sign [move.index] > 0) continue;
					
					sign [move.index] = 2;
					score -= 1;
					enemyQueue.push (move);
				}
			}
		}
		
		return score;
	}
	
	private function negamax (my:Node, enemy:Node, depth:Int, a:Float, b:Float, path:String = ""):Float
	{
		if (depth == 0) return evaluate_pos (my, enemy);
		
		var bestMove:Node = my;
		var isTerminal:Bool = true;
		for (move in my.connects)
		{
			if (move.use) continue;
			isTerminal = false;
			
			move.use = true;
			var score = -negamax (enemy, move, depth - 1, -b, -a);
			move.use = false;
			
			if (score > a)
			{
				a = score;
				bestMove = move;
				if (a >= b) break;
			}
			else if (bestMove == my) bestMove = move;
		}
		
		nextMove = bestMove;
		
		if (isTerminal) return evaluate_pos (my, enemy);
		return a;
	}
	
	private function copy ():Node
	{
		if (Math.abs (enemyPosition.x - myPosition.x) <= minManhattan
		&&	Math.abs (enemyPosition.y - myPosition.y) <= minManhattan)
		{
			phrase = ATTACK;
			return attack ();
		}
		
		if (nodes [Value.MAP_SIZE - enemyPosition.x - 1] == null)
		{
			phrase = ATTACK;
			return attack ();
		}
		
		return nodes [Value.MAP_SIZE - enemyPosition.x - 1][Value.MAP_SIZE - enemyPosition.y - 1];
	}
	
	private function center ():Node
	{
		return null;
	}
	
	private var oldMy:Node;
	private var oldEnemy:Node;
	private function updateBoard ():Void
	{
		var current:Node = nodes [myPosition.x][myPosition.y];
		for (node in current.connects) node.connects.remove (current);
		
		if (oldMy != null) while (oldMy.connects.length > 0) oldMy.connects.pop ();
		oldMy = current;
		
		current = nodes [enemyPosition.x][enemyPosition.y];
		for (node in current.connects) node.connects.remove (current);
		
		if (oldEnemy != null) while (oldEnemy.connects.length > 0) oldEnemy.connects.pop ();
		oldEnemy = current;
		
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
			if (Value.MAP_SIZE % 2 != 0)
			{
				var centerX:Int = (Value.MAP_SIZE - 1) >> 1;
				var centerY:Int = (Value.MAP_SIZE - 1) >> 1;
				centerNode = nodes [centerX][centerY];
				
				if (board [centerX][centerY] == Value.BLOCK_EMPTY)
				{
					if (board [centerX - 1][centerY] == Value.BLOCK_EMPTY
					&&	board [centerX][centerY - 1] == Value.BLOCK_EMPTY)
						minManhattan =  5;
				}
			}
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
					if (board [x - 1][y] == Value.BLOCK_EMPTY) connects.push (nodes [x - 1][y]);
				}
				
				if (y > 0 && board [x][y - 1] == Value.BLOCK_EMPTY)
				{
					if (board [x][y - 1] != Value.BLOCK_OBSTACLE) nears.push (nodes [x][y - 1]);
					if (board [x][y - 1] == Value.BLOCK_EMPTY) connects.push (nodes [x][y - 1]);
				}
				
				if (x < Value.MAP_SIZE - 1 && board [x + 1][y] == Value.BLOCK_EMPTY)
				{
					if (board [x + 1][y] != Value.BLOCK_OBSTACLE) nears.push (nodes [x + 1][y]);
					if (board [x + 1][y] == Value.BLOCK_EMPTY) connects.push (nodes [x + 1][y]);
				}
				
				if (y < Value.MAP_SIZE - 1 && board [x][y + 1] == Value.BLOCK_EMPTY)
				{
					if (board [x][y + 1] != Value.BLOCK_OBSTACLE) nears.push (nodes [x][y + 1]);
					if (board [x][y + 1] == Value.BLOCK_EMPTY) connects.push (nodes [x][y + 1]);
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