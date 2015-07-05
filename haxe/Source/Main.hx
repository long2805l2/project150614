package;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.display.Sprite;
import flash.display.DisplayObject;

class Main extends Sprite
{
	public var board:Board = null;
	public var game:Game = null;
	
	private var randomBtn:Button;
	private var resetBtn:Button;
	private var controlBtn:Button;
	private var debuglBtn:Button;
	
	public function new ()
	{
		super ();
		Fonts.init ();
		
		board = new Board (Value.MAP_SIZE, Value.MAP_SIZE, Value.BLOCK_SIZE);
		board.x = 70;
		board.y = 70;
		addChild (board);
		
		randomBtn = new Button (0x8F8F8F, "<font color=\"#FFFFFF\">New Map</font>", 160, 40);
		randomBtn.x = 700;
		randomBtn.y = 70;
		randomBtn.addEventListener (MouseEvent.CLICK, onRandom);
		addChild (randomBtn);
		
		resetBtn = new Button (0x8F8F8F, "<font color=\"#FFFFFF\">Reset</font>", 160, 40);
		resetBtn.x = 700;
		resetBtn.y = 70 + 40 + 10;
		resetBtn.addEventListener (MouseEvent.CLICK, onReset);
		// addChild (resetBtn);
		
		controlBtn = new Button (0x8F8F8F, "<font color=\"#FFFFFF\">Play</font>", 160, 40);
		controlBtn.x = 700;
		controlBtn.y = 70 + 40 + 10 + 40 + 10;
		controlBtn.name = "play";
		controlBtn.addEventListener (MouseEvent.CLICK, onControl);
		// addChild (controlBtn);
		
		debuglBtn = new Button (0x8F8F8F, "<font color=\"#FFFFFF\">Debug</font>", 160, 40);
		debuglBtn.x = 700;
		debuglBtn.y = 70 + 40 + 10 + 40 + 10 + 40 + 10;
		debuglBtn.addEventListener (MouseEvent.CLICK, onDebug);
		addChild (debuglBtn);
		
		addEventListener (Event.ENTER_FRAME, onEnterFrame);
	}

	public function onControl (e:MouseEvent):Void
	{
		trace ("onControl");
		if (game == null) return;
		
		switch (controlBtn.name)
		{
			case "play":
			game.start (new AI5 (Value.TURN_PLAYER_1), new Tron (Value.TURN_PLAYER_2));
			controlBtn.name = "pause";
			controlBtn.text = "<font color=\"#FFFFFF\">Pause</font>";
			
			case "pause":
			game.pause ();
			controlBtn.name = "continue";
			controlBtn.text = "<font color=\"#FFFFFF\">Continue</font>";
			timer = Value.TURN_TIME;
			
			case "continue":
			game.play ();
			controlBtn.name = "pause";
			controlBtn.text = "<font color=\"#FFFFFF\">Pause</font>";
		}
	}

	public function onRandom (e:MouseEvent):Void
	{
		game = new Game (Value.MAP_SIZE, Value.OBSTACLES);
		board.draw (game.getBoard ());
		board.path (game.pathPlayer1, Value.BLOCK_PLAYER_1);
		board.path (game.pathPlayer2, Value.BLOCK_PLAYER_2);
		
		controlBtn.name = "play";
		controlBtn.text = "<font color=\"#FFFFFF\">Play</font>";
	}

	public function onReset (e:MouseEvent):Void
	{
		if (game != null) game.reset ();
		
		controlBtn.name = "play";
		controlBtn.text = "<font color=\"#FFFFFF\">Play</font>";
	}

	public function onDebug (e:MouseEvent):Void
	{
		trace ("onDebug: " + game);
		if (game != null)
		{
			timer = 0xFFFFFF;
			
			if (!game.isPlay ()) onControl (e);
			game.update (board);
		}
	}
	
	private var timer:Int = Value.TURN_TIME;
	public function onEnterFrame (e:Event):Void
	{
		if (game != null)
		{
			if (timer-- > 0) return;
			timer = Value.TURN_TIME;
			
			game.update ();
			board.draw (game.board);
			board.path (game.pathPlayer1, Value.BLOCK_PLAYER_1);
			board.path (game.pathPlayer2, Value.BLOCK_PLAYER_2);
		}
	}
}