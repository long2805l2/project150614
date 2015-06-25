package;

class Tron extends Player
{
	override public function myTurn ():Int
	{
		if (allValidMoves == null) createVaildMoves ();
		
		nextMove = null;
		var score = negamax (myPosition, enemyPosition, 10, -1e6, 1e6);
		if (nextMove == null) return 0;
		
		var dir:Int = -1;
		if (this.x - 1 == nextMove.x)			dir = Value.DIRECTION_LEFT;
		else if (this.x + 1 == nextMove.x)		dir = Value.DIRECTION_RIGHT;
		else if (this.y - 1 == nextMove.y)		dir = Value.DIRECTION_UP;
		else if (this.y + 1 == nextMove.y)		dir = Value.DIRECTION_DOWN;
		
		return dir;
	}

	public function floodfill (map:Array<Array<Int>>, current:Position):Array<Array<Int>>
	{
		var q:Array<Position> = [current];
		var q2:Array<Position> = [];
		var dist:Int = 1;

		var data:Array<Array<Int>> = [];
		for (x in 0 ... map.length)
		{
			data [x] = [];
			for (y in 0 ... map [x].length)
				data [x][y] = (map [x][y] == Value.BLOCK_EMPTY) ? 0 : -1;
		}
		
		data [current.x][current.y] = 1;
		while (q.length > 0)
		{
			dist++;
			for (position in q)
			{
				var validMoves:Array<Position> = allValidMoves [position.x][position.y];
				for (move in validMoves)
				{
					if (data [move.x][move.y] != 0) continue;
					data [move.x][move.y] = dist;
					q2.push (move);
				}
			}
			q = q2; q2 = [];
		}
		return data;
	}
	
	private function evaluate_pos (my:Position, enemy:Position):Int
	{
		// trace ("evaluate_pos");
		var p1dist:Array<Array<Int>> = floodfill (board, my);
		var p2dist:Array<Array<Int>> = floodfill (board, enemy);
		
		var score:Int = 0;
		// var p1score:Int = 0;
		// var	p2score:Int = 0;
		for (x in 0 ... board.length)
		{
			for (y in 0 ... board [x].length)
			{
				if (board [x][y] != Value.BLOCK_EMPTY) continue;
				
				if (p2dist [x][y] < 1) {
					if (p1dist [x][y] > 1)
					// {
						// p1score ++;
						score ++;
					// }
					continue;
				}
				
				if (p1dist [x][y] < 1) {
					if (p2dist [x][y] > 1)
					// {
						// p2score ++;
						score --;
					// }
					continue;
				}
				
				var d = p1dist [x][y] - p2dist [x][y];
				if (d > 0)
				// {
					// p2score ++;
					score --;
				// }
				else if (d < 0)
				// {
					// p1score ++;
					score ++;
				// }
			}
		}
		
		// trace (id + " evaluate_pos: " + score + " >> " + p1score + "/" + p2score);
		return score;
	}
	
	private var nextMove:Position;
	private function negamax (my:Position, enemy:Position, depth:Int, a:Float, b:Float):Float
	{
		// trace ("negamax: " + my + " >> " + depth);
		if (depth == 0) return evaluate_pos (my, enemy);
		
		var moves:Array<Position> = allValidMoves [my.x][my.y];
		var bestMove:Position = my;
		for (move in moves)
		{
			if (board [move.x][move.y] != Value.BLOCK_EMPTY) continue;
			
			board [move.x][move.y] = Value.BLOCK_OBSTACLE;
			var score = -negamax (enemy, move, depth - 1, -b, -a);
			board [move.x][move.y] = Value.BLOCK_EMPTY;
			
			if (score > a)
			{
				a = score;
				bestMove = move;
				if(a >= b) break;
			}
		}
		
		nextMove = bestMove;
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
	
	override function debug (canvas:Board):Void
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