//
//  SquareLink.h
//  Square
//
//  Created by LIN BOYU on 1/1/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SquareGame.h"

//layout 
#define LINK_BOARD_POSITION ccp(100,25)

#define LINK_TILEBATCH_POSITION ccpAdd(LINK_BOARD_POSITION,ccp(BOARD_MARGIN,BOARD_MARGIN))

#define LINK_TIMEBAR_POSITION ccp(100,705)

#define LINK_SCORELABEL_POSITION ccp(870,705)

#define LINK_BOARD_ROW 10

#define LINK_BOARD_COLUMN 12

#define LINK_TILE_WIDTH 64

#define LINK_TILE_HEIGHT 64

#define LINK_TILE_NUM 12

#define LINK_ROUND_TIME 60

#define LINK_ADD_TIME 0.5

@interface SquareLink : SquareGame {
			
	//game logic

	int * tileColors_;
			
	float timeLeft_;
	
	BOOL someTileSelected_;
	
	int selectedColor_;
	
	int selectedR_;
	
	int selectedC_;
    
    int tileLeft_;
	
	//nodes
	
    NSMutableArray * tileSprites_;
    
    SquareBoardSprite * board_;
	
	CCSpriteBatchNode * tileBatch_;
	
	CCSpriteBatchNode * dotBatch_;
	
	CCProgressBar * timeBar_;
	
	CCLabelBMFont * scoreLabel_;
	
	CCSprite * maskSprite_;
    
}

-(id) init;

-(void) dealloc;

-(void) update:(ccTime)dt;

-(void) selectRow:(int)r column:(int)c;

-(void) unselect;

-(BOOL) checkSourceRow:(int)sr sourceColumn:(int)sc targetRow:(int)tr targetColumen:(int)tc;

-(void) addDotAtRow:(int)r column:(int)c;

-(void) addHorizontalDotsRow:(int)r column:(int)c targetColumn:(int)tc;

-(void) addVerticalDotsRow:(int)r column:(int)c targetRow:(int)tr;

-(void) fadeSourceRow:(int)sr sourceColumn:(int)sc targetRow:(int)tr targetColumn:(int)tc;

@end
