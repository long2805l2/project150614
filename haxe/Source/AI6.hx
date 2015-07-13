package;

import flash.events.Event;
import flash.display.Sprite;

class AI6 extends Player
{
	public var phrase:Int;
	
	override public function myTurn ():Int
	{
		switch (phrase)
		{
			case INIT:
			init ();
			tartic ();
			move ();
			phrase = ;
			
			case :
		}
		return 0;
	}
}

class Node
{
	public var x:Int;
	public var y:Int;
	
	public var nears:Array<Node>;
	public var connects:Array<Node>;
	
	public var component:Int;
}