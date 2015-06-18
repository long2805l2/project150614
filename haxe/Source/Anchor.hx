
class Anchor
{
	inline public static var _LEFT:Int = (1<<0);
	inline public static var _RIGHT:Int = (1<<1);
	inline public static var _HCENTER:Int = (1<<2);
	inline public static var _TOP:Int = (1<<3);
	inline public static var _BOTTOM:Int = (1<<4);
	inline public static var _VCENTER:Int = (1<<5);
	
	inline public static var NONE:Int			= -1;
	inline public static var LEFT_TOP:Int		= _LEFT | _TOP;
	inline public static var LEFT_CENTER:Int	= _LEFT | _VCENTER;
	inline public static var LEFT_BOTTOM:Int	= _LEFT | _BOTTOM;
	inline public static var CENTER_TOP:Int		= _HCENTER | _TOP;
	inline public static var CENTER_CENTER:Int	= _HCENTER | _VCENTER;
	inline public static var CENTER_BOTTOM:Int	= _HCENTER | _BOTTOM;
	inline public static var RIGHT_TOP:Int		= _RIGHT | _TOP;
	inline public static var RIGHT_CENTER:Int	= _RIGHT | _VCENTER;
	inline public static var RIGHT_BOTTOM:Int	= _RIGHT | _BOTTOM;
}