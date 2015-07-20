package;

import flash.events.Event;
import flash.display.Sprite;

class AI7 extends Player
{
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
		if (nodes == null) init ();
		
		var nextMove:Node = null;
		
		updateBoard ();
		nextMove = attack ();

		if (nextMove == null) return -1;
		
		var dir:Int = -1;
		if (this.x - 1 == nextMove.x)			dir = Value.DIRECTION_LEFT;
		else if (this.x + 1 == nextMove.x)		dir = Value.DIRECTION_RIGHT;
		else if (this.y - 1 == nextMove.y)		dir = Value.DIRECTION_UP;
		else if (this.y + 1 == nextMove.y)		dir = Value.DIRECTION_DOWN;
		
		return dir;
	}
	
	private function attack ():Node
	{
		if (isFinal ()) return final ();
		
		nextMove = null;
		
		var deep:Int = 12;
		
		nodes [myPosition.x][myPosition.y].use = true;
		nodes [enemyPosition.x][enemyPosition.y].use = true;
		negamax (nodes [myPosition.x][myPosition.y], nodes [enemyPosition.x][enemyPosition.y], deep, -1e6, 1e6);
		nodes [enemyPosition.x][enemyPosition.y].use = false;
		nodes [myPosition.x][myPosition.y].use = false;
		
		return nextMove;
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
	
		for (myMove in my.connects)
		{
			if (myMove.use) continue;
			myMove.use = true;
			for (enemyMove in enemy.connects)
			{
				enemyMove.use = true;
				var v:Float = negamax (myMove, enemyMove, depth - 2, a, b);
				enemyMove.use = false;
			}
			myMove.use = false;
		}
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