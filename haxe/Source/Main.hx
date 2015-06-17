package;

import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.display.Sprite;
import openfl.display.DisplayObject;

class Main extends Sprite
{
	public static var turn:Int = -1;
	public static var gameState:Int = -1;
	
	public static var board:Board = null;
	public static var player1:Player = null;
	public static var player2:Player = null;
	
	public function new ()
	{
		super ();
		
		player1 = new Me (1);
		Value.myPosition = player1.position;
		
		player2 = new Player (2);
		Value.enemyPosition = player2.position;
		
		board = new Board ();
		addChild (board);
		
		var startBtn:Sprite = new Sprite ();
		startBtn.x = 675;
		startBtn.y = 100;
		startBtn.graphics.beginFill (0x8F8F8F, 1);
		startBtn.graphics.lineStyle (1, 0x000000, 2);
		startBtn.graphics.drawRoundRect (-100, -15, 200, 30, 10);
		startBtn.addEventListener (MouseEvent.CLICK, onStart);
		addChild (startBtn);
	}

	public function onStart (e:MouseEvent):Void
	{
		gameState = Value.GAMESTATE_COMMENCING;
		turn = Value.TURN_PLAYER_1;
		
		player1.x = 0;
		player1.y = 0;
		
		player2.x = Value.MAP_SIZE - 1;
		player2.y = Value.MAP_SIZE - 1;
		
		board.newGame (player1, player2);
		
		addEventListener (Event.ENTER_FRAME, onEnterFrame);
	}
	
	private var countdown:Int = Value.TURN_TIME;
	public function onEnterFrame (e:Event):Void
	{
		if (gameState == Value.GAMESTATE_END)
		{
			removeEventListener (Event.ENTER_FRAME, onEnterFrame);
			return;
		}
		
		if (-- countdown > 0) return;
		countdown = Value.TURN_TIME;
		
		
		switch (turn)
		{
			case Value.TURN_PLAYER_1:
			if (board.block (player1.x, player1.y, Value.BLOCK_PLAYER_1_TRAIL))
			{
				player1.move ();
				if (board.block (player1.x, player1.y, Value.BLOCK_PLAYER_1))
					turn = Value.TURN_PLAYER_2;
				else
					gameState = Value.GAMESTATE_END;
			}
			else
				gameState = Value.GAMESTATE_END;
			
			case Value.TURN_PLAYER_2:
			// if (board.block (player2.x, player2.y, Value.BLOCK_PLAYER_2_TRAIL))
			// {
				// player2.move ();
				// if (board.block (player2.x, player2.y, Value.BLOCK_PLAYER_2))
					turn = Value.TURN_PLAYER_1;
				// else
					// gameState = Value.GAMESTATE_END;
			// }
			// else
				// gameState = Value.GAMESTATE_END;
		}
	}
}