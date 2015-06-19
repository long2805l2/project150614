package;

import flash.display.Sprite;

class Block extends Sprite
{
	public var color (default, set):Int;
	public var text (default, set):String;
	public var size (default, null):Float;
	
	private var label:Label;
	
	public function new (color:Int = 0xFFFFFF, text:String = "", cubeSize:Float = 50)
	{
		super ();
		this.size = cubeSize;
		this.color = color;
		this.text = text;
	}
	
	private function set_color (value:Int):Int
	{
		if (color == value) return value;
		
		color = value;
		graphics.clear ();
		graphics.beginFill (color, 1);
		graphics.lineStyle (1, 0x000000, 2);
		graphics.drawRect (-size * 0.5, -size * 0.5, size, size);
		
		return color;
	}
	
	private function set_text (value:String):String
	{
		if (text == value) return value;
		
		text = value;		
		if (label == null)
		{
			if (text != null && text != "")
			{
				label = new Label (text, Fonts.BLACK_20, 0, 0, Anchor.CENTER_CENTER);
				this.addChild (label);
			}
		}
		else
		{
			label.text = text;
			label.update ();
		}
		
		return text;
	}
}