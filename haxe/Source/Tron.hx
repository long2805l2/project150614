package;

class Tron extends Player
{
	private var evaluateData:Array<Array<Int>>;
	private var evaluateMark:Int;
	private var nextMove:Position;
	
	private var state:Int = DIVIDE;
	private static var DIVIDE = 0;
	private static var CONQUER = 1;
	
	private var turn:Int = 0;
	private var validBlock:Int = 0;
	
	override public function myTurn ():Int
	{
		if (allValidMoves == null)
		{
			evaluateData = [];
			for (x in 0 ... board.length)
			{
				evaluateData [x] = [];
				for (y in 0 ... board [x].length)
					evaluateData [x][y] = 0;
			}
			evaluateMark = 0;
			turn = 0;
		
			createVaildMoves ();
		}
		else updateVaildMoves ();
		
		nextMove = null;
		switch (state)
		{
			case Tron.DIVIDE:
			evaluate_map ();
			var score = negamax (myPosition, enemyPosition, 12, -1e6, 1e6);
			
			case Tron.CONQUER:
			var score = minimax (myPosition, 3, true);
		}
		
		var dir:Int = -1;
		if (this.x - 1 == nextMove.x)			dir = Value.DIRECTION_LEFT;
		else if (this.x + 1 == nextMove.x)		dir = Value.DIRECTION_RIGHT;
		else if (this.y - 1 == nextMove.y)		dir = Value.DIRECTION_UP;
		else if (this.y + 1 == nextMove.y)		dir = Value.DIRECTION_DOWN;
		
		return dir;
	}
	
	private function evaluate_map ():Void
	{
		turn ++;
		evaluateMark ++;
		var enemy:Int = board [enemyPosition.x][enemyPosition.y];
		board [enemyPosition.x][enemyPosition.y] = Value.BLOCK_EMPTY;
		
		var current:Position = null;
		var myZone:Array<Position> = [myPosition];
		var length:Int = -1;
		var temp:Array<Position> = [];
		
		validBlock = 0;
		while (myZone.length != 0)
		{
			length = myZone.length;
			for (id in 0 ... length)
			{
				current = myZone.pop ();
				if (board [current.x][current.y] == Value.BLOCK_OBSTACLE) continue;
				
				if (current.x > 0 && board [current.x - 1][current.y] == Value.BLOCK_EMPTY) 					temp.push (new Position (current.x - 1, current.y));
				if (current.y > 0 && board [current.x][current.y - 1] == Value.BLOCK_EMPTY) 					temp.push (new Position (current.x, current.y - 1));
				if (current.x < Value.MAP_SIZE - 1 && board [current.x + 1][current.y] == Value.BLOCK_EMPTY)	temp.push (new Position (current.x + 1, current.y));
				if (current.y < Value.MAP_SIZE - 1 && board [current.x][current.y + 1] == Value.BLOCK_EMPTY)	temp.push (new Position (current.x, current.y + 1));
				
				while (temp.length > 0)
				{
					current = temp.pop ();
					if (evaluateData [current.x][current.y] != evaluateMark)
					{
						evaluateData [current.x][current.y] = evaluateMark;
						myZone.push (current);
						validBlock ++;
					}
				}
			}
		}
		
		if (evaluateData [enemyPosition.x][enemyPosition.y] != evaluateMark)
			state = CONQUER;
		
		board [enemyPosition.x][enemyPosition.y] = enemy;
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
		
		// trace (my + " vs " + enemy + " >> " + (myValue - enemyValue));
		return myValue - enemyValue;
	}
	
	private function evaluate_waste (my:Position):Float
	{
		var allMark:Array<Int> = [];
		var total:Float = 0;
		var maxSize:Float = 0;
		for (move in allValidMoves [my.x][my.y])
		{
			if (board [move.x][move.y] != Value.BLOCK_EMPTY) continue;
			
			evaluateMark ++;
			if (allMark.indexOf (evaluateData [move.x][move.y]) != -1) continue;
			allMark.push (evaluateMark);
			
			var size:Int = 1;
			var length:Int = -1;
			var current:Position = null;
			var myZone:Array<Position> = [move];
			
			while (myZone.length != 0)
			{
				length = myZone.length;
				for (i in 0 ... length)
				{
					current = myZone.pop ();
					for (move in allValidMoves [current.x][current.y])
					{
						if (board [move.x][move.y] == Value.BLOCK_EMPTY)
						if (evaluateData [move.x][move.y] != evaluateMark)
						{
							evaluateData [move.x][move.y] = evaluateMark;
							myZone.push (move);
							size ++;
						}
					}
				}
			}
			
			maxSize = Math.max (maxSize, size);
			total += size;
		}
		
		if (total == 0) return 0;
		
		// return maxSize / total;
		return maxSize;
	}
	
	private function evaluate_my (my:Position):Float
	{
		var size:Int = 1;
		var length:Int = -1;
		var current:Position = null;
		var myZone:Array<Position> = [my];
		
		while (myZone.length != 0)
		{
			length = myZone.length;
			for (i in 0 ... length)
			{
				current = myZone.pop ();
				for (move in allValidMoves [current.x][current.y])
				{
					if (board [move.x][move.y] == Value.BLOCK_EMPTY)
					if (evaluateData [move.x][move.y] != evaluateMark)
					{
						evaluateData [move.x][move.y] = evaluateMark;
						myZone.push (move);
						size ++;
					}
				}
			}
		}
		
		return size;
	}
	
	private function negamax (my:Position, enemy:Position, depth:Int, a:Float, b:Float):Float
	{
		if (depth == 0) return evaluate_pos (my, enemy);
		
		var moves:Array<Position> = allValidMoves [my.x][my.y];
		var bestMove:Position = my;
		var isTerminal:Bool = true;
		for (move in moves)
		{
			if (board [move.x][move.y] != Value.BLOCK_EMPTY) continue;
			isTerminal = false;
			
			board [move.x][move.y] = Value.BLOCK_OBSTACLE;
			var score = -negamax (enemy, move, depth - 1, -b, -a);
			board [move.x][move.y] = Value.BLOCK_EMPTY;
			
			if (score > a)
			{
				a = score;
				bestMove = move;
				// if (a >= b) break;
			}
			else if (bestMove == my) bestMove = move;
		}
		
		nextMove = bestMove;
		
		if (isTerminal) return evaluate_pos (my, enemy);
		return a;
	}
	
	private function minimax (my:Position, depth:Int, a:Bool):Float
	{
		if (depth == 0) return evaluate_waste (my);
		
		var bestValue:Float = a ? -10000000 : 10000000;
		var bestMove:Position = my;
		var isTerminal:Bool = true;
		
		for (move in allValidMoves [my.x][my.y])
		{
			if (board [move.x][move.y] != Value.BLOCK_EMPTY) continue;
			isTerminal = false;
			
			board [move.x][move.y] = Value.BLOCK_OBSTACLE;
			var val:Float = 1 + minimax (move, depth - 1, a);
			board [move.x][move.y] = Value.BLOCK_EMPTY;
			
			if (a && bestValue < val)
			{
				bestValue = val;
				bestMove = move;
			}
			else if (!a && bestValue > val)
			{
				bestValue = val;
				bestMove = move;
			}
		}
		
		nextMove = bestMove;
		
		if (isTerminal) return evaluate_waste (my);
		return bestValue;
	}
	
	private var allValidMoves:Array<Array<Array<Position>>>;
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
	
	private function updateVaildMoves ():Void
	{
		var checkList:Array<Position> = [
			new Position (myPosition.x - 1, myPosition.y), new Position (myPosition.x + 1, myPosition.y),
			new Position (myPosition.x, myPosition.y - 1), new Position (myPosition.x, myPosition.y + 1), 
			new Position (enemyPosition.x - 1, enemyPosition.y), new Position (enemyPosition.x + 1, enemyPosition.y),
			new Position (enemyPosition.x, enemyPosition.y - 1), new Position (enemyPosition.x, enemyPosition.y + 1), 
		];
		
		for (block in checkList)
		{
			var x:Int = block.x;
			if (x < 0 || x > Value.MAP_SIZE - 1) continue;
			
			var y:Int = block.y;
			if (y < 0 || y > Value.MAP_SIZE - 1) continue;
			
			for (move in allValidMoves [x][y])
				if (board [move.x][move.y] != Value.BLOCK_EMPTY)
					allValidMoves [x][y].remove (move);
		}
	}
	
	override public function debug (canvas:Board):Void
	{
		trace ("debug: " + id);
		if (allValidMoves == null) createVaildMoves ();
		
		var data:Array<Array<Int>> = [];
		for (x in 0 ... board.length)
		{
			data [x] = [];
			for (y in 0 ... board [x].length)
				data [x][y] = (board [x][y] == Value.BLOCK_EMPTY) ? 0 : (-1000);
		}
		data [myPosition.x][myPosition.y] = 1000;
		data [enemyPosition.x][enemyPosition.y] = 2000;
		
		var myZone:Array<Position> = [myPosition];
		var enemyZone:Array<Position> = [enemyPosition];
		
		var myRound:Int = 1;
		var myValue:Int = 1;
		var enemyRound:Int = 1;
		var enemyValue:Int = 1;
		var current:Position = null;
		var temp:Array<Position> = null;
		while (myZone.length != 0 || enemyZone.length != 0)
		{
			temp = [];
			myRound ++;
			while (myZone.length > 0)
			{
				current = myZone.pop ();
				for (move in allValidMoves [current.x][current.y])
				{
					if (data [move.x][move.y] == 0)
					{
						data [move.x][move.y] = 1000 + myRound;
						temp.push (move);
						myValue ++;
					}
				}
			}
			myZone = temp;

			temp = [];
			enemyRound ++;
			while (enemyZone.length > 0)
			{
				current = enemyZone.pop ();
				for (move in allValidMoves [current.x][current.y])
				{
					if (data [move.x][move.y] == 0)
					{
						data [move.x][move.y] = 2000 + enemyRound;
						temp.push (move);
						enemyValue ++;
					}
				}
			}
			enemyZone = temp;
		}
		data [myPosition.x][myPosition.y] = myValue;
		data [enemyPosition.x][enemyPosition.y] = enemyValue;
		
		for (x in 0 ... data.length)
		{
			for (y in 0 ... data [x].length)
			{
				var color:Int = switch (Std.int (data [x][y] / 1000))
				{
					case 0:		0xFFFFFF;
					case 1:		0xFFCCCC;
					case 2:		0xCCFFCC;
					default:	0x000000;
				}
				
				canvas.block (x, y, color, "" + (data [x][y] % 1000));
			}
		}
	}
}