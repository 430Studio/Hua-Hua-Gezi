//
//  SquareJewelery.h
//  Square
//
//  Created by mac on 12-2-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SquareGame.h"


#define JEWELERY_BOARD_POSITION ccp(404,350)

#define JEWELERY_TILEBATCH_POSITION ccpAdd(ccp(100,70),ccp(BOARD_MARGIN,BOARD_MARGIN))

#define JEWELERY_SCORELABEL_POSITION ccp(835,385)

#define JEWELERY_TIMEBAR_POSITION ccp(94,695)

#define JEWELERY_BOARD_ROW 8

#define JEWELERY_BOARD_COLUMN 8

#define JEWELERY_BOARD_TILE_WIDTH 73

#define JEWELERY_BOARD_TILE_HEIGHT 73

#define JEWELERY_COLOR_NUM 8

#define JEWELERY_ROUND_TIME 120.0

#define JEWELERY_TIP_TIME 5.0

#define JEWELERY_BONUS_TIME 2.0

#define JEWELERY_EACHUPGRADE_SCORE 1500


enum {
    touchStateBegan = 0,
    touchStateMoved,
    touchStateNone,
    touchStateForbidden
};

@interface SquareJewelery : SquareGame {
    
    NSMutableArray * tiles_;
    
    NSMutableArray * nullTiles_;
    
    NSMutableArray * tileToCheck_;
    
    NSMutableSet * tileToUpdate_;
    
    NSMutableSet * spacialTiles_;
    
    NSMutableArray * specialTiles1_;
    NSMutableArray * specialTiles2_;
    
    NSMutableSet * tileToWipe_;
    
    NSMutableSet * tileMayOccur_;
    
	SquareBoardSprite * board_;
	
	CCSpriteBatchNode * tileBatch_;
    
	CCProgressBar * timeBar_;
    
	CCLabelBMFont * scoreLabel_;
    
	CCSprite * maskSprite_;
    
	BOOL someTileSelected_;
    
    BOOL gameJustBegin_;
	
	int selectedR_;
	
	int selectedC_;
    
	float timeLeft_;
    
    //float autoSwapInterval_;
    
    BOOL willWipe_;
    
    int comboWipe_;
    
    int currentColorNum_;
    
    int touchState_;
    
    int nextUpgradeScore_;
    
    CCSprite * targetMask_;
    
    CCSprite * resetJeweleryTip_;
    
    CCSprite * canWipeTip1_;
    
    CCSprite * canWipeTip2_;
    
    BOOL isJeweleryMoving_;
    
    BOOL willResetJewelery_;
    
    BOOL isExistSpecialTile_;
    
    BOOL isExistSpecialWipe_;
    
    CGPoint canWipeTipPos1_;
    
    CGPoint canWipeTipPos2_;
    
    float noTouchLastTime_;
    
    NSValue * specialTilePos_;
    
    int specialTileLinkedNum_;
    
    int wipeTimes_;
    
    BOOL isWipeTileNew_;
    
    BOOL isWipeAll_;
    
    BOOL isComboWiping_;
    
    //BOOL shouldAutoSwap_;
    
    float specialHandleDelayTime_;
}

@property (nonatomic,readwrite) BOOL isJeweleryMoving;
@property (nonatomic,readwrite) BOOL isExistSpecialTile;
@property (nonatomic,readonly) BOOL isExistSpecialWipe;
@property (nonatomic,retain) NSValue * specialTilePos;
@property (nonatomic,readwrite) int specialTileLinkedNum;

-(void) update:(ccTime)dt;

-(CGPoint) worldPositionForTilePos:(CGPoint)tp;

-(void) selectRow:(int)r column:(int)c;

-(void) unselectWhatever;

-(void) unselect;

-(BOOL) isInRangeWithRow:(int)r column:(int)c;

-(int) numToWipeTheRowWithTiles:(NSMutableArray *)tiles row:(int)r column:(int)c isCheck:(BOOL)check;

-(int) numToWipeTheColumnWithTiles:(NSMutableArray *)tiles row:(int)r column:(int)c isCheck:(BOOL)check;

-(void) swapTileWithRow:(int)r column:(int)c;

-(void) wipeTheJewelery;

-(void) resetTouch;

-(void) checkWithRow:(int)r column:(int)c;

-(void) handleNullTiles;

-(void) checkAllAndWipe;

-(void) handleSpecialState;

-(void) checkAndWipeTheTileNew;

-(void) resetAllWipeProperty;

-(void) produceNewJewelery;

-(void) produceNewTiles;

-(void) addScore:(int)score;

-(void) addExtraScoreWithNum:(int)num;

-(void) showExtraScore:(int)totalExtraScore;

-(BOOL) setOccurTileForPos:(NSValue *)pos;

-(void) changeTileLevelWithNum:(int)num forPos:(NSValue *)pos;

-(void) handleSpecialTileForPos:(NSValue *)pos;

-(void) wipeSquareForPos:(NSValue *)pos WithNum:(int)num;

-(void) wipeTheSameTilesForPos:(NSValue *)pos;

-(void) wipeTheCrossForPos:(NSValue *)pos;

-(void) wipeAllTiles;

-(void) resetAllJewelery;

-(id) tipAction;

-(void) showCanWipeTip;

-(void) hideCanWipeTip;

//-(void) autoSwap;

//-(void) setShouldAutoSwap;

-(void) checkIsExistWipeSwap;

@end
