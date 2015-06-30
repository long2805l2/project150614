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
	private var _canvas1:Sprite;
	private var _canvas2:Sprite;
	
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
		
		addChild (this._canvas1 = new Sprite ());
		addChild (this._canvas2 = new Sprite ());
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
	
	public function path (data:Array<Position>, color:Int):Void
	{
		var canvas:Sprite = color == Value.BLOCK_PLAYER_1 ? _canvas1 : _canvas2;
		var block:Block = null;
		var p:Position = null;
		var c:Int = 0;
		var t:Float = 2;
		
		canvas.graphics.clear ();
		if (data == null) return;
		
		canvas.graphics.beginFill (color, 1);
		canvas.graphics.lineStyle (t, color, 1);
		
		p = data [0];
		block = _blocks.get (p.x + "_" + p.y);
		if (block != null)
		{
			canvas.graphics.drawRect (block.x - 4, block.y - 4, 8, 8);
			canvas.graphics.moveTo (block.x, block.y);
		}
		
		for (id in 1 ... data.length)
		{
			p = data [id];
			block = _blocks.get (p.x + "_" + p.y);
			if (block != null)
			{
				canvas.graphics.lineTo (block.x, block.y);
				if (++c == 10)
				{
					c = 0;
					canvas.graphics.drawRect (block.x - 2, block.y - 2, 4, 4);
					
					t += 1;
					canvas.graphics.lineStyle (t, color, 0.75);
				}
				canvas.graphics.moveTo (block.x, block.y);
			}
		}
	}
}