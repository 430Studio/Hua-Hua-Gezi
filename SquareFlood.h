//
//  SquareFlood.h
//  Square
//
//  Created by LIN BOYU on 1/1/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SquareGame.h"

//layout 
#define FLOOD_BOARD_POSITION ccp(38,30)

#define FLOOD_TILEBATCH_POSITION ccpAdd(FLOOD_BOARD_POSITION,ccp(BOARD_MARGIN,BOARD_MARGIN))

#define FLOOD_BUTTON0_POSITION ccp(850,670)

#define FLOOD_BUTTON1_POSITION ccpAdd(FLOOD_BUTTON0_POSITION, ccp(0,-118))

#define FLOOD_BUTTON2_POSITION ccpAdd(FLOOD_BUTTON0_POSITION, ccp(0,-2*118))

#define FLOOD_BUTTON3_POSITION ccpAdd(FLOOD_BUTTON0_POSITION, ccp(0,-3*118))

#define FLOOD_BUTTON4_POSITION ccpAdd(FLOOD_BUTTON0_POSITION, ccp(0,-4*118))

#define FLOOD_BUTTON5_POSITION ccpAdd(FLOOD_BUTTON0_POSITION, ccp(0,-5*118))

#define FLOOD_STEPSPRITE_POSITION ccp(48,715)

#define FLOOD_SLASHSPRITE_POSITION ccp(230,715)

#define FLOOD_STEPLABEL_POSITION ccp(200,715)

#define FLOOD_MAXSTEPLABEL_POSITION ccp(260,715)

//game logic
#define FLOOD_BOARD_ROW 12

#define FLOOD_BOARD_COLUMN 12

#define FLOOD_BOARD_TILE_WIDTH 54

#define FLOOD_BOARD_TILE_HEIGHT 54

#define FLOOD_COLOR_NUM 6

#define FLOOD_MAX_STEP 22

@interface SquareFlood : SquareGame {
	
	int currentColor_;
	
	int step_;
		
	int * tileColors_;
	
	int * tileVisit_;
	
	int * colorCount_;
		
	//node
    NSMutableArray * tileSprites_;

    SquareBoardSprite * board_;
	
	CCSpriteBatchNode * tileBatch_;
	
	CCButton * colorButton0_;
	
	CCButton * colorButton1_;
	
	CCButton * colorButton2_;
	
	CCButton * colorButton3_;
	
	CCButton * colorButton4_;
	
	CCButton * colorButton5_;
	
	CCSprite * stepSprite_;
	
	CCSprite * slashSprite_;

	CCLabelBMFont * stepLabel_;
	
	CCLabelBMFont * maxStepLabel_;
}

#pragma mark SquareFlood - init & dealloc

-(id) init;

-(void) dealloc;

#pragma mark SquareFlood - game logic

-(void) startRound;

-(void) turnToColor:(int)color;

-(void) spreadColor:(int)color row:(int)i column:(int)j;

-(int) colorNumber;

#pragma mark SquareFlood - handle button event

-(void) colorButtonClicked0;

-(void) colorButtonClicked1;

-(void) colorButtonClicked2;

-(void) colorButtonClicked3;

-(void) colorButtonClicked4;

-(void) colorButtonClicked5;

@end
