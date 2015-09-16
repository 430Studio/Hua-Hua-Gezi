//
//  FlyBomb.m
//  Square
//
//  Created by mac on 12-4-10.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "FlyBomb.h"
#import "SquareParticle.h"
#import "SimpleAudioEngine.h"

@implementation FlyBomb

-(id) init
{
    if ( (self = [super init]) ) {
        self.visible = NO;
        self.anchorPoint = ccp(0.25, 0.5);
    }
    return self;
}

-(void) flyFrom:(CGPoint)p1 to:(CGPoint)p2
{
    self.position = p1;
    targetPos_ = p2;
    self.visible = YES;
    CGPoint p = ccpSub(p2, p1);
    float angle = M_PI - atan2f(p.y, p.x);
    self.rotation = angle*180/M_PI;
    id action = [CCSequence actions:[CCMoveTo actionWithDuration:0.4 position:p2],
                 [CCDelayTime actionWithDuration:0.2],
                 [CCCallFunc actionWithTarget:self selector:@selector(bomb)],
                 [CCDelayTime actionWithDuration:0.2],
                 [CCCallFunc actionWithTarget:self selector:@selector(removeFromParentAndCleanup:)], nil];
    
    [self runAction:action];
}

-(void) bomb
{
    FlyBombParticle * particle = [FlyBombParticle node];
    particle.position = targetPos_;
    [self.parent addChild:particle z:4];
    [[SimpleAudioEngine sharedEngine] playEffect:@"bomb.mp3"];
}

@end
