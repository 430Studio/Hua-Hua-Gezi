//  JSButton
//  Created by LIN BOYU


#import <Foundation/Foundation.h>
#import "cocos2d.h"

#define JSBUTTON_MOVE_X 1
#define JSBUTTON_MOVE_Y -1


@interface CCButton : CCSprite <CCTouchOneByOneDelegate> {
	
	NSInvocation * invocation;
	
	BOOL enabled_;
	
	BOOL selected_;
	
	int touchState_;
    
    int touchPriority_;
	
	NSString * normalFrameName_;
	
	NSString * selectedFrameName_;
}

@property(nonatomic,readwrite) BOOL enabled;

@property(nonatomic,readwrite) BOOL selected;

@property(nonatomic,readwrite) int touchPriority;

+(id) buttonWithTarget:(id)r selector:(SEL)s normalFrame:(NSString *)nF selectedFrame:(NSString *)sF;

-(id) initWithTarget:(id)r selector:(SEL)s normalFrame:(NSString *)nF selectedFrame:(NSString *)sF;

-(id) init;

-(void) enable;

-(void) disable;

-(BOOL) containPoint:(CGPoint)p;

-(BOOL) containNodePoint:(CGPoint)p;

@end