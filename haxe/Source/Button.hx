package;

import openfl.display.Sprite;

class Button extends Sprite
{
	public var color (default, set):Int;
	public var text (default, set):String;
	
	public var boundWidth (default, null):Float;
	public var boundHeight (default, null):Float;
	
	private var label:Label;
	
	public function new (color:Int = 0xFFFFFF, text:String = "click", width:Float = 160, height:Float = 40)
	{
		super ();
		this.boundWidth = width;
		this.boundHeight = height;
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
		graphics.drawRect (-boundWidth * 0.5, -boundHeight * 0.5, boundWidth, boundHeight);
		
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