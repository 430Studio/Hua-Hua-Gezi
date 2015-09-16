//
//  SquareStar.m
//  square
//
//  Created by LIN BOYU on 6/18/13.
//  Copyright (c) 2013 LIN BOYU. All rights reserved.
//

#import "SquareStar.h"

@implementation SquareStar

#pragma mark SquareStar - init & dealloc

-(id) init
{
    gameName_ = [@"star" retain];
	if (( self = [super init] )) {
		
		CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
		tileColors_ = (int *)calloc((STAR_BOARD_COLUMN*STAR_BOARD_ROW),sizeof(int));
		tileVisit_ = (int *)calloc((STAR_BOARD_COLUMN*STAR_BOARD_ROW),sizeof(int));
		tileSprites_ = [[NSMutableArray alloc] init];
		
		board_ = [[SquareBoardSprite spriteWithBackFile:@"boardbg.png"
											   tileFile:@"boardtile.png"
													row:STAR_BOARD_ROW
												 column:STAR_BOARD_COLUMN
											  tileWidth:STAR_BOARD_TILE_WIDTH
											 tileHeight:STAR_BOARD_TILE_HEIGHT] retain];
		board_.position = ccpAdd(STAR_BOARD_POSITION,ccp(0,-screenSize.height));
        CCLayerColor * maskLayer = [CCLayerColor layerWithColor:ccc4(203, 188, 166, 180) width:board_.contentSize.width height:board_.contentSize.height];
        ccBlendFunc bf = {GL_DST_COLOR, GL_ONE_MINUS_SRC_ALPHA};
        maskLayer.blendFunc = bf;
        maskLayer.anchorPoint = ccp(0,0);
        maskLayer.position = ccp(0,0);
        [board_ addChild:maskLayer z:1];
        
		[gameLayer_ addChild:board_ z:1];
		
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"startile.plist"];
		tileBatch_ = [[CCSpriteBatchNode batchNodeWithFile:@"startile.pvr.ccz"] retain];
        tileBatch_.position = ccpAdd(STAR_TILEBATCH_POSITION,ccp(0,-screenSize.height));
		[gameLayer_ addChild:tileBatch_ z:2];
        
        timeBar_ = [[CCProgressBar barWithBackFile:@"linktimebarbacks.png"
                                         frontFile:@"linktimebarfront.png"
                                      particleFile:@"linktimebarparticle.png"] retain];
		timeBar_.position = ccpAdd(STAR_TIMEBAR_POSITION,ccp(0,-screenSize.height));;
		[gameLayer_ addChild:timeBar_ z:3];
        
        
        scoreLabel_ = [[CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%d",score_] fntFile:@"number.fnt"] retain];
		scoreLabel_.anchorPoint = ccp(1,0.5);
		scoreLabel_.scale = 1.0;
		scoreLabel_.position = ccpAdd(STAR_SCORELABEL_POSITION,ccp(0,-screenSize.height));
        [scoreLabel_ setColor:ccc3(255,255,255)];
        [gameLayer_ addChild:scoreLabel_ z:3];
	}
	return self;
}

-(void) dealloc
{
	free(tileColors_);
	free(tileVisit_);
    
    [gameName_ release];
	[localScoreArray_ release];
	
    [tileSprites_ release];
    [board_ release];
    [tileBatch_ release];
    
	[super dealloc];
}

#pragma mark SquareStar - game logic

-(void) startRound
{
    [super startRound];
	[tileSprites_ removeAllObjects];
	[tileBatch_ removeAllChildrenWithCleanup:YES];
	for (int r=0; r<STAR_BOARD_ROW; r++) {
		for (int c=0; c<STAR_BOARD_COLUMN; c++) {
			int tileColor = [self getRandomColor];
			tileColors_[r*STAR_BOARD_COLUMN+c] = tileColor;			
            CCSprite * tile = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"star%d.png",tileColor]];
            tile.position = ccp((c+0.5)*STAR_BOARD_TILE_WIDTH,(r+0.5)*STAR_BOARD_TILE_HEIGHT);
            tile.scale = 0.98;
            [tileBatch_ addChild:tile];
            [tileSprites_ addObject:tile];
		}
	}
	timeLeft_ = STAR_ROUND_TIME;
	[timeBar_ setProgress:(timeLeft_/STAR_ROUND_TIME)];
	score_ = 0;
	[scoreLabel_ setString:[NSString stringWithFormat:@"%d",score_]];
	[[CCDirector sharedDirector].scheduler scheduleUpdateForTarget:self priority:0 paused:NO];
}

-(void) endRound
{
	[[CCDirector sharedDirector].scheduler unscheduleUpdateForTarget:self];
	[super endRound];
}

-(void) update:(ccTime)dt
{
	if (gameState_ == gameStateRunning) {
		timeLeft_ -= dt;
		[timeBar_ setProgress:(timeLeft_/STAR_ROUND_TIME)];
		if (timeLeft_<=0) {
			[self overRound];
		}
	}
}

-(void) overRound
{
    timeLeft_ = 0;
	[[SimpleAudioEngine sharedEngine] playEffect:@"endgame.mp3"];
	[[CCDirector sharedDirector].scheduler unscheduleUpdateForTarget:self];
	if (score_ > 0) {
		[self saveScore:score_ local:gameName_ gameCenter:gameName_];
	}
    [super overRound];
}

-(int) getRandomColor
{
	int c = rand()%STAR_COLOR_NUM;
    return c;
}


-(void) clearColorAtRow:(int)r column:(int)c
{
    for (int r=0; r<STAR_BOARD_ROW; r++) {
        for (int c=0; c<STAR_BOARD_COLUMN; c++) {
            tileVisit_[r*STAR_BOARD_COLUMN+c] = 0;
        }
    }
    
    int color = tileColors_[r*STAR_BOARD_COLUMN+c];
    [self spreadColor:color row:r column:c];
    
    int count = 0;
    for (int r=0; r<STAR_BOARD_ROW; r++) {
        for (int c=0; c<STAR_BOARD_COLUMN; c++) {
            if(tileVisit_[r*STAR_BOARD_COLUMN+c] == 1){
                count++;
            }
        }
    }
    if (count<=2) {
		[[SimpleAudioEngine sharedEngine] playEffect:@"mistake.mp3"];
		timeLeft_ -= STAR_PUNISH_TIME;
        for (int r=0; r<STAR_BOARD_ROW; r++) {
            for (int c=0; c<STAR_BOARD_COLUMN; c++) {
                if(tileVisit_[r*STAR_BOARD_COLUMN+c] == 1){
                    CCSprite * sprite = [tileSprites_ objectAtIndex:r*STAR_BOARD_COLUMN+c];
                    [sprite runAction:
                     [CCSequence actions:
                      [CCTintTo actionWithDuration:0.2 red:150 green:150 blue:150],
                      [CCTintTo actionWithDuration:0.2 red:255 green:255 blue:255],
                      nil]];
                }
            }
        }
    }else{
        score_ += count*count;
        [scoreLabel_ setString:[NSString stringWithFormat:@"%d",score_]];
        [[SimpleAudioEngine sharedEngine] playEffect:@"starclear.mp3"];
        for (int r=0; r<STAR_BOARD_ROW; r++) {
            for (int c=0; c<STAR_BOARD_COLUMN; c++) {
                if(tileVisit_[r*STAR_BOARD_COLUMN+c] == 1){
                    int newColor = (color + 1 + rand()%(STAR_COLOR_NUM-1))%STAR_COLOR_NUM;
                    tileColors_[r*STAR_BOARD_COLUMN+c] = newColor;
                    [self fly:r*STAR_BOARD_COLUMN+c];
                }
            }
        }
    }
}

-(void) fly:(int)p
{
	CCSprite * sprite = [tileSprites_ objectAtIndex:p];
	[tileBatch_ reorderChild:sprite z:NSIntegerMax];
	float jumpToX = sprite.position.x-300+rand()%600;
	float jumpToY = -50;
	float jumpToH = 200+rand()%50;
	id action = [CCSequence actions:
				 [CCDelayTime actionWithDuration:0.1],
				 [CCSpawn actions:
				  [CCJumpTo actionWithDuration:0.6 position:ccp(jumpToX,jumpToY) height:jumpToH jumps:1],
				  [CCRotateBy actionWithDuration:0.6 angle: 50],
                  [CCFadeOut actionWithDuration:0.6],
				  nil],
				 [CCCallFuncN actionWithTarget:sprite selector:@selector(removeFromParentAndCleanup:)],
				 nil];
	[sprite runAction:action];
    
    int tileColor = tileColors_[p];
    CCSprite * tile = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"star%d.png",tileColor]];
    tile.position = sprite.position;
    tile.scale = 0;
    [tileBatch_ addChild:tile];
    [tileSprites_ addObject:tile];
	[tileSprites_ replaceObjectAtIndex:p withObject:tile];
    [tile runAction:[CCScaleTo actionWithDuration:0.4 scale:0.98]];
}

-(void) spreadColor:(int)color row:(int)i column:(int)j
{
	if (tileVisit_[i*STAR_BOARD_COLUMN+j] == 0) {
		tileVisit_[i*STAR_BOARD_COLUMN+j] = 1;
		if (i-1>=0 && i-1<STAR_BOARD_ROW && tileVisit_[(i-1)*STAR_BOARD_COLUMN+j] == 0 && tileColors_[(i-1)*STAR_BOARD_COLUMN+j] == color){
			[self spreadColor:color row:i-1 column:j];
		}
		if (i+1>=0 && i+1<STAR_BOARD_ROW && tileVisit_[(i+1)*STAR_BOARD_COLUMN+j] == 0 && tileColors_[(i+1)*STAR_BOARD_COLUMN+j] == color) {
			[self spreadColor:color row:i+1 column:j];
		}
		if (j-1>=0 && j-1<STAR_BOARD_COLUMN && tileVisit_[i*STAR_BOARD_COLUMN+j-1] == 0 && tileColors_[i*STAR_BOARD_COLUMN+j-1] == color) {
			[self spreadColor:color row:i column:j-1];
		}
		if (j+1>=0 && j+1<STAR_BOARD_COLUMN && tileVisit_[i*STAR_BOARD_COLUMN+j+1] == 0 && tileColors_[i*STAR_BOARD_COLUMN+j+1] == color) {
			[self spreadColor:color row:i column:j+1];
		}
	}
}



#pragma mark SquareSTAR - control nodes

-(void) moveGameIn
{
    [board_ runAction:[CCMoveTo actionWithDuration:0.2 position:STAR_BOARD_POSITION]];
    [tileBatch_ runAction:[CCMoveTo actionWithDuration:0.2 position:STAR_TILEBATCH_POSITION]];
    [timeBar_ runAction:[CCMoveTo actionWithDuration:0.2 position:STAR_TIMEBAR_POSITION]];
    [scoreLabel_ runAction:[CCMoveTo actionWithDuration:0.2 position:STAR_SCORELABEL_POSITION]];
}

-(void) moveGameOut
{
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    [board_ runAction:[CCMoveTo actionWithDuration:0.2 position:ccpAdd(STAR_BOARD_POSITION,ccp(0,-screenSize.height))]];
    [tileBatch_ runAction:[CCMoveTo actionWithDuration:0.2 position:ccpAdd(STAR_TILEBATCH_POSITION,ccp(0,-screenSize.height))]];
    [timeBar_ runAction:[CCMoveTo actionWithDuration:0.2 position:ccpAdd(STAR_TIMEBAR_POSITION,ccp(0,-screenSize.height))]];
    [scoreLabel_ runAction:[CCMoveTo actionWithDuration:0.2 position:ccpAdd(STAR_SCORELABEL_POSITION,ccp(0,-screenSize.height))]];
}

#pragma mark SquareStar - touch

-(void) touchBeganAt:(CGPoint)location
{
    if (gameState_ == gameStateRunning){
		CGPoint localPosition = [tileBatch_ convertToNodeSpace:location];
		int r = floor(localPosition.y/STAR_BOARD_TILE_HEIGHT);
		int c = floor(localPosition.x/STAR_BOARD_TILE_WIDTH);
		if (r>=0 && r<STAR_BOARD_ROW && c>=0 && c<STAR_BOARD_COLUMN) {
			[self clearColorAtRow:r column:c];
		}
    }
}


@end
