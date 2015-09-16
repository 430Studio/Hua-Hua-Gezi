//
//  SquareBoardSprite.m
//  Square
//
//  Created by LIN BOYU on 12/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SquareBoardSprite.h"

@implementation SquareBoardSprite

+(id) spriteWithBackFile:(NSString *)bF tileFile:(NSString *)tF row:(int)r column:(int)c tileWidth:(int)tW tileHeight:(int)tH;
{
	return [[[SquareBoardSprite alloc] initWithBackFile:bF tileFile:tF row:r column:c tileWidth:tW tileHeight:tH] autorelease];
}

-(id) initWithBackFile:(NSString *)bF tileFile:(NSString *)tF row:(int)r column:(int)c tileWidth:(int)tW tileHeight:(int)tH;
{
	CGRect boardRect = CGRectMake(0, 0, c*tW+2*BOARD_MARGIN, r*tH+2*BOARD_MARGIN);	
	if (( self = [super initWithFile:bF rect:boardRect] )) {
		self.anchorPoint = ccp(0,0);
        
        CCSprite * shadowSprite = [CCSprite spriteWithFile:@"boardshadow.png"];
        shadowSprite.scaleX = boardRect.size.width/900;
        shadowSprite.scaleY = boardRect.size.height/900;
        shadowSprite.position = ccp(0.5*boardRect.size.width+8,0.5*boardRect.size.height-8);
        [self addChild:shadowSprite z:-1];
        
		CCSpriteBatchNode * tileBatch = [CCSpriteBatchNode batchNodeWithFile:@"boardtile.pvr.ccz"];
		tileBatch.position = ccp(BOARD_MARGIN,BOARD_MARGIN);
		[self addChild:tileBatch];
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"boardtile.plist"];
		CCSprite * tileSprite;
		for (int rCount = 0; rCount<r+1; rCount++) {
			for (int cCount = 0; cCount<c+1; cCount++) {
				if (rCount == 0) {
					if (cCount == 0 ) {
						tileSprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"boardtile2%d.png",rand()%4]];
					}
					else if(cCount == c) {
						tileSprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"boardtile2%d.png",rand()%4]];
						tileSprite.rotation = -90;
					}
					else {
						tileSprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"boardtile3%d.png",rand()%4]];
					}
				}
				else if(rCount == r){
					if (cCount == 0) {
						tileSprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"boardtile2%d.png",rand()%4]];
						tileSprite.rotation = 90;
					}
					else if(cCount == c){
						tileSprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"boardtile2%d.png",rand()%4]];
						tileSprite.rotation = 180;
					}
					else {
						tileSprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"boardtile3%d.png",rand()%4]];
						tileSprite.rotation = 180;
					}
				}
				else{
					if (cCount == 0) {
						tileSprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"boardtile3%d.png",rand()%4]];
						tileSprite.rotation = 90;
					}
					else if(cCount == c) {
						tileSprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"boardtile3%d.png",rand()%4]];
						tileSprite.rotation = 270;
					}
					else {
						tileSprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"boardtile4%d.png",rand()%4]];
					}
				}
				tileSprite.scaleX = (float)tW/ORIGINAL_TILE_WIDTH;
				tileSprite.scaleY = (float)tH/ORIGINAL_TILE_HEIGHT;
				tileSprite.position = ccp(cCount*tW,rCount*tH);
				[tileBatch addChild:tileSprite];
			}
		}
	}
	return self;
}

@end
