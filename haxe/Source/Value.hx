package;

class Value
{
	public static var GAMESTATE_WAIT_FOR_PLAYER:Int = 0;
	public static var GAMESTATE_COMMENCING:Int = 1;
	public static var GAMESTATE_END:Int = 2;
	
	public static var COMMAND_SEND_KEY:Int = 1;
	public static var COMMAND_SEND_INDEX:Int = 2;
	public static var COMMAND_SEND_DIRECTION:Int = 3;
	public static var COMMAND_SEND_STAGE:Int = 4;
	
	public static var TURN_PLAYER_1:Int = 1;
	public static var TURN_PLAYER_2:Int = 2;
	
	public static var BLOCK_EMPTY:Int = 0xFFFFFF;
	public static var BLOCK_PLAYER_1:Int = 0x00FF00;
	public static var BLOCK_PLAYER_1_TRAIL:Int = 0x007700;
	public static var BLOCK_PLAYER_2:Int = 0xFF0000;
	public static var BLOCK_PLAYER_2_TRAIL:Int = 0x770000;
	public static var BLOCK_OBSTACLE:Int = 0x777777;
	
	public static var DIRECTION_LEFT:Int = 1;
	public static var DIRECTION_UP:Int = 2;
	public static var DIRECTION_RIGHT:Int = 3;
	public static var DIRECTION_DOWN:Int = 4;
	
	public static var MAP_SIZE:Int = 5;
	public static var OBSTACLES:Int = 3;
	public static var TURN_TIME:Int = 5;
	
	public static var BLOCK_SIZE:Int = 50;
	public static var BLOCK_COLORS:Array<Int> = [0xFFFFFF, 0x229922, 0x007700, 0x992222, 0x770000, 0x777777];
	
	public static var board:Array<Array<Int>> = null;
	
	public static var myPosition:Position = null;
	public static var enemyPosition:Position = null;
	
	public static var CHAR_START:String = "■";
	public static var CHAR_CURRENT:String = "●";
	public static var CHAR_TOP:String = "─";
	public static var CHAR_LEFT:String = "│";
	public static var CHAR_LEFT_TOP:String = "┌";
	public static var CHAR_RIGHT_TOP:String = "┐";
	public static var CHAR_RIGHT_BOTTOM:String = "┘";
	public static var CHAR_LEFT_BOTTOM:String = "└";
}