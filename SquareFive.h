//
//  SquareFive.h
//  Square
//
//  Created by LIN BOYU on 1/1/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SquareGame.h"

#define FIVE_BOARD_POSITION ccp(100,90)

#define FIVE_TILEBATCH_POSITION ccpAdd(FIVE_BOARD_POSITION,ccp(BOARD_MARGIN,BOARD_MARGIN))

#define FIVE_SCORELABEL_POSITION ccp(850,450)

#define FIVE_SCORETEXT_POSITION ccp(850,600)

#define FIVE_NEXTTEXT_POSITION ccp(850,400)

#define FIVE_NEXT_POSITION ccp(915, 270)

#define FIVE_BOARD_ROW 9

#define FIVE_BOARD_COLUMN 9

#define FIVE_BOARD_TILE_WIDTH 64

#define FIVE_BOARD_TILE_HEIGHT 64

#define FIVE_COLOR_NUM 6

#define FIVE_GENERATE_NUM 3

@class FiveNextBanner;

@interface SquareFive : SquareGame {

	int * tileColors_;
			
	int * tileParent_;
	
	NSMutableArray * checkList_;
	
	BOOL someTileSelected_;
	
	int selectedR_;
	
	int selectedC_;
    
    int tileNum_;
    
    CGPoint preTargetPoint_;
    
    CGPoint preSourcePoint_;

//node
	
	NSMutableArray * tileSprites_;
    
    NSMutableArray * nextGenerateColors_;
		
	SquareBoardSprite * board_;
	
	CCSpriteBatchNode * tileBatch_;
	
	CCSpriteBatchNode * dotBatch_;
    
	CCLabelBMFont * scoreLabel_;

	CCSprite * maskSprite_;
    
    FiveNextBanner * nextGenerateBanner_;
	
}

#pragma mark SquareFive - init & dealloc

-(id) init;

-(void) dealloc;

#pragma mark SquareFive - game logic

-(void) startRound;

-(void) selectRow:(int)r column:(int)c;

-(void) nextGenerateColors;

-(void) unselect;

-(BOOL) findRoadSourceRow:(int)sr sourceColumn:(int)sc targetRow:(int)tr targetColumn:(int)tc;

-(void) addToCheckListWithRow:(int)r column:(int)c parent:(int)p;

-(void) moveTileSourceRow:(int)sr sourceColumn:(int)sc targetRow:(int)tr targetColumn:(int)tc;

-(BOOL) checkFiveAtRow:(int)r column:(int)c;

-(void) checkFiveWith:(id)sender index:(int *)i;

-(void) removeTile:(int)index;

-(CGPoint) checkAroundPos:(CGPoint)pos;

-(void) generateTile:(int)n;

#pragma mark SquareFive - touch begin

-(void) touchBeganAt:(CGPoint)location;

@end
