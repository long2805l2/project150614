import openfl.Assets;
import flash.text.TextFormat;

class Fonts
{
	public static inline var RED:Int	= 0xFF0000;
	public static inline var GREEN:Int	= 0x00FF00;
	public static inline var BLUE:Int	= 0x69d0fb;
	public static inline var YELLOW:Int	= 0xFFFF00;
	public static inline var WHITE:Int	= 0xFFFFFF;
	public static inline var BLACK:Int	= 0x000000;
	public static inline var PURPLE:Int	= 0xcc6cce;
	public static inline var ORANGE:Int	= 0xd29e65;
	
	public static var DETAIL_FONT:String = null;
	
	public static var BLACK_20 = null;
	public static var BLACK_25 = null;
	public static var BLACK_30 = null;
	
	private function new() {}
	
	public static function init ():Void
	{
		DETAIL_FONT = Assets.getFont ("assets/tahoma.ttf").fontName;
		
		BLACK_20 = new TextFormat (DETAIL_FONT, 20, BLACK);
		BLACK_25 = new TextFormat (DETAIL_FONT, 25, BLACK);
		BLACK_30 = new TextFormat (DETAIL_FONT, 30, BLACK);
	}	
}