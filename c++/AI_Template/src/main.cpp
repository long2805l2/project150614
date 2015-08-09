#include <ai/Game.h>
#include <ai/AI.h>
#include <time.h>
#include <ai/tron.h>
#include <iostream>

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
// - 2 players starts at 2 corners of the game board                  //
// - Each player will take turn to move                                             //
// - Player can only move left/right/up/down and stay inside the game board         //
// - The game is over when one of 2 players cannot make a valid move                //
// - In a competitive match:                                                        //
//   + A player will lose if they cannot connect to server within 10 seconds        //
//   + A player will lose if they don't make a valid move within 3 seconds          //
//////////////////////////////////////////////////////////////////////////////////////

// This function is called automatically each turn.
// If it's your turn, remember to call AI_Move() with a valid move before the time is run out.
// See <ai/Game.h> and <ai/AI.h> for supported APIs.
void AI_Update()
{
	AI *p_ai = AI::GetInstance ();
	if (p_ai->IsMyTurn ())
	{
		int * board = p_ai->GetBoard ();
		Position myPos = p_ai->GetMyPosition ();
		Position enemyPos = p_ai->GetEnemyPosition ();

		Game::GetInstance()->AI_Move (run (board, myPos, enemyPos));
	}
	else
	{
		// Do something while waiting for your opponent
	}
}

////////////////////////////////////////////////////////////
//                DON'T TOUCH THIS PART                   //
////////////////////////////////////////////////////////////

int main(int argc, char* argv[])
{
	system ("call E:\\Workspace\\project150614\\trunk\\nodejs\\vsPC_debug.bat");
	for (int w = 0; w < 2000000; w++);

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
	
	// cout << "Arguments:" << argc << endl;
    // for (int i = 0; i < argc; ++i) cout << argv[i] << endl;
	
	argv [0] = "-h";
	argv [1] = "127.0.0.1";
	argv [2] = "-p";
	argv [3] = "3011";
	argv [4] = "-k";
	argv [5] = "11";
	argv [6] = "";
	argc = 7;
	if (p_Game->Connect(argc, argv) == -1)
	{
		LOG("Failed to connect to server!\n");
		return -1;
	}

	// Set up function pointer
	AI::GetInstance()->Update = &AI_Update;
	
	p_Game->PollingFromServer();

	Game::DestroyInstance();

#ifdef _WIN32
    WSACleanup();
#endif

	return 0;
}