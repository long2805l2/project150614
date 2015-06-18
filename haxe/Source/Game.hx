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
	public var player2:Player;
	
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
		
		for (obstacle in 0 ... obstacles)
		{
			var x:Int = Std.random (Value.MAP_SIZE);
			var y:Int = Std.random (Value.MAP_SIZE);
			
			map [x][y] = Value.BLOCK_OBSTACLE;
			map [Value.MAP_SIZE - x - 1][Value.MAP_SIZE - y - 1] = Value.BLOCK_OBSTACLE;
			
			board [x][y] = Value.BLOCK_OBSTACLE;
			board [Value.MAP_SIZE - x - 1][Value.MAP_SIZE - y - 1] = Value.BLOCK_OBSTACLE;
		}
		
		map [0][0] = Value.BLOCK_PLAYER_1;
		board [0][0] = Value.BLOCK_PLAYER_1;
		
		map [Value.MAP_SIZE - 1][Value.MAP_SIZE - 1] = Value.BLOCK_PLAYER_1;
		board [Value.MAP_SIZE - 1][Value.MAP_SIZE - 1] = Value.BLOCK_PLAYER_2;

		state = Value.GAMESTATE_WAIT_FOR_PLAYER;
	}
	
	public function start (p1:Player, p2:Player):Void
	{
		player1 = p1;
		player2 = p2;
		
		state = Value.GAMESTATE_COMMENCING;
		turn = Value.TURN_PLAYER_1;
	}
	
	public function pause ():Void
	{
	}
	
	public function reset ():Void
	{
		for (x in 0 ... mapSize)
			for (y in 0 ... mapSize)
				board [x][y] = map [x][y];
	}
	
	public function update ():Void
	{
	}
}