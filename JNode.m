//
//  JNode.m
//  Square
//
//  Created by mac on 12-2-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "JNode.h"
#import "SquareJewelery.h"

@implementation JNode

@synthesize canWipePortrait = canWipePortrait_;
@synthesize canWipeLandscape = canWipeLandscape_;
@synthesize isNullVisited = isNullVisited_;
@synthesize canWipe = canWipe_;
@synthesize type = type_;
@synthesize jewelery = jewelery_;
@synthesize jeweleryLevel = jeweleryLevel_;
@synthesize subLevel = subLevel_;
@synthesize isUpdated = isUpdated_;
@synthesize isOccur = isOccur_;
@synthesize linkedNum = linkedNum_;
@synthesize pos = pos_;

+(JNode *) jNodeWithType:(int)type andGame:(SquareJewelery *)currentGame
{
    return [[[self alloc] initWithType:type andGame:currentGame] autorelease];
}

-(id) initWithType:(int)type andGame:(SquareJewelery *)currentGame
{
    if ( (self = [super init]) ) {
        jewelery_ = nil;
        canWipePortrait_ = NO;
        canWipeLandscape_ = NO;
        isNullVisited_ = NO;
        canWipe_ = NO;
        isOccur_ = NO;
        isUpdated_ = NO;
        type_ = type;
        currentGame_ = currentGame;
        jeweleryLevel_ = levelPrimary;
    }
    return self;
}

-(void) setLevel:(NSNumber *)jeweleryLevel
{
    if (jeweleryLevel_ != levelPrimary) {
        isUpdated_ = YES;
        return;
    }
    jeweleryLevel_ = [jeweleryLevel intValue]>levelWipeAll?levelWipeAll:[jeweleryLevel intValue];
    subLevel_ = rand()%2+1;
    [self performSelector:@selector(addLevelMask) withObject:nil afterDelay:0.3];
}

-(void) addLevelMask
{    
    NSString * frameName = [NSString stringWithFormat:@"level%d",jeweleryLevel_];
    if (jeweleryLevel_ == 2) {
        frameName = [frameName stringByAppendingFormat:@"%d.png",subLevel_];
    }else {
        frameName = [frameName stringByAppendingString:@".png"];
    }
    CCSprite *spacialMask = [CCSprite spriteWithSpriteFrameName:frameName];
    spacialMask.position = ccp(jewelery_.contentSize.width/2,jewelery_.contentSize.height/2);
    [jewelery_ addChild:spacialMask z:-1];
    id action = [CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:1.0 angle:60+CCRANDOM_0_1()*60]];
    [spacialMask runAction:action];
}

-(void) addLinkedNum:(int)linkedNum
{
    linkedNum_ += linkedNum_>0?linkedNum-1:linkedNum;
    if (linkedNum_ >= 5 && canWipeLandscape_ && canWipePortrait_) {
        currentGame_.isExistSpecialTile = YES;
        currentGame_.specialTilePos = pos_;
        currentGame_.specialTileLinkedNum = linkedNum_;
        //        [currentGame_ changeTileLevelWithNum:linkedNum_ forPos:pos_];
    }
}

-(void) produceJeweleryAt:(CGPoint)position withDuration:(float)duration
{
    jewelery_ = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"jewelery%d.png",type_+1]];
    jewelery_.position = position;
    jewelery_.scale = 0.0;
    id scaleOut = [CCScaleTo actionWithDuration:duration scale:1.0];
    [jewelery_ runAction:scaleOut];
}

-(void) resetJeweleryState
{
    currentGame_.isJeweleryMoving = NO;
}

-(void) resetVisitProperty
{
    canWipeLandscape_ = NO;
    canWipePortrait_ = NO;
    canWipe_ = NO;
}

-(void) resetJNode
{
    type_ = -1;
    [self resetVisitProperty];
    jeweleryLevel_ = levelPrimary;
}

-(void) setNull
{      
    [self resetJNode];
    id shrinkOut = [CCSequence actionOne:[CCScaleTo actionWithDuration:0.3 scale:0.0] two:[CCCallFunc actionWithTarget:jewelery_ selector:@selector(removeFromParentAndCleanup:)]];
    if (jewelery_) {
        [jewelery_ runAction:shrinkOut];
    }
}

-(void) comboWipe
{
    id action = [CCSequence actionOne:[CCScaleTo actionWithDuration:0.2 scale:1.3]
                                  two:[CCCallFunc actionWithTarget:self selector:@selector(setNull)]];
    if (jewelery_) {
        [jewelery_ runAction:action];
    }
}

-(void) specialWipe
{
    id scaleOut = [CCScaleBy actionWithDuration:0.2 scale:1.2];
    id scaleIn = [scaleOut reverse];
    id fadeOut = [CCFadeOut actionWithDuration:0.2];
    id action = [CCSequence actions:scaleOut,scaleIn,scaleOut,scaleIn,[CCSpawn actionOne:scaleOut two:fadeOut], nil];
    [jewelery_ runAction:action];
}

-(void) occurToPos:(CGPoint)pos
{
    //    [self resetJNode];
    //    id action = [CCSequence actions:[CCMoveTo actionWithDuration:0.3 position:pos],[CCCallFunc actionWithTarget:jewelery_ selector:@selector(removeFromParentAndCleanup:)],nil];
    canWipe_ = YES;
    isOccur_ = YES;
    [jewelery_ stopAllActions];
    id action = [CCMoveTo actionWithDuration:0.2 position:pos];
    [jewelery_ runAction:action];
}

-(void) swapWithJNode:(JNode *)jNode
{
    CGPoint pos = [pos_ CGPointValue];
    pos = ccp((0.5+pos.y)*JEWELERY_BOARD_TILE_WIDTH,(0.5+pos.x)*JEWELERY_BOARD_TILE_HEIGHT);
    CGPoint jPos = [jNode.pos CGPointValue];
    jPos = ccp((0.5+jPos.y)*JEWELERY_BOARD_TILE_WIDTH,(0.5+jPos.x)*JEWELERY_BOARD_TILE_HEIGHT);
    currentGame_.isJeweleryMoving = YES;
    [jewelery_ runAction:[CCMoveTo actionWithDuration:0.2 position:pos]];
    [jNode.jewelery runAction:[CCSequence actionOne:[CCMoveTo actionWithDuration:0.2 position:jPos] two:[CCCallFunc actionWithTarget:self selector:@selector(resetJeweleryState)]]];
}

-(void) moveDownWithDistance:(float)dis downOrder:(int)d
{
    CGPoint pos = ccp((int)jewelery_.position.y/JEWELERY_BOARD_TILE_HEIGHT, (int)jewelery_.position.x/JEWELERY_BOARD_TILE_WIDTH);
    //CGPoint pos = [pos_ CGPointValue];
    pos = ccp((0.5+pos.y)*JEWELERY_BOARD_TILE_WIDTH,(0.5+pos.x)*JEWELERY_BOARD_TILE_HEIGHT);
    pos = ccpAdd(pos, ccp(0, -dis));
    float time;
    if (d!=-1) {
        time = 0.2;//+(d+1)*0.05;
    }else {
        time = 0.2;
    }
    id moveDown = [CCMoveTo actionWithDuration:time position:pos];
    if (jewelery_) {
        [jewelery_ runAction:moveDown];
    }
}

-(BOOL) isNull
{
    return type_ == -1;
}

-(void) dealloc
{
    [pos_ release];
    [super dealloc];
}

@end
