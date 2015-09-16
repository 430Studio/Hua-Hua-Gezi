//
//  SquareFlood.m
//  Square
//
//  Created by LIN BOYU on 1/1/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SquareFlood.h"

@implementation SquareFlood

#pragma mark SquareFlood - init & dealloc

-(id) init
{
    gameName_ = [@"flood" retain];
	if (( self = [super init] )) {	
		
		
		CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
		tileColors_ = (int *)calloc((FLOOD_BOARD_COLUMN*FLOOD_BOARD_ROW),sizeof(int));
		tileVisit_ = (int *)calloc((FLOOD_BOARD_COLUMN*FLOOD_BOARD_ROW),sizeof(int));
		colorCount_ = (int *)calloc(FLOOD_COLOR_NUM,sizeof(int));
		tileSprites_ = [[NSMutableArray alloc] init];
		
		board_ = [[SquareBoardSprite spriteWithBackFile:@"boardbg.png"
											   tileFile:@"boardtile.png"
													row:FLOOD_BOARD_ROW 
												 column:FLOOD_BOARD_COLUMN
											  tileWidth:FLOOD_BOARD_TILE_WIDTH
											 tileHeight:FLOOD_BOARD_TILE_HEIGHT] retain];
		board_.position = ccpAdd(FLOOD_BOARD_POSITION,ccp(0,-screenSize.height));
		[gameLayer_ addChild:board_ z:1];
		
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"floodtile.plist"];
		tileBatch_ = [[CCSpriteBatchNode batchNodeWithFile:@"floodtile.pvr.ccz"] retain];
        tileBatch_.position = ccpAdd(FLOOD_TILEBATCH_POSITION,ccp(0,-screenSize.height));
		[gameLayer_ addChild:tileBatch_ z:2];
		
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"floodcolorbutton.plist"];
		colorButton0_ = [[CCButton buttonWithTarget:self
										  selector:@selector(colorButtonClicked0)
									   normalFrame:@"floodcolorbutton0.png"
									 selectedFrame:@"floodcolorbutton0.png"] retain];
		colorButton0_.position = ccpAdd(FLOOD_BUTTON0_POSITION,ccp(0,-screenSize.height));
		[gameLayer_ addChild:colorButton0_ z:2];
		colorButton1_ = [[CCButton buttonWithTarget:self
										  selector:@selector(colorButtonClicked1)
									   normalFrame:@"floodcolorbutton1.png"
									 selectedFrame:@"floodcolorbutton1.png"] retain];
		colorButton1_.position = ccpAdd(FLOOD_BUTTON1_POSITION,ccp(0,-screenSize.height));
		[gameLayer_ addChild:colorButton1_ z:2];
		colorButton2_ = [[CCButton buttonWithTarget:self
										  selector:@selector(colorButtonClicked2)
									   normalFrame:@"floodcolorbutton2.png"
									 selectedFrame:@"floodcolorbutton2.png"] retain];
		colorButton2_.position = ccpAdd(FLOOD_BUTTON2_POSITION,ccp(0,-screenSize.height));
		[gameLayer_ addChild:colorButton2_ z:2];
		colorButton3_ = [[CCButton buttonWithTarget:self
										  selector:@selector(colorButtonClicked3)
									   normalFrame:@"floodcolorbutton3.png"
									 selectedFrame:@"floodcolorbutton3.png"] retain];
		colorButton3_.position = ccpAdd(FLOOD_BUTTON3_POSITION,ccp(0,-screenSize.height));
		[gameLayer_ addChild:colorButton3_ z:2];
		colorButton4_ = [[CCButton buttonWithTarget:self
													selector:@selector(colorButtonClicked4)
												 normalFrame:@"floodcolorbutton4.png"
											   selectedFrame:@"floodcolorbutton4.png"] retain];
		colorButton4_.position = ccpAdd(FLOOD_BUTTON4_POSITION,ccp(0,-screenSize.height));
		[gameLayer_ addChild:colorButton4_ z:2];
		colorButton5_ = [[CCButton buttonWithTarget:self
										  selector:@selector(colorButtonClicked5)
									   normalFrame:@"floodcolorbutton5.png"
									 selectedFrame:@"floodcolorbutton5.png"] retain];
		colorButton5_.position = ccpAdd(FLOOD_BUTTON5_POSITION,ccp(0,-screenSize.height));
		[gameLayer_ addChild:colorButton5_ z:2];
		
		stepSprite_ = [[CCSprite spriteWithFile:@"floodstep.png"] retain];
		stepSprite_.anchorPoint = ccp(0,0.5);
		stepSprite_.position = ccpAdd(FLOOD_STEPSPRITE_POSITION,ccp(0,-screenSize.height));
		[gameLayer_ addChild:stepSprite_ z:2];
		
		slashSprite_ = [[CCSprite spriteWithFile:@"floodslash.png"] retain];
		slashSprite_.position = ccpAdd(FLOOD_SLASHSPRITE_POSITION,ccp(0,-screenSize.height));
		[gameLayer_ addChild:slashSprite_];
		
		stepLabel_ = [[CCLabelBMFont labelWithString:@"00" fntFile:@"number.fnt"] retain];
		stepLabel_.anchorPoint = ccp(1,0.5);
		stepLabel_.color = ccc3(255, 255, 255);
		stepLabel_.position = ccpAdd(FLOOD_STEPLABEL_POSITION,ccp(0,-screenSize.height));
		[gameLayer_ addChild:stepLabel_ z:2];
		
		maxStepLabel_ = [[CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%d",FLOOD_MAX_STEP] fntFile:@"number.fnt"] retain];
		maxStepLabel_.anchorPoint = ccp(0,0.5);
		maxStepLabel_.color = ccc3(255, 255, 255);
		maxStepLabel_.position = ccpAdd(FLOOD_MAXSTEPLABEL_POSITION,ccp(0,-screenSize.height));
		[gameLayer_ addChild:maxStepLabel_ z:2];
	}
	return self;
}

-(void) dealloc
{
	free(tileColors_);
	free(tileVisit_);
	free(colorCount_);

    [gameName_ release];
	[localScoreArray_ release];
	
    [tileSprites_ release];
    [board_ release];
    [tileBatch_ release];
	[colorButton0_ release];
	[colorButton1_ release];
	[colorButton2_ release];
	[colorButton3_ release];
	[colorButton4_ release];
	[colorButton5_ release];
	[stepSprite_ release];
	[slashSprite_ release];
	[stepLabel_ release];
	[maxStepLabel_ release];    
	[super dealloc];
}

#pragma mark SquareFlood - game logic

-(void) startRound
{
	[super startRound];
    [tileBatch_ removeAllChildrenWithCleanup:YES];
    [tileSprites_ removeAllObjects];
	for (int r = 0; r<FLOOD_BOARD_ROW; r++) {
		for (int c = 0; c<FLOOD_BOARD_COLUMN; c++) {
			int color = rand()%FLOOD_COLOR_NUM;
			tileColors_[r*FLOOD_BOARD_COLUMN+c] = color;
			CCSprite * tile = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"floodtile%d.png",color]];
			tile.position = ccp((c+0.5)*FLOOD_BOARD_TILE_WIDTH,(r+0.5)*FLOOD_BOARD_TILE_HEIGHT);
			[tileBatch_ addChild:tile];
			[tileSprites_ addObject:tile];
		}
	}
	currentColor_ = tileColors_[(FLOOD_BOARD_ROW-1)*FLOOD_BOARD_COLUMN];
	step_ = 0;
    [stepLabel_ setString:@"0"];
}

-(void) overRound
{
	[[SimpleAudioEngine sharedEngine] playEffect:@"endgame.mp3"];	
	score_ = step_>=FLOOD_MAX_STEP?0:10+10*(FLOOD_MAX_STEP-step_)*(FLOOD_MAX_STEP-step_)*(FLOOD_MAX_STEP-step_);
	[self saveScore:score_ local:gameName_ gameCenter:gameName_];
    [super overRound];
}

-(void) turnToColor:(int)color
{
	if (color == currentColor_ || gameState_ != gameStateRunning) {
		return;
	}
	for (int i=0; i<FLOOD_BOARD_ROW; i++) {
		for (int j=0; j<FLOOD_BOARD_COLUMN; j++) {
			tileVisit_[i*FLOOD_BOARD_COLUMN+j] = 0;
		}
	}
	[self spreadColor:color row:FLOOD_BOARD_ROW-1 column:0];
	currentColor_ = color;
	step_ ++;
	NSString * stepString = nil;
	if (step_>=10) {
		stepString = [NSString stringWithFormat:@"%d",step_];
	}
	else {
		stepString = [NSString stringWithFormat:@"0%d",step_];
	}
	[stepLabel_ setString:stepString];
	if ([self colorNumber] == 1 || step_>=FLOOD_MAX_STEP) {
		[self overRound];
	}
}

-(int) colorNumber
{
	for (int i=0; i<FLOOD_COLOR_NUM; i++) {
		colorCount_[i] = 0;
	}
	for (int i=0; i<FLOOD_BOARD_ROW; i++) {
		for (int j=0; j<FLOOD_BOARD_COLUMN; j++) {
			colorCount_[tileColors_[i*FLOOD_BOARD_COLUMN+j]]++;
		}
	}
	int counter = 0;
	for (int i=0; i<FLOOD_COLOR_NUM; i++) {
		if(colorCount_[i] != 0){
			counter ++;
		}
	}
	return counter;
}

-(void) spreadColor:(int)color row:(int)i column:(int)j
{
	CCSpriteFrame * newColorFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"floodtile%d.png",color]];
	if (tileVisit_[i*FLOOD_BOARD_COLUMN+j] == 0) {
		tileVisit_[i*FLOOD_BOARD_COLUMN+j] = 1;
		[[tileSprites_ objectAtIndex:i*FLOOD_BOARD_COLUMN+j] setDisplayFrame:newColorFrame];
		tileColors_[i*FLOOD_BOARD_COLUMN+j] = color;
		if (i-1>=0 && i-1<FLOOD_BOARD_ROW && tileVisit_[(i-1)*FLOOD_BOARD_COLUMN+j] == 0 && tileColors_[(i-1)*FLOOD_BOARD_COLUMN+j] == currentColor_){
			[self spreadColor:color row:i-1 column:j];
		}
		if (i+1>=0 && i+1<FLOOD_BOARD_ROW && tileVisit_[(i+1)*FLOOD_BOARD_COLUMN+j] == 0 && tileColors_[(i+1)*FLOOD_BOARD_COLUMN+j] == currentColor_) {
			[self spreadColor:color row:i+1 column:j];
		}
		if (j-1>=0 && j-1<FLOOD_BOARD_COLUMN && tileVisit_[i*FLOOD_BOARD_COLUMN+j-1] == 0 && tileColors_[i*FLOOD_BOARD_COLUMN+j-1] == currentColor_) {
			[self spreadColor:color row:i column:j-1];
		}
		if (j+1>=0 && j+1<FLOOD_BOARD_COLUMN && tileVisit_[i*FLOOD_BOARD_COLUMN+j+1] == 0 && tileColors_[i*FLOOD_BOARD_COLUMN+j+1] == currentColor_) {
			[self spreadColor:color row:i column:j+1];
		}
	}
}

#pragma mark SquareFlood - control sprite

-(void) moveGameIn
{
    [board_ runAction:[CCMoveTo actionWithDuration:0.2 position:FLOOD_BOARD_POSITION]];
    [tileBatch_ runAction:[CCMoveTo actionWithDuration:0.2 position:FLOOD_TILEBATCH_POSITION]];
    [stepSprite_ runAction:[CCMoveTo actionWithDuration:0.2 position:FLOOD_STEPSPRITE_POSITION]];
    [slashSprite_ runAction:[CCMoveTo actionWithDuration:0.2 position:FLOOD_SLASHSPRITE_POSITION]];
    [stepLabel_ runAction:[CCMoveTo actionWithDuration:0.2 position:FLOOD_STEPLABEL_POSITION]];
    [maxStepLabel_ runAction:[CCMoveTo actionWithDuration:0.2 position:FLOOD_MAXSTEPLABEL_POSITION]];
    [colorButton0_ runAction:[CCMoveTo actionWithDuration:0.2 position:FLOOD_BUTTON0_POSITION]];
    [colorButton1_ runAction:[CCMoveTo actionWithDuration:0.2 position:FLOOD_BUTTON1_POSITION]];
    [colorButton2_ runAction:[CCMoveTo actionWithDuration:0.2 position:FLOOD_BUTTON2_POSITION]];
    [colorButton3_ runAction:[CCMoveTo actionWithDuration:0.2 position:FLOOD_BUTTON3_POSITION]];
    [colorButton4_ runAction:[CCMoveTo actionWithDuration:0.2 position:FLOOD_BUTTON4_POSITION]];
    [colorButton5_ runAction:[CCMoveTo actionWithDuration:0.2 position:FLOOD_BUTTON5_POSITION]];
}

-(void) moveGameOut
{
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
	[board_ runAction:[CCMoveTo actionWithDuration:0.2 position:ccpAdd(FLOOD_BOARD_POSITION,ccp(0,-screenSize.height))]];
    [tileBatch_ runAction:[CCMoveTo actionWithDuration:0.2 position:ccpAdd(FLOOD_TILEBATCH_POSITION,ccp(0,-screenSize.height))]];
    [stepSprite_ runAction:[CCMoveTo actionWithDuration:0.2 position:ccpAdd(FLOOD_STEPSPRITE_POSITION,ccp(0,-screenSize.height))]];
    [slashSprite_ runAction:[CCMoveTo actionWithDuration:0.2 position:ccpAdd(FLOOD_SLASHSPRITE_POSITION,ccp(0,-screenSize.height))]];
    [stepLabel_ runAction:[CCMoveTo actionWithDuration:0.2 position:ccpAdd(FLOOD_STEPLABEL_POSITION,ccp(0,-screenSize.height))]];
    [maxStepLabel_ runAction:[CCMoveTo actionWithDuration:0.2 position:ccpAdd(FLOOD_MAXSTEPLABEL_POSITION,ccp(0,-screenSize.height))]];
    [colorButton0_ runAction:[CCMoveTo actionWithDuration:0.2 position:ccpAdd(FLOOD_BUTTON0_POSITION,ccp(0,-screenSize.height))]];
    [colorButton1_ runAction:[CCMoveTo actionWithDuration:0.2 position:ccpAdd(FLOOD_BUTTON1_POSITION,ccp(0,-screenSize.height))]];
    [colorButton2_ runAction:[CCMoveTo actionWithDuration:0.2 position:ccpAdd(FLOOD_BUTTON2_POSITION,ccp(0,-screenSize.height))]];
    [colorButton3_ runAction:[CCMoveTo actionWithDuration:0.2 position:ccpAdd(FLOOD_BUTTON3_POSITION,ccp(0,-screenSize.height))]];
    [colorButton4_ runAction:[CCMoveTo actionWithDuration:0.2 position:ccpAdd(FLOOD_BUTTON4_POSITION,ccp(0,-screenSize.height))]];
    [colorButton5_ runAction:[CCMoveTo actionWithDuration:0.2 position:ccpAdd(FLOOD_BUTTON5_POSITION,ccp(0,-screenSize.height))]];
}

#pragma mark SquareFlood - handle button event

-(void) colorButtonClicked0
{
	[self turnToColor:0];
}

-(void) colorButtonClicked1
{
	[self turnToColor:1];
}

-(void) colorButtonClicked2
{
	[self turnToColor:2];
}

-(void) colorButtonClicked3
{
	[self turnToColor:3];
}

-(void) colorButtonClicked4
{
	[self turnToColor:4];
}

-(void) colorButtonClicked5
{
	[self turnToColor:5];
}

@end
