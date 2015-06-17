package;

import openfl.display.Sprite;

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