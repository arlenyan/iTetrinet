//
//  iTetGameViewController.m
//  iTetrinet
//
//  Created by Alex Heinz on 10/7/09.
//

#import "iTetGameViewController.h"
#import "iTetAppController.h"
#import "iTetLocalPlayer.h"
#import "iTetLocalBoardView.h"
#import "iTetNextBlockView.h"
#import "iTetSpecialsView.h"

#define BOARD_1	0x01
#define BOARD_2	0x02
#define BOARD_3	0x04
#define BOARD_4	0x08
#define BOARD_5	0x10

@implementation iTetGameViewController

#pragma mark -
#pragma mark Interface Actions

- (IBAction)sendMessage:(id)sender
{
	// FIXME: WRITEME
}

#pragma mark -
#pragma mark Player-Board Assignment

- (void)assignBoardToPlayer:(iTetPlayer*)player
{	
	// If this player is the local player, assign the local board and related views
	if ([player isKindOfClass:[iTetLocalPlayer class]])
	{
		[localBoardView setOwner:player];
		[nextBlockView setOwner:player];
		[specialsView setOwner:player];
		return;
	}
	
	// Otherwise, find an un-assigned board, and assign it to the player
	if ((assignedBoards & BOARD_1) == 0)
	{
		[board1 setOwner:player];
		assignedBoards += BOARD_1;
	}
	else if ((assignedBoards & BOARD_2) == 0)
	{
		[board2 setOwner:player];
		assignedBoards += BOARD_2;
	}
	else if ((assignedBoards & BOARD_3) == 0)
	{
		[board3 setOwner:player];
		assignedBoards += BOARD_3;
	}
	else if ((assignedBoards & BOARD_4) == 0)
	{
		[board4 setOwner:player];
		assignedBoards += BOARD_4;
	}
	else if ((assignedBoards & BOARD_5) == 0)
	{
		[board5 setOwner:player];
		assignedBoards += BOARD_5;
	}
	else
	{
		// No available boards (shouldn't happen)
		NSLog(@"Warning: iTetGameController -assignBoardToPlayer: called with no available boards");
	}
}

- (void)removeBoardAssignmentForPlayer:(iTetPlayer*)player
{
	// If this is the local player, remove the local views' owner
	if ([player isKindOfClass:[iTetLocalPlayer class]])
	{
		[localBoardView setOwner:nil];
		[nextBlockView setOwner:nil];
		[specialsView setOwner:nil];
		return;
	}
	
	// Otherwise, find the board belonging to this player
	int playerNum = [player playerNumber];
	if ([[board1 owner] playerNumber] == playerNum)
	{
		[board1 setOwner:nil];
		assignedBoards -= BOARD_1;
	}
	else if ([[board2 owner] playerNumber] == playerNum)
	{
		[board2 setOwner:nil];
		assignedBoards -= BOARD_2;
	}
	else if ([[board3 owner] playerNumber] == playerNum)
	{
		[board3 setOwner:nil];
		assignedBoards -= BOARD_3;
	}
	else if ([[board4 owner] playerNumber] == playerNum)
	{
		[board4 setOwner:nil];
		assignedBoards -= BOARD_4;
	}
	else if ([[board5 owner] playerNumber] == playerNum)
	{
		[board5 setOwner:nil];
		assignedBoards -= BOARD_5;
	}
	else
	{
		// Player is not assigned to a board (shouldn't happen)
		NSLog(@"Warning: iTetGameController -removeBoardAssignmentForPlayer: called with player not assigned to a board");
	}
}

#pragma mark -
#pragma mark Starting a Game

- (void)newGameWithStartingLevel:(int)startLevel
		  initialStackHeight:(int)stackHeight
				   rules:(iTetGameRules*)rules
{
	// Give the players blank boards
	for (iTetPlayer* player in [appController playerList])
		[player setBoard:[iTetBoard board]];
	
	// Give the local player a new board with the given stack height
	[[appController localPlayer] setBoard:[iTetBoard boardWithStackHeight:stackHeight]];
	
	// FIXME: WRITEME
}

#pragma mark -
#pragma mark Accessors

- (BOOL)gameInProgress
{
	// FIXME: WRITEME
	return NO;
}

@end
