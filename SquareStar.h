//
//  SquareStar.h
//  square
//
//  Created by LIN BOYU on 6/18/13.
//  Copyright (c) 2013 LIN BOYU. All rights reserved.
//

#import "SquareGame.h"

//layout
#define STAR_BOARD_POSITION ccp(95,34)

#define STAR_TILEBATCH_POSITION ccpAdd(STAR_BOARD_POSITION,ccp(BOARD_MARGIN,BOARD_MARGIN))

#define STAR_TIMEBAR_POSITION ccp(95,710)

#define STAR_SCORELABEL_POSITION ccp(884,710)


//game logic
#define STAR_BOARD_ROW 10

#define STAR_BOARD_COLUMN 12

#define STAR_BOARD_TILE_WIDTH 64

#define STAR_BOARD_TILE_HEIGHT 64

#define STAR_COLOR_NUM 5

#define STAR_ROUND_TIME 60

#define STAR_PUNISH_TIME 5

@interface SquareStar : SquareGame
{
	   
    int currentColor_;
    
	int * tileColors_;
	
	int * tileVisit_;
	    
    float timeLeft_;
	
    CCProgressBar * timeBar_;
	
    CCLabelBMFont * scoreLabel_;
    
    
    //
    NSMutableArray * tileSprites_;
    
    SquareBoardSprite * board_;
	
	CCSpriteBatchNode * tileBatch_;
}

#pragma mark SquareStar - init & dealloc

-(id) init;

-(void) dealloc;

#pragma mark SquareStar - game logic

-(void) startRound;

-(int) getRandomColor;

-(void) clearColorAtRow:(int)r column:(int)c;


#pragma mark SquareStar - touch

-(void) touchBeganAt:(CGPoint)location;


@end
