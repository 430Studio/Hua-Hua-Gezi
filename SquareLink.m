//
//  SquareLink.m
//  Square
//
//  Created by LIN BOYU on 1/1/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SquareLink.h"

@implementation SquareLink

#pragma mark SquareLinkLayer - init & dealloc

-(id) init
{
    gameName_ = [@"link" retain];
	if (( self = [super init] )) {
		//logic
		
		tileColors_ = (int *)calloc((LINK_BOARD_COLUMN*LINK_BOARD_ROW),sizeof(int));
		
		tileSprites_ = [[NSMutableArray alloc] init];
		
        //node
		CGSize screenSize = [[CCDirector sharedDirector] winSize];
		
		board_ = [[SquareBoardSprite spriteWithBackFile:@"boardbg.png"
											   tileFile:@"boardtile.png"
													row:LINK_BOARD_ROW
												 column:LINK_BOARD_COLUMN
											  tileWidth:LINK_TILE_WIDTH
											 tileHeight:LINK_TILE_HEIGHT] retain];
		board_.anchorPoint = ccp(0,0);
		board_.position = ccpAdd(LINK_BOARD_POSITION,ccp(0,-screenSize.height));
		[gameLayer_ addChild:board_ z:0];
		
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"linktile.plist"];
		tileBatch_ = [[CCSpriteBatchNode batchNodeWithFile:@"linktile.pvr.ccz"] retain];
		tileBatch_.position = ccpAdd(LINK_TILEBATCH_POSITION,ccp(0,-screenSize.height));
		[gameLayer_ addChild:tileBatch_ z:1];
		
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"linkdot.plist"];
		dotBatch_ = [[CCSpriteBatchNode batchNodeWithFile:@"linkdot.pvr.ccz"] retain];
		dotBatch_.position = ccpAdd(LINK_TILEBATCH_POSITION,ccp(0,-screenSize.height));
		[gameLayer_ addChild:dotBatch_ z:1];
		
		maskSprite_ = [[CCSprite spriteWithFile:@"linkhighlight.png"] retain];
		[gameLayer_ addChild:maskSprite_ z:2];
		maskSprite_.visible = NO;
		
		timeBar_ = [[CCProgressBar barWithBackFile:@"linktimebarbacks.png" 
										frontFile:@"linktimebarfront.png"
									 particleFile:@"linktimebarparticle.png"] retain];
		timeBar_.position = ccpAdd(LINK_TIMEBAR_POSITION,ccp(0,-screenSize.height));
		[gameLayer_ addChild:timeBar_ z:2];
		
		scoreLabel_ = [[CCLabelBMFont labelWithString:@"0" fntFile:@"number.fnt"] retain];
		scoreLabel_.anchorPoint = ccp(1,0.5);
        scoreLabel_.scale = 1.0;
		scoreLabel_.position = ccpAdd(LINK_SCORELABEL_POSITION, ccp(0,-screenSize.height));
		scoreLabel_.color = ccc3(253, 255, 6);
		[gameLayer_ addChild:scoreLabel_ z:2];
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
	[tileBatch_ release];
	[dotBatch_ release];
	[timeBar_ release];
	[scoreLabel_ release];
	[maskSprite_ release];
	[super dealloc];
}

#pragma mark SquareLink - game logic

-(void) startRound
{
	[super startRound];
	[tileSprites_ removeAllObjects];
	[tileBatch_ removeAllChildrenWithCleanup:YES]; 

    int * thisColorNum = (int *)calloc(LINK_TILE_NUM, sizeof(int));
    for (int i=0; i<LINK_TILE_NUM; i++) {
        thisColorNum[i] = 0;
    }
    int * thisColorPos = (int *)calloc(LINK_TILE_NUM, sizeof(int));
    for (int i=0; i<LINK_TILE_NUM; i++) {
        thisColorPos[i] = -1;
    }
	for (int r = 0; r<LINK_BOARD_ROW; r++) {
		for (int c = 0; c<LINK_BOARD_COLUMN; c++) {
			int tileColor = rand()%LINK_TILE_NUM;
            thisColorNum[tileColor] ++;
            if (thisColorPos[tileColor] == -1) {
                thisColorPos[tileColor] = r*LINK_BOARD_COLUMN+c;
            }
            tileColors_[r*LINK_BOARD_COLUMN+c] = tileColor;
		}
	}
    for (int i=0; i<LINK_TILE_NUM; i++) {
        if (thisColorNum[i]%2 != 0) {
            for (int j=i+1; j<LINK_TILE_NUM; j++) {
                if (thisColorNum[j]%2 != 0) {
                    tileColors_[thisColorPos[i]] = j;
                    thisColorNum[i] --;
                    thisColorNum[j] ++;
                    break;
                }
            }
        }
    }
    for (int r = 0; r<LINK_BOARD_ROW; r++) {
		for (int c = 0; c<LINK_BOARD_COLUMN; c++) {
            int tileColor = tileColors_[r*LINK_BOARD_COLUMN+c];
            CCSprite * tile = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"linktile%d.png",tileColor]];
            tile.position = ccp((0.5+c)*LINK_TILE_WIDTH,(0.5+r)*LINK_TILE_HEIGHT);
            [tileBatch_ addChild:tile];
            [tileSprites_ addObject:tile];
		}
	}
    
    free(thisColorNum);
    free(thisColorPos);
    
	score_ = 0;
    [scoreLabel_ setString:[NSString stringWithFormat:@"%d",score_]];
	timeLeft_ = LINK_ROUND_TIME;
    tileLeft_ = LINK_BOARD_ROW * LINK_BOARD_COLUMN;
	someTileSelected_ = NO;
	selectedColor_ = -1;
	selectedC_ = -1;
	selectedR_ = -1;
	[[CCDirector sharedDirector].scheduler scheduleUpdateForTarget:self priority:0 paused:NO];
}

-(void)endRound
{
	[[CCDirector sharedDirector].scheduler unscheduleUpdateForTarget:self];
    maskSprite_.visible = NO;    
	[super endRound];
}

-(void) overRound
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"endgame.mp3"];	
	[[CCDirector sharedDirector].scheduler unscheduleUpdateForTarget:self];
    score_ += timeLeft_*10;
    [scoreLabel_ setString:[NSString stringWithFormat:@"%d",score_]];
	[self saveScore:score_ local:gameName_ gameCenter:gameName_];
    maskSprite_.visible = NO; 
    [super overRound];
}

-(void) update:(ccTime)dt
{
	if (gameState_ == gameStateRunning) {
		timeLeft_ -= dt;
		[timeBar_ setProgress:(timeLeft_/LINK_ROUND_TIME)];
        if (timeLeft_<=0) {
            timeLeft_ = 0;
			[self overRound];
		}
	}
}

-(void) selectRow:(int)r column:(int)c
{
	someTileSelected_ = YES;
	selectedR_ = r;
	selectedC_ = c;
	selectedColor_ = tileColors_[r*LINK_BOARD_COLUMN+c];
	maskSprite_.position = ccpAdd(LINK_TILEBATCH_POSITION,ccp((0.5+c)*LINK_TILE_WIDTH,(0.5+r)*LINK_TILE_HEIGHT));
	maskSprite_.visible = YES;
	[[SimpleAudioEngine sharedEngine] playEffect:@"linkselect.mp3"];
}

-(void) unselect
{
	someTileSelected_ = NO;
	selectedR_ = -1;
	selectedC_ = -1;
	selectedColor_ = -1;
	maskSprite_.visible = NO;
}

-(BOOL) checkSourceRow:(int)sr sourceColumn:(int)sc targetRow:(int)tr targetColumen:(int)tc
{
	int sn,tn,ss,ts,sw,tw,se,te;
	sn = tn = LINK_BOARD_ROW;
	ss = ts = -1;
	sw = tw = -1;
	se = te = LINK_BOARD_COLUMN;
	for (int j=sc+1; j<LINK_BOARD_COLUMN; j++) {
		if (tileColors_[sr*LINK_BOARD_COLUMN+j] != -1) {
			se = j;
			break;
		}
	}
	for (int j=sc-1; j>=0; j--) {
		if (tileColors_[sr*LINK_BOARD_COLUMN+j] != -1) {
			sw = j;
			break;
		}
	}
	for (int i=sr+1; i<LINK_BOARD_ROW; i++) {
		if (tileColors_[i*LINK_BOARD_COLUMN+sc] != -1) {
			sn = i;
			break;
		}
	}
	for (int i=sr-1; i>=0; i--) {
		if (tileColors_[i*LINK_BOARD_COLUMN+sc] != -1) {
			ss = i;
			break;
		}
	}
	for (int j=tc+1; j<LINK_BOARD_COLUMN; j++) {
		if (tileColors_[tr*LINK_BOARD_COLUMN+j] != -1) {
			te = j;
			break;
		}
	}
	for (int j=tc-1; j>=0; j--) {
		if (tileColors_[tr*LINK_BOARD_COLUMN+j] != -1) {
			tw = j;
			break;
		}
	}
	for (int i=tr+1; i<LINK_BOARD_ROW; i++) {
		if (tileColors_[i*LINK_BOARD_COLUMN+tc] != -1) {
			tn = i;
			break;
		}
	}
	for (int i=tr-1; i>=0; i--) {
		if (tileColors_[i*LINK_BOARD_COLUMN+tc] != -1) {
			ts = i;
			break;
		}
	}
	int west = sw>tw?sw:tw;
	int east = se<te?se:te;
	int north = sn<tn?sn:tn;
	int south = ss>ts?ss:ts;
	int westC = sc<tc?sc:tc;
	int eastC = sc>tc?sc:tc;
	int northR = sr>tr?sr:tr;
	int southR = sr<tr?sr:tr;
	
	for (int j = ((west+1)>westC?(west+1):westC); j<=((east-1)<eastC?(east-1):eastC); j++) {
		BOOL isBlock = NO;
		for (int i = southR+1; i<northR; i++) {
			if(tileColors_[i*LINK_BOARD_COLUMN+j] != -1){
				isBlock = YES;
				break;
			}
		}
		if (!isBlock) {
			[self fadeSourceRow:sr sourceColumn:sc targetRow:tr targetColumn:tc];
			if (tc>=sc) {
				[self addHorizontalDotsRow:sr column:sc targetColumn:j-1];
				[self addHorizontalDotsRow:tr column:j+1 targetColumn:tc];
			}
			else {
				[self addHorizontalDotsRow:sr column:j+1 targetColumn:sc];
				[self addHorizontalDotsRow:tr column:tc targetColumn:j-1];
			}
			[self addVerticalDotsRow:southR column:j targetRow:northR];
			return YES;
		}
	}
	for (int i = ((south+1)>southR?(south+1):southR); i<=((north-1)<northR?(north-1):southR); i++) {
		BOOL isBlock = NO;
		for (int j = westC+1; j<eastC; j++) {
			if (tileColors_[i*LINK_BOARD_COLUMN+j] != -1) {
				isBlock = YES;
				break;
			}
		}
		if (!isBlock) {
			[self fadeSourceRow:sr sourceColumn:sc targetRow:tr targetColumn:tc];
			if (tr>=sr) {
				[self addVerticalDotsRow:sr column:sc targetRow:i-1];
				[self addVerticalDotsRow:i+1 column:tc targetRow:tr];
			}
			else {
				[self addVerticalDotsRow:i+1 column:sc targetRow:sr];
				[self addVerticalDotsRow:tr column:tc targetRow:i-1];
			}
			[self addHorizontalDotsRow:i column:westC targetColumn:eastC];
			return YES;
		}
	}
	int k = 0;
	BOOL eastBlocked = NO;
	BOOL westBlocked = NO;
	BOOL northBlocked = NO;
	BOOL southBlocked = NO;
	while (!eastBlocked || !westBlocked || !northBlocked || !southBlocked) {
		k++;
		if (eastC+k<east) {
			BOOL isBlock = NO;
			for (int i = southR+1; i<northR; i++) {
				if(tileColors_[i*LINK_BOARD_COLUMN+eastC+k] != -1){
					isBlock = YES;
					break;
				}
			}
			if (!isBlock) {
				[self fadeSourceRow:sr sourceColumn:sc targetRow:tr targetColumn:tc];
				[self addHorizontalDotsRow:sr column:sc targetColumn:eastC+k-1];
				[self addHorizontalDotsRow:tr column:tc targetColumn:eastC+k-1];
				[self addVerticalDotsRow:southR column:eastC+k targetRow:northR];
				return YES;
			}
		}
		else if(!eastBlocked) {
			eastBlocked = YES;
		}
		if (westC-k>west) {
			BOOL isBlock = NO;
			for (int i = southR+1; i<northR; i++) {
				if(tileColors_[i*LINK_BOARD_COLUMN+westC-k] != -1){
					isBlock = YES;
					break;
				}
			}
			if (!isBlock) {
				[self fadeSourceRow:sr sourceColumn:sc targetRow:tr targetColumn:tc];
				[self addHorizontalDotsRow:sr column:westC-k+1 targetColumn:sc];
				[self addHorizontalDotsRow:tr column:westC-k+1 targetColumn:tc];
				[self addVerticalDotsRow:southR column:westC-k targetRow:northR];
				return YES;
			}
		}
		else if(!westBlocked) {
			westBlocked = YES;
		}
		if (northR+k<north) {
			BOOL isBlock = NO;
			for (int j = westC+1; j<eastC; j++) {
				if(tileColors_[(northR+k)*LINK_BOARD_COLUMN+j] != -1){
					isBlock = YES;
					break;
				}
			}
			if (!isBlock) {
				[self fadeSourceRow:sr sourceColumn:sc targetRow:tr targetColumn:tc];
				[self addVerticalDotsRow:sr column:sc targetRow:northR+k-1];
				[self addVerticalDotsRow:tr column:tc targetRow:northR+k-1];
				[self addHorizontalDotsRow:northR+k column:westC targetColumn:eastC];
				return YES;
			}
		}
		else if(!northBlocked){
			northBlocked = YES;
		}
		if (southR-k>south) {
			BOOL isBlock = NO;
			for (int j = westC+1; j<eastC; j++) {
				if(tileColors_[(southR-k)*LINK_BOARD_COLUMN+j] != -1){
					isBlock = YES;
					break;
				}
			}
			if (!isBlock) {
				[self fadeSourceRow:sr sourceColumn:sc targetRow:tr targetColumn:tc];
				[self addVerticalDotsRow:southR-k+1 column:sc targetRow:sr];
				[self addVerticalDotsRow:southR-k+1 column:tc targetRow:tr];
				[self addHorizontalDotsRow:southR-k column:westC targetColumn:eastC];
				return YES;
			}
		}
		else if(!southBlocked){
			southBlocked = YES;
		}
	}
	return NO;
}

-(void) addDotAtRow:(int)r column:(int)c
{
	CCSprite * dotSprite = [CCSprite spriteWithSpriteFrameName:@"linkdot.png"];
	dotSprite.position = ccp((0.5+c)*LINK_TILE_WIDTH,(0.5+r)*LINK_TILE_HEIGHT);
	[dotBatch_ addChild:dotSprite];
	id action = [CCSequence actions:
				 [CCDelayTime actionWithDuration:0.2],
				 [CCFadeOut actionWithDuration:0.2],
				 [CCCallFuncN actionWithTarget:dotSprite selector:@selector(removeFromParentAndCleanup:)],nil];
	[dotSprite runAction:action];
}

-(void) addHorizontalDotsRow:(int)r column:(int)c targetColumn:(int)tc
{
	if (c<=tc) {
		for (int j = c; j<=tc; j++) {
			[self addDotAtRow:r column:j];
		}
	}
}

-(void) addVerticalDotsRow:(int)r column:(int)c targetRow:(int)tr
{
	if (r<=tr) {
		for (int i = r; i <= tr; i++) {
			[self addDotAtRow:i column:c];
		}
	}
}

-(void) fadeSourceRow:(int)sr sourceColumn:(int)sc targetRow:(int)tr targetColumn:(int)tc
{
	int sp = sr*LINK_BOARD_COLUMN+sc;
	tileColors_[sp] = -1;
	CCSprite * sSprite = [tileSprites_ objectAtIndex:sp];
	[sSprite runAction:[CCSequence actions:
						[CCFadeOut actionWithDuration:0.2],
						[CCCallFuncN actionWithTarget:sSprite selector:@selector(removeFromParentAndCleanup:)],nil]];
	[tileSprites_ replaceObjectAtIndex:sp withObject:[NSNull null]];
	
	int tp = tr*LINK_BOARD_COLUMN+tc;
	tileColors_[tp] = -1;
	CCSprite * tSprite = [tileSprites_ objectAtIndex:tp];
	[tSprite runAction:[CCSequence actions:
						[CCFadeOut actionWithDuration:0.2],
						[CCCallFuncN actionWithTarget:tSprite selector:@selector(removeFromParentAndCleanup:)],nil]];
	[tileSprites_ replaceObjectAtIndex:tp withObject:[NSNull null]];
	
	score_ += 2;
	[scoreLabel_ setString:[NSString stringWithFormat:@"%d",score_]];
}

#pragma mark SquareLink - control node

-(void) moveGameIn
{
    [board_ runAction:[CCMoveTo actionWithDuration:0.2 position:LINK_BOARD_POSITION]];
    [tileBatch_ runAction:[CCMoveTo actionWithDuration:0.2 position:LINK_TILEBATCH_POSITION]];
    [dotBatch_ runAction:[CCMoveTo actionWithDuration:0.2 position:LINK_TILEBATCH_POSITION]];
    [timeBar_ runAction:[CCMoveTo actionWithDuration:0.2 position:LINK_TIMEBAR_POSITION]];
    [scoreLabel_ runAction:[CCMoveTo actionWithDuration:0.2 position:LINK_SCORELABEL_POSITION]];
}

-(void) moveGameOut
{
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    [board_ runAction:[CCMoveTo actionWithDuration:0.2 position:ccpAdd(LINK_BOARD_POSITION,ccp(0,-screenSize.height))]];
    [tileBatch_ runAction:[CCMoveTo actionWithDuration:0.2 position:ccpAdd(LINK_TILEBATCH_POSITION,ccp(0,-screenSize.height))]];
    [dotBatch_ runAction:[CCMoveTo actionWithDuration:0.2 position:ccpAdd(LINK_TILEBATCH_POSITION,ccp(0,-screenSize.height))]];
    [timeBar_ runAction:[CCMoveTo actionWithDuration:0.2 position:ccpAdd(LINK_TIMEBAR_POSITION,ccp(0,-screenSize.height))]];
    [scoreLabel_ runAction:[CCMoveTo actionWithDuration:0.2 position:ccpAdd(LINK_SCORELABEL_POSITION,ccp(0,-screenSize.height))]];
}

#pragma mark SquareLink - touch and event

-(void) touchBeganAt:(CGPoint)location
{
	CGPoint tileBatchLocation = [tileBatch_ convertToNodeSpace:location];
	int r = floor(tileBatchLocation.y/LINK_TILE_HEIGHT);
	int c = floor(tileBatchLocation.x/LINK_TILE_WIDTH);
	if (gameState_ != gameStateRunning || r<0 || r>=LINK_BOARD_ROW || c<0 || c>=LINK_BOARD_COLUMN) {
		return;
	}
	else{
		int currentColor = tileColors_[r*LINK_BOARD_COLUMN+c];
		if (someTileSelected_) {
			if (currentColor == -1 || (r == selectedR_ && c == selectedC_)) {
				[self unselect];
			}
			else if(currentColor == selectedColor_){
				if ([self checkSourceRow:r sourceColumn:c targetRow:selectedR_ targetColumen:selectedC_]){
					[self unselect];
                    timeLeft_ += LINK_ADD_TIME;
                    tileLeft_ -= 2;
                    if (tileLeft_ == 0) {
                        [self overRound];
                    }
					[[SimpleAudioEngine sharedEngine] playEffect:@"linkclear.mp3"];
				}
				else {
					[self unselect];
					[self selectRow:r column:c];
				}
			}
			else {
				[self unselect];
				[self selectRow:r column:c];
			}
		}
		else if(currentColor != -1){
			[self selectRow:r column:c];
		}
	}
}

@end
