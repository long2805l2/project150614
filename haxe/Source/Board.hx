package;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.display.Sprite;
import flash.display.DisplayObject;

class Board extends Sprite
{
	public var mapWidth:Int;
	public var mapHeight:Int;
	public var blockSize:Float;
	
	private var _blocks:Map<String, Block>;
	
	public function new (width:Int, height:Int, size:Float = 50)
	{
		super ();
		
		this.mapWidth = width;
		this.mapHeight = height;
		this.blockSize = size;
		
		_blocks = new Map <String, Block> ();
		
		for (x in 0 ... mapWidth)
			this.addChild (new Label ("" + x, Fonts.BLACK_20, x * blockSize, -blockSize, Anchor.CENTER_CENTER));
		
		for (y in 0 ... mapHeight)
			this.addChild (new Label ("" + y, Fonts.BLACK_20, -blockSize, y * blockSize, Anchor.CENTER_CENTER));
		
		for (x in 0 ... mapWidth)
		{
			for (y in 0 ... mapHeight)
			{
				var name:String = x + "_" + y;
				
				var block:Block = new Block (0xFFFFFF, "", blockSize);
				block.x = blockSize * x;
				block.y = blockSize * y;
				block.name = name;
				
				_blocks.set (name, block);
				this.addChild (block);
			}
		}
	}
	
	public function draw (data:Array<Array<Int>>):Void
	{
		for (x in 0 ... mapWidth)
			for (y in 0 ... mapHeight)
				block (x, y, data [x][y]);
	}
	
	public function block (x:Int, y:Int, color:Int = 0, text:String = ""):Void
	{
		var block:Block = _blocks.get (x + "_" + y);
		if (block != null)
		{
			block.color = color;
			block.text = text;
		}
	}
}