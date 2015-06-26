#include <ai/Game.h>
#include <ai/AI.h>
#include <time.h>

// ==================== HOW TO RUN THIS =====================
// Call:
// "AI_Template.exe -h [host] -p [port] -k [key]"
//
// If no argument given, it'll be 127.0.0.1:3011
// key is a secret string that authenticate the bot identity
// it is not required when testing
// ===========================================================

//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
//                                    GAME RULES                                    //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////
// - Game board is an array of MAP_SIZExMAP_SIZE blocks                             //
// - 2 players starts at 2 corners of the game board                                //
// - Each player will take turn to move                                             //
// - Player can only move left/right/up/down and stay inside the game board         //
// - The game is over when one of 2 players cannot make a valid move                //
// - In a competitive match:                                                        //
//   + A player will lose if they cannot connect to server within 10 seconds        //
//   + A player will lose if they don't make a valid move within 3 seconds          //
//////////////////////////////////////////////////////////////////////////////////////

// This function is called automatically when it's your turn.
// Remember to call AI_Move() with a valid move before the time is run out.
// See <ai/Game.h> and <ai/AI.h> for supported APIs.
void AI_Update()
{
	AI *p_ai = AI::GetInstance();
	int * board = p_ai->GetBoard();	// Access block at (x, y) by using board[CONVERT_COORD(x,y)]
	Position myPos = p_ai->GetMyPosition();
	Position enemyPos = p_ai->GetEnemyPosition();

	//Just a silly bot with random moves
	vector<int> freeMoves;
	if(myPos.x > 0 && p_ai->GetBlock(Position(myPos.x - 1, myPos.y)) == BLOCK_EMPTY)
	{
		freeMoves.push_back(DIRECTION_LEFT);
	}
	if(myPos.x < MAP_SIZE-1 && p_ai->GetBlock(Position(myPos.x + 1, myPos.y)) == BLOCK_EMPTY)
	{
		freeMoves.push_back(DIRECTION_RIGHT);
	}
	if(myPos.y > 0 && p_ai->GetBlock(Position(myPos.x, myPos.y - 1)) == BLOCK_EMPTY)
	{
		freeMoves.push_back(DIRECTION_UP);
	}
	if(myPos.y < MAP_SIZE-1 && p_ai->GetBlock(Position(myPos.x, myPos.y + 1)) == BLOCK_EMPTY)
	{
		freeMoves.push_back(DIRECTION_DOWN);
	}

	int size = freeMoves.size();
	if(size > 0)
	{
		int direction = freeMoves[rand() % size];
		LOG("Move: %d\n", direction);

		//Remember to call AI_Move() within allowed time
		Game::GetInstance()->AI_Move(direction);
	}
	else
	{
		LOG("Damn, I was trapped!\n");
	}
}

////////////////////////////////////////////////////////////
//                DON'T TOUCH THIS PART                   //
////////////////////////////////////////////////////////////

int main(int argc, char* argv[])
{
	srand(clock());
	
#ifdef _WIN32
    INT rc;
    WSADATA wsaData;

    rc = WSAStartup(MAKEWORD(2, 2), &wsaData);
    if (rc) {
        printf("WSAStartup Failed.\n");
        return 1;
    }
#endif

	Game::CreateInstance();
	Game * p_Game = Game::GetInstance();
	
	// Create connection
	if (p_Game->Connect(argc, argv) == -1)
	{
		LOG("Failed to connect to server!\n");
		return -1;
	}

	// Set up function pointer
	AI::GetInstance()->Update = &AI_Update;
	
	// Polling every 100ms until the connection is dead
    p_Game->PollingFromServer(100);

	Game::DestroyInstance();

#ifdef _WIN32
    WSACleanup();
#endif
	return 0;
}