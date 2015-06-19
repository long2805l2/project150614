import flash.events.Event;

import flash.geom.Rectangle;
import flash.geom.Point;
import flash.geom.Matrix;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.Sprite;

import flash.Vector;

import flash.text.Font;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFieldAutoSize;
import flash.text.TextLineMetrics;
import flash.text.TextFormatAlign;
import flash.text.AntiAliasType;
import flash.text.GridFitType;

class Label extends Sprite
{
	public var textField (default, null):TextField;
	public var textFormat (get, set):TextFormat;
	public var text (get, set):String;
	public var anchor (default, set):Int;
	
	public function new (text:String, format:TextFormat, x:Float = 0, y:Float = 0, anchor:Int = 0)
	{
		super ();
		
		addChild (textField = new TextField ());
		textField.x = 0;
		textField.y = 0;
		textField.embedFonts = true;
		textField.selectable = false;
		textField.autoSize = TextFieldAutoSize.LEFT;
		textField.wordWrap = false;
		
		this.textFormat = format;
		this.text = text;
		this.x = x;
		this.y = y;
		this.anchor = anchor;
		
		this.update ();
	}
	
	public function set_anchor (anchor:Int):Int
	{
		this.anchor = anchor;
		return this.anchor;
	}
	
	public function set_text (text:String):String
	{
		// if (textField == null) return null;
		textField.htmlText = text;
		return textField.htmlText;		
	}
	
	public function get_text ():String
	{
		// if (textField == null) return null;
		return textField.htmlText;
	}
	
	public function set_textFormat (format:TextFormat):TextFormat
	{
		// if (textField == null) return null;
		textField.defaultTextFormat = format;
		return textField.defaultTextFormat;
	}
	
	public function get_textFormat ():TextFormat
	{
		// if (textField == null) return null;
		return textField.defaultTextFormat;
	}
	
	public function update ():Void
	{
		var rect:Rectangle = textField.getRect (this);
		if((anchor & Anchor._HCENTER) != 0) textField.x = -rect.width * 0.5;
		else if((anchor & Anchor._RIGHT) != 0) textField.x = -rect.width;
		else textField.x = 0;
		
		if((anchor & Anchor._VCENTER) != 0) textField.y = -rect.height * 0.5;
		else if((anchor & Anchor._BOTTOM) != 0) textField.y = -rect.height;
		else textField.y = 0;
	}
}