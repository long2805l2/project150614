package;

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