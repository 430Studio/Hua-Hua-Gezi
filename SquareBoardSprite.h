//
//  SquareBoardSprite.h
//  Square
//
//  Created by LIN BOYU on 12/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#define BOARD_MARGIN 4
#define ORIGINAL_TILE_WIDTH 64
#define ORIGINAL_TILE_HEIGHT 64

@interface SquareBoardSprite : CCSprite {

}

+(id) spriteWithBackFile:(NSString *)bF tileFile:(NSString *)tF row:(int)r column:(int)c tileWidth:(int)tW tileHeight:(int)tH;

-(id) initWithBackFile:(NSString *)bF tileFile:(NSString *)tF row:(int)r column:(int)c tileWidth:(int)tW tileHeight:(int)tH;

@end
