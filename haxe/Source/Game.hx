package;

class Game
{
	private var map:Array<Array<Int>>;
	private var mapSize:Int;
	private var obstacles:Int;
	public var board:Array<Array<Int>>;
	
	private var state:Int;
	private var turn:Int;
	
	public var player1:Player;
	public var pathPlayer1:Array<Position>;
	
	public var player2:Player;
	public var pathPlayer2:Array<Position>;
	
	public function new (mapSize:Int, obstacles:Int)
	{
		this.mapSize = mapSize;
		this.obstacles = obstacles;
		
		map = [];
		board = [];
		for (x in 0 ... mapSize)
		{
			map [x] = [];
			board [x] = [];
			for (y in 0 ... mapSize)
			{				
				map [x][y] = Value.BLOCK_EMPTY;
				board [x][y] = Value.BLOCK_EMPTY;
			}
		}
		
		var x:Int = -1;
		var y:Int = -1;
		for (obstacle in 0 ... obstacles)
		{
			x = Std.random (Value.MAP_SIZE);
			y = Std.random (Value.MAP_SIZE);
			
			// x ++;
			// y = 1;
			
			map [x][y] = Value.BLOCK_OBSTACLE;
			map [Value.MAP_SIZE - x - 1][Value.MAP_SIZE - y - 1] = Value.BLOCK_OBSTACLE;
			
			board [x][y] = Value.BLOCK_OBSTACLE;
			board [Value.MAP_SIZE - x - 1][Value.MAP_SIZE - y - 1] = Value.BLOCK_OBSTACLE;
		}
		
		map [0][0] = Value.BLOCK_PLAYER_1;
		board [0][0] = Value.BLOCK_PLAYER_1;
		
		map [Value.MAP_SIZE - 1][Value.MAP_SIZE - 1] = Value.BLOCK_PLAYER_2;
		board [Value.MAP_SIZE - 1][Value.MAP_SIZE - 1] = Value.BLOCK_PLAYER_2;

		state = Value.GAMESTATE_WAIT_FOR_PLAYER;
	}
	
	public function getBoard ():Array<Array<Int>>
	{
		var temp:Array<Array<Int>> = [];
		for (x in 0 ... mapSize)
		{
			temp [x] = [];
			for (y in 0 ... mapSize)
				temp [x][y] = board [x][y];
		}
		return temp;
	}
	
	public function validMove (position:Position, dir:Int):Bool
	{
		var x:Int = position.x;
		var y:Int = position.y;
		switch (dir)
		{
			case Value.DIRECTION_LEFT:		x -= 1;
			case Value.DIRECTION_UP:		y -= 1;
			case Value.DIRECTION_RIGHT:		x += 1;
			case Value.DIRECTION_DOWN:		y += 1;
		}
		return board [x][y] == Value.BLOCK_EMPTY;
	}
	
	public function start (p1:Player, p2:Player):Void
	{
		player1 = p1;
		pathPlayer1 = [];
		
		player2 = p2;
		pathPlayer2 = [];
		
		reset ();
	}
	
	public function pause ():Void
	{
		state = Value.GAMESTATE_END;
	}
	
	public function play ():Void
	{
		state = Value.GAMESTATE_COMMENCING;
	}
	
	public function isPlay ():Bool
	{
		return state == Value.GAMESTATE_COMMENCING;
	}
	
	public function reset ():Void
	{
		for (x in 0 ... mapSize)
			for (y in 0 ... mapSize)
				board [x][y] = map [x][y];
		
		if (player1 != null)
		{
			player1.x = 0;
			player1.y = 0;
			pathPlayer1 = [new Position (player1.x, player1.y)];
		}
		
		if (player2 != null)
		{		
			player2.x = Value.MAP_SIZE - 1;
			player2.y = Value.MAP_SIZE - 1;
			pathPlayer2 = [new Position (player2.x, player2.y)];
		}
		
		state = Value.GAMESTATE_COMMENCING;
		turn = Value.TURN_PLAYER_1;
	}
	
	public function update (?canvas:Board):Void
	{
		switch (state)
		{
			case Value.GAMESTATE_WAIT_FOR_PLAYER:
			case Value.GAMESTATE_COMMENCING:
			switch (turn)
			{
				case Value.TURN_PLAYER_1:
					player1.update (player2.position, getBoard ());
					var dir:Int = player1.myTurn ();
					if (canvas != null) player1.debug (canvas);
					
					if (validMove (player1.position, dir))
					{
						turn = Value.TURN_PLAYER_2;
						board [player1.x][player1.y] = Value.BLOCK_PLAYER_1_TRAIL;
						player1.move (dir);
						board [player1.x][player1.y] = Value.BLOCK_PLAYER_1;
						pathPlayer1.push (new Position (player1.x, player1.y));
					}
					else
						state = Value.GAMESTATE_END;
				
				case Value.TURN_PLAYER_2:
					// player2.update (player1.position, getBoard ());
					// if (canvas != null) player2.debug (canvas);
					
					// var dir:Int = player2.myTurn ();
					// if (validMove (player2.position, dir))
					// {
						turn = Value.TURN_PLAYER_1;
						// board [player2.x][player2.y] = Value.BLOCK_PLAYER_2_TRAIL;
						// player2.move (dir);
						// board [player2.x][player2.y] = Value.BLOCK_PLAYER_2;
						// pathPlayer2.push (new Position (player2.x, player2.y));
					// }
					// else
						// state = Value.GAMESTATE_END;
			}
			case Value.GAMESTATE_END:
		}
	}
}