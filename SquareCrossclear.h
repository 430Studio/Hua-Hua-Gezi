//
//  SquareCrossclear.h
//  Square
//
//  Created by LIN BOYU on 12/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SquareGame.h"
#import "SquareParticle.h"

//layout
#define CROSSCLEAR_BOARD_POSITION ccp(50,30)

#define CROSSCLEAR_TILEBATCH_POSITION ccpAdd(CROSSCLEAR_BOARD_POSITION,ccp(BOARD_MARGIN,BOARD_MARGIN))

#define CROSSCLEAR_TIMEBAR_POSITION ccp(93,710)

#define CROSSCLEAR_SCORELABEL_POSITION ccp(910,710)

#define CROSSCLEAR_BOARD_ROW 12

#define CROSSCLEAR_BOARD_COLUMN 16

#define CROSSCLEAR_BOARD_TILE_WIDTH 54

#define CROSSCLEAR_BOARD_TILE_HEIGHT 54

#define CROSSCLEAR_COLOR_NUM 9

#define CROSSCLEAR_ROUND_TIME 60

#define CROSSCLEAR_PUNISH_TIME 5

@interface SquareCrossclear : SquareGame {		
	 
	int * tileColors_;
	
	float timeLeft_;	    
	
	//node
	
	CCSprite * board_;
	
	CCProgressBar * timeBar_;
	
	CCLabelBMFont * scoreLabel_;
		
	CCSpriteBatchNode * tileBatch_;
	
	CCSpriteBatchNode * dotBatch_;

	NSMutableArray * tileSprites_;
}

-(id) init;

-(void) dealloc;

-(void) startRound;

-(void) endRound;

-(void) update:(ccTime)dt;

-(int) getRandomColor;

-(void) check:(int)x and:(int)y;

-(void) addDotAt:(int)x and:(int)y;

-(void) fly:(int)p;

-(void) touchBeganAt:(CGPoint)location;

@end
