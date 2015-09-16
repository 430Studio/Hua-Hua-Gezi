//
//  SquareJewelery.m
//  Square
//
//  Created by mac on 12-2-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SquareJewelery.h"
#import "SquareParticle.h"
#import "JNode.h"
#import "FlyBomb.h"

@implementation SquareJewelery

@synthesize isJeweleryMoving = isJeweleryMoving_;
@synthesize specialTilePos = specialTilePos_;
@synthesize isExistSpecialTile = isExistSpecialTile_;
@synthesize isExistSpecialWipe = isExistSpecialWipe_;
@synthesize specialTileLinkedNum = specialTileLinkedNum_;

#pragma mark SquareFive - init & dealloc

-(id) init
{
    gameName_ = [@"jewelery" retain];
	if (( self = [super init] )) {
		
        //logic
        
        tiles_ = [[NSMutableArray alloc] init];		
		nullTiles_ = [[NSMutableArray alloc] init];
        tileToCheck_ = [[NSMutableArray alloc] init];
        tileToUpdate_ = [[NSMutableSet alloc] init];
        spacialTiles_ = [[NSMutableSet alloc] init];
        specialTiles1_ = [[NSMutableArray alloc] init];
        specialTiles2_ = [[NSMutableArray alloc] init];
        tileToWipe_ = [[NSMutableSet alloc] init];
        tileMayOccur_ = [[NSMutableSet alloc] init];
		
		score_ = 0;		
		someTileSelected_ = NO;	
        gameJustBegin_ = NO;
		selectedR_ = -1;		
		selectedC_ = -1;
        willWipe_ = NO;
        isJeweleryMoving_ = NO;
        willResetJewelery_ = NO;
		
		//node
		CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
        /*---
        CCButton * button = [CCButton buttonWithTarget:self
                                              selector:@selector(setShouldAutoSwap)
                                           normalFrame:@"helpbutton.png"
                                         selectedFrame:@"helpbutton.png"];
        button.position = ccp(screenSize.width-50, 50);
        [gameLayer_ addChild:button];
        */
		
		board_ = [[CCSprite spriteWithFile:@"jeweleryboardbg.png"] retain];
		board_.position = ccpAdd(JEWELERY_BOARD_POSITION, ccp(0,-screenSize.height));
		[gameLayer_ addChild:board_ z:0];     
        
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"jewelerytile.plist"];
		tileBatch_ = [[CCSpriteBatchNode batchNodeWithFile:@"jewelerytile.pvr.ccz"] retain];
		tileBatch_.position = ccpAdd(JEWELERY_TILEBATCH_POSITION, ccp(0,-screenSize.height));
		[gameLayer_ addChild:tileBatch_ z:1];
		
		maskSprite_ = [[CCSprite spriteWithFile:@"jewelerymask.png"] retain];
		[gameLayer_ addChild:maskSprite_ z:2];
		maskSprite_.visible = NO;
        
        targetMask_ = [[CCSprite spriteWithFile:@"jewelerymask.png"] retain];
        [gameLayer_ addChild:targetMask_ z:2];
        targetMask_.visible = NO;
        
        resetJeweleryTip_ = [[CCSprite spriteWithFile:@"resetjewelerytip.png"] retain];
        resetJeweleryTip_.position = JEWELERY_BOARD_POSITION;
        [gameLayer_ addChild:resetJeweleryTip_ z:NSIntegerMax];
        resetJeweleryTip_.visible = NO;
        
        canWipeTip1_ = [[CCSprite spriteWithFile:@"canwipetip.png"] retain];
        [gameLayer_ addChild:canWipeTip1_ z:3];
        canWipeTip1_.visible = NO;
        
        canWipeTip2_ = [[CCSprite spriteWithFile:@"canwipetip.png"] retain];
        [gameLayer_ addChild:canWipeTip2_ z:3];
        canWipeTip2_.visible = NO;
        
        
        timeBar_ = [[CCProgressBar barWithBackFile:@"linktimebarbacks.png" 
                                         frontFile:@"linktimebarfront.png"
                                      particleFile:@"linktimebarparticle.png"] retain];
		timeBar_.position = ccpAdd(JEWELERY_TIMEBAR_POSITION,ccp(0,-screenSize.height));
		[gameLayer_ addChild:timeBar_ z:2];
        
		scoreLabel_ = [[CCLabelBMFont labelWithString:@"0" fntFile:@"number.fnt"] retain];
		scoreLabel_.position = ccpAdd(JEWELERY_SCORELABEL_POSITION, ccp(0,-screenSize.height));
		scoreLabel_.color = ccc3(255, 255, 255);
        [gameLayer_ addChild:scoreLabel_ z:2];
        
        //data

        localScoreArray_ = [[[JSLocalScoreManager sharedLocalScoreManager] getLocalHighScore:gameName_] retain];
        
    }
	return self;
}

-(void) dealloc
{
    [tiles_ release];
    [nullTiles_ release];
    [tileToCheck_ release];
    [tileToUpdate_ release];
    [spacialTiles_ release];
    [specialTiles1_ release];
    [specialTiles2_ release];
    [tileToWipe_ release];
    [tileMayOccur_ release];
    [specialTilePos_ release];
    
    [gameName_ release];
	[localScoreArray_ release];
    
	[board_ release];
	[tileBatch_ release];
	[scoreLabel_ release];
	[timeBar_ release];
	[maskSprite_ release];
    [targetMask_ release];
    [resetJeweleryTip_ release];
    [canWipeTip1_ release];
    [canWipeTip2_ release];
    
    [super dealloc];
}

#pragma mark SquareFive - game logic

-(void) startRound
{    
	[super startRound];
	score_ = 0;
    //autoSwapInterval_ = 0.3;
    [scoreLabel_ setString:[NSString stringWithFormat:@"%d",score_]];
	someTileSelected_ = NO;
    isJeweleryMoving_ = NO;
    willResetJewelery_ = NO;
    isWipeTileNew_ = NO;
    isWipeAll_ = NO;
    isComboWiping_ = NO;
    //shouldAutoSwap_ = NO;
    noTouchLastTime_ = 0.0;
	selectedR_ = -1;
	selectedC_ = -1;
    comboWipe_ = 0;
    nextUpgradeScore_ = JEWELERY_EACHUPGRADE_SCORE;
    currentColorNum_ = 4;
    timeLeft_ = JEWELERY_ROUND_TIME;
	[tiles_ removeAllObjects];
	[tileBatch_ removeAllChildrenWithCleanup:YES];
	[self produceNewJewelery];
	gameState_ = gameStateRunning;
    gameJustBegin_ = YES;
    [self checkAllAndWipe];
}

-(void) produceNewJewelery
{    
	for (int r = 0; r<JEWELERY_BOARD_ROW; r++) {
		for (int c = 0; c<JEWELERY_BOARD_COLUMN; c++) {
			int tileColor = rand()%currentColorNum_;
            JNode * tile = [JNode jNodeWithType:tileColor andGame:self];
            tile.pos = [NSValue valueWithCGPoint:ccp(r, c)];
			[tiles_ addObject:tile];
		}
	}
}

-(void) produceNewTiles
{
    for (int r = 0; r<JEWELERY_BOARD_ROW; r++) {
		for (int c = 0; c<JEWELERY_BOARD_COLUMN; c++) {
            JNode * tile = [tiles_ objectAtIndex:r*JEWELERY_BOARD_ROW+c];
            [tile produceJeweleryAt:ccp((0.5+c)*JEWELERY_BOARD_TILE_WIDTH,(0.5+r)*JEWELERY_BOARD_TILE_HEIGHT) withDuration:0.2];
            [tileBatch_ addChild:tile.jewelery];
		}
	}
    if (willResetJewelery_) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"healthcrash.wav"];
        willResetJewelery_ = NO;
    }else {
        [[SimpleAudioEngine sharedEngine] playEffect:@"win1.mp3"];
    }
    touchState_ = touchStateNone;
    
    [[CCDirector sharedDirector].scheduler scheduleUpdateForTarget:self priority:0 paused:NO];
    //[[CCDirector sharedDirector].scheduler scheduleSelector:@selector(autoSwap) forTarget:self interval:autoSwapInterval_ paused:NO];
}

-(void) endRound
{    
    maskSprite_.visible = NO;
    targetMask_.visible = NO;
    canWipeTip1_.visible = NO;
    canWipeTip2_.visible = NO;
    
    [[CCDirector sharedDirector].scheduler unscheduleUpdateForTarget:self];
    [super endRound];
}

-(void) overRound
{
    maskSprite_.visible = NO;
    targetMask_.visible = NO;
    canWipeTip1_.visible = NO;
    canWipeTip2_.visible = NO;
    
    [[CCDirector sharedDirector].scheduler unscheduleUpdateForTarget:self];
    [[SimpleAudioEngine sharedEngine] playEffect:@"gameover.mp3"];
	[self saveScore:score_ local:gameName_ gameCenter:gameName_];
	[super overRound];
}

-(void) update:(ccTime)dt
{
	if (gameState_ == gameStateRunning) {
        if (timeLeft_>JEWELERY_ROUND_TIME) {
            timeLeft_ = JEWELERY_ROUND_TIME;
        }
		timeLeft_ -= dt;
		[timeBar_ setProgress:(timeLeft_/JEWELERY_ROUND_TIME)];
        if (timeLeft_<=0) {
			[self overRound];
            timeLeft_ = 0;
		}
        if (!willWipe_) {
            noTouchLastTime_ += dt;
        }else {
            noTouchLastTime_ = 0;
        }
        if (noTouchLastTime_ >= JEWELERY_TIP_TIME) {
            [self showCanWipeTip];
            noTouchLastTime_ = 0.0;
        }
    }
}

-(id) tipAction
{
    id moveUp = [CCMoveBy actionWithDuration:0.5 position:ccp(0, -10)];
    id moveDown = [moveUp reverse];
    id move = [CCSequence actionOne:moveUp two:moveDown];
    id repeat = [CCRepeat actionWithAction:move times:3];
    id action = [CCSequence actionOne:repeat two:[CCCallFunc actionWithTarget:self selector:@selector(hideCanWipeTip)]];
    return action;
}

-(void) showCanWipeTip
{
    canWipeTip1_.position = ccpAdd(JEWELERY_TILEBATCH_POSITION,ccp((0.5+canWipeTipPos1_.y)*JEWELERY_BOARD_TILE_WIDTH,(0.5+canWipeTipPos1_.x)*JEWELERY_BOARD_TILE_HEIGHT+40));
    canWipeTip1_.visible = YES;
    canWipeTip2_.position = ccpAdd(JEWELERY_TILEBATCH_POSITION,ccp((0.5+canWipeTipPos2_.y)*JEWELERY_BOARD_TILE_WIDTH,(0.5+canWipeTipPos2_.x)*JEWELERY_BOARD_TILE_HEIGHT+40));
    canWipeTip2_.visible = YES;
    [canWipeTip1_ runAction:[self tipAction]];
    [canWipeTip2_ runAction:[self tipAction]];
}

-(void) hideCanWipeTip
{
    canWipeTip1_.visible = NO;
    canWipeTip2_.visible = NO;
}

-(void) resetAllJewelery
{
    resetJeweleryTip_.visible = NO;
    [tileBatch_ removeAllChildrenWithCleanup:YES];
    [tiles_ removeAllObjects];
    [self produceNewJewelery];
    gameJustBegin_ = YES;
    [self checkAllAndWipe];
}

-(void) selectRow:(int)r column:(int)c
{
    if (!someTileSelected_) {
        someTileSelected_ = YES;	
        selectedR_ = r;
        selectedC_ = c;
        maskSprite_.position = ccpAdd(JEWELERY_TILEBATCH_POSITION,ccp((0.5+c)*JEWELERY_BOARD_TILE_WIDTH,(0.5+r)*JEWELERY_BOARD_TILE_HEIGHT));
        maskSprite_.visible = YES;
        
        [[SimpleAudioEngine sharedEngine] playEffect:@"gemclick.mp3"];
    }else {
        targetMask_.position = ccpAdd(JEWELERY_TILEBATCH_POSITION,ccp((0.5+c)*JEWELERY_BOARD_TILE_WIDTH,(0.5+r)*JEWELERY_BOARD_TILE_HEIGHT));
        targetMask_.visible = YES;
    }    
}

-(void) unselectWhatever
{
    someTileSelected_ = NO;
    selectedR_ = -1;
    selectedC_ = -1;		
    maskSprite_.visible = NO;
    targetMask_.visible = NO;
}

-(void) unselect
{   
    if (maskSprite_.visible&&targetMask_.visible) {
        [self unselectWhatever];
    }
}

-(BOOL) isInRangeWithRow:(int)r column:(int)c
{
    int d[4][2] = {{-1,0},{1,0},{0,-1},{0,1}};
    for (int i=0; i<4; i++) {
        if (selectedR_+d[i][0]==r && selectedC_+d[i][1]==c) {
            return YES;
        }
    }
    return NO;
}

-(CGPoint) worldPositionForTilePos:(CGPoint)tp
{
    CGPoint wp = ccpAdd(JEWELERY_TILEBATCH_POSITION,ccp((0.5+tp.y)*JEWELERY_BOARD_TILE_WIDTH,(0.5+tp.x)*JEWELERY_BOARD_TILE_HEIGHT));
    return wp;
}

-(int) numToWipeTheRowWithTiles:(NSMutableArray *)tiles row:(int)r column:(int)c isCheck:(BOOL)check
{
    NSMutableSet * ma = [[NSMutableSet alloc] init];
    NSMutableSet * ct = [[NSMutableSet alloc] init];
    JNode * tile = [tiles objectAtIndex:r*JEWELERY_BOARD_COLUMN+c];
    if (tile.canWipeLandscape) {
        [ma release];
        [ct release];
        return 0;
    }
    tile.canWipeLandscape = YES;
    int column = c;
    int num = 1;
    while (--column>=0) {
        JNode * j = [tiles objectAtIndex:r*JEWELERY_BOARD_COLUMN+column];
        if (j.type == tile.type) {
            if (j.canWipeLandscape) {
                break;
            }
            if (!check) {
                [ma addObject:[NSValue valueWithCGPoint:ccp(r, column)]];
                [ct addObject:j];
            }
            j.canWipeLandscape = YES;
            num++;
        }else {
            break;
        }
    }
    column = c;
    while (++column<JEWELERY_BOARD_COLUMN) {
        JNode * j = [tiles objectAtIndex:r*JEWELERY_BOARD_COLUMN+column];
        if (j.type == tile.type) {
            if (j.canWipeLandscape) {
                break;
            }
            if (!check) {
                [ma addObject:[NSValue valueWithCGPoint:ccp(r, column)]];
                [ct addObject:j];
            }
            j.canWipeLandscape = YES;
            num++;
        }else {
            break;
        }
    }
    if (num >= 3) {
        if (!check) {
            [tileToWipe_ addObject:[NSValue valueWithCGPoint:ccp(r, c)]];
            for (NSValue * value in ma) {
                [tileToWipe_ addObject:value];
            }
            [ct addObject:tile];
            for (JNode * jn in ct) {
                [jn addLinkedNum:num];
            }
        }
        [ma release];
        [ct release];
        return num;
    }
    [ma release];
    [ct release];
    tile.canWipeLandscape = NO;
    column = c;
    while (--column>=0) {
        JNode * j = [tiles objectAtIndex:r*JEWELERY_BOARD_COLUMN+column];
        if (j.type == tile.type) {
            j.canWipeLandscape = NO;
        }else {
            break;
        }
    }
    column = c;
    while (++column<JEWELERY_BOARD_COLUMN) {
        JNode * j = [tiles objectAtIndex:r*JEWELERY_BOARD_COLUMN+column];
        if (j.type == tile.type) {
            j.canWipeLandscape = NO;
        }else {
            break;
        }
    }
    return 0;
}

-(int) numToWipeTheColumnWithTiles:(NSMutableArray *)tiles row:(int)r column:(int)c isCheck:(BOOL)check
{
    NSMutableSet * ma = [[NSMutableSet alloc] init];
    NSMutableSet * ct = [[NSMutableSet alloc] init];
    JNode * tile = [tiles objectAtIndex:r*JEWELERY_BOARD_COLUMN+c];
    if (tile.canWipePortrait) {
        [ma release];
        [ct release];
        return 0;
    }
    tile.canWipePortrait = YES;
    int row = r;
    int num = 1;
    while (--row>=0) {
        JNode * j = [tiles objectAtIndex:row*JEWELERY_BOARD_COLUMN+c];
        if (j.type == tile.type) {
            if (j.canWipePortrait) {
                break;
            }
            if (!check) {
                [ma addObject:[NSValue valueWithCGPoint:ccp(row, c)]];
                [ct addObject:j];
            }
            j.canWipePortrait = YES;
            num++;
        }else {
            break;
        }
    }
    row = r;
    while (++row<JEWELERY_BOARD_ROW) {
        JNode * j = [tiles objectAtIndex:row*JEWELERY_BOARD_COLUMN+c];
        if (j.type == tile.type) {
            if (j.canWipePortrait) {
                break;
            }
            if (!check) {
                [ma addObject:[NSValue valueWithCGPoint:ccp(row, c)]];
                [ct addObject:j];
            }
            j.canWipePortrait = YES;
            num++;
        }else {
            break;
        }
    }
    if (num >= 3) {
        if (!check) {
            [tileToWipe_ addObject:[NSValue valueWithCGPoint:ccp(r, c)]];
            for (NSValue * value in ma) {
                [tileToWipe_ addObject:value];
            }
            [ct addObject:tile];
            for (JNode * jn in ct) {
                [jn addLinkedNum:num];
            }
        }
        [ct release];
        [ma release];
        return num;
    }
    [ma release];
    [ct release];
    tile.canWipePortrait = NO;
    row = r;
    while (--row>=0) {
        JNode * j = [tiles objectAtIndex:row*JEWELERY_BOARD_COLUMN+c];
        if (j.type == tile.type) {
            j.canWipePortrait = NO;
        }else {
            break;
        }
    }
    row = r;
    while (++row<JEWELERY_BOARD_ROW) {
        JNode * j = [tiles objectAtIndex:row*JEWELERY_BOARD_COLUMN+c];
        if (j.type == tile.type) {
            j.canWipePortrait = NO;
        }else {
            break;
        }
    }
    return 0;
}

-(void) swapTileWithRow:(int)r column:(int)c
{
    JNode * oriTile = [tiles_ objectAtIndex:selectedR_*JEWELERY_BOARD_COLUMN+selectedC_];
    JNode * curTile = [tiles_ objectAtIndex:r*JEWELERY_BOARD_COLUMN+c];
    JNode * temp = [oriTile retain];
    NSValue * pos = [oriTile.pos retain];
    oriTile.pos = curTile.pos;
    curTile.pos = pos;
    [pos release];
    [tiles_ replaceObjectAtIndex:selectedR_*JEWELERY_BOARD_COLUMN+selectedC_ withObject:curTile];
    [tiles_ replaceObjectAtIndex:r*JEWELERY_BOARD_COLUMN+c withObject:temp];
    [temp release];
}

-(void) resetAllWipeProperty
{    
    for (int r = 0; r<JEWELERY_BOARD_ROW; r++) {
		for (int c = 0; c<JEWELERY_BOARD_COLUMN; c++) {
            JNode * tile = [tiles_ objectAtIndex:r*JEWELERY_BOARD_ROW+c];
            [tile resetVisitProperty];
        }
    }
}
/*
-(void) setShouldAutoSwap
{
    shouldAutoSwap_ = !shouldAutoSwap_;
}

-(void) autoSwap
{   
    if (!shouldAutoSwap_ ||resetJeweleryTip_.visible || gameState_ != gameStateRunning) {
        return;
    }
    [self selectRow:canWipeTipPos1_.x column:canWipeTipPos1_.y];
    [self selectRow:canWipeTipPos2_.x column:canWipeTipPos2_.y];
    [self swapTileWithRow:canWipeTipPos2_.x column:canWipeTipPos2_.y];
    [self checkWithRow:canWipeTipPos2_.x column:canWipeTipPos2_.y];
    [self resetTouch];
    [self performSelector:@selector(unselect) withObject:nil afterDelay:0.2];
}
*/
-(void) checkIsExistWipeSwap
{
    NSMutableArray * tilesCopy = [[NSMutableArray arrayWithArray:tiles_] retain];
    int d[4][2] = {{1,0},{-1,0},{0,1},{0,-1}};
    for (int r = JEWELERY_BOARD_ROW-1; r>=0; r--) {
		for (int c = 0; c<JEWELERY_BOARD_COLUMN; c++) {
            for (int i=0; i<4; i++) {
                int cr = r+d[i][0];
                int cc = c+d[i][1];
                if (cr>=0 && cr<JEWELERY_BOARD_ROW && cc>=0 && cc<JEWELERY_BOARD_COLUMN) {               
                    if (r != cr || c != cc) {                        
                        JNode * oriTile = [tilesCopy objectAtIndex:cr*JEWELERY_BOARD_COLUMN+cc];
                        JNode * curTile = [tilesCopy objectAtIndex:r*JEWELERY_BOARD_COLUMN+c];
                        JNode * temp = [oriTile retain];
                        [tilesCopy replaceObjectAtIndex:cr*JEWELERY_BOARD_COLUMN+cc withObject:curTile];
                        [tilesCopy replaceObjectAtIndex:r*JEWELERY_BOARD_COLUMN+c withObject:temp];
                        [temp release];
                        BOOL isExist = NO;
                        int rowNum = [self numToWipeTheRowWithTiles:tilesCopy row:r column:c isCheck:YES];
                        int columnNum = [self numToWipeTheColumnWithTiles:tilesCopy row:r column:c isCheck:YES];
                        if (rowNum > 0 || columnNum > 0) {
                            isExist = YES;
                        }
                        rowNum = [self numToWipeTheRowWithTiles:tilesCopy row:cr column:cc isCheck:YES];
                        columnNum = [self numToWipeTheColumnWithTiles:tilesCopy row:cr column:cc isCheck:YES];
                        if (rowNum > 0 || columnNum > 0) {
                            isExist = YES;
                        }
                        oriTile = [tilesCopy objectAtIndex:cr*JEWELERY_BOARD_COLUMN+cc];
                        curTile = [tilesCopy objectAtIndex:r*JEWELERY_BOARD_COLUMN+c];
                        temp = [oriTile retain];
                        [tilesCopy replaceObjectAtIndex:cr*JEWELERY_BOARD_COLUMN+cc withObject:curTile];
                        [tilesCopy replaceObjectAtIndex:r*JEWELERY_BOARD_COLUMN+c withObject:temp];
                        [temp release];
                        if (isExist) {
                            canWipeTipPos1_ = ccp(cr, cc);
                            canWipeTipPos2_ = ccp(r, c);
                            [self resetAllWipeProperty];                            
                            //[[CCDirector sharedDirector].scheduler scheduleSelector:@selector(autoSwap) forTarget:self interval:autoSwapInterval_ paused:NO];
                            [tilesCopy release];
                            return;
                        }
                    }
                }
            }
        }
    }
    [tilesCopy release];
    touchState_ = touchStateForbidden;
    resetJeweleryTip_.visible = YES;
    willResetJewelery_ = YES;
    if (gameJustBegin_) {
        [self resetAllJewelery];
    }else {
        [[CCDirector sharedDirector].scheduler unscheduleUpdateForTarget:self];
        //[[CCDirector sharedDirector].scheduler unscheduleSelector:@selector(autoSwap) forTarget:self];        
        [self performSelector:@selector(resetAllJewelery) withObject:nil afterDelay:3.0f];
    }
}

-(void) handleNullTiles
{
    touchState_ = touchStateForbidden;
    [tileToCheck_ removeAllObjects];
    NSMutableSet * posYs_ = [[NSMutableSet alloc] init];
    int maxOrder = 0;
    for (NSValue * value in nullTiles_) {
        CGPoint pos = [value CGPointValue];
        int nullNum = 1;
        int row = pos.x;
        NSNumber * posY = [NSNumber numberWithInt:(int)pos.y];
        if ([posYs_ containsObject:posY]) {
            continue;
        }
        [posYs_ addObject:posY];
        [tileToCheck_ addObject:[NSValue valueWithCGPoint:ccp(row, pos.y)]];
        while (++row < JEWELERY_BOARD_ROW) {
            [tileToCheck_ addObject:[NSValue valueWithCGPoint:ccp(row, pos.y)]];
            JNode * j = [tiles_ objectAtIndex:row*JEWELERY_BOARD_COLUMN+pos.y];
            if ([j isNull]) {
                nullNum ++;
            }else {
                [tiles_ replaceObjectAtIndex:(row-nullNum)*JEWELERY_BOARD_COLUMN+pos.y withObject:j];
                j.pos = [NSValue valueWithCGPoint:ccp(row-nullNum, pos.y)];
                [j moveDownWithDistance:nullNum*JEWELERY_BOARD_TILE_HEIGHT downOrder:-1];
            }
        }
        row = JEWELERY_BOARD_ROW;
        int downOrder = 0;
        while (row++ < JEWELERY_BOARD_ROW+nullNum) {
			int tileColor = rand()%currentColorNum_;
            JNode * tile = [JNode jNodeWithType:tileColor andGame:self];
            [tiles_ replaceObjectAtIndex:(row-nullNum-1)*JEWELERY_BOARD_COLUMN+pos.y withObject:tile];
            tile.pos = [NSValue valueWithCGPoint:ccp(row-nullNum-1, pos.y)];
            if (!gameJustBegin_) {
                [tile produceJeweleryAt:ccp((0.5+pos.y)*JEWELERY_BOARD_TILE_WIDTH,(0.5+row-1)*JEWELERY_BOARD_TILE_HEIGHT) withDuration:0.0];
                [tile moveDownWithDistance:nullNum*JEWELERY_BOARD_TILE_HEIGHT downOrder:downOrder++];
                [tileBatch_ addChild:tile.jewelery];
            }
        }
        maxOrder = maxOrder<downOrder?downOrder:maxOrder;
        if (!gameJustBegin_) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"ting.mp3"];
        }
    }
    [posYs_ release];
    float duration;
    if (!gameJustBegin_) {
        if (isExistSpecialWipe_) {
            maxOrder --;
            duration = 0.0;//maxOrder*0.05;
        }else {
            duration = 0.0;
        }
    }else {
        duration = 0.0;
    }
    [self performSelector:@selector(checkAndWipeTheTileNew) withObject:nil afterDelay:duration];
}

-(void) resetTouch
{
    if (!resetJeweleryTip_.visible) {
        touchState_ = touchStateNone;
    }
}

-(BOOL) setOccurTileForPos:(NSValue *)pos
{
    NSMutableSet * ma = [[NSMutableSet alloc] init];
    int r = [pos CGPointValue].x;
    int c = [pos CGPointValue].y;
    JNode * tile = [tiles_ objectAtIndex:r*JEWELERY_BOARD_COLUMN+c];
    if (tile.isOccur) {
        [ma release];
        return NO;
    }
    int column = c;
    int num = 1;
    int total = 0;
    while (--column>=0) {
        JNode * j = [tiles_ objectAtIndex:r*JEWELERY_BOARD_COLUMN+column];
        if (j.type == tile.type) {
            if (isWipeTileNew_ && tile.linkedNum<j.linkedNum) {
                [ma release];
                return NO;
            }
            [ma addObject:j.pos];
            num++;
        }else {
            break;
        }
    }
    column = c;
    while (++column<JEWELERY_BOARD_COLUMN) {
        JNode * j = [tiles_ objectAtIndex:r*JEWELERY_BOARD_COLUMN+column];
        if (j.type == tile.type) {
            if (isWipeTileNew_ && tile.linkedNum<j.linkedNum) {
                [ma release];
                return NO;
            }
            [ma addObject:j.pos];
            num++;
        }else {
            break;
        }
    }
    if (num >= 3) {
        for (NSValue * value in ma) {
            [tileMayOccur_ addObject:value];
        }
        total += num;
    }
    [ma removeAllObjects];
    int row = r;
    num = 1;
    while (--row>=0) {
        JNode * j = [tiles_ objectAtIndex:row*JEWELERY_BOARD_COLUMN+c];
        if (j.type == tile.type) {
            if (isWipeTileNew_ && tile.linkedNum<j.linkedNum) {
                [ma release];
                return NO;
            }
            [ma addObject:j.pos];
            num++;
        }else {
            break;
        }
    }
    row = r;
    while (++row<JEWELERY_BOARD_ROW) {
        JNode * j = [tiles_ objectAtIndex:row*JEWELERY_BOARD_COLUMN+c];
        if (j.type == tile.type) {
            if (isWipeTileNew_ && tile.linkedNum<j.linkedNum) {
                [ma release];
                return NO;
            }
            [ma addObject:j.pos];
            num++;
        }else {
            break;
        }
    }
    if (num >= 3) {
        for (NSValue * value in ma) {
            [tileMayOccur_ addObject:value];
        }
        total += num;
    }
    [ma release];
    if (total < 4) {
        return NO;
    }
    return YES;
}

-(void) changeTileLevelWithNum:(int)num forPos:(NSValue *)pos
{
    int jeweleryLevel = num-3;
    [tileMayOccur_ removeAllObjects];
    [tileToUpdate_ addObject:pos];
    CGPoint rc = [pos CGPointValue];
    JNode * tile = [tiles_ objectAtIndex:rc.x*JEWELERY_BOARD_COLUMN+rc.y];
    if (tile.jeweleryLevel == levelPrimary) {        
        if (!gameJustBegin_ && [self setOccurTileForPos:pos]) {
            for (NSValue * value in tileMayOccur_) {
                CGPoint p = [value CGPointValue];
                JNode * j = [tiles_ objectAtIndex:p.x*JEWELERY_BOARD_COLUMN+p.y];
                if (j.jeweleryLevel != levelPrimary) {
                    continue;
                }        
                [j occurToPos:ccp((0.5+rc.y)*JEWELERY_BOARD_TILE_WIDTH,(0.5+rc.x)*JEWELERY_BOARD_TILE_HEIGHT)];
            } 
            [[SimpleAudioEngine sharedEngine] playEffect:@"occur.mp3"];
        }else {
            [tileToUpdate_ removeObject:pos];
            return;
        }
    }    
    [tile setLevel:[NSNumber numberWithInt:jeweleryLevel]];
}

-(void) wipeSquareForPos:(NSValue *)pos WithNum:(int)num
{
    CGPoint rc = [pos CGPointValue];
    
    for (int i=rc.x-num; i<=rc.x+num; i++) {
        for (int j=rc.y-num; j<=rc.y+num; j++) {
            if (i<0 || i>=JEWELERY_BOARD_ROW || j<0 || j>=JEWELERY_BOARD_COLUMN) {
                continue;
            }
            NSValue * p = [NSValue valueWithCGPoint:ccp(i, j)];
            JNode * tile = [tiles_ objectAtIndex:i*JEWELERY_BOARD_COLUMN+j];
            if (!tile.isUpdated&&[tileToUpdate_ containsObject:p]) {
                continue;
            }
            if (![tile isNull]) {                
                tile.canWipe = YES;            
            }
            if (![spacialTiles_ containsObject:p]&&tile.jeweleryLevel!=levelPrimary) {
                [spacialTiles_ addObject:p];
                [self handleSpecialTileForPos:p];
            }
        }
    }    
}

-(void) wipeTheCrossForPos:(NSValue *)pos
{
    CGPoint rc = [pos CGPointValue];
    int i;
    for (i=0; i<JEWELERY_BOARD_ROW; i++) {
        NSValue * p = [NSValue valueWithCGPoint:ccp(i, rc.y)];
        JNode * tile = [tiles_ objectAtIndex:i*JEWELERY_BOARD_COLUMN+rc.y]; 
        CGPoint loc = [self worldPositionForTilePos:ccp(i, rc.y)];
        [JeweleryExplosion explosionWithRangeLevel:0 atPos:loc inLayer:gameLayer_];       
        if (!tile.isUpdated&&[tileToUpdate_ containsObject:p]) {
            continue;
        }
        if (![tile isNull]) {                
            tile.canWipe = YES; 
        }
        if (![spacialTiles_ containsObject:p]&&tile.jeweleryLevel!=levelPrimary) {
            [spacialTiles_ addObject:p];
            [self handleSpecialTileForPos:p];
        }
    }
    for (i=0; i<JEWELERY_BOARD_COLUMN; i++) {
        NSValue * p = [NSValue valueWithCGPoint:ccp(rc.x, i)];
        JNode * tile = [tiles_ objectAtIndex:rc.x*JEWELERY_BOARD_COLUMN+i];   
        CGPoint loc = [self worldPositionForTilePos:ccp(rc.x, i)];
        [JeweleryExplosion explosionWithRangeLevel:0 atPos:loc inLayer:gameLayer_];  
        if (!tile.isUpdated&&[tileToUpdate_ containsObject:p]) {
            continue;
        }
        if (![tile isNull]) {                
            tile.canWipe = YES;
        }
        if (![spacialTiles_ containsObject:p]&&tile.jeweleryLevel!=levelPrimary) {
            [spacialTiles_ addObject:p];
            [self handleSpecialTileForPos:p];
        }
    }
}

-(void) wipeTheSameTilesForPos:(NSValue *)pos
{
    CGPoint rc = [pos CGPointValue];
    int r = rc.x;
    int c = rc.y;
    JNode * jn = [tiles_ objectAtIndex:r*JEWELERY_BOARD_COLUMN+c];
    CGPoint oriloc = ccpAdd(jn.jewelery.position,JEWELERY_TILEBATCH_POSITION);
    for (int i=0; i<JEWELERY_BOARD_ROW; i++) {
        for (int j=0; j<JEWELERY_BOARD_COLUMN; j++) {
            JNode * tile = [tiles_ objectAtIndex:i*JEWELERY_BOARD_COLUMN+j];
            NSValue * p = [NSValue valueWithCGPoint:ccp(i, j)];     
            if (!tile.isUpdated&&[tileToUpdate_ containsObject:p]) {
                continue;
            }
            if (tile.type==jn.type && ![tile isNull]) {
                tile.canWipe = YES;       
                if (r == i && c == j) {
                    continue;
                }
                CGPoint loc = ccpAdd(tile.jewelery.position,JEWELERY_TILEBATCH_POSITION);
                FlyBomb * bomb = [FlyBomb spriteWithFile:@"flybomb.png"];
                [gameLayer_ addChild:bomb z:4];
                [bomb flyFrom:oriloc to:loc];
                if (![spacialTiles_ containsObject:p]&&tile.jeweleryLevel!=levelPrimary) {
                    [spacialTiles_ addObject:p];
                    [self handleSpecialTileForPos:p];
                }
            }
        }
    }
}

-(void) wipeAllTiles
{
    isWipeAll_ = YES;
    for (int i=0; i<JEWELERY_BOARD_ROW; i++) {
        for (int j=0; j<JEWELERY_BOARD_COLUMN; j++) {
            NSValue * p = [NSValue valueWithCGPoint:ccp(i, j)]; 
            JNode * tile = [tiles_ objectAtIndex:i*JEWELERY_BOARD_COLUMN+j];     
            if (!tile.isUpdated&&[tileToUpdate_ containsObject:p]) {
                continue;
            }
            if (![tile isNull]) {
                tile.canWipe = YES;
            }
        }
    }
}

-(void) handleSpecialTileForPos:(NSValue *)pos
{
    timeLeft_ += JEWELERY_BONUS_TIME;
    [tileMayOccur_ removeAllObjects];
    CGPoint rc = [pos CGPointValue];
    [self setOccurTileForPos:pos];
    for (NSValue * value in tileMayOccur_) {
        CGPoint p = [value CGPointValue];
        JNode * j = [tiles_ objectAtIndex:p.x*JEWELERY_BOARD_COLUMN+p.y];
        if (j.jeweleryLevel != levelPrimary) {
            continue;
        }        
        [j occurToPos:ccp((0.5+rc.y)*JEWELERY_BOARD_TILE_WIDTH,(0.5+rc.x)*JEWELERY_BOARD_TILE_HEIGHT)];
    } 
    JNode * tile = [tiles_ objectAtIndex:rc.x*JEWELERY_BOARD_COLUMN+rc.y];
    CGPoint loc = ccpAdd(tile.jewelery.position,JEWELERY_TILEBATCH_POSITION);
    switch (tile.jeweleryLevel) {
        case 1: {
            [self wipeSquareForPos:pos WithNum:1];
            [JeweleryExplosion explosionWithRangeLevel:1 atPos:loc inLayer:gameLayer_];
            CCSprite *square9 = [CCSprite spriteWithFile:@"square9.png"];
            square9.position = loc;
            [gameLayer_ addChild:square9 z:4];
            id action = [CCSequence actionOne:
                                          [CCRepeat actionWithAction:[CCRotateBy actionWithDuration:0.4 angle:360] times:3]two:
                         [CCCallFunc actionWithTarget:square9 selector:@selector(removeFromParentAndCleanup:)]];
            [square9 runAction:action];
            [[SimpleAudioEngine sharedEngine] playEffect:@"square9.mp3"];
            break;
        }    
        case 2: {
            if (tile.subLevel == 1) {
                [self wipeTheSameTilesForPos:pos];
                [[SimpleAudioEngine sharedEngine] playEffect:@"flybomb.mp3"];
            }else if(tile.subLevel == 2) {
                [self wipeTheCrossForPos:pos];
                [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"rowwipe.plist"];
                CCAnimation * animation = [CCAnimation animation];
                for (int i=0; i<3; i++) {
                    NSString * frameName = [NSString stringWithFormat:@"rowwipe%d.png",i];
                    CCSpriteFrame * frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
                    [animation addSpriteFrame:frame];
                }
                animation.delayPerUnit = 0.075f;
                id aniAction1 = [CCAnimate actionWithAnimation:animation];
                id aniAction2 = [CCAnimate actionWithAnimation:animation];
                CCSprite *sprite1 = [CCSprite spriteWithSpriteFrameName:@"rowwipe0.png"];
                sprite1.position = ccpAdd(ccp(4*JEWELERY_BOARD_TILE_WIDTH, (rc.x+0.5)*JEWELERY_BOARD_TILE_HEIGHT), JEWELERY_TILEBATCH_POSITION);
                [gameLayer_ addChild:sprite1 z:5];
                CCSprite *sprite2 = [CCSprite spriteWithSpriteFrameName:@"rowwipe0.png"];
                sprite2.rotation = 90;
                sprite2.position = ccpAdd(ccp((rc.y+0.5)*JEWELERY_BOARD_TILE_WIDTH, 4*JEWELERY_BOARD_TILE_HEIGHT), JEWELERY_TILEBATCH_POSITION);
                [gameLayer_ addChild:sprite2 z:5];
                
                id action1 = [CCSequence actionOne:[CCRepeat actionWithAction:aniAction1 times:6] two:[CCCallFunc actionWithTarget:sprite1 selector:@selector(removeFromParentAndCleanup:)]];
                id action2 = [CCSequence actionOne:[CCRepeat actionWithAction:aniAction2 times:6] two:[CCCallFunc actionWithTarget:sprite2 selector:@selector(removeFromParentAndCleanup:)]];
                [sprite1 runAction:action1];
                [sprite2 runAction:action2];
                [[SimpleAudioEngine sharedEngine] playEffect:@"cross.mp3"];
            }
            break;
        }
        case 3: {
            [self wipeSquareForPos:pos WithNum:2];
            [JeweleryExplosion explosionWithRangeLevel:2 atPos:loc inLayer:gameLayer_];
            CCSprite *square25 = [CCSprite spriteWithFile:@"square25.png"];
            square25.scale = 0.0;
            square25.position = loc;
            [gameLayer_ addChild:square25 z:5];
            id rotate = [CCEaseBounce actionWithAction:[CCRotateBy actionWithDuration:0.1 angle:90]];
            id delay = [CCDelayTime actionWithDuration:0.02];
            id rots = [CCRepeat actionWithAction:[CCSequence actions:rotate,delay, nil] times:10];
            id action = [CCSequence actionOne:
                         [CCSpawn actions:[CCScaleTo actionWithDuration:1.2 scale:1.0],
                          rots,
                          nil]two:
                         [CCCallFunc actionWithTarget:square25 selector:@selector(removeFromParentAndCleanup:)]];
            [square25 runAction:action];
            [[SimpleAudioEngine sharedEngine] playEffect:@"square25.mp3"];
            break;
        }
        default: {
            [self wipeAllTiles];
            CGPoint location = ccpAdd(ccp(4*JEWELERY_BOARD_TILE_WIDTH, 4*JEWELERY_BOARD_TILE_HEIGHT), JEWELERY_TILEBATCH_POSITION);
            [JeweleryExplosion explosionWithRangeLevel:3 atPos:[self worldPositionForTilePos:ccp(3, 3)] inLayer:gameLayer_];
            [JeweleryExplosion explosionWithRangeLevel:3 atPos:[self worldPositionForTilePos:ccp(3, 4)] inLayer:gameLayer_];
            [JeweleryExplosion explosionWithRangeLevel:3 atPos:[self worldPositionForTilePos:ccp(4, 3)] inLayer:gameLayer_];
            [JeweleryExplosion explosionWithRangeLevel:3 atPos:[self worldPositionForTilePos:ccp(4, 4)] inLayer:gameLayer_];
            CCSprite *squareall1 = [CCSprite spriteWithFile:@"squareall1.png"];
            squareall1.position = location;
            [gameLayer_ addChild:squareall1 z:5];
            id action1 = [CCSequence actionOne:
                          [CCRepeat actionWithAction:[CCRotateBy actionWithDuration:0.4 angle:360] times:3]two:
                          [CCCallFunc actionWithTarget:squareall1 selector:@selector(removeFromParentAndCleanup:)]];
            [squareall1 runAction:action1];
            CCSprite *squareall2 = [CCSprite spriteWithFile:@"squareall2.png"];
            squareall2.position = location;
            squareall2.scale = 0.0;
            [gameLayer_ addChild:squareall2 z:5];
            id action2 = [CCSequence actionOne:
                          [CCSpawn actions:[CCScaleTo actionWithDuration:1.2 scale:1.0],[CCRepeat actionWithAction:[CCRotateBy actionWithDuration:0.4 angle:360] times:3], nil
                           ]two:
                          [CCCallFunc actionWithTarget:squareall2 selector:@selector(removeFromParentAndCleanup:)]];
            [squareall2 runAction:action2];
            [[SimpleAudioEngine sharedEngine] playEffect:@"squareall.wav"];
            break;
        }
    }
    tile.jeweleryLevel = levelPrimary;
}

-(void) checkAllAndWipe
{    
    if (gameState_ != gameStateRunning) {
        return;
    }
    touchState_ = touchStateForbidden;
    willWipe_ = NO;
    //[[CCDirector sharedDirector].scheduler unscheduleSelector:@selector(autoSwap) forTarget:self];
    [tileMayOccur_ removeAllObjects];
    [tileToWipe_ removeAllObjects];
    [spacialTiles_ removeAllObjects];
    for (int r = 0; r<JEWELERY_BOARD_ROW; r++) {
		for (int c = JEWELERY_BOARD_COLUMN-1; c>=0; c--) {
            int rowNum = [self numToWipeTheRowWithTiles:tiles_ row:r column:c isCheck:NO];
            int columnNum = [self numToWipeTheColumnWithTiles:tiles_ row:r column:c isCheck:NO];
            int num = rowNum + columnNum;
            if (rowNum && columnNum) {
                num = (num >= 5 ? num-1:num);
            }
            if (num >= 3) {
                willWipe_ = YES;
                if (!gameJustBegin_) {
                    [self addExtraScoreWithNum:num];
                }
            }
            if (!gameJustBegin_) {
                if (num>=4) {
                    [self changeTileLevelWithNum:num forPos:[NSValue valueWithCGPoint:ccp(r, c)]];
                }else {
                    [tileMayOccur_ removeAllObjects];
                }
            }
		}
	}
    if (willWipe_) {
        float duration;
        if (gameJustBegin_) {
            duration = 0.0;
        }else {
            duration = 0.5;
        }
        [self performSelector:@selector(wipeTheJewelery) withObject:nil afterDelay:duration];
    }else {        
        comboWipe_ = 0;
        [self performSelector:@selector(resetTouch) withObject:nil afterDelay:0.3];
        [self checkIsExistWipeSwap];
        if (gameJustBegin_) {
            [self performSelector:@selector(produceNewTiles) withObject:nil afterDelay:0.3];
            gameJustBegin_ = NO;
        }
    }   
}

-(void) handleSpecialState
{
    for (NSDictionary * dic in specialTiles1_) {
        int num = [[dic objectForKey:@"num"] intValue];
        NSValue * pos = [dic objectForKey:@"pos"];
        [self changeTileLevelWithNum:num forPos:pos];
    }
    for (NSDictionary * dic in specialTiles2_) {
        int num = [[dic objectForKey:@"num"] intValue];
        NSValue * pos = [dic objectForKey:@"pos"];
        [self changeTileLevelWithNum:num forPos:pos];
    }
}

-(void) checkAndWipeTheTileNew
{
    if (gameState_ != gameStateRunning) {
        return;
    }
    //[[CCDirector sharedDirector].scheduler unscheduleSelector:@selector(autoSwap) forTarget:self];
    touchState_ = touchStateForbidden;
    willWipe_ = NO;
    isWipeTileNew_ = YES;
    [tileToWipe_ removeAllObjects];
    [tileToUpdate_ removeAllObjects];
    [spacialTiles_ removeAllObjects];
    [specialTiles1_ removeAllObjects];
    [specialTiles2_ removeAllObjects];
    for (NSValue * value in tileToCheck_) {
        [tileMayOccur_ removeAllObjects];
        CGPoint pos = [value CGPointValue];
        isExistSpecialTile_ = NO;
        int rowNum = [self numToWipeTheRowWithTiles:tiles_ row:pos.x column:pos.y isCheck:NO];
        int columnNum = [self numToWipeTheColumnWithTiles:tiles_ row:pos.x column:pos.y isCheck:NO];
        int num = rowNum + columnNum;
        if (rowNum && columnNum) {
            num = (num >= 5 ? num-1:num);
        }
        if (num >= 3) {
            willWipe_ = YES;
            if (!gameJustBegin_) {
                [self addExtraScoreWithNum:num];
            }
        }
        if (!gameJustBegin_) {
            if (num>=3 && isExistSpecialTile_ && specialTileLinkedNum_>num) { 
                isExistSpecialTile_ = NO;
                
                NSMutableDictionary * dic = [NSMutableDictionary dictionary];
                [dic setObject:[NSNumber numberWithInt:specialTileLinkedNum_] forKey:@"num"];
                [dic setObject:specialTilePos_ forKey:@"pos"];
                [specialTiles1_ addObject:dic];
                
            }else if (num>=4) {
                NSMutableDictionary * dic = [NSMutableDictionary dictionary];
                [dic setObject:[NSNumber numberWithInt:num] forKey:@"num"];
                [dic setObject:[NSValue valueWithCGPoint:ccp(pos.x, pos.y)] forKey:@"pos"];
                [specialTiles2_ addObject:dic];
            }            
        }
    }
    BOOL existSpecial = NO;
    if (specialTiles1_.count || specialTiles2_.count) {
        existSpecial = YES;
        [self performSelector:@selector(handleSpecialState) withObject:nil afterDelay:0.3];
    }
    isWipeTileNew_ = NO;
    if (willWipe_) {
        float duration;
        if (gameJustBegin_) {
            duration = 0.0;
        }else {
            duration = 0.2;
            isComboWiping_ = YES;
            if (existSpecial) {
                duration += 0.3;
            }
        }
        isExistSpecialWipe_ = NO;
        wipeTimes_ = 0;
        [self performSelector:@selector(wipeTheJewelery) withObject:nil afterDelay:duration];
    }else {        
        comboWipe_ = 0;
        isComboWiping_ = NO;
        [self performSelector:@selector(resetTouch) withObject:nil afterDelay:0.3];        
        [self checkIsExistWipeSwap];
        if (gameJustBegin_) {
            [self performSelector:@selector(produceNewTiles) withObject:nil afterDelay:0.3];
            gameJustBegin_ = NO;
        }
    }
}

-(void) addScore:(int)score
{
    score_ += score;
    if (score_ >= nextUpgradeScore_) {
        currentColorNum_ = currentColorNum_ < JEWELERY_COLOR_NUM ? ++currentColorNum_:currentColorNum_;
        nextUpgradeScore_ += JEWELERY_EACHUPGRADE_SCORE;
    }
    [scoreLabel_ setString:[NSString stringWithFormat:@"%d",score_]];
}

-(void) addExtraScoreWithNum:(int)num
{
    int totalExtraScore = 0;
    for (int i=1; i<=num-3; i++) {
        int score = 10+i;
        totalExtraScore += score;
    }
    [self showExtraScore:totalExtraScore];
    score_ += totalExtraScore;
    [scoreLabel_ setString:[NSString stringWithFormat:@"%d",score_]];
}

-(void) showExtraScore:(int)totalExtraScore
{
}

-(void) wipeTheJewelery
{  
    if (gameState_ == gameStateOver) {
        return;
    }
    touchState_ = touchStateForbidden;
    [nullTiles_ removeAllObjects];
    for (NSValue * value in tileToWipe_) {
        CGPoint rc = [value CGPointValue];
        JNode * tile = [tiles_ objectAtIndex:rc.x*JEWELERY_BOARD_COLUMN+rc.y];
        if (tile.isUpdated) {
            [tileToUpdate_ removeObject:value];
        }
        if (!isWipeAll_&&![tileToUpdate_ containsObject:value]&&tile.jeweleryLevel != levelPrimary) {
            isExistSpecialWipe_ = YES;
            [spacialTiles_ addObject:value];
            [self handleSpecialTileForPos:value];
        }
    }
    isWipeAll_ = NO;
    if (!gameJustBegin_&&isExistSpecialWipe_&&wipeTimes_==0) {
        [self performSelector:@selector(wipeTheJewelery) withObject:nil afterDelay:0.4];
        wipeTimes_ ++;
        return;
    }
    if (!gameJustBegin_) {
        comboWipe_ ++;
        timeLeft_ += 1.0f;
    }
    for (int r = 0; r<JEWELERY_BOARD_ROW; r++) {
		for (int c = JEWELERY_BOARD_COLUMN-1; c>=0; c--) {
            JNode * tile = [tiles_ objectAtIndex:r*JEWELERY_BOARD_ROW+c];
            NSValue * pos = [NSValue valueWithCGPoint:ccp(r, c)];
            if (!tile.isUpdated&&[tileToUpdate_ containsObject:pos]) {
                [tile resetVisitProperty];
                [tileToUpdate_ removeObject:pos];
                continue;
            }
            if (tile.canWipe || tile.canWipePortrait || tile.canWipeLandscape) {
                if (!gameJustBegin_) {
                    [self addScore:10*comboWipe_];
                }
                if (!gameJustBegin_ && isComboWiping_ && !tile.isOccur && !tile.canWipe) {
                    [tile comboWipe];
                    [[SimpleAudioEngine sharedEngine] playEffect:@"tock.mp3"];
                }else {
                    [tile setNull];
                }
                [nullTiles_ addObject:pos];                
                if ([spacialTiles_ containsObject:pos]) {
                    [spacialTiles_ removeObject:pos];
                }
            }
		}
	}
    float duration;
    if (gameJustBegin_) {
        duration = 0.0;
    }else {
        duration = 0.2;
        if (isComboWiping_) {
            duration = 0.5;
        }
        if (isExistSpecialWipe_) {
            duration = 1.0;
        }
    }
    [self performSelector:@selector(handleNullTiles) withObject:nil afterDelay:duration];
}

-(void) checkWithRow:(int)r column:(int)c
{
    if (gameState_ != gameStateRunning) {
        return;
    }
    touchState_ = touchStateForbidden;
    //
    //[[CCDirector sharedDirector].scheduler unscheduleSelector:@selector(autoSwap) forTarget:self];
    //
    [tileMayOccur_ removeAllObjects];
    [tileToWipe_ removeAllObjects];
    [spacialTiles_ removeAllObjects];
    JNode * oriTile = [tiles_ objectAtIndex:selectedR_*JEWELERY_BOARD_ROW+selectedC_];
    JNode * curTile = [tiles_ objectAtIndex:r*JEWELERY_BOARD_COLUMN+c]; 
    willWipe_ = NO;
    isExistSpecialTile_ = NO;
    int rowNum = [self numToWipeTheRowWithTiles:tiles_ row:r column:c isCheck:NO];
    int columnNum = [self numToWipeTheColumnWithTiles:tiles_ row:r column:c isCheck:NO];
    int num = rowNum + columnNum;
    if (rowNum && columnNum) {
        num = (num >= 5 ? num-1:num);
    }
    if (num >= 3) {
        willWipe_ = YES;
        [self addExtraScoreWithNum:num];
    }    
    if (!gameJustBegin_) {
        if (num>=4) {
            [self changeTileLevelWithNum:num forPos:[NSValue valueWithCGPoint:ccp(r, c)]];
        }else {
            [tileMayOccur_ removeAllObjects];
        }
    }
    rowNum = [self numToWipeTheRowWithTiles:tiles_ row:selectedR_ column:selectedC_ isCheck:NO];
    columnNum = [self numToWipeTheColumnWithTiles:tiles_ row:selectedR_ column:selectedC_ isCheck:NO];
    num = rowNum + columnNum;
    if (rowNum && columnNum) {
        num = (num >= 5 ? num-1:num);
    }
    if (num >= 3) {
        willWipe_ = YES;
        [self addExtraScoreWithNum:num];
    }
    if (!gameJustBegin_) {
        if (num>=4) {
            [self changeTileLevelWithNum:num forPos:[NSValue valueWithCGPoint:ccp(selectedR_, selectedC_)]];
        }else {
            [tileMayOccur_ removeAllObjects];
        }
    }
    [oriTile swapWithJNode:curTile]; 
    if (willWipe_) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"match.mp3"];
        isExistSpecialWipe_ = NO;
        wipeTimes_ = 0;
        [self performSelector:@selector(wipeTheJewelery) withObject:nil afterDelay:0.3];
    }else {
        [self checkIsExistWipeSwap];
        comboWipe_ = 0;
        [self performSelector:@selector(resetTouch) withObject:nil afterDelay:0.3];
        [self swapTileWithRow:r column:c];
        [oriTile performSelector:@selector(swapWithJNode:) withObject:curTile afterDelay:0.3];
        [[SimpleAudioEngine sharedEngine] playEffect:@"mismatch.mp3"];
    }
}

#pragma mark SquareFive - control node

-(void) moveGameIn
{
    [board_ runAction:[CCMoveTo actionWithDuration:0.2 position:JEWELERY_BOARD_POSITION]];
    [tileBatch_ runAction:[CCMoveTo actionWithDuration:0.2 position:JEWELERY_TILEBATCH_POSITION]];  
    [timeBar_ runAction:[CCMoveTo actionWithDuration:0.2 position:JEWELERY_TIMEBAR_POSITION]];
    [scoreLabel_ runAction:[CCMoveTo actionWithDuration:0.2 position:JEWELERY_SCORELABEL_POSITION]];
}

-(void) moveGameOut
{
    maskSprite_.visible = NO;
    targetMask_.visible = NO;
    canWipeTip1_.visible = NO;
    canWipeTip2_.visible = NO;
    
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    [board_ runAction:[CCMoveTo actionWithDuration:0.2 position:ccpAdd(JEWELERY_BOARD_POSITION,ccp(0,-screenSize.height))]];
    [tileBatch_ runAction:[CCMoveTo actionWithDuration:0.2 position:ccpAdd(JEWELERY_TILEBATCH_POSITION,ccp(0,-screenSize.height))]]; 
    [timeBar_ runAction:[CCMoveTo actionWithDuration:0.2 position:ccpAdd(JEWELERY_TIMEBAR_POSITION,ccp(0,-screenSize.height))]];
    [scoreLabel_ runAction:[CCMoveTo actionWithDuration:0.2 position:ccpAdd(JEWELERY_SCORELABEL_POSITION,ccp(0,-screenSize.height))]];	
}

#pragma mark SquareFive - handle touch event

-(void) touchBeganAt:(CGPoint)location
{
    if (isJeweleryMoving_ || touchState_ == touchStateForbidden) {
        return;
    }
    noTouchLastTime_ = 0;
    canWipeTip1_.visible = NO;
    canWipeTip2_.visible = NO;
    touchState_ = touchStateBegan;
    CGPoint tileBatchLocation = [tileBatch_ convertToNodeSpace:location];
	int r = floor(tileBatchLocation.y/JEWELERY_BOARD_TILE_HEIGHT);
	int c = floor(tileBatchLocation.x/JEWELERY_BOARD_TILE_WIDTH);
    
	if (gameState_ != gameStateRunning || r<0 || r>=JEWELERY_BOARD_ROW || c<0 || c>=JEWELERY_BOARD_COLUMN) {
		return;
	}
	else {
        if (someTileSelected_) {            
            if (r == selectedR_ && c == selectedC_) {
                [self unselectWhatever];
            }else if([self isInRangeWithRow:r column:c]) {
                [self swapTileWithRow:r column:c];
                [self checkWithRow:r column:c];
                [self selectRow:r column:c];
            }else {
                [self unselectWhatever];
                [self selectRow:r column:c];
            }
        }else {
            [self selectRow:r column:c];
        }
	}
}

-(void) touchMovedAt:(CGPoint)location
{
    if (isJeweleryMoving_ || touchState_ == touchStateNone || touchState_ == touchStateForbidden) {
        return;
    }
    noTouchLastTime_ = 0;
    touchState_ = touchStateMoved;
    CGPoint tileBatchLocation = [tileBatch_ convertToNodeSpace:location];
	int r = floor(tileBatchLocation.y/JEWELERY_BOARD_TILE_HEIGHT);
	int c = floor(tileBatchLocation.x/JEWELERY_BOARD_TILE_WIDTH);
    
	if (gameState_ != gameStateRunning || r<0 || r>=JEWELERY_BOARD_ROW || c<0 || c>=JEWELERY_BOARD_COLUMN) {
		return;
	}
	else {
        if(!(r==selectedR_&&c==selectedC_)&&[self isInRangeWithRow:r column:c]) {            
            [self selectRow:r column:c];
            [self swapTileWithRow:r column:c];
            [self checkWithRow:r column:c];
            [self resetTouch];
            [self performSelector:@selector(unselect) withObject:nil afterDelay:0.2];
        }
	}
}

-(void) touchEndedAt:(CGPoint)location
{
    noTouchLastTime_ = 0;
    [self performSelector:@selector(unselect) withObject:nil afterDelay:0.2];
}






@end
