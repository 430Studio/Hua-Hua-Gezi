//
//  SquareFive.m
//  Square
//
//  Created by LIN BOYU on 1/1/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SquareFive.h"
#import "SquareParticle.h"
#import "SquareBanner.h"

@implementation SquareFive

#pragma mark SquareFive - init & dealloc

-(id) init
{
    gameName_ = [@"five" retain];
	if (( self = [super init] )) {
		
        //logic
		
		tileColors_ = (int *)calloc((FIVE_BOARD_COLUMN*FIVE_BOARD_ROW),sizeof(int));
						
		tileParent_ = (int *)calloc((FIVE_BOARD_COLUMN*FIVE_BOARD_ROW), sizeof(int));
		
		checkList_ = [[NSMutableArray alloc] init];
        
        nextGenerateColors_ = [[NSMutableArray alloc] init];
		
		score_ = 0;
		
		someTileSelected_ = NO;
		
		selectedR_ = -1;
		
		selectedC_ = -1;
		
		//node
		CGSize screenSize = [[CCDirector sharedDirector] winSize];
		
		board_ = [[SquareBoardSprite spriteWithBackFile:@"boardbg.png"
											   tileFile:nil
													row:FIVE_BOARD_ROW
												 column:FIVE_BOARD_COLUMN
											  tileWidth:FIVE_BOARD_TILE_WIDTH
											 tileHeight:FIVE_BOARD_TILE_HEIGHT] retain];
		board_.position = ccpAdd(FIVE_BOARD_POSITION, ccp(0,-screenSize.height));
		[gameLayer_ addChild:board_ z:0];
		
		tileSprites_ = [[NSMutableArray alloc] init];
 
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"fivetile.plist"];
		tileBatch_ = [[CCSpriteBatchNode batchNodeWithFile:@"fivetile.pvr.ccz"] retain];
		tileBatch_.position = ccpAdd(FIVE_TILEBATCH_POSITION, ccp(0,-screenSize.height));
		[gameLayer_ addChild:tileBatch_ z:1];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"linkdot.plist"];
		dotBatch_ = [[CCSpriteBatchNode batchNodeWithFile:@"linkdot.pvr.ccz"] retain];
		dotBatch_.position = ccpAdd(FIVE_TILEBATCH_POSITION,ccp(0,-screenSize.height));
		[gameLayer_ addChild:dotBatch_ z:1];
		
		maskSprite_ = [[CCSprite spriteWithFile:@"linkhighlight.png"] retain];
		[gameLayer_ addChild:maskSprite_ z:2];
		maskSprite_.visible = NO;
       
		scoreLabel_ = [[CCLabelBMFont labelWithString:@"0" fntFile:@"number.fnt"] retain];
		scoreLabel_.position = ccpAdd(FIVE_SCORELABEL_POSITION, ccp(0,-screenSize.height));
		scoreLabel_.color = ccc3(255, 255, 255);
        [gameLayer_ addChild:scoreLabel_ z:2];
        
        nextGenerateBanner_ = [[FiveNextBanner bannerWithGenerateNumber:FIVE_GENERATE_NUM] retain];
        nextGenerateBanner_.position = ccpAdd(FIVE_NEXT_POSITION, ccp(0, -screenSize.height));
        [gameLayer_ addChild:nextGenerateBanner_];
    }
	return self;
}

-(void) dealloc
{
	free(tileColors_);
	free(tileParent_);
	[checkList_ release];
    [nextGenerateColors_ release];

    [gameName_ release];
	[localScoreArray_ release];

	[tileSprites_ release];
	[board_ release];
	[tileBatch_ release];
    [dotBatch_ release];
	[scoreLabel_ release];
	[maskSprite_ release];
    [nextGenerateBanner_ release];

	[super dealloc];
}

#pragma mark SquareFive - game logic

-(void) startRound
{
    [super startRound];
	score_ = 0;
    tileNum_ = 0;
    [scoreLabel_ setString:[NSString stringWithFormat:@"%d",score_]];
	someTileSelected_ = NO;
	selectedR_ = -1;
	selectedC_ = -1;
    preTargetPoint_ = ccp(-1, -1);
    preSourcePoint_ = ccp(-1, -1);
	[tileSprites_ removeAllObjects];
	[tileBatch_ removeAllChildrenWithCleanup:YES];
	for (int r = 0; r<FIVE_BOARD_ROW; r++) {
		for (int c = 0; c<FIVE_BOARD_COLUMN; c++) {
			tileColors_[r*FIVE_BOARD_COLUMN+c] = -1;
			[tileSprites_ addObject:[NSNull null]];
		}
	}
	gameState_ = gameStateRunning;
    for (int i=0; i<5; i++) {
        int color = rand()%FIVE_COLOR_NUM;
        [nextGenerateColors_ addObject:[NSNumber numberWithInt:color]];
    }
	[self generateTile:5];
    [self nextGenerateColors];
}

-(void) endRound
{
    maskSprite_.visible = NO;
    [super endRound];
}

-(void) overRound
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"endgame.mp3"];
	[self saveScore:score_ local:gameName_ gameCenter:gameName_];
    maskSprite_.visible = NO;
	[super overRound];
}

-(void) nextGenerateColors
{
    [nextGenerateColors_ removeAllObjects];
    for (int i = 0; i<FIVE_GENERATE_NUM; i++) {
        int color = rand()%FIVE_COLOR_NUM;
        [nextGenerateColors_ addObject:[NSNumber numberWithInt:color]];
    }
    [nextGenerateBanner_ setNextGenerateTile:nextGenerateColors_];
}

-(void) selectRow:(int)r column:(int)c
{
    someTileSelected_ = YES;	
    selectedR_ = r;
    selectedC_ = c;
    preSourcePoint_ = ccp(selectedR_, selectedC_);
    maskSprite_.position = ccpAdd(FIVE_TILEBATCH_POSITION,ccp((0.5+c)*FIVE_BOARD_TILE_WIDTH,(0.5+r)*FIVE_BOARD_TILE_HEIGHT));
    maskSprite_.visible = YES;
    [[SimpleAudioEngine sharedEngine] playEffect:@"linkselect.mp3"];
}

-(void) unselect
{
    someTileSelected_ = NO;
    selectedR_ = -1;
    selectedC_ = -1;		
    maskSprite_.visible = NO;
}

-(BOOL) findRoadSourceRow:(int)sr sourceColumn:(int)sc targetRow:(int)tr targetColumn:(int)tc
{
	[checkList_ removeAllObjects];
	for (int r = 0; r<FIVE_BOARD_ROW; r++) {
		for (int c = 0; c<FIVE_BOARD_COLUMN; c++) {
			tileParent_[r*FIVE_BOARD_COLUMN+c] = -1;
		}
	}
	[checkList_ addObject:[NSNumber numberWithInt:tr*FIVE_BOARD_COLUMN+tc]];
	tileParent_[tr*FIVE_BOARD_COLUMN+tc] = tr*FIVE_BOARD_COLUMN+tc;
	while ([checkList_ count]>0) {
		int index = [[checkList_ objectAtIndex:0] intValue];
		int row = index/FIVE_BOARD_COLUMN;
		int column = index%FIVE_BOARD_COLUMN;
		if (row+1 == sr && column == sc) {
			tileParent_[sr*FIVE_BOARD_COLUMN+sc] = index;
			return YES;
		}
		else {
			[self addToCheckListWithRow:(row+1) column:column parent:index];
		}
		if (row-1 == sr && column == sc) {
			tileParent_[sr*FIVE_BOARD_COLUMN+sc] = index;
			return YES;
		}
		else {
			[self addToCheckListWithRow:(row-1) column:column parent:index];
		}
		if (row == sr && column+1 == sc) {
			tileParent_[sr*FIVE_BOARD_COLUMN+sc] = index;
			return YES;
		}
		else {
			[self addToCheckListWithRow:row column:(column+1) parent:index];
		}
		if (row == sr && column-1 == sc) {
			tileParent_[sr*FIVE_BOARD_COLUMN+sc] = index;
			return YES;
		}
		else {
			[self addToCheckListWithRow:row column:(column-1) parent:index];			
		}
		[checkList_ removeObjectAtIndex:0];
	}
	return NO;
}

-(void) addToCheckListWithRow:(int)r column:(int)c parent:(int)p
{
	int index = r*FIVE_BOARD_COLUMN+c;
	if (r>=0 && r<FIVE_BOARD_ROW && c>=0 && c<FIVE_BOARD_COLUMN && tileParent_[index] == -1 && tileColors_[index] == -1) {
		tileParent_[index] = p;
		[checkList_ addObject:[NSNumber numberWithInt:index]];
	}
}

-(void) moveTileSourceRow:(int)sr sourceColumn:(int)sc targetRow:(int)tr targetColumn:(int)tc
{
    preTargetPoint_ = ccp(tr, tc);
	tileColors_[tr*FIVE_BOARD_COLUMN+tc] = tileColors_[sr*FIVE_BOARD_COLUMN+sc];
	tileColors_[sr*FIVE_BOARD_COLUMN+sc] = -1;
	CCSprite * sprite = [tileSprites_ objectAtIndex:(sr*FIVE_BOARD_COLUMN+sc)];
	[tileSprites_ replaceObjectAtIndex:(tr*FIVE_BOARD_COLUMN+tc) withObject:sprite];
	[tileSprites_ replaceObjectAtIndex:(sr*FIVE_BOARD_COLUMN+sc) withObject:[NSNull null]];
	int nextStep = sr*FIVE_BOARD_COLUMN+sc;
	while(nextStep!=tileParent_[nextStep]){
        CCSprite * dotSprite = [CCSprite spriteWithSpriteFrameName:@"linkdot.png"];
        dotSprite.position = ccp((0.5+nextStep%FIVE_BOARD_COLUMN)*FIVE_BOARD_TILE_WIDTH,(0.5+nextStep/FIVE_BOARD_COLUMN)*FIVE_BOARD_TILE_HEIGHT);
        [dotBatch_ addChild:dotSprite];
        id action = [CCSequence actions:
                     [CCDelayTime actionWithDuration:0.2],
                     [CCFadeOut actionWithDuration:0.2],
                     [CCCallFuncN actionWithTarget:dotSprite selector:@selector(removeFromParentAndCleanup:)],nil];
        [dotSprite runAction:action];
		nextStep = tileParent_[nextStep];
	}
	sprite.position = ccp((0.5+tc)*FIVE_BOARD_TILE_WIDTH,(0.5+tr)*FIVE_BOARD_TILE_HEIGHT);
    [[SimpleAudioEngine sharedEngine] playEffect:@"linkclear.mp3"];
}

-(BOOL) checkFiveAtRow:(int)r column:(int)c
{
	NSMutableArray * eArray = [[NSMutableArray alloc] init];
	NSMutableArray * nArray = [[NSMutableArray alloc] init];
	NSMutableArray * neArray = [[NSMutableArray alloc] init];
	NSMutableArray * nwArray = [[NSMutableArray alloc] init];
	BOOL isFive = NO;
	
	int index = r*FIVE_BOARD_COLUMN+c;
	int color = tileColors_[index];
	if (color == -1) {
		return isFive;
	}

	int dc = 1;
	while (c+dc<FIVE_BOARD_COLUMN && tileColors_[r*FIVE_BOARD_COLUMN+c+dc] == color) {
		[eArray addObject:[NSNumber numberWithInt:r*FIVE_BOARD_COLUMN+c+dc]];
		dc++;
	}
	dc = 1;
	while (c-dc>=0 && tileColors_[r*FIVE_BOARD_COLUMN+c-dc] == color) {
		[eArray addObject:[NSNumber numberWithInt:r*FIVE_BOARD_COLUMN+c-dc]];
		dc++;
	}
	int dr = 1;
	while (r+dr<FIVE_BOARD_ROW && tileColors_[(r+dr)*FIVE_BOARD_COLUMN+c] == color) {
		[nArray addObject:[NSNumber numberWithInt:(r+dr)*FIVE_BOARD_COLUMN+c]];
		dr++;
	}
	dr = 1;
	while (r-dr>=0 && tileColors_[(r-dr)*FIVE_BOARD_COLUMN+c] == color) {
		[nArray addObject:[NSNumber numberWithInt:(r-dr)*FIVE_BOARD_COLUMN+c]];
		dr++;
	}
	int drc = 1;
	while (r+drc<FIVE_BOARD_ROW && c+drc<FIVE_BOARD_COLUMN && tileColors_[(r+drc)*FIVE_BOARD_COLUMN+c+drc] == color) {
		[neArray addObject:[NSNumber numberWithInt:(r+drc)*FIVE_BOARD_COLUMN+c+drc]];
		drc++;
	}
	drc = 1;
	while (r-drc>=0 && c-drc>=0 && tileColors_[(r-drc)*FIVE_BOARD_COLUMN+c-drc] == color) {
		[neArray addObject:[NSNumber numberWithInt:(r-drc)*FIVE_BOARD_COLUMN+c-drc]];
		drc++;
	}
	drc = 1;
	while (r+drc<FIVE_BOARD_ROW && c-drc>=0 && tileColors_[(r+drc)*FIVE_BOARD_COLUMN+c-drc] == color) {
		[nwArray addObject:[NSNumber numberWithInt:(r+drc)*FIVE_BOARD_COLUMN+c-drc]];
		drc++;
	}
	drc = 1;
	while (r-drc>=0 && c+drc<FIVE_BOARD_COLUMN && tileColors_[(r-drc)*FIVE_BOARD_COLUMN+c+drc] == color) {
		[nwArray addObject:[NSNumber numberWithInt:(r-drc)*FIVE_BOARD_COLUMN+c+drc]];
		drc++;
	}
	
	if ([eArray count]>=4) {
		for (int i = 0; i<[eArray count]; i++) {
			[self removeTile:[[eArray objectAtIndex:i] intValue]];
		}
		if (!isFive) {
			isFive = YES;
		}
	}
	if ([nArray count]>=4) {
		for (int i = 0; i<[nArray count]; i++) {
			[self removeTile:[[nArray objectAtIndex:i] intValue]];
		}
		if (!isFive) {
			isFive = YES;
		}
	}
	if ([neArray count]>=4) {
		for (int i = 0; i<[neArray count]; i++) {
			[self removeTile:[[neArray objectAtIndex:i] intValue]];
		}
		if (!isFive) {
			isFive = YES;
		}
	}
	if ([nwArray count]>=4) {
		for (int i = 0; i<[nwArray count]; i++) {
			[self removeTile:[[nwArray objectAtIndex:i] intValue]];
		}
		if (!isFive) {
			isFive = YES;
		}
	}
	if (isFive) {
		[self removeTile:r*FIVE_BOARD_COLUMN+c];
		[[SimpleAudioEngine sharedEngine] playEffect:@"clear.mp3"];
	}
	[eArray release];
	[nArray release];
	[neArray release];
	[nwArray release];
	return isFive;
}
		 
-(void) removeTile:(int)index
{
	tileColors_[index] = -1;
	CCSprite * sprite = [tileSprites_ objectAtIndex:index];
	[sprite runAction:[CCSequence actions:
                       [CCFadeOut actionWithDuration:0.2],
                       [CCCallFuncN actionWithTarget:sprite selector:@selector(removeFromParentAndCleanup:)],nil]];	
    [tileSprites_ replaceObjectAtIndex:index withObject:[NSNull null]];
    score_ += 10;
    [scoreLabel_ setString:[NSString stringWithFormat:@"%d",score_]];
    tileNum_--;
}

-(CGPoint) checkAroundPos:(CGPoint)pos
{
    if (pos.x != -1 && pos.y != -1) {
        int dir[8][2]={{1,0},{1,-1},{1,1},{0,-1},{0,1},{-1,-1},{-1,1},{-1,0}};
        for (int i=0; i<8; i++) {
            int r = pos.x+dir[i][0];
            int c = pos.y+dir[i][1];
            if (r>=0 && r<FIVE_BOARD_ROW && c>=0 && c<FIVE_BOARD_COLUMN) {
                if (tileColors_[r*FIVE_BOARD_COLUMN+c] != -1) {
                    int rr = pos.x+dir[7-i][0];
                    int rc = pos.y+dir[7-i][1];
                    if (rr>=0 && rr<FIVE_BOARD_ROW && rc>=0 && rc<FIVE_BOARD_COLUMN) {
                        if (tileColors_[rr*FIVE_BOARD_COLUMN+rc] == -1) {
                            return ccp(rr, rc);
                        }
                    }
                }
            }
        }
    }
    return ccp(-1, -1);
}

-(void) checkFiveWith:(id)sender index:(int *)i
{
    [self checkFiveAtRow:((*i)/FIVE_BOARD_COLUMN) column:((*i)%FIVE_BOARD_COLUMN)];
    free(i);
}

-(void) generateTile:(int)n
{
	int count = 0;
	for (int tileCount = 0; tileCount < n; tileCount++) {
		int randIndex = rand()%(FIVE_BOARD_ROW*FIVE_BOARD_COLUMN);
		int i = randIndex;
		int color = [[nextGenerateColors_ objectAtIndex:tileCount] intValue];
        CGPoint point;
        if (CCRANDOM_0_1()<0.8) {
            if (preTargetPoint_.x>=0&&preTargetPoint_.x<FIVE_BOARD_ROW
                &&preTargetPoint_.y>=0&&preTargetPoint_.y<FIVE_BOARD_COLUMN
                &&tileColors_[(int)preTargetPoint_.x*FIVE_BOARD_COLUMN+(int)preTargetPoint_.y]==color) {
                point = ccp(-1, -1);
            }else {
                point = [self checkAroundPos:preTargetPoint_];
            }
        }else {
            point = preSourcePoint_;
        }
        if (CCRANDOM_0_1()<0.8 && point.x!=-1 && point.y!=-1) {
            i = point.x*FIVE_BOARD_COLUMN+point.y;
        }else {
            do {
                if (tileColors_[i] == -1) {
                    count++;				
                    break;
                }
                i = (i+1)%(FIVE_BOARD_ROW*FIVE_BOARD_COLUMN);
            } while (i != (randIndex-1)%(FIVE_BOARD_ROW*FIVE_BOARD_COLUMN));
        }
        if (tileColors_[i] != -1) {
            break;
        }
        tileColors_[i] = color;
        CCSprite * tileSprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"fivetile%d.png",color]];
        tileSprite.position = CGPointZero;
        int *index = (int *)malloc(sizeof(int));
        *index = i;
        [tileSprite runAction:[CCSequence actions:
                               [CCMoveTo actionWithDuration:0.5 position:ccp((0.5+i%FIVE_BOARD_COLUMN)*FIVE_BOARD_TILE_WIDTH,(0.5+i/FIVE_BOARD_COLUMN)*FIVE_BOARD_TILE_HEIGHT)],
                               [CCCallFuncND actionWithTarget:self selector:@selector(checkFiveWith:index:) data:index], nil]];
        [tileSprites_ replaceObjectAtIndex:i withObject:tileSprite];
        [tileBatch_ addChild:tileSprite];
        tileNum_ ++;
        
	}
	if (tileNum_ == FIVE_BOARD_ROW*FIVE_BOARD_COLUMN) {
		[self overRound];
	}
}


#pragma mark SquareFive - control node

-(void) moveGameIn
{
    [board_ runAction:[CCMoveTo actionWithDuration:0.2 position:FIVE_BOARD_POSITION]];
    [tileBatch_ runAction:[CCMoveTo actionWithDuration:0.2 position:FIVE_TILEBATCH_POSITION]];
    [dotBatch_ runAction:[CCMoveTo actionWithDuration:0.2 position:FIVE_TILEBATCH_POSITION]];
    [nextGenerateBanner_ runAction:[CCMoveTo actionWithDuration:0.2 position:FIVE_NEXT_POSITION]];
    [scoreLabel_ runAction:[CCMoveTo actionWithDuration:0.2 position:FIVE_SCORELABEL_POSITION]];
}

-(void) moveGameOut
{
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    [board_ runAction:[CCMoveTo actionWithDuration:0.2 position:ccpAdd(FIVE_BOARD_POSITION,ccp(0,-screenSize.height))]];
    [tileBatch_ runAction:[CCMoveTo actionWithDuration:0.2 position:ccpAdd(FIVE_TILEBATCH_POSITION,ccp(0,-screenSize.height))]];
    [dotBatch_ runAction:[CCMoveTo actionWithDuration:0.2 position:ccpAdd(FIVE_TILEBATCH_POSITION,ccp(0,-screenSize.height))]];
    [nextGenerateBanner_ runAction:[CCMoveTo actionWithDuration:0.2 position:ccpAdd(FIVE_NEXT_POSITION,ccp(0,-screenSize.height))]];
    [scoreLabel_ runAction:[CCMoveTo actionWithDuration:0.2 position:ccpAdd(FIVE_SCORELABEL_POSITION,ccp(0,-screenSize.height))]];	
}

#pragma mark SquareFive - handle touch event

-(void) touchBeganAt:(CGPoint)location
{
	CGPoint tileBatchLocation = [tileBatch_ convertToNodeSpace:location];
	int r = floor(tileBatchLocation.y/FIVE_BOARD_TILE_HEIGHT);
	int c = floor(tileBatchLocation.x/FIVE_BOARD_TILE_WIDTH);
	if (gameState_ != gameStateRunning || r<0 || r>=FIVE_BOARD_ROW || c<0 || c>=FIVE_BOARD_COLUMN) {
		return;
	}
	else {
		int currentColor = tileColors_[r*FIVE_BOARD_COLUMN+c];
		if (someTileSelected_) {
			if (r == selectedR_ && c == selectedC_) {
				[self unselect];
			}
			else if(currentColor != -1) {
				[self selectRow:r column:c];
			}
			else if(currentColor == -1){
				if ([self findRoadSourceRow:selectedR_ sourceColumn:selectedC_ targetRow:r targetColumn:c]){
					[self moveTileSourceRow:selectedR_ sourceColumn:selectedC_ targetRow:r targetColumn:c];
					[self unselect];
					if (![self checkFiveAtRow:r column:c] || tileNum_ == 0) {
						[self generateTile:FIVE_GENERATE_NUM];
                        [self nextGenerateColors];
					}
				}
				else {
					[self unselect];
				}
			}
		}
		else if(currentColor != -1){
			[self selectRow:r column:c];
		}
	}
}


@end
