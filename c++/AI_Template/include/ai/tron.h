#include <stdio.h>
#include <iostream>
#include <stdlib.h>
#include <string.h>
#include <windows.h>
#include <limits.h>
#include <assert.h>
#include <csignal>
// #include <signal.h>
#include <process.h>
#include <ai/defines.h>
#include <ai/Position.h>
#include <ai/Map.h>
#include <vector>

#define TIMEOUT_USEC 990000
#define FIRSTMOVE_USEC 2950000
#define DEPTH_INITIAL 1
#define DEPTH_MAX 10
#define DRAW_PENALTY 0 // -itr // -500
#define VERBOSE 0

#define K1 55
#define K2 194
#define K3 3

const int move_permute[4]={1,3,2,4};

static inline int _min(int a, int b) { return a<b ? a : b; }
static inline int _max(int a, int b) { return a>b ? a : b; }

struct gamestate
{
	Position p[2];
	int m[2];

	gamestate move(Map<char> M)
	{
		gamestate s = *this;
		M(p[0]) = 1;
		M(p[1]) = 1;
		s.p[0] = p[0].next(m[0]);
		s.p[1] = p[1].next(m[1]);
		return s;
	}
	
	void unmove(Map<char> M)
	{
		M(p[0]) = 0;
		M(p[1]) = 0;
	}
};

static Map<char> M;
static Map<int> dp0, dp1;
static Map<int> low, num, articd;
static gamestate curstate;
static char _killer[DEPTH_MAX*2+2];
static int _maxitr=0;

bool map_update (int * board, Position myPos, Position enemyPos)
{
	if (!M.map)
	{
		M.resize		(MAP_SIZE + 2, MAP_SIZE + 2);
		dp0.resize		(MAP_SIZE + 2, MAP_SIZE + 2);
		dp1.resize		(MAP_SIZE + 2, MAP_SIZE + 2);
		num.resize		(MAP_SIZE + 2, MAP_SIZE + 2);
		low.resize		(MAP_SIZE + 2, MAP_SIZE + 2);
		articd.resize	(MAP_SIZE + 2, MAP_SIZE + 2);
	}
	
	for (int x = 0; x < MAP_SIZE; x++)
	{
		for (int y = 0; y < MAP_SIZE; y++)
		{
			int b = board [CONVERT_COORD(x,y)];
			if (b == BLOCK_EMPTY)
			{
				M (x + 1, y + 1) = 0;
				cout << '.';
			}
			else
			{
				M (x + 1, y + 1) = 1;
				cout << '0';
			}
		}
		cout<<endl;
	}
	
	// for(int i=0;i<M.width;i++) { M(i,0) = 1; M(i,M.height-1)=1; }
	// for(int j=0;j<M.height;j++) { M(0,j) = 1; M(M.width-1,j)=1; }
	myPos = Position (myPos.x + 1, myPos.y + 1); 
	enemyPos = Position (enemyPos.x + 1, enemyPos.y + 1); 
	M (myPos) = 0;
	M (enemyPos) = 0;
	curstate.p [0] = myPos;
	curstate.p [1] = enemyPos;
	curstate.m [0] = 0;
	curstate.m [1] = 0;
	
	return true;
}

static inline int color(Position x) { return (x.x ^ x.y)&1; }
static inline int color(int x, int y) { return (x ^ y)&1; }

struct colorcount
{
	int red, black, edges, front;
	colorcount() {}
	colorcount(int r, int b, int e, int f): red(r), black(b), edges(e), front(f) {}
	int& operator()(const Position &x) { return color(x) ? red : black; }
};

static colorcount operator+(const colorcount &a, const colorcount &b) { return colorcount(a.red+b.red, a.black+b.black, a.edges+b.edges, a.front+b.front); }

int num_fillable(const colorcount &c, int startcolor) {
	if(startcolor)
		return 2*_min(c.red-1, c.black) + (c.black >= c.red ? 1 : 0);
	
	return 2*_min(c.red, c.black-1) + (c.red >= c.black ? 1 : 0);
}

static int degree(Position x)
{
	int idx = x.x+x.y*M.width;
	return 4 - M(idx-1) - M(idx+1) - M(idx-M.width) - M(idx+M.width);
}

static int degree(int idx)
{
	return 4 - M(idx-1) - M(idx+1) - M(idx-M.width) - M(idx+M.width);
}

static int neighbors(Position s)
{
	return (M(s.x-1, s.y-1)
	|	(M(s.x	, s.y-1)<<1)
	|	(M(s.x+1, s.y-1)<<2)
	|	(M(s.x+1, s.y	)<<3)
	|	(M(s.x+1, s.y+1)<<4)
	|	(M(s.x	, s.y+1)<<5)
	|	(M(s.x-1, s.y+1)<<6)
	|	(M(s.x-1, s.y	)<<7));
}

static char _potential_articulation[256] = {
	0,0,0,0,0,1,0,0,0,1,0,0,0,1,0,0,
	0,1,1,1,1,1,1,1,0,1,0,0,0,1,0,0,
	0,1,1,1,1,1,1,1,0,1,0,0,0,1,0,0,
	0,1,1,1,1,1,1,1,0,1,0,0,0,1,0,0,
	0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
	0,1,1,1,1,1,1,1,0,1,0,0,0,1,0,0,
	0,1,1,1,1,1,1,1,0,1,0,0,0,1,0,0,
	0,0,0,0,1,1,0,0,1,1,0,0,1,1,0,0,
	1,1,1,1,1,1,1,1,1,1,0,0,1,1,0,0,
	0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,1,1,0,0,1,1,0,0,1,1,0,0,
	1,1,1,1,1,1,1,1,1,1,0,0,1,1,0,0,
	0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0
};

static int potential_articulation(Position s) { return _potential_articulation[neighbors(s)]; }

struct Components
{
	Map<int> c;
	std::vector<int> cedges, red, black;

	Components(Map<char> &M): c(M.width, M.height) { recalc(); }

	void recalc(void) {
		static std::vector<int> equiv;
		equiv.clear(); equiv.push_back(0);
		cedges.clear(); red.clear(); black.clear();
		int nextclass = 1;
		int mapbottom = M.width*(M.height-1)-1;
		for(int idx=M.width+1;idx<mapbottom;idx++) {
			if(M(idx)) continue; // wall
			int cup	 = equiv[c(idx-M.width)],
					cleft = equiv[c(idx-1)];
			if(cup == 0 && cleft == 0) { // new component
				equiv.push_back(nextclass);
				c(idx) = nextclass++;
			} else if(cup == cleft) { // existing component
				c(idx) = cup;
			} else { // join components
				// deprecate the higher-numbered component in favor of the lower
				if(cleft == 0 || (cup != 0 && cup < cleft)) {
					c(idx) = cup;
					if(cleft != 0) _merge(equiv, cleft, cup);
				} else {
					c(idx) = cleft;
					if(cup != 0) _merge(equiv, cup, cleft);
				}
			}
		}
		cedges.resize(nextclass, 0);
		red.resize(nextclass, 0);
		black.resize(nextclass, 0);
		// now make another pass to translate equivalences and compute connected area
		for(int j=1,idx=M.width+1;j<M.height-1;j++,idx+=2) {
			for(int i=1;i<M.width-1;i++,idx++) {
				int e = equiv[c(idx)];
				c(idx) = e;
				cedges[e] += degree(idx);
				if(color(i,j)) red[e] ++; else black[e] ++;
			}
		}
	}

	void remove(Position s) {
		c(s) = 0;
		if(potential_articulation(s)) {
			recalc();
		} else {
			cedges[c(s)] -= 2*degree(s);
			if(color(s)) red[c(s)] --; else black[c(s)] --;
		}
	}
	void add(Position s) {
		for(int m=0;m<4;m++) {
			Position r = s.next(m);
			if(M(r)) continue;
			if(c(s) != 0 && c(s) != c(r)) { recalc(); return; }
			c(s) = c(r);
		}
		cedges[c(s)] += 2*degree(s);
		if(color(s)) red[c(s)] ++; else black[c(s)] ++;
	}
	
	int component(const Position &p) { return c(p); }
	int connectedarea(int component) { return red[component]+black[component]; }
	int connectedarea(const Position &p) { return red[c(p)]+black[c(p)]; }
	// number of fillable squares in area when starting on 'startcolor' (assuming starting point is not included)
	int fillablearea(int component, int startcolor) {
		return num_fillable(
		colorcount(red[component],
		black[component], 0,0),
		startcolor);
	}
	// number of fillable squares starting from p (not including p)
	int fillablearea(const Position &p) { return fillablearea(c(p), color(p)); }
	int connectedvalue(int component) { return cedges[component]; }
	int connectedvalue(const Position &p) { return cedges[c(p)]; }
private:
	void _merge(std::vector<int> &equiv, int o, int n)
	{
		for(size_t k=0;k<equiv.size();k++)
			if(equiv[k] == o) equiv[k] = n;
	}
};

long getTime()
{
	return GetTickCount ();
}

static long _timer, _timeout;
static volatile bool _timed_out = false;
static int _ab_runs=0;
static int _spacefill_runs=0;

static void _alrm_handler(int sig) { _timed_out = true; }

static void reset_timer(long t)
{
	_timer = getTime();
	// itimerval timer;
	// memset(&timer, 0, sizeof(timer));
	// timer.it_value.tv_sec = t/1000000;
	// timer.it_value.tv_usec = t%1000000;
	// setitimer(ITIMER_REAL, &timer, NULL);
	_timed_out = false;
	_ab_runs = 0;
	_spacefill_runs = 0;
	_timeout = t;
}

static long elapsed_time() { return getTime() - _timer; }

static void dijkstra(Map<int> &d, const Position &s, Components &cp, int component)
{
	static std::vector<Position> Q[2];
	size_t activeq=0;
	int siz = M.width*M.height;
	for(int idx=0;idx<siz;idx++)
		d(idx) = INT_MAX;

	Q[0].push_back(s);
	d(s) = 0;
	int radius = 0;
	do {
		while(!Q[activeq].empty())
		{
			Position u = Q[activeq].back();
			// assert(d(u) == radius);
			Q[activeq].pop_back();
			for(int m=0;m<4;m++) {
				Position v = u.next(m);
				if(M(v)) continue;
				int dist = d(v);
				if(dist == INT_MAX) {
					Q[activeq^1].push_back(v);
					d(v) = 1+d(u);
				} else {
					// assert(1+d(u) >= dist);
				}
			}
		}
		activeq ^= 1;
		radius++;
	} while(!Q[activeq].empty());

	// assert(Q[0].empty());
	// assert(Q[1].empty());
}

static int floodfill(Components &ca, Position s, bool fixup=true)
{
	int bestv=0;
	Position b = s;
	for(int m=0;m<4;m++)
	{
		Position p = s.next(m);
		if(M(p)) continue;
		int v = ca.connectedvalue(p) + ca.fillablearea(p) - 2 * degree(p) - 4 * potential_articulation (p);
		if(v > bestv) { bestv = v; b = p; }
	}
	if(bestv == 0)
		return 0;
	M(b) = 1; ca.remove(b);
	int a = 1+floodfill(ca, b);
	M(b) = 0; if(fixup) ca.add(b);
	return a;
}

static int _spacefill(int &move, Components &ca, Position p, int itr)
{
	int bestv = 0;
	int spacesleft = ca.fillablearea(p);
	
	if(degree(p) == 0)
	{
		move=1;
		return 0;
	}
	
	if(_timed_out) return 0;
	
	if(itr == 0) return floodfill(ca, p);
	
	for(int m = 0; m < 4 && !_timed_out; m++)
	{
		Position r = p.next(m);
	
		if(M(r)) continue;
		M(r) = 1;
		ca.remove(r);
		
		int _m, v = 1+_spacefill(_m, ca, r, itr-1);
		
		M(r) = 0;
		ca.add(r);
		
		if (v > bestv)
		{
			bestv = v;
			move = m;
		}
		
		if (v == spacesleft) break;
		
		if (itr == 0) break;
	}
	
	return bestv;
}

static int next_move_spacefill(Components &ca)
{
	int itr;
	int area = ca.fillablearea(curstate.p[0]);
	int bestv = 0, bestm = 1;
	
	for(itr=DEPTH_INITIAL;itr<DEPTH_MAX && !_timed_out; itr++)
	{
		cout<<"next_move_spacefill: "<<itr<<endl;
		int m;
		_maxitr = itr;
		int v = _spacefill(m, ca, curstate.p[0], itr);
		if(v > bestv) { bestv = v; bestm = m; }
		if(v <= itr) break;
		if(v >= area) break;
	}
	return bestm;
}

static int _art_counter=0;
static void reset_articulations()
{
	_art_counter=0;
	low.clear();
	num.clear();
	articd.clear();
}

static int calc_articulations(Map<int> *dp0, Map<int> *dp1, const Position &v, int parent=-1)
{
	int nodenum = ++_art_counter;
	low(v) = num(v) = nodenum;
	int children=0;
	int count=0;
	for(int m=0;m<4;m++)
	{
		Position w = v.next(m);
		if(M(w)) continue;
		if(dp0 && (*dp0)(w) >= (*dp1)(w)) continue;
		if(!num(w))
		{
			children++;
			count += calc_articulations(dp0, dp1, w, nodenum);
			if(low(w) >= nodenum && parent != -1)
			{
				articd(v) = 1;
				count++;
			}
			if(low(w) < low(v)) low(v) = low(w);
		}
		else
		{
			if(num(w) < nodenum)
				if(num(w) < low(v))
					low(v) = num(w);
		}
	}
	
	if(parent == -1 && children > 1)
	{
		count++;
		articd(v) = 1;
	}
	return count;
}

static colorcount _explore_space(Map<int> *dp0, Map<int> *dp1, std::vector<Position> &exits, const Position &v)
{
	colorcount c(0,0,0,0);
	if(num(v) == 0) return c;
	c(v) ++;
	num(v) = 0;
	if(articd(v))
	{
		for(int m=0;m<4;m++)
		{
			Position w = v.next(m);
			if(M(w)) continue;
			c.edges++;
			if(dp0 && (*dp0)(w) >= (*dp1)(w)) { c.front=1; continue; }
			if(!num(w)) continue;
			exits.push_back(w);
		}
	}
	else
	{
		for(int m=0;m<4;m++)
		{
			Position w = v.next(m);
			if(M(w)) continue;
			c.edges++;
			
			if (dp0 && (*dp0)(w) >= (*dp1)(w))
			{
				c.front = 1;
				continue;
			}

			if(!num(w)) continue;
			if(articd(w))
			{
				exits.push_back(w);
			}
			else
			{
				c = c + _explore_space(dp0,dp1,exits,w);
			}
		}
	}
	return c;
}

static colorcount max_articulated_space(Map<int> *dp0, Map<int> *dp1, const Position &v)
{
	std::vector<Position> exits;
	colorcount space = _explore_space(dp0,dp1,exits,v);
	
	colorcount maxspace = space;
	int maxsteps=0;
	int entrancecolor = color(v);
	int localsteps[2] = {
		num_fillable(colorcount(space.red, space.black+1, 0,0), entrancecolor),
		num_fillable(colorcount(space.red+1, space.black, 0,0), entrancecolor)
	};

	for(size_t i=0;i<exits.size();i++)
	{
		int exitcolor = color(exits[i]);
		colorcount child = max_articulated_space(dp0,dp1,exits[i]);
		int steps = num_fillable(child, exitcolor);
		if(!child.front) steps += localsteps[exitcolor];
		else steps += (*dp0)(exits[i])-1;
		
		if(steps > maxsteps)
		{
			maxsteps=steps;
			if(!child.front)
			{
				maxspace = space + child;
			}
			else
			{
				maxspace = child;
			}
		}
	}
	return maxspace;
}

static int _evaluate_territory(const gamestate &s, Components &cp, int comp, bool vis)
{
	dijkstra(dp0, s.p[0], cp, comp);
	dijkstra(dp1, s.p[1], cp, comp);
	reset_articulations();
	M(s.p[0])=0; M(s.p[1])=0;
	calc_articulations(&dp0, &dp1, s.p[0]);
	calc_articulations(&dp1, &dp0, s.p[1]);
	colorcount ccount0 = max_articulated_space(&dp0, &dp1, s.p[0]);
	colorcount ccount1 = max_articulated_space(&dp1, &dp0, s.p[1]);
	int nc0_ = K1*(ccount0.front + num_fillable(ccount0, color(s.p[0]))) + K2*ccount0.edges;
	int nc1_ = K1*(ccount1.front + num_fillable(ccount1, color(s.p[1]))) + K2*ccount1.edges;
	M(s.p[0])=1; M(s.p[1])=1;
	int nodecount = nc0_ - nc1_;
	return nodecount;
}

static int evaluations=0;
static int _evaluate_board(gamestate s, int player, bool vis=false)
{
	// assert(player == 0);
	
	M(s.p[0]) = 0; M(s.p[1]) = 0;
	Components cp(M);
	M(s.p[0]) = 1; M(s.p[1]) = 1;

	if(s.p[0] == s.p[1]) return 0;

	evaluations++;
	
	int comp;
	if((comp = cp.component(s.p[0])) == cp.component(s.p[1]))
	{
		int v = _evaluate_territory(s, cp, comp, vis);
		return v;
	}

	reset_articulations();
	M(s.p[0])=0; M(s.p[1])=0;
	calc_articulations(NULL, NULL, s.p[0]);
	calc_articulations(NULL, NULL, s.p[1]);

	colorcount ccount0 = max_articulated_space(NULL, NULL, s.p[0]);
	colorcount ccount1 = max_articulated_space(NULL, NULL, s.p[1]);
	int ff0 = num_fillable(ccount0, color(s.p[0])); 
	int ff1 = num_fillable(ccount1, color(s.p[1]));
	int v = 10000*(ff0-ff1);
	
	if(v != 0 && abs(v) <= 30000)
	{
		int _m;
		
		ff0 = _spacefill(_m, cp, s.p[0], 3);
		ff1 = _spacefill(_m, cp, s.p[1], 3);
		v = 10000*(ff0-ff1);
	}

	if(player == 1) v = -v;
	
	M(s.p[0])=1; M(s.p[1])=1;
	return v;
}

static int _alphabeta(char *moves, gamestate s, int player, int a, int b, int itr)
{
	// base cases: no more moves?	draws?
	*moves=1; // set default move
	_ab_runs++;
	if(s.p[0] == s.p[1]) { return DRAW_PENALTY; } // crash!	draw!
	int dp0 = degree(s.p[player]),
			dp1 = degree(s.p[player^1]);
	if(dp0 == 0) {
		if(dp1 == 0) { // both boxed in; draw
			return DRAW_PENALTY;
		}
		return -INT_MAX;
	}
	if(dp1 == 0) {
		// choose any move
		int m;
		for (m=0;m<4;m++) if(!M(s.p[player].next(m))) break;
		*moves = m;
		return INT_MAX;
	}

	if (_timed_out) {
		return a;
	}

	// last iteration?
	if(itr == 0) {
		int v = _evaluate_board(s, player);
		return v;
	}

	// periodically check timeout.	if we do time out, give up, we can't do any
	// more work; whatever we found so far will have to do
	int kill = _killer[_maxitr-itr];
	char bestmoves[DEPTH_MAX*2+2];
	memset(bestmoves, 0, itr);
	for(int _m=-1;_m<4 && !_timed_out;_m++) {
		// convoluted logic: do "killer heuristic" move first
		if(_m == kill) continue;
		int m = _m == -1 ? kill : _m;
		if(M(s.p[player].next(m))) // impossible move?
			continue;
		gamestate r = s;
		r.m[player] = m;
		// after both players 0 and 1 make their moves, the game state updates
		if(player == 1) {
			r.p[0] = s.p[0].next(r.m[0]);
			r.p[1] = s.p[1].next(r.m[1]);
			M(r.p[0]) = 1;
			M(r.p[1]) = 1;
		}
		int a_ = -_alphabeta(moves+1, r, player^1, -b, -a, itr-1);
		if(a_ > a) {
			a = a_;
			bestmoves[0] = m;
			_killer[_maxitr-itr] = m;
			memcpy(bestmoves+1, moves+1, itr-1);
		}
		// undo game state update
		if(player == 1) {
			M(r.p[0]) = 0;
			M(r.p[1]) = 0;
			r.p[0] = s.p[0];
			r.p[1] = s.p[1];
		}

		if(_timed_out) return -INT_MAX;

		if(a >= b) break;
	}
	memcpy(moves, bestmoves, itr);
	return a;
}

static int next_move_alphabeta ()
{
	int itr;
	int lastv = -INT_MAX, lastm = 1;
	evaluations=0;
	char moves[DEPTH_MAX*2+2];
	memset(moves, 0, sizeof(moves));

	for(itr=DEPTH_INITIAL;itr<DEPTH_MAX && !_timed_out;itr++)
	{
		_maxitr = itr*2;
		int v = _alphabeta(moves, curstate, 0, -INT_MAX, INT_MAX, itr*2);

		if(v == INT_MAX) return moves[0];

		if(v == -INT_MAX) break;
		
		lastv = v;
		lastm = moves[0];
		memcpy(_killer, moves, itr*2);
	}
	
	memmove(_killer, _killer+2, sizeof(_killer)-2); // shift our best-move tree forward to accelerate next move's search
	return lastm;
}

static int next_move()
{
	cout<<"next move"<<endl;
	Components cp (M);
	
	M(curstate.p[0]) = 1;
	M(curstate.p[1]) = 1;
	
	if (cp.component (curstate.p[0]) == cp.component (curstate.p[1]))
	{
		cout<<"use next_move_alphabeta"<<endl;
		return next_move_alphabeta ();
	}
	
	cout<<"use next_move_spacefill"<<endl;
	return next_move_spacefill(cp);
}

void  silly( void *arg )
{
    cout <<"The silly() function was passed"<<endl;
}

int run (int * board, Position myPos, Position enemyPos)
{
	_beginthread( silly, 0, (void*)12 );
	
	memset (_killer, 0, sizeof(_killer));
	// signal (SIGINT, _alrm_handler);
	// setlinebuf (stdout);
	
	if (map_update (board, myPos, enemyPos))
	{
		// Position p = curstate.p[0];
		// curstate.p[0] = curstate.p[1];
		// curstate.p[1] = p;
	}
	
	return move_permute[next_move()];
}