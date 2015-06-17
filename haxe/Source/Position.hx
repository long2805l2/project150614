package;

class Position
{
	public var x:Int = 0;
	public var y:Int = 0;
	public function new (_x:Int = 0, _y:Int = 0)
	{
		x = _x;
		y = _y;
	}
	
	public function toString () { return "(" + x + ", " + y + ")"; }
}