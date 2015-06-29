package;

import flash.events.Event;

class AI3 extends Player
{
	private var allValidMoves:Array<Array<Array<Position>>>;
	private var commands:Array<String>;
	private var backup:Array<Position>;
	private var path:Array<Position>;
	
	override public function myTurn ():Int
	{
		if (allValidMoves == null)
		{
			commands = [];
			backup = [];
			path = [];
			
			createVaildMoves ();
			calculator ();
		}
		
		return 0;
	}
	
	private function calculator ():Void
	{
		var data:Array<Array<Int>> = [];
		for (x in 0 ... board.length)
		{
			data [x] = [];
			for (y in 0 ... board [x].length)
				data [x][y] = (board [x][y] == Value.BLOCK_EMPTY) ? 0 : -1;
		}
		
	}
	
	private function jump(cX:int, cY:int, dX:int, dY:int, start:Position, end:Position):Position
	{
		var nextX:int = cX + dX;
		var nextY:int = cY + dY;
	
		if (board [nextX][nextY] != Value.BLOCK_EMPTY) return null;
		if (nextX == end.x && nextY == end.y) return new Position (nextX, nextY);
		
		if (dX != 0 && dY != 0)
		{
			if (/*... Diagonal Forced Neighbor Check ...*/)
				return Node.pooledNode(nextX, nextY);
			
			if (jump(nextX, nextY, dX, 0, start, end) != null ||
				jump(nextX, nextY, 0, dY, start, end) != null)
				return Node.pooledNode(nextX, nextY);
		}
		else
		{
			if (dX != 0)
			{
				if (/*... Horizontal Forced Neighbor Check ...*/)
					return Node.pooledNode(nextX, nextY);
			}
			else
			{
				if (/*... Vertical Forced Neighbor Check ...*/)
					return Node.pooledNode(nextX, nextY);
			}
		}
		
		return jump (nextX, nextY, dX, dY, start, end);
	}
	
	private function createVaildMoves ():Void
	{
		allValidMoves = [];
		for (x in 0 ... board.length)
		{
			allValidMoves [x] = [];
			for (y in 0 ... board [x].length)
			{
				allValidMoves [x][y] = [];
				if (board [x][y] == Value.BLOCK_OBSTACLE) continue;
				if (x > 0 && board [x - 1][y] == Value.BLOCK_EMPTY) 					allValidMoves [x][y].push (new Position (x - 1, y));
				if (y > 0 && board [x][y - 1] == Value.BLOCK_EMPTY) 					allValidMoves [x][y].push (new Position (x, y - 1));
				if (x < Value.MAP_SIZE - 1 && board [x + 1][y] == Value.BLOCK_EMPTY)	allValidMoves [x][y].push (new Position (x + 1, y));
				if (y < Value.MAP_SIZE - 1 && board [x][y + 1] == Value.BLOCK_EMPTY)	allValidMoves [x][y].push (new Position (x, y + 1));
			}
		}
	}
	
	override public function debug (canvas:Board):Void
	{
	}
}
/*
1: for all passable tiles in map do
2: zone(tile) ← free
3: end for
4: currZone ← 1
5: repeat
6: (xLeft, y) ← top and leftmost free tile on the map
7: shrunkR ← shrunkL ← false
8: repeat
9: {Mark line until hit wall or area opens upwards}
10: x ← xLeft
11: zone(x, y) ← currZone
12: while (x + 1, y) = free && (x + 1, y − 1) 6= free do
13: x ← x + 1
14: zone(x, y) ← currZone
15: end while
16: {Stop filling area if right border regrowing}
17: if (x + 1, y − 1) = currZone then
18: shrunkR = true
19: else if (x, y − 1) 6= currZone && shrunkR then
20: {Undo line markings}
21: while (x, y) = currZone do
22: zone(x, y) ← free
23: x ← x − 1
24: end while
25: break
26: end if
27: {Goto same initial x-pos in next line}
28: (x, y) ← (xLeft, y + 1)
29: {If on obstacle, go right in zone until empty}
30: while (x, y) 6= free && zone(x, y − 1) = currZone do
31: x ← x + 1
32: end while
33: {Move further left until wall or opens upward}
34: while (x − 1, y) = free && (x − 1, y − 1) 6= free do
35: x ← x − 1
36: end while
37: {Stop filling area if left border regrowing}
38: if (x − 1, y − 1) = currZone then
39: shrunkL = true
40: else if (x, y − 1) 6= currZone && shrunkL then
41: break
42: end if
43: until break
44: currZone ← currZone + 1
45: until no free tiles are found in map

*/
/* Expectimax 
private function value (state):Int
{
	if (dead) return ...
	if (max) return maxValue (state)
	if (exp) return expValue (state)
}

private function maxValue (state)
{
	initialize v = 0/0
	for (successor in state)
		v = max (v, value (successor))
	return v
}

private function expValue (state)
{
	initialize v = 0
	for (successor in state)
	{
		p = probability (successor)
		v += p * value (successor)
	}
	return v
}
       - 1/2 -- 8
[s] --|- 1/3 -- 24
       - 1/6 -- -12
v = 1/2 * 8 + 1/3 * 24 + 1/6 * -12 => 10

*/