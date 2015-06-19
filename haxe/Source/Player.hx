package;

class Player
{
	private var myPosition:Position;
	private var enemyPosition:Position;
	private var board:Array<Array<Int>>;
	
	public var position (get, null):Position;
	public var x (get, set):Int;
	public var y (get, set):Int;
	public var id:Int;
	
	public function new (playId:Int)
	{
		id = playId;
		myPosition = new Position ();
		enemyPosition = new Position ();
		board = [];
	}
	
	private function get_position ():Position
	{
		return new Position (x, y);
	}
	
	private function get_x ():Int
	{
		return myPosition.x;
	}
	
	private function set_x (value:Int):Int
	{
		return myPosition.x = value;
	}
	
	private function get_y ():Int
	{
		return myPosition.y;
	}
	
	private function set_y (value:Int):Int
	{
		return myPosition.y = value;
	}
	
	public function update (enemyPosition, board):Void
	{
		this.myPosition.x = myPosition.x;
		this.myPosition.y = myPosition.y;
		this.enemyPosition.x = enemyPosition.x;
		this.enemyPosition.y = enemyPosition.y;
		this.board = board;
	}
	
	public function myTurn ():Int
	{
		return 0;
	}
	
	public function move (dir:Int)
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