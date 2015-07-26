#pragma once

#include <cstdio>
#include <iostream>

static char dx [4] = {-1, 0, 1, 0};
static char dy [4] = {0, -1, 0, 1};

struct Position
{
	int x;
	int y;
	Position() : x(0), y(0) {}
	Position(int _x, int _y) : x(_x), y(_y) {}
	Position operator =(Position pos) {x = pos.x; y = pos.y; return *this;}
	bool operator ==(Position pos) {return x == pos.x && y == pos.y;}

	// static const char dx [4];
	// static const char dy [4];
	Position next (int move) const { return Position (x + dx [move], y + dy [move]); }
	Position prev (int move) const { return Position (x - dx [move], y - dy [move]); }
};