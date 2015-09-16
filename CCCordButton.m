//
//  CCCord.m
//  Square
//
//  Created by LIN BOYU on 12/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CCCordButton.h"
#import "SimpleAudioEngine.h"

@implementation CCCordButton

+(id) buttonWithTarget:(id)t selector:(SEL)s frameName:(NSString *)fN
{
	return [[[CCCordButton alloc] initWithTarget:t selector:s frameName:fN] autorelease];
}

-(id) initWithTarget:(id)t selector:(SEL)s frameName:(NSString *)fN
{
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"button.plist"];
	if(( self = [super initWithSpriteFrameName:fN] )) {
		if( t && s ) {
			NSMethodSignature * sig = [t methodSignatureForSelector:s];
			invocation_ = [NSInvocation invocationWithMethodSignature:sig];
			[invocation_ setTarget:t];
			[invocation_ setSelector:s];
			[invocation_ retain];
		}
		selected_ = NO;
        firstPull_ = NO;
		self.anchorPoint = ccp(0.5,1);
	}
	return self;
}

-(void) dealloc
{
	[invocation_ release];
	[super dealloc];
}


#pragma mark CCCordButton - register & remove touch event 

-(void) onEnter
{
	[super onEnter];
	[[CCDirector sharedDirector].touchDispatcher addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

-(void) onExit
{
	[[CCDirector sharedDirector].touchDispatcher removeDelegate:self];
	[super onExit];
}

#pragma mark CCCordButton - handle touch event

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint location = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
	if (!selected_ && [self containPoint:location]) {
		selected_ = YES;
        if (!firstPull_) {
            beginButtonPosition_ = _position;
            firstPull_ = YES;
        }
		beginTouchPosition_ = location;
		return YES;
	}
	return NO;
}

-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint location = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
	if ([self containPoint:location]) {
		if (selected_) {
            if (location.y>beginTouchPosition_.y) {
                return;
            }
			self.position = ccpAdd(beginButtonPosition_,ccp(0,location.y-beginTouchPosition_.y));
			if (beginButtonPosition_.y-self.position.y>=100) {
				[self runAction:[CCMoveTo actionWithDuration:0.3 position:beginButtonPosition_]];
				selected_ = NO;
                [[SimpleAudioEngine sharedEngine] playEffect:@"buttonclick.mp3"];
				[invocation_ invoke];
			}
		}
	}
	else if (selected_) {
		selected_ = NO;
	}
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	if (selected_) {
        [self runAction:[CCMoveTo actionWithDuration:0.3 position:beginButtonPosition_]];
		selected_ = NO;
	}
}

-(BOOL) containPoint:(CGPoint)p
{
	CGPoint location = [self convertToNodeSpace:p];
	return [self containNodePoint:location];
}

-(BOOL) containNodePoint:(CGPoint)p
{
	CGRect rect = CGRectMake(0,0,_contentSize.width,_contentSize.height+10);
	if (CGRectContainsPoint(rect,p)) {
		return YES;
	}
	else {
		return NO;
	}
}
						
@end
