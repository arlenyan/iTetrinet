//
//  iTetGameViewController.h
//  iTetrinet
//
//  Created by Alex Heinz on 10/7/09.
//

#import <Cocoa/Cocoa.h>
#import "iTetSpecials.h"

@class iTetAppController;
@class iTetBoardView;
@class iTetLocalBoardView;
@class iTetNextBlockView;
@class iTetSpecialsView;
@class iTetPlayer;
@class iTetGameRules;

@interface iTetGameViewController : NSObject
{
	IBOutlet iTetAppController* appController;
	
	// Interface objects
	// Local player's views
	IBOutlet iTetLocalBoardView* localBoardView;
	IBOutlet iTetNextBlockView* nextBlockView;
	IBOutlet iTetSpecialsView* specialsView;
	
	// Remote players' board views
	IBOutlet iTetBoardView* board1;
	IBOutlet iTetBoardView* board2;
	IBOutlet iTetBoardView* board3;
	IBOutlet iTetBoardView* board4;
	IBOutlet iTetBoardView* board5;
	
	// Chat views
	IBOutlet NSTextView* chatView;
	IBOutlet NSTextField* messageField;
	
	// Action history view
	IBOutlet NSTableView* actionListView;
	
	// Assigned board views
	char assignedBoards;
	
	// List of player actions (e.g., specials)
	NSMutableArray* actionHistory;
}

- (IBAction)sendMessage:(id)sender;

- (void)assignBoardToPlayer:(iTetPlayer*)player;
- (void)removeBoardAssignmentForPlayer:(iTetPlayer*)player;

- (void)newGameWithStartingLevel:(int)startLevel
		  initialStackHeight:(int)stackHeight
				   rules:(iTetGameRules*)rules;

- (void)specialUsed:(iTetSpecialType)special
	     byPlayer:(iTetPlayer*)sender
	     onPlayer:(iTetPlayer*)target;
- (void)linesAdded:(int)numLines
	    byPlayer:(iTetPlayer*)sender;
- (void)recordAction:(NSString*)description;

@property (readonly) BOOL gameInProgress;

@end
