package;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import flash.display.Sprite;
import flash.display.DisplayObject;
import flash.Lib;

class Main extends Sprite
{
	public var board:Board = null;
	public var game:Game = null;
	
	private var randomBtn:Button;
	private var resetBtn:Button;
	private var controlBtn:Button;
	private var humanBtn:Button;
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
		addChild (resetBtn);
		
		controlBtn = new Button (0x8F8F8F, "<font color=\"#FFFFFF\">Play</font>", 160, 40);
		controlBtn.x = 700;
		controlBtn.y = 70 + 40 + 10 + 40 + 10;
		controlBtn.name = "play";
		controlBtn.addEventListener (MouseEvent.CLICK, onControl);
		addChild (controlBtn);
		
		debuglBtn = new Button (0x8F8F8F, "<font color=\"#FFFFFF\">Debug</font>", 160, 40);
		debuglBtn.x = 700;
		debuglBtn.y = 70 + 40 + 10 + 40 + 10 + 40 + 10;
		debuglBtn.addEventListener (MouseEvent.CLICK, onDebug);
		// addChild (debuglBtn);
		
		humanBtn = new Button (0x8F8F8F, "<font color=\"#FFFFFF\">A.I.</font>", 160, 40);
		humanBtn.x = 700;
		humanBtn.y = 70 + 40 + 10 + 40 + 10 + 40 + 10 + 40 + 10;
		humanBtn.name = "ai";
		humanBtn.addEventListener (MouseEvent.CLICK, onHuman);
		addChild (humanBtn);
		
		addEventListener (Event.ENTER_FRAME, onEnterFrame);
		Lib.current.stage.addEventListener (KeyboardEvent.KEY_UP, onKeyDown);
	}

	private function onControl (e:MouseEvent):Void
	{
		trace ("onControl");
		if (game == null) return;
		
		switch (controlBtn.name)
		{
			case "play":
			game.start (new Tron (Value.TURN_PLAYER_1), new AI6 (Value.TURN_PLAYER_2));
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

	private function onRandom (e:MouseEvent):Void
	{
		game = new Game (Value.MAP_SIZE, Value.OBSTACLES);
		board.draw (game.getBoard ());
		board.path (game.pathPlayer1, Value.BLOCK_PLAYER_1);
		board.path (game.pathPlayer2, Value.BLOCK_PLAYER_2);
		
		controlBtn.name = "play";
		controlBtn.text = "<font color=\"#FFFFFF\">Play</font>";
	}
	
	private var humanTurn:Int = -1;
	private function onHuman (e:MouseEvent):Void
	{
		if (game == null) return;
		
		humanMove = -1;
		switch (humanBtn.name)
		{
			case "ai":
			humanTurn = Value.TURN_PLAYER_1;
			humanBtn.name = "human1";
			humanBtn.text = "<font color=\"#FFFFFF\">Human 1</font>";
			
			case "human1":
			humanTurn = Value.TURN_PLAYER_2;
			humanBtn.name = "human2";
			humanBtn.text = "<font color=\"#FFFFFF\">Human 2</font>";
			
			case "human2":
			humanTurn = -1;
			humanBtn.name = "ai";
			humanBtn.text = "<font color=\"#FFFFFF\">A.I.</font>";
		}			
	}

	private function onReset (e:MouseEvent):Void
	{
		if (game != null) game.reset ();
		
		controlBtn.name = "play";
		controlBtn.text = "<font color=\"#FFFFFF\">Play</font>";
	}

	private function onDebug (e:MouseEvent):Void
	{
		trace ("onDebug: " + game);
		if (game != null)
		{
			timer = 0xFFFFFF;
			
			if (!game.isPlay ()) onControl (e);
			// game.update (board);
		}
	}
	
	private var humanMove:Int = -1;
	private function onKeyDown (e:KeyboardEvent):Void
	{
		switch (e.keyCode)
		{
			case 37:	humanMove = Value.DIRECTION_LEFT;
			case 38:	humanMove = Value.DIRECTION_UP;
			case 39:	humanMove = Value.DIRECTION_RIGHT;
			case 40:	humanMove = Value.DIRECTION_DOWN;
		}
	}
	
	private var timer:Int = Value.TURN_TIME;
	public function onEnterFrame (e:Event):Void
	{
		if (game != null)
		{
			if (game.turn == humanTurn)
			if (humanMove == -1) return;
			
			if (timer-- > 0) return;
			timer = Value.TURN_TIME;
			
			game.update (humanMove);
			humanMove = -1;
			
			board.draw (game.board);
			board.path (game.pathPlayer1, Value.BLOCK_PLAYER_1);
			board.path (game.pathPlayer2, Value.BLOCK_PLAYER_2);
		}
	}
}