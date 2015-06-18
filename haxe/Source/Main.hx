package;

import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.display.Sprite;
import openfl.display.DisplayObject;

class Main extends Sprite
{
	public var board:Board = null;
	public var game:Game = null;
	
	public function new ()
	{
		super ();
		Fonts.init ();
		
		board = new Board (Value.MAP_SIZE, Value.MAP_SIZE, Value.BLOCK_SIZE);
		board.x = 70;
		board.y = 70;
		addChild (board);
		
		var randomBtn:Button = new Button (0x8F8F8F, "<font color=\"#FFFFFF\">New Map</font>", 160, 40);
		randomBtn.x = 700;
		randomBtn.y = 70;
		randomBtn.addEventListener (MouseEvent.CLICK, onRandom);
		addChild (randomBtn);
		
		var resetBtn:Button = new Button (0x8F8F8F, "<font color=\"#FFFFFF\">Reset</font>", 160, 40);
		resetBtn.x = 700;
		resetBtn.y = 70 + 40 + 10;
		resetBtn.addEventListener (MouseEvent.CLICK, onReset);
		addChild (resetBtn);
		
		var controlBtn:Button = new Button (0x8F8F8F, "<font color=\"#FFFFFF\">Play</font>", 160, 40);
		controlBtn.x = 700;
		controlBtn.y = 70 + 40 + 10 + 40 + 10;
		controlBtn.addEventListener (MouseEvent.CLICK, onControl);
		addChild (controlBtn);
	}

	public function onControl (e:MouseEvent):Void
	{
	}

	public function onRandom (e:MouseEvent):Void
	{
		game = new Game (Value.MAP_SIZE, Value.OBSTACLES);
		// board.draw (game.colors);
		
		for (x in 0 ... Value.MAP_SIZE)
			for (y in 0 ... Value.MAP_SIZE)
				board.block (x, y, Value.BLOCK_COLORS [game.board [x][y]], "");
	}

	public function onReset (e:MouseEvent):Void
	{
	}
	
	public function onEnterFrame (e:Event):Void
	{
	}
}