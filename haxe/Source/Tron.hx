package;

class Tron extends Player
{
	override public function myTurn ():Int
	{
		if (allValidMoves == null) createVaildMoves ();
		
		nextMove = null;
		var score = negamax (myPosition, enemyPosition, 10, -1e6, 1e6);
		// if (nextMove == null)
		
		var dir:Int = -1;
		if (this.x - 1 == nextMove.x)			dir = Value.DIRECTION_LEFT;
		else if (this.x + 1 == nextMove.x)		dir = Value.DIRECTION_RIGHT;
		else if (this.y - 1 == nextMove.y)		dir = Value.DIRECTION_UP;
		else if (this.y + 1 == nextMove.y)		dir = Value.DIRECTION_DOWN;
		
		return dir;
	}
	
	private function evaluate_pos (my:Position, enemy:Position):Int
	{
		var data:Array<Array<Int>> = [];
		for (x in 0 ... board.length)
		{
			data [x] = [];
			for (y in 0 ... board [x].length)
				data [x][y] = (board [x][y] == Value.BLOCK_EMPTY) ? 0 : -1;
		}
		
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
					if (data [move.x][move.y] == 0)
					{
						data [move.x][move.y] = -1;
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
					if (data [move.x][move.y] == 0)
					{
						data [move.x][move.y] = -1;
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
	
	private var nextMove:Position;
	private function negamax (my:Position, enemy:Position, depth:Int, a:Float, b:Float):Float
	{
		// trace ("negamax [" + depth + "]: " + my + " vs " + enemy + " / " + a + " / " + b);
		if (depth == 0)
		{
			nextMove = my;
			return evaluate_pos (my, enemy);
		}
		
		var moves:Array<Position> = allValidMoves [my.x][my.y];
		var bestMove:Position = my;
		
		for (move in moves)
		{
			if (board [move.x][move.y] != Value.BLOCK_EMPTY) continue;
			
			board [move.x][move.y] = Value.BLOCK_OBSTACLE;
			var score = -negamax (enemy, move, depth - 1, -b, -a);
			board [move.x][move.y] = Value.BLOCK_EMPTY;
			
			// trace ("move: " + move + " >> " + score);
			if (score > a)
			{
				a = score;
				bestMove = move;
				if (a >= b) break;
			}
			else if (bestMove == my) bestMove = move;
		}
		
		nextMove = bestMove;
		// trace ("bestMove: " + bestMove);
		// if (bestMove == my) return b;
		return a;
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