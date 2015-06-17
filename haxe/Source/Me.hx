package;

class Me extends Player
{
	public var AI:Int;
	
	public function new (id:Int, AI:Int = 2)
	{
		super (id);
		this.AI = AI;
	}
	
	override private function clone ():Void
	{
		super.clone ();
		
		zone [this.x][this.y] = 0;
		
		// if (Value.enemyPosition.x > 0 && zone [Value.enemyPosition.x - 1][Value.enemyPosition.y] == 0)
			// zone [Value.enemyPosition.x - 1][Value.enemyPosition.y] = -1;
			
		// if (Value.enemyPosition.y > 0 && zone [Value.enemyPosition.x][Value.enemyPosition.y - 1] == 0)
			// zone [Value.enemyPosition.x][Value.enemyPosition.y - 1] = -1;
			
		// if (Value.enemyPosition.x < Value.MAP_SIZE - 1 && zone [Value.enemyPosition.x + 1][Value.enemyPosition.y] == 0)
			// zone [Value.enemyPosition.x + 1][Value.enemyPosition.y] = -1;
			
		// if (Value.enemyPosition.y < Value.MAP_SIZE - 1 && zone [Value.enemyPosition.x][Value.enemyPosition.y + 1] == 0)
			// zone [Value.enemyPosition.x][Value.enemyPosition.y + 1] = -1;
	}
	
	override public function move ():Void
	{
		clone ();
		
		var dir:Int = switch (AI)
		{
			case 1:		AI_1 ();
			case 2:		AI_2 ();
			default:	AI_0 ();
		}
		
		command (dir);
	}
	
	private function AI_0 ():Int
	{
		var suitableDir:Array<Int> = suitable (x, y, zone);
		var selection:Int = Std.random (suitableDir.length);
		return suitableDir[selection];
	}
	
	private function AI_1 ():Int
	{
		var func = null;
		func = function (data:Array<Array<Int>>, x:Int, y:Int, move:Int)
		{
			if (data [x][y] != 0 && data [x][y] < move) return;
			
			data [x][y] = move;
			
			if (x > 0) func (data, x - 1, y, move + 1);
			if (y > 0) func (data, x, y - 1, move + 1);
			if (x < Value.MAP_SIZE - 1) func (data, x + 1, y, move + 1);
			if (y < Value.MAP_SIZE - 1) func (data, x, y + 1, move + 1);
		};
		func (this.zone, this.x, this.y, 1);
		
		var max:Int = -1;
		var maxX:Int = -1;
		var maxY:Int = -1;
		for (x in 0 ... Value.MAP_SIZE) for (y in 0 ... Value.MAP_SIZE)
			if (zone [x][y] > max) { max = zone [x][y]; maxX = x; maxY = y; }
		
		func = function (data:Array<Array<Int>>, x:Int, y:Int, move:Int)
		{
			if (move == 1) { maxX = x; maxY = y; return; }
	
			var suitableDir = [];
			if (x > 0 && data [x - 1][y] == move) 					suitableDir.push (Value.DIRECTION_LEFT);
			if (y > 0 && data [x][y - 1] == move) 					suitableDir.push (Value.DIRECTION_UP);
			if (x < Value.MAP_SIZE - 1 && data [x + 1][y] == move)	suitableDir.push (Value.DIRECTION_RIGHT);
			if (y < Value.MAP_SIZE - 1 && data [x][y + 1] == move)	suitableDir.push (Value.DIRECTION_DOWN);
			
			var selection = Std.random (suitableDir.length);
			var dir = suitableDir[selection];
			
			trace ("suitableDir: " + suitableDir + " >> " + dir);
			
			if (dir == Value.DIRECTION_LEFT)			func (data, x - 1, y, move - 1);
			else if (dir == Value.DIRECTION_UP)			func (data, x, y - 1, move - 1);
			else if (dir == Value.DIRECTION_RIGHT)		func (data, x + 1, y, move - 1);
			else if (dir == Value.DIRECTION_DOWN)		func (data, x, y + 1, move - 1);
		};
		
		func (this.zone, maxX, maxY, max - 1);
		
		var dir:Int = -1;
		if (this.x - 1 == maxX)				dir = Value.DIRECTION_LEFT;
		else if (this.x + 1 == maxX)		dir = Value.DIRECTION_RIGHT;
		else if (this.y - 1 == maxY)		dir = Value.DIRECTION_UP;
		else if (this.y + 1 == maxY)		dir = Value.DIRECTION_DOWN;
		
		trace ("" + dir);
		return dir;
	}
	
	private var moves:Array<Position> = null;
	private function AI_2 ():Int
	{
		var validMoves = function (map:Array<Array<Int>>, x:Int, y:Int):Array<Position>
		{
			var list:Array<Position> = [];
			if (x > 0 && map [x - 1][y] == 0) 					list.push (new Position (x - 1, y));
			if (y > 0 && map [x][y - 1] == 0) 					list.push (new Position (x, y - 1));
			if (x < Value.MAP_SIZE - 1 && map [x + 1][y] == 0)	list.push (new Position (x + 1, y));
			if (y < Value.MAP_SIZE - 1 && map [x][y + 1] == 0)	list.push (new Position (x, y + 1));
			return list;
		};
		
		// if (moves == null)
		// {
			var queue:Array<Position> = validMoves (zone, Value.myPosition.x, Value.myPosition.y);
			
			var moves:Array<Position> = [];
			while (queue.length > 0)
			{
				// trace ("");
				var move:Position = queue.pop ();
				var listMove:Array<Position> = validMoves (zone, move.x, move.y);
				// trace ("current: " + move + " >> " + listMove);
				if (listMove.length > 0)
				{
					for (m in listMove) queue.push (m);
					moves.push (move);
					zone [move.x][move.y] = moves.length;
					// trace ("queue " + queue);
					// trace ("go " + move);
				}
				else if (moves.length > 0)
				{
					var oldMove:Position = moves.pop ();
					// trace ("back " + oldMove);
					zone [oldMove.x][oldMove.y] = 0;
				}
				
				// if (moves.length == 7) break;
			}

			// trace ("moves: " + moves);
			// moves.shift ();
		// }
		
		if (moves.length == 0) return -1;
		var currentMove:Position = moves.shift ();
		
		var dir:Int = -1;
		if (this.x - 1 >= currentMove.x)			dir = Value.DIRECTION_LEFT;
		else if (this.x + 1 <= currentMove.x)		dir = Value.DIRECTION_RIGHT;
		else if (this.y - 1 >= currentMove.y)		dir = Value.DIRECTION_UP;
		else if (this.y + 1 <= currentMove.y)		dir = Value.DIRECTION_DOWN;
		
		trace ("my: " + Value.myPosition + " >> " + currentMove + " >> " + dir);
		return dir;
	}
}