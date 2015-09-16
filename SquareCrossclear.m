//
//  SquareCrossclear.m
//  Square
//
//  Created by LIN BOYU on 12/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SquareCrossclear.h"

@implementation SquareCrossclear

#pragma mark SquareCrossclear - init & dealloc

-(id) init
{
    gameName_ = [@"crossclear" retain];
	if (( self = [super init] )) {
		
        //logic
						
		tileColors_ = (int *)calloc((CROSSCLEAR_BOARD_COLUMN*CROSSCLEAR_BOARD_ROW),sizeof(int));

		tileSprites_ = [[NSMutableArray alloc] init];
		
		//nodes	
		CGSize screenSize = [[CCDirector sharedDirector] winSize];
		
		board_ = [[SquareBoardSprite spriteWithBackFile:@"boardbg.png"
											   tileFile:@"boardtile.png"
													row:CROSSCLEAR_BOARD_ROW
												 column:CROSSCLEAR_BOARD_COLUMN
											  tileWidth:CROSSCLEAR_BOARD_TILE_WIDTH
											 tileHeight:CROSSCLEAR_BOARD_TILE_HEIGHT] retain];
		board_.position = ccpAdd(CROSSCLEAR_BOARD_POSITION,ccp(0,-screenSize.height));
		[gameLayer_ addChild:board_ z:1];
		
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"crosscleardot.plist"];
		dotBatch_ = [[CCSpriteBatchNode batchNodeWithFile:@"crosscleardot.pvr.ccz"] retain];
		dotBatch_.position = ccpAdd(CROSSCLEAR_TILEBATCH_POSITION,ccp(0,-screenSize.height));
		[gameLayer_ addChild:dotBatch_ z:2];

        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"crosscleartile.plist"];
		tileBatch_ = [[CCSpriteBatchNode batchNodeWithFile:@"crosscleartile.pvr.ccz"] retain];
		tileBatch_.position = ccpAdd(CROSSCLEAR_TILEBATCH_POSITION,ccp(0,-screenSize.height));
		[gameLayer_ addChild:tileBatch_ z:3];

		timeBar_ = [[CCProgressBar barWithBackFile:@"crosscleartimebarback.png" 
										 frontFile:@"crosscleartimebarfront.png"
									  particleFile:@"crosscleartimebarparticle.png"] retain];
		timeBar_.position = ccpAdd(CROSSCLEAR_TIMEBAR_POSITION,ccp(0,-screenSize.height));;
		[gameLayer_ addChild:timeBar_ z:3];
		
		scoreLabel_ = [[CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%d",score_] fntFile:@"number.fnt"] retain];
		scoreLabel_.anchorPoint = ccp(1,0.5);
		scoreLabel_.scale = 1.0;
		scoreLabel_.position = ccpAdd(CROSSCLEAR_SCORELABEL_POSITION,ccp(0,-screenSize.height));		
        [scoreLabel_ setColor:ccc3(255,255,255)];
		[gameLayer_ addChild:scoreLabel_ z:3];

    }
	return self;
}

-(void) dealloc
{
	free(tileColors_);

    [gameName_ release];
	[localScoreArray_ release];	
    [tileSprites_ release];
	[board_ release];
	[timeBar_ release];
	[scoreLabel_ release];
	[tileBatch_ release];
	[dotBatch_ release];
	[super dealloc];
}

#pragma mark SquareCrossclear - game logic

-(void) startRound
{
	[super startRound];
	[tileSprites_ removeAllObjects];
	[tileBatch_ removeAllChildrenWithCleanup:YES];
	for (int r=0; r<CROSSCLEAR_BOARD_ROW; r++) {
		for (int c=0; c<CROSSCLEAR_BOARD_COLUMN; c++) {
			int tileColor = [self getRandomColor];
			tileColors_[r*CROSSCLEAR_BOARD_COLUMN+c] = tileColor;
			if (tileColor == -1) {
				[tileSprites_ addObject:[NSNull null]];
			}
			else{
				CCSprite * tile = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"crosscleartile%d.png",tileColor]];
				tile.position = ccp((c+0.5)*CROSSCLEAR_BOARD_TILE_WIDTH,(r+0.5)*CROSSCLEAR_BOARD_TILE_HEIGHT);
				[tileBatch_ addChild:tile];
				[tileSprites_ addObject:tile];
			}
		}
	}
	timeLeft_ = CROSSCLEAR_ROUND_TIME;
	[timeBar_ setProgress:(timeLeft_/CROSSCLEAR_ROUND_TIME)];
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
		[timeBar_ setProgress:(timeLeft_/CROSSCLEAR_ROUND_TIME)];
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
	float p = (float)rand()/RAND_MAX;
	int c = rand()%CROSSCLEAR_COLOR_NUM;
	if (p<0.25) {
		return -1;
	}
	else {
		return c;
	}
}

-(void) check:(int)r and:(int)c
{
	int rColors[4] = {-1,-1,-1,-1};
	BOOL rShouldFly[4] = {NO,NO,NO,NO};
	int rP[4] = {-1,-1,-1,-1};
	BOOL clear = NO;
	for (int i=1; i<CROSSCLEAR_BOARD_COLUMN-c; i++) {
		if(tileColors_[r*CROSSCLEAR_BOARD_COLUMN+c+i] != -1){
			rP[0] = r*CROSSCLEAR_BOARD_COLUMN+c+i;
			rColors[0] = tileColors_[rP[0]];
			break;
		}
	}
	for (int i=1; i<c+1; i++) {
		if(tileColors_[r*CROSSCLEAR_BOARD_COLUMN+c-i] != -1){
			rP[1] = r*CROSSCLEAR_BOARD_COLUMN+c-i;
			rColors[1] = tileColors_[rP[1]];
			break;
		}
	}
	for (int j=1; j<r+1; j++) {
		if(tileColors_[(r-j)*CROSSCLEAR_BOARD_COLUMN+c] != -1){
			rP[2] = (r-j)*CROSSCLEAR_BOARD_COLUMN+c;
			rColors[2] = tileColors_[rP[2]];
			break;
		}
	}
	for (int j=1; j<CROSSCLEAR_BOARD_ROW-r; j++) {
		if(tileColors_[(r+j)*CROSSCLEAR_BOARD_COLUMN+c] != -1){
			rP[3] = (r+j)*CROSSCLEAR_BOARD_COLUMN+c;
			rColors[3] = tileColors_[rP[3]];
			break;
		}
	}
	for (int i=0; i<4; i++) {
		for (int j=i+1; j<4; j++) {
			if (rColors[i] != -1 && rColors[i] == rColors[j]) {
				if(rShouldFly[i] == NO){
					rShouldFly[i] = YES;
				}
				if (rShouldFly[j] == NO) {
					rShouldFly[j] = YES;
				}
			}
		}
	}
	if (rShouldFly[0]) {
		for (int i=1; i<CROSSCLEAR_BOARD_COLUMN-c; i++) {
            [self addDotAt:r and:c+i];
			if(tileColors_[r*CROSSCLEAR_BOARD_COLUMN+c+i] != -1){
				break;
			}
		}
	}
	if (rShouldFly[1]) {
		for (int i=1; i<c+1; i++) {
            [self addDotAt:r and:c-i];
			if(tileColors_[r*CROSSCLEAR_BOARD_COLUMN+c-i] != -1){
				break;
			}
		}
	}
	if (rShouldFly[2]) {
		for (int j=1; j<r+1; j++) {
            [self addDotAt:r-j and:c];
			if(tileColors_[(r-j)*CROSSCLEAR_BOARD_COLUMN+c] != -1){
				break;
			}
		}
	}
	if (rShouldFly[3]) {
		for (int j=1; j<CROSSCLEAR_BOARD_ROW-r; j++) {
            [self addDotAt:r+j and:c];
			if(tileColors_[(r+j)*CROSSCLEAR_BOARD_COLUMN+c] != -1){
				break;
			}
		}
	}
	for (int i=0; i<4; i++) {
		if (rShouldFly[i]) {
			score_++;
			[scoreLabel_ setString:[NSString stringWithFormat:@"%d",score_]];
			[self fly:rP[i]];
			if (!clear) {
				clear = YES;
			}
		}
	}
	if (clear) {
		[[SimpleAudioEngine sharedEngine] playEffect:@"clear.mp3"];
        SquareParticleTouch * touchParticle = [SquareParticleTouch node];
        touchParticle.position = ccpAdd(CROSSCLEAR_TILEBATCH_POSITION,ccp((c+0.5)*CROSSCLEAR_BOARD_TILE_WIDTH,(r+0.5)*CROSSCLEAR_BOARD_TILE_HEIGHT));
        [gameLayer_ addChild:touchParticle z:NSIntegerMax];
        [self addDotAt:r and:c];
	}
	else {
		[[SimpleAudioEngine sharedEngine] playEffect:@"mistake.mp3"];
		timeLeft_ -= CROSSCLEAR_PUNISH_TIME;
	}
}

-(void) addDotAt:(int)r and:(int)c
{
	CCSprite * dotSprite = [CCSprite spriteWithSpriteFrameName:@"crosscleardot.png"];
	dotSprite.position = ccp((c+0.5)*CROSSCLEAR_BOARD_TILE_WIDTH,(r+0.5)*CROSSCLEAR_BOARD_TILE_HEIGHT);
	[dotBatch_ addChild:dotSprite];
	id action = [CCSequence actions:
				 [CCDelayTime actionWithDuration:0.1],
				 [CCFadeOut actionWithDuration:1.0],
				 [CCCallFuncN actionWithTarget:dotSprite selector:@selector(removeFromParentAndCleanup:)],nil];
	[dotSprite runAction:action];
}

-(void) fly:(int)p
{
	tileColors_[p] = -1;
	CCSprite * sprite = [tileSprites_ objectAtIndex:p];
	[tileBatch_ reorderChild:sprite z:NSIntegerMax];
	float jumpToX = sprite.position.x-200+rand()%400;
	float jumpToY = -50;
	float jumpToH = 200+rand()%50;
	id action = [CCSequence actions:
				 [CCDelayTime actionWithDuration:0.1],
				 [CCSpawn actions:
				  [CCJumpTo actionWithDuration:0.6 position:ccp(jumpToX,jumpToY) height:jumpToH jumps:1],
				  [CCRotateBy actionWithDuration:0.6 angle: 50],
				  nil],
				 [CCCallFuncN actionWithTarget:sprite selector:@selector(removeFromParentAndCleanup:)],
				 nil];
	[sprite runAction:action];
	[tileSprites_ replaceObjectAtIndex:p withObject:[NSNull null]];
}

#pragma mark SquareCrossclear - control nodes

-(void) moveGameIn
{
    [board_ runAction:[CCMoveTo actionWithDuration:0.2 position:CROSSCLEAR_BOARD_POSITION]];
    [tileBatch_ runAction:[CCMoveTo actionWithDuration:0.2 position:CROSSCLEAR_TILEBATCH_POSITION]];
    [dotBatch_ runAction:[CCMoveTo actionWithDuration:0.2 position:CROSSCLEAR_TILEBATCH_POSITION]];
    [timeBar_ runAction:[CCMoveTo actionWithDuration:0.2 position:CROSSCLEAR_TIMEBAR_POSITION]];
    [scoreLabel_ runAction:[CCMoveTo actionWithDuration:0.2 position:CROSSCLEAR_SCORELABEL_POSITION]];
}

-(void) moveGameOut
{
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    [board_ runAction:[CCMoveTo actionWithDuration:0.2 position:ccpAdd(CROSSCLEAR_BOARD_POSITION,ccp(0,-screenSize.height))]];
    [tileBatch_ runAction:[CCMoveTo actionWithDuration:0.2 position:ccpAdd(CROSSCLEAR_TILEBATCH_POSITION,ccp(0,-screenSize.height))]];
    [dotBatch_ runAction:[CCMoveTo actionWithDuration:0.2 position:ccpAdd(CROSSCLEAR_TILEBATCH_POSITION,ccp(0,-screenSize.height))]];
    [timeBar_ runAction:[CCMoveTo actionWithDuration:0.2 position:ccpAdd(CROSSCLEAR_TIMEBAR_POSITION,ccp(0,-screenSize.height))]];
    [scoreLabel_ runAction:[CCMoveTo actionWithDuration:0.2 position:ccpAdd(CROSSCLEAR_SCORELABEL_POSITION,ccp(0,-screenSize.height))]];
}

#pragma mark SquareCrossclear - handle button event

-(void) touchBeganAt:(CGPoint)location
{
	if (gameState_ == gameStateRunning){
		CGPoint localPosition = [tileBatch_ convertToNodeSpace:location];
		int r = floor(localPosition.y/CROSSCLEAR_BOARD_TILE_HEIGHT);
		int c = floor(localPosition.x/CROSSCLEAR_BOARD_TILE_WIDTH);
		if (r>=0 && r<CROSSCLEAR_BOARD_ROW && c>=0 && c<CROSSCLEAR_BOARD_COLUMN && tileColors_[r*CROSSCLEAR_BOARD_COLUMN+c]==-1) {
			[self check:r and:c];
		}
    }
}

@end
