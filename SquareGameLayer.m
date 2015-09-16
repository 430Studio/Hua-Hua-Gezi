//
//  SquareLayer.m
//  Square
//
//  Created by mac on 12-1-5.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "SquareGameLayer.h"
#import "SquareGame.h"


@implementation SquareGameLayer




+(id) layerWithGame:(SquareGame *)g
{
	return [[[SquareGameLayer alloc] initWithGame:g] autorelease];
}

-(id) initWithGame:(SquareGame *)g
{
    if ((self = [super init])) {
        [self setContentSize:CGSizeMake(1024, 768)];
		game_ = g;
		[self setTouchEnabled:YES];
	}
    return self;
}

-(void) onEnter
{
    [super onEnter];
    [game_ addTableView];
}

-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	for( UITouch *touch in touches ) {
		CGPoint location = [[CCDirector sharedDirector] convertToGL: [touch locationInView: [touch view]]];
		[game_ touchBeganAt:location];
	}
}

-(void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	for( UITouch *touch in touches ) {
		CGPoint location = [[CCDirector sharedDirector] convertToGL: [touch locationInView: [touch view]]];
		[game_ touchMovedAt:location];
	}	
}

-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	for( UITouch *touch in touches ) {
		CGPoint location = [[CCDirector sharedDirector] convertToGL: [touch locationInView: [touch view]]];
		[game_ touchEndedAt:location];
	}	
}

@end
