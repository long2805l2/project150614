package;

import flash.events.Event;

class AI3 extends Player
{
	override public function myTurn ():Int
	{
		if (allValidMoves == null)
		{
			createVaildMoves ();
			calculator ();
		}
		
		return 0;
	}

	private var commands:Array<String>;
	private var backup:Array<Position>;
	private var path:Array<Position>;
	private function calculator ():Void
	{
		commands = [];
		backup = [];
		path = [];
		
		var data:Array<Array<Int>> = [];
		for (x in 0 ... board.length)
		{
			data [x] = [];
			for (y in 0 ... board [x].length)
				data [x][y] = (board [x][y] == Value.BLOCK_EMPTY) ? 0 : -1;
		}
		
		backtracing (data, myPosition, 1);
	}
	
	private function backtracing (map:Array<Array<Int>>, current:Position, moveId:Int):Void
	{
		// for (move in allValidMoves [current.x][current.y])
		// {
			// if (map [move.x][move.y] != 0) continue;
			// map [move.x][move.y] = moveId;
			// commands.push ("move;" + move.x + ";" + move.y);
			// backtracing (map, move, moveId + 1);
			// map [move.x][move.y] = 0;
			// commands.push ("back;" + move.x + ";" + move.y);
		// }
		
		var stack:Array<Dynamic> = [{p:current, m:moveId, go:true}];
		var temp:Dynamic = null;
		while (stack.length > 0)
		{
			temp = stack [stack.length - 1];
			if (!temp.go)
			{
				if (path.length < backup.length)
				{
					path = [];
					for (move in backup) path.push (move);
				}
				
				stack.pop ();
				backup.pop ();
				map [temp.p.x][temp.p.y] = 0;
				continue;
			}
			
			temp.go = false;
			map [temp.p.x][temp.p.y] = temp.m;
			backup.push (temp.p);
			
			for (move in allValidMoves [temp.p.x][temp.p.y])
			{
				if (map [move.x][move.y] != 0) continue;
				stack.push ({p:move, m:temp.m + 1, go:true});
			}
		}
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
		var timer:Int = Value.TURN_TIME;
		var showPath = null;
		
		showPath = function (e:Event):Void
		{
			if (timer-- > 0) return;
			timer = Value.TURN_TIME;
			
			if (path.length == 0)
			{
				canvas.removeEventListener (Event.ENTER_FRAME, showPath);
				return;
			}
			
			var current:Position = path.shift ();
			canvas.block (current.x, current.y, Value.BLOCK_PLAYER_1, "" + path.length);
		};
		
		canvas.addEventListener (Event.ENTER_FRAME, showPath);
	}
}