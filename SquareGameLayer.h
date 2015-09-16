//
//  SquareLayer.h
//  Square
//
//  Created by mac on 12-1-5.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"



@class SquareGame;

@interface SquareGameLayer : CCLayer {
 
	SquareGame * game_;
    
    CGPoint lastPoint1_;
    CGPoint lastPoint2_;

}


+(id) layerWithGame:(SquareGame *)g;

-(id) initWithGame:(SquareGame *)g;

@end
