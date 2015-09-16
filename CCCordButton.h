//
//  CCCord.h
//  Square
//
//  Created by LIN BOYU on 12/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CCCordButton : CCSprite<CCTouchOneByOneDelegate> {
	
	NSInvocation * invocation_;
		
	BOOL selected_;
	
	int touchState_;
	
	CGPoint beginButtonPosition_;
	
	CGPoint beginTouchPosition_;
	
    BOOL firstPull_;
}

+(id) buttonWithTarget:(id)t selector:(SEL)s frameName:(NSString *)fN;

-(id) initWithTarget:(id)t selector:(SEL)s frameName:(NSString *)fN;

-(void) dealloc;

-(void) onEnter;

-(void) onExit;

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event;

-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event;

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event;

-(BOOL) containPoint:(CGPoint)p;

-(BOOL) containNodePoint:(CGPoint)p;

@end
