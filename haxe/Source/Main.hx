package;

import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.display.Sprite;
import openfl.display.DisplayObject;

class Main extends Sprite
{
	public static var turn:Int = -1;
	public static var gameState:Int = -1;
	
	public static var board:Board = null;
	public static var player1:Player = null;
	public static var player2:Player = null;
	
	public function new ()
	{
		super ();
		
		player1 = new Me (1);
		Value.myPosition = player1.position;
		
		player2 = new Player (2);
		Value.enemyPosition = player2.position;
		
		board = new Board ();
		addChild (board);
		
		var startBtn:Sprite = new Sprite ();
		startBtn.x = 675;
		startBtn.y = 100;
		startBtn.graphics.beginFill (0x8F8F8F, 1);
		startBtn.graphics.lineStyle (1, 0x000000, 2);
		startBtn.graphics.drawRoundRect (-100, -15, 200, 30, 10);
		startBtn.addEventListener (MouseEvent.CLICK, onStart);
		addChild (startBtn);
	}

	public function onStart (e:MouseEvent):Void
	{
		gameState = Value.GAMESTATE_COMMENCING;
		turn = Value.TURN_PLAYER_1;
		
		player1.x = 0;
		player1.y = 0;
		
		player2.x = Value.MAP_SIZE - 1;
		player2.y = Value.MAP_SIZE - 1;
		
		board.newGame (player1, player2);
		
		addEventListener (Event.ENTER_FRAME, onEnterFrame);
	}
	
	private var countdown:Int = Value.TURN_TIME;
	public function onEnterFrame (e:Event):Void
	{
		if (gameState == Value.GAMESTATE_END)
		{
			removeEventListener (Event.ENTER_FRAME, onEnterFrame);
			return;
		}
		
		if (-- countdown > 0) return;
		countdown = Value.TURN_TIME;
		
		
		switch (turn)
		{
			case Value.TURN_PLAYER_1:
			var current:Position = new Position (player1.x, player1.y);
			player1.move ();
			
			switch (Value.board [player1.x][player1.y])
			{
				case Value.BLOCK_EMPTY:
				board.block (current.x, current.y, Value.BLOCK_PLAYER_1_TRAIL);
				board.block (player1.x, player1.y, Value.BLOCK_PLAYER_1);
				// trace ("Value.board: " + Value.board);
				
				case Value.BLOCK_PLAYER_1_TRAIL:
				board.block (current.x, current.y, Value.BLOCK_EMPTY);
				board.block (player1.x, player1.y, Value.BLOCK_PLAYER_1);
				// trace ("Value.board: " + Value.board);
				
				default:
				gameState = Value.GAMESTATE_END;
			}
			
			case Value.TURN_PLAYER_2:
			// if (board.block (player2.x, player2.y, Value.BLOCK_PLAYER_2_TRAIL))
			// {
				// player2.move ();
				// if (board.block (player2.x, player2.y, Value.BLOCK_PLAYER_2))
					turn = Value.TURN_PLAYER_1;
				// else
					// gameState = Value.GAMESTATE_END;
			// }
			// else
				// gameState = Value.GAMESTATE_END;
		}
	}
}

class Board extends Sprite
{
	public function new ()
	{
		super ();
		
		Value.board = [];
		for (x in 0 ... Value.MAP_SIZE)
		{
			Value.board [x] = [];
			for (y in 0 ... Value.MAP_SIZE)
			{
				Value.board [x][y] = 0;
				var block:Block = new Block ();
				block.x = Value.BLOCK_SIZE * x;
				block.y = Value.BLOCK_SIZE * y;
				block.name = x + "_" + y;
				
				this.addChild (block);
			}
		}
	}
	
	public function newGame (player1:Player, player2:Player):Void
	{
		for (x in 0 ... Value.MAP_SIZE)
		{
			for (y in 0 ... Value.MAP_SIZE)
			{
				Value.board [x][y] = Value.BLOCK_EMPTY;
				block (x, y, Value.BLOCK_EMPTY);
			}
		}

		block (player1.x, player1.y, Value.BLOCK_PLAYER_1);
		block (player2.x, player2.y, Value.BLOCK_PLAYER_2);
		
		var obstacle:Int = 5 + Std.random (20);
		while (obstacle > 0)
		{
			var x = Std.random (Value.MAP_SIZE);
			var y = Std.random (Value.MAP_SIZE);
			
			if (Value.board [x][y] != Value.BLOCK_EMPTY)
				continue;
			
			block (x, y, Value.BLOCK_OBSTACLE);
			obstacle -= 1;
		}
	}
	
	public function block (x:Int, y:Int, status:Int):Bool
	{
		var obj:DisplayObject = getChildByName (x + "_" + y);
		if (obj == null) return false;
		
		var block:Block = cast (obj, Block);
		if (block == null) return false;
		
		// var blockState = Value.board [x][y];
		// switch (blockState)
		// {
			// case Value.BLOCK_EMPTY:
			
			// case Value.BLOCK_PLAYER_1:
			// if (status != Value.BLOCK_PLAYER_1_TRAIL) return false;
			
			// case Value.BLOCK_PLAYER_2:
			// if (status != Value.BLOCK_PLAYER_2_TRAIL) return false;
			
			// default:
			// return false;
		// }
		
		block.status = status;
		Value.board [x][y] = status;
		return true;
	}
}

class Block extends Sprite
{
	public var status (default, set):Int;
	
	public function new ()
	{
		super ();
		status = 0;
	}
	
	private function set_status (value:Int):Int
	{
		if (value < 0) status = 0;
		else if (value > Value.BLOCK_COLORS.length - 1) status = Value.BLOCK_COLORS.length - 1;
		else status = value;
		
		graphics.clear ();
		graphics.beginFill (Value.BLOCK_COLORS [status], 1);
		graphics.lineStyle (1, 0x000000, 2);
		graphics.drawRect (0, 0, Value.BLOCK_SIZE, Value.BLOCK_SIZE);
		
		return status;
	}
}

class Player
{
	public var id:Int;
	
	public var position:Position;
	public var x (get, set):Int;
	public var y (get, set):Int;
	
	private var zone:Array<Array<Int>>;
	
	public function new (id:Int)
	{
		this.position = new Position ();
		this.id = id;
		
		zone = [];
		for (x in 0 ... Value.MAP_SIZE)
		{
			zone [x] = [];
			for (y in 0 ... Value.MAP_SIZE)
				zone [x][y] = Value.BLOCK_EMPTY;
		}
	}
	
	private function get_x ():Int
	{
		return position.x;
	}
	
	private function set_x (value:Int):Int
	{
		return position.x = value;
	}
	
	private function get_y ():Int
	{
		return position.y;
	}
	
	private function set_y (value:Int):Int
	{
		return position.y = value;
	}
	
	private function clone ():Void
	{
		for (x in 0 ... Value.MAP_SIZE)
		{
			for (y in 0 ... Value.MAP_SIZE)
			{
				switch (Value.board [x][y])
				{
					case Value.BLOCK_EMPTY:
					zone [x][y] = 0;
					
					default:
					zone [x][y] = -1;
				}
			}
		}
	}
	
	public function move ():Void
	{
		var suitableDir:Array<Int> = suitable (x, y, Value.board);
		var selection:Int = Std.random (suitableDir.length);
		command (suitableDir [selection]);
	}
	
	private function suitable (x:Int, y:Int, data:Array<Array<Int>>):Array<Int>
	{
		var suitableDir:Array<Int> = [];
		
		if (x > 0 && data [x-1][y] == Value.BLOCK_EMPTY)
			suitableDir.push (Value.DIRECTION_LEFT);
		
		if (y > 0 && data [x][y-1] == Value.BLOCK_EMPTY)
			suitableDir.push (Value.DIRECTION_UP);
		
		if (x < Value.MAP_SIZE - 1 &&  data [x+1][y] == Value.BLOCK_EMPTY)
			suitableDir.push (Value.DIRECTION_RIGHT);
		
		if (y < Value.MAP_SIZE - 1 && data [x][y+1] == Value.BLOCK_EMPTY)
			suitableDir.push (Value.DIRECTION_DOWN);
		
		return suitableDir;
	}
	
	private function command (dir:Int):Void
	{
		switch (dir)
		{
			case Value.DIRECTION_LEFT:		x -= 1;			
			case Value.DIRECTION_UP:		y -= 1;			
			case Value.DIRECTION_RIGHT:		x += 1;			
			case Value.DIRECTION_DOWN:		y += 1;
		}
	}
}

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
		
		// zone [this.x][this.y] = 0;
		
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
			
			// trace ("suitableDir: " + suitableDir + " >> " + dir);
			
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
		
		// trace ("" + dir);
		return dir;
	}
	
	private var moves:Array<Position> = null;
	private var queue:Array<Position> = null;
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
		
		var nextMove:Position = null;
		
		if (moves == null) moves = [];
		if (queue == null) queue = validMoves (zone, Value.myPosition.x, Value.myPosition.y);
		
		if (queue.length > 0)
		{
			var move:Position = queue.pop ();
			var listMove:Array<Position> = validMoves (zone, move.x, move.y);
			// trace ("");
			// trace ("zone: " + zone);
			
			if (listMove.length > 0)
			{
				for (m in listMove) queue.push (m);
				nextMove = move;
				moves.push (move);
				trace ("move: " + move + " >> " + listMove);
			}
			else if (moves.length > 0)
			{
				nextMove = moves.pop ();
				trace ("back: " + move + " >> " + nextMove + " >> " + queue);
			}
		}
		
		var dir:Int = -1;
		if (this.x - 1 >= nextMove.x)			dir = Value.DIRECTION_LEFT;
		else if (this.x + 1 <= nextMove.x)		dir = Value.DIRECTION_RIGHT;
		else if (this.y - 1 >= nextMove.y)		dir = Value.DIRECTION_UP;
		else if (this.y + 1 <= nextMove.y)		dir = Value.DIRECTION_DOWN;
		
		// trace ("my: " + Value.myPosition + " >> " + nextMove + " >> " + dir);
		return dir;
	}
}

class Value
{
	public static var GAMESTATE_WAIT_FOR_PLAYER:Int = 0;
	public static var GAMESTATE_COMMENCING:Int = 1;
	public static var GAMESTATE_END:Int = 2;
	
	public static var COMMAND_SEND_KEY:Int = 1;
	public static var COMMAND_SEND_INDEX:Int = 2;
	public static var COMMAND_SEND_DIRECTION:Int = 3;
	public static var COMMAND_SEND_STAGE:Int = 4;
	
	public static var TURN_PLAYER_1:Int = 1;
	public static var TURN_PLAYER_2:Int = 2;
	
	public static var BLOCK_EMPTY:Int = 0;
	public static var BLOCK_PLAYER_1:Int = 1;
	public static var BLOCK_PLAYER_1_TRAIL:Int = 2;
	public static var BLOCK_PLAYER_2:Int = 3;
	public static var BLOCK_PLAYER_2_TRAIL:Int = 4;
	public static var BLOCK_OBSTACLE:Int = 5;
	
	public static var DIRECTION_LEFT:Int = 1;
	public static var DIRECTION_UP:Int = 2;
	public static var DIRECTION_RIGHT:Int = 3;
	public static var DIRECTION_DOWN:Int = 4;
	
	public static var MAP_SIZE:Int = 11;
	public static var TURN_TIME:Int = 10;
	
	public static var BLOCK_SIZE:Int = 50;
	public static var BLOCK_COLORS:Array<Int> = [0xFFFFFF, 0x00FF00, 0x007700, 0xFF0000, 0x770000, 0x777777];
	
	public static var board:Array<Array<Int>> = null;
	
	public static var myPosition:Position = null;
	public static var enemyPosition:Position = null;
}

class Position
{
	public var x:Int = 0;
	public var y:Int = 0;
	public function new (_x:Int = 0, _y:Int = 0)
	{
		x = _x;
		y = _y;
	}
	
	public function toString () { return "[" + x + ", " + y + "]"; }
}