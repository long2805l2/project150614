#pragma once

#include "Position.h"
#include <cstdio>
#include <iostream>

template <class T> struct Map
{
	T *map;
	int width, height;
	Map() { map = NULL; }
	Map(int w, int h) { resize(w,h); }
	
	void resize(int w, int h)
	{
		width = w; height = h;
		map = new T[w*h];
		clear();
	}

	void clear(void) { memset(map, 0, width*height*sizeof(T)); }

	Map(const Map &m) { abort(); }
	// ~Map() { if(map) delete[] map; }

	T& operator()(Position p) { return map[p.x + p.y*width]; }
	T& operator()(int x, int y) { return map[x + y*width]; }
	T& operator()(int idx) { return map[idx]; }
	T& M (Position p) { return map[p.x + p.y*width]; }
	T& M (int x, int y) { return map[x + y*width]; }
	
	int idx (Position p) { return p.x + p.y*width; }
};