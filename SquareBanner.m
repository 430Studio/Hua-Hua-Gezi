//
//  SquareBanner.m
//  Square
//
//  Created by LIN BOYU on 11/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SquareBanner.h"
#import "SquareGame.h"

@implementation SquareScoreBanner

+(id) bannerWithGame:(SquareGame *)g score:(int)s
{
	return [[[SquareScoreBanner alloc] initWithGame:g score:s] autorelease];
}

-(id) initWithGame:(SquareGame *)g score:(int)s
{
	if (( self  = [super initWithFile:@"scorebanner.png"] )) {
        
        NSString * languageCode = [[SquareDirector sharedDirector] getLanguageCode];

        CCSprite * titleSprite = [CCSprite spriteWithFile:[NSString stringWithFormat:@"scorebannertitle_%@.png",languageCode]];
        [titleSprite setPosition:ccp(194, 245)];
        [self addChild:titleSprite z:0];
        
		CCLabelBMFont * scoreLabel = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%d",s] fntFile:@"number.fnt"];
		scoreLabel.color = ccc3(28, 28, 28);
		scoreLabel.position = ccp(180,180);
        scoreLabel.scale = 1.2;
		[self addChild:scoreLabel z:0];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"button.plist"];
        CCButton * restartButton = [CCButton buttonWithTarget:g 
                                                     selector:@selector(restartButtonClicked) 
                                                  normalFrame:@"restartbutton.png" 
                                                selectedFrame:@"restartbutton1.png"];
        restartButton.position = ccp(305,105);
        [self addChild:restartButton z:1];
        
        CCButton * leaderboardButton = [CCButton buttonWithTarget:g 
                                                     selector:@selector(leadboardButtonClicked)
                                                  normalFrame:@"scoreboardbutton.png" 
                                                selectedFrame:@"scoreboardbutton1.png"];
        leaderboardButton.position = ccp(191,105);
        [self addChild:leaderboardButton z:1];
        
        CCButton * menuButton = [CCButton buttonWithTarget:g 
                                                  selector:@selector(menuButtonClicked) 
                                               normalFrame:@"menubutton.png" 
                                             selectedFrame:@"menubutton1.png"];
        menuButton.position = ccp(80,105);
        [self addChild:menuButton z:1];
	}
	return self;
}
									   
@end

#define FIVE_TILE_WIDTH 64.0
#define FIVE_TILE_HEIGHT 64.0
#define TILE_MARGIN 48.0

@implementation FiveNextBanner

+(id) bannerWithGenerateNumber:(int)num
{
    return [[[self alloc] initWithGenerateNumber:num] autorelease];
}

-(id) initWithGenerateNumber:(int)num
{
    if (( self = [super init] )) {
        self.contentSize = CGSizeMake(FIVE_TILE_WIDTH*3+TILE_MARGIN*2, FIVE_TILE_HEIGHT);
        for (int i=0; i<num; i++) {
            CCSprite * sprite = [CCSprite node];
            sprite.contentSize = CGSizeMake(FIVE_TILE_WIDTH, FIVE_TILE_HEIGHT);
            sprite.position = ccp(i*TILE_MARGIN+i*(FIVE_TILE_WIDTH/2), FIVE_TILE_HEIGHT/2);
            [self addChild:sprite z:0 tag:i];
        }
    }
    return self;
}

-(void) setNextGenerateTile:(NSArray *)colors
{
    for (int i=0; i<[colors count]; i++) {
        NSString * frameName = [NSString stringWithFormat:@"fivetile%d.png",[[colors objectAtIndex:i] intValue]];
        CCSprite *sprite = (CCSprite *)[self getChildByTag:i];
        [sprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName]];
    }
}

@end