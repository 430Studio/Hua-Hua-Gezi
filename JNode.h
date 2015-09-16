//
//  JNode.h
//  Square
//
//  Created by mac on 12-2-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class SquareJewelery;

enum {
    levelPrimary = 0,
    levelBombNine,
    levelWipeSameType,
    levelWipeTweentyFive,
    levelWipeAll
};

@interface JNode : NSObject {
    BOOL canWipeLandscape_;
    BOOL canWipePortrait_;
    BOOL isNullVisited_;
    int type_;
    BOOL canWipe_;
    CCSprite * jewelery_;
    SquareJewelery * currentGame_;
    int jeweleryLevel_;
    int subLevel_;
    BOOL isUpdated_;
    BOOL isOccur_;
    int linkedNum_;
    NSValue * pos_;
}

@property (nonatomic,readwrite) BOOL canWipeLandscape;
@property (nonatomic,readwrite) BOOL canWipePortrait;
@property (nonatomic,readwrite) BOOL isNullVisited;
@property (nonatomic,readwrite) BOOL canWipe;
@property (nonatomic,readwrite) BOOL isUpdated;
@property (nonatomic,readonly) BOOL isOccur;
@property (nonatomic,retain) CCSprite * jewelery;
@property (nonatomic,readwrite) int type;
@property (nonatomic,readwrite) int jeweleryLevel;
@property (nonatomic,readonly) int subLevel;
@property (nonatomic,readwrite) int linkedNum;
@property (nonatomic,retain) NSValue * pos;

+(JNode *) jNodeWithType:(int)type andGame:(SquareJewelery *)currentGame;

-(id) initWithType:(int)type andGame:(SquareJewelery *)currentGame;

-(void) produceJeweleryAt:(CGPoint)position withDuration:(float)duration;

-(void) setNull;

-(void) comboWipe;

-(void) specialWipe;

-(void) resetJNode;

-(void) addLevelMask;

-(void) setLevel:(NSNumber *)jeweleryLevel;

-(void) addLinkedNum:(int)linkedNum;

-(void) swapWithJNode:(JNode *)jNode;

-(void) moveDownWithDistance:(float)dis downOrder:(int)d;

-(BOOL) isNull;

-(void) occurToPos:(CGPoint)pos;

-(void) resetVisitProperty;

-(void) resetJeweleryState;

@end
