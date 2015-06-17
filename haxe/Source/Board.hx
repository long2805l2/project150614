package;

import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.display.Sprite;
import openfl.display.DisplayObject;

class Board extends Sprite
{
	public function new ()
	{
		super ();
		
		Value.board = [];
		for (x in 0 ... Value.MAP_SIZE)
		{
			Value.board [x] = [];
			for (y in 0 ... Value.MAP_SIZE)
			{
				Value.board [x][y] = 0;
				var block:Block = new Block ();
				block.x = Value.BLOCK_SIZE * x;
				block.y = Value.BLOCK_SIZE * y;
				block.name = x + "_" + y;
				
				this.addChild (block);
			}
		}
	}
	
	public function newGame (player1:Player, player2:Player):Void
	{
		for (x in 0 ... Value.MAP_SIZE)
		{
			for (y in 0 ... Value.MAP_SIZE)
			{
				Value.board [x][y] = Value.BLOCK_EMPTY;
				block (x, y, Value.BLOCK_EMPTY);
			}
		}

		block (player1.x, player1.y, Value.BLOCK_PLAYER_1);
		block (player2.x, player2.y, Value.BLOCK_PLAYER_2);
		
		var obstacle:Int = 5 + Std.random (20);
		while (obstacle > 0)
		{
			var x = Std.random (Value.MAP_SIZE);
			var y = Std.random (Value.MAP_SIZE);
			
			if (Value.board [x][y] != Value.BLOCK_EMPTY)
				continue;
			
			block (x, y, Value.BLOCK_OBSTACLE);
			obstacle -= 1;
		}
	}
	
	public function block (x:Int, y:Int, status:Int):Bool
	{
		var obj:DisplayObject = getChildByName (x + "_" + y);
		if (obj == null) return false;
		
		var block:Block = cast (obj, Block);
		if (block == null) return false;
		
		var blockState = Value.board [x][y];
		switch (blockState)
		{
			case Value.BLOCK_EMPTY:
			
			case Value.BLOCK_PLAYER_1:
			if (status != Value.BLOCK_PLAYER_1_TRAIL) return false;
			
			case Value.BLOCK_PLAYER_2:
			if (status != Value.BLOCK_PLAYER_2_TRAIL) return false;
			
			default:
			return false;
		}
		
		block.status = status;
		Value.board [x][y] = status;
		return true;
	}
}