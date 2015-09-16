//
//  SquareBanner.h
//  Square
//
//  Created by LIN BOYU on 11/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCButton.h"


@class SquareGame;

@interface SquareScoreBanner : CCSprite {


}

+(id) bannerWithGame:(SquareGame *)g score:(int)s;

-(id) initWithGame:(SquareGame *)g score:(int)s;

@end


@interface FiveNextBanner : CCSprite {
    
}

+(id) bannerWithGenerateNumber:(int)num;

-(id) initWithGenerateNumber:(int)num;

-(void) setNextGenerateTile:(NSArray *)colors;

@end