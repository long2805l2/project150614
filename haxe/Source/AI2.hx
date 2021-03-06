package;

class AI2 extends Player
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
		var p1dist:Array<Array<Int>> = floodfill (board, my);
		var p2dist:Array<Array<Int>> = floodfill (board, enemy);
		
		var score:Int = 0;
		for (x in 0 ... board.length)
		{
			for (y in 0 ... board [x].length)
			{
				if (board [x][y] != Value.BLOCK_EMPTY) continue;
				
				if (p2dist [x][y] < 1) {
					if (p1dist [x][y] > 1) score ++;
					continue;
				}
				
				if (p1dist [x][y] < 1) {
					if (p2dist [x][y] > 1) score --;
					continue;
				}
				
				var d = p1dist [x][y] - p2dist [x][y];
				if (d > 0) score --;
				else if (d < 0) score ++;
			}
		}
		
		return score;
	}
	
	private var nextMove:Position;
	private function negamax (my:Position, enemy:Position, depth:Int, a:Float, b:Float):Float
	{
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
	
	override public function debug (canvas:Board):Void
	{
		trace ("debug: " + id);
	}
}