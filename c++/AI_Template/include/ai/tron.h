#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <windows.h>
#include <limits.h>
#include <assert.h>
#include <signal.h>
#include <ai/defines.h>
#include <ai/Position.h>
#include <ai/Map.h>
#include <vector>

#define TIMEOUT_USEC 990000
#define FIRSTMOVE_USEC 2950000
#define DEPTH_INITIAL 1
#define DEPTH_MAX 100
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

bool map_update()
{
	if(!M.map)
	{
		M.resize		(MAP_SIZE, MAP_SIZE);
		dp0.resize		(MAP_SIZE, MAP_SIZE);
		dp1.resize		(MAP_SIZE, MAP_SIZE);
		num.resize		(MAP_SIZE, MAP_SIZE);
		low.resize		(MAP_SIZE, MAP_SIZE);
		articd.resize	(MAP_SIZE, MAP_SIZE);
	}
	for(int i=0;i<M.width;i++) { M(i,0) = 1; M(i,M.height-1)=1; }
	for(int j=0;j<M.height;j++) { M(0,j) = 1; M(M.width-1,j)=1; }
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
		return num_fillable(colorcount(red[component], black[component], 0,0), startcolor);
	}
	// number of fillable squares starting from p (not including p)
	int fillablearea(const Position &p) { return fillablearea(c(p), color(p)); }
	int connectedvalue(int component) { return cedges[component]; }
	int connectedvalue(const Position &p) { return cedges[c(p)]; }
private:
#if 0
	int _find_equiv(std::map<int,int> &equiv, int c) {
		while(true) {
			std::map<int,int>::iterator e = equiv.find(c);
			if(e == equiv.end()) break;
			if(c < e->second)
				c = e->second;
			else
				break;
		}
		return c;
	}
#endif
	void _merge(std::vector<int> &equiv, int o, int n) {
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
			assert(d(u) == radius);
			Q[activeq].pop_back();
			for(int m=0;m<4;m++) {
				Position v = u.next(m);
				if(M(v)) continue;
				int dist = d(v);
				if(dist == INT_MAX) {
					Q[activeq^1].push_back(v);
					d(v) = 1+d(u);
				} else {
					assert(1+d(u) >= dist);
				}
			}
		}
		activeq ^= 1;
		radius++;
	} while(!Q[activeq].empty());

	assert(Q[0].empty());
	assert(Q[1].empty());
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
	colorcount ccount0 = max_articulated_space(&dp0, &dp1, s.p[0]),
						 ccount1 = max_articulated_space(&dp1, &dp0, s.p[1]);
	int nc0_ = K1*(ccount0.front + num_fillable(ccount0, color(s.p[0]))) + K2*ccount0.edges,
			nc1_ = K1*(ccount1.front + num_fillable(ccount1, color(s.p[1]))) + K2*ccount1.edges;
	M(s.p[0])=1; M(s.p[1])=1;
	int nodecount = nc0_ - nc1_;
#if VERBOSE >= 2
	if(vis) {
		for(int j=0;j<M.height;j++) {
			/*
			for(int i=0;i<M.width;i++) {
				if(dp0(i,j) == INT_MAX) fprintf(stderr,M(i,j) ? " #" : "	");
				else fprintf(stderr,"%2d", dp0(i,j));
			}
			fprintf(stderr," ");
			for(int i=0;i<M.width;i++) {
				if(dp1(i,j) == INT_MAX) fprintf(stderr,M(i,j) ? " #" : "	");
				else fprintf(stderr,"%2d", dp1(i,j));
			}
			fprintf(stderr," ");
			*/
			fprintf(stderr, "~~~ ");
			for(int i=0;i<M.width;i++) {
				int d = dp1(i,j)-dp0(i,j);
				if(Position(i,j) == s.p[0])
					fprintf(stderr,"A");
				else if(Position(i,j) == s.p[1])
					fprintf(stderr,"B");
				else if(articd(i,j))
					fprintf(stderr,d<0 ? "x" : "o");
				else if(d == INT_MAX || d == -INT_MAX || M(i,j))
					fprintf(stderr,"#");
				else if(d == 0)
					fprintf(stderr, ".");
				else {
					d = d<0 ? 2 : d>0 ? 1 : 0;
					fprintf(stderr,"%d", d);
				}
			}
			fprintf(stderr,"\n");
		}
		fprintf(stderr, "nodecount: %d 0: %d/(r%db%de%dT%d), 1: %d/(r%db%de%dT%d)\n", nodecount,
						nc0_, ccount0.red, ccount0.black, ccount0.edges, cp.fillablearea(s.p[0]),
						nc1_, ccount1.red, ccount1.black, ccount1.edges, cp.fillablearea(s.p[1]));
#if 0
		for(int j=0;j<M.height;j++) {
			for(int i=0;i<M.width;i++) {
				if(num(i,j) == 0) fprintf(stderr,"	%c", M(i,j) ? '#' : '.');
				else fprintf(stderr,"%3d", num(i,j));
			}
			fprintf(stderr," ");
			for(int i=0;i<M.width;i++) {
				if(low(i,j) == 0) fprintf(stderr,"	%c", M(i,j) ? '#' : '.');
				else fprintf(stderr,"%3d", low(i,j));
			}
			fprintf(stderr," ");
			for(int i=0;i<M.width;i++) {
				int d = num(i,j)-low(i,j);
				if(num(i,j) == 0)
					fprintf(stderr, " #");
				else if(d <= 0)
					fprintf(stderr," *");
				else fprintf(stderr," .");
			}
			fprintf(stderr,"\n");
		}
#endif
	}
#endif
	return nodecount;
}

static int evaluations=0;
static int _evaluate_board(gamestate s, int player, bool vis=false)
{
	assert(player == 0); // we're always searching an even number of plies

	// remove players from the board when evaluating connected components,
	// because if a player is separating components he still gets to choose which
	// one to move into.
	M(s.p[0]) = 0; M(s.p[1]) = 0;
	Components cp(M); // pre-move components
	M(s.p[0]) = 1; M(s.p[1]) = 1;

	if(s.p[0] == s.p[1])
		return 0; // crash!

	evaluations++;
#if VERBOSE >= 2
	if(vis) {
		fprintf(stderr, "evaluating board: \n");
		M(s.p[0]) = 2; M(s.p[1]) = 3; M.dump();
		M(s.p[0]) = 1; M(s.p[1]) = 1;
	}
#endif
	int comp;
	// follow the maximum territory gain strategy until we partition
	// space or crash
	if((comp = cp.component(s.p[0])) == cp.component(s.p[1])) {
		int v = _evaluate_territory(s, cp, comp, vis);
		return v;
	}

	reset_articulations();
	M(s.p[0])=0; M(s.p[1])=0;
	calc_articulations(NULL, NULL, s.p[0]);
	calc_articulations(NULL, NULL, s.p[1]);

	colorcount ccount0 = max_articulated_space(NULL, NULL, s.p[0]);
	colorcount ccount1 = max_articulated_space(NULL, NULL, s.p[1]);
	int ff0 = num_fillable(ccount0, color(s.p[0])),
			ff1 = num_fillable(ccount1, color(s.p[1]));
	int v = 10000*(ff0-ff1);
	// if our estimate is really close, try some searching
	if(v != 0 && abs(v) <= 30000) {
		int _m;
// #if VERBOSE >= 2
		// if(vis) fprintf(stderr, "num_fillable %d %d too close to call; searching\n", ff0, ff1);
// #endif
		ff0 = _spacefill(_m, cp, s.p[0], 3);
		ff1 = _spacefill(_m, cp, s.p[1], 3);
		v = 10000*(ff0-ff1);
	}
	if(player == 1) v = -v;
// #if VERBOSE >= 2
	// if(vis) {
		// fprintf(stderr, "player=%d connectedarea value: %d (0:%d/%d/%d 1:%d/%d/%d)\n", player, v, ff0,cf0,cc0, ff1,cf1,cc1);
	// }
// #endif
	M(s.p[0])=1; M(s.p[1])=1;
	return v;
}
// }}}

// {{{ alpha-beta iterative deepening search

// do an iterative-deepening search on all moves and see if we can find a move
// sequence that cuts off our opponent
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
		for(m=0;m<4;m++) if(!M(s.p[player].next(m))) break;
		*moves = m;
		return INT_MAX;
	}

	if(_timed_out) {
#if VERBOSE >= 1
		fprintf(stderr, "timeout; a=%d b=%d itr=%d\n", a,b,itr);
#endif
		return a;
	}

	// last iteration?
	if(itr == 0) {
#if VERBOSE >= 3
		int v = _evaluate_board(s, player, true);
		fprintf(stderr, "_alphabeta(itr=%d [%d,%d,%d]|[%d,%d,%d] p=%d a=%d b=%d) -> %d\n",
						itr, s.p[0].x, s.p[0].y, s.m[0],
						s.p[1].x, s.p[1].y, s.m[1], player, a,b,v);
#else
		int v = _evaluate_board(s, player);
#endif
		return v;
	}
#if VERBOSE >= 3
	fprintf(stderr, "_alphabeta(itr=%d [%d,%d,%d]|[%d,%d,%d] p=%d a=%d b=%d)\n",
					itr, s.p[0].x, s.p[0].y, s.m[0],
					s.p[1].x, s.p[1].y, s.m[1], player, a,b);
#endif

#if 0
	// "singularity enhancement": if we have only one valid move, then just
	// deepen the search assuming that move without using up an iteration count
	if(dp0 == 1) {
		// choose only move
		int m;
		for(m=0;m<4;m++) if(!M(s.p[player].next(m))) break;
		gamestate r = s;
		r.m[player] = m;
		if(player == 1) {
			r.p[0] = s.p[0].next(r.m[0]);
			r.p[1] = s.p[1].next(r.m[1]);
			M(r.p[0]) = 1;
			M(r.p[1]) = 1;
		}
		*moves = m;
		int a_ = -_alphabeta(moves+1, r, player^1, -b, -a, itr + (player == 0 ? 1 : -1));
		// undo game state update
		if(player == 1) {
			M(r.p[0]) = 0;
			M(r.p[1]) = 0;
			r.p[0] = s.p[0];
			r.p[1] = s.p[1];
		}
		return a_;
	}
#endif

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

		if(_timed_out) // a_ is garbage if we timed out
			return -INT_MAX;

		if(a >= b) // beta cut-off
			break;
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
#if VERBOSE >= 1
		struct timeval tv;
		gettimeofday(&tv, NULL);
		fprintf(stderr, "%d.%06d: v=%d m=[", (int) tv.tv_sec, (int) tv.tv_usec, v);
		for(int i=0;i<(itr < 10 ? itr*2 : 20);i++) fprintf(stderr, "%d", move_permute[(int)moves[i]]);
		fprintf(stderr, "] @depth %d _ab_runs=%d\n", itr*2, _ab_runs);
#endif

		if(v == INT_MAX)
			return moves[0];

		if(v == -INT_MAX)
			break;
		
		lastv = v;
		lastm = moves[0];
		memcpy(_killer, moves, itr*2);
	}
#if VERBOSE >= 1
	long e = elapsed_time();
	float rate = (float)evaluations*1000000.0/(float)e;
	fprintf(stderr, "%d evals in %ld us; %0.1f evals/sec; lastv=%d move=%d\n", evaluations, e, rate, lastv, move_permute[lastm]);
	if(e > TIMEOUT_USEC*11/10) {
		fprintf(stderr, "10%% timeout violation: %ld us\n", e);
	}
#endif
	memmove(_killer, _killer+2, sizeof(_killer)-2); // shift our best-move tree forward to accelerate next move's search
	return lastm;
}

static int next_move()
{
	Components cp (M);
	
#if VERBOSE >= 2
	cp.dump();
	_evaluate_board(curstate, 0, true);
#endif
	
	M(curstate.p[0]) = 1;
	M(curstate.p[1]) = 1;
	
	if (cp.component (curstate.p[0]) == cp.component (curstate.p[1]))
		return next_move_alphabeta ();

	return next_move_spacefill(cp);
}

int run (int argc, char **argv)
{
	if (argc>1 && atoi(argv[1]))
	{
		Position p = curstate.p[0];
		curstate.p[0] = curstate.p[1];
		curstate.p[1] = p;
	}

	// firstmove=false;
	return move_permute [next_move()];
}