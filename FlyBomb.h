//
//  FlyBomb.h
//  Square
//
//  Created by mac on 12-4-10.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface FlyBomb : CCSprite {
    CGPoint targetPos_;
}

-(void) flyFrom:(CGPoint)p1 to:(CGPoint)p2;

-(void) bomb;

@end
