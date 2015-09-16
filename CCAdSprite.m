//
//  CCAdSprite.m
//  square
//
//  Created by LIN BOYU on 6/22/13.
//  Copyright (c) 2013 LIN BOYU. All rights reserved.
//

#import "CCAdSprite.h"
#import "SquareDirector.h"
#import "ServerPortAd.h"

@implementation CCAdSprite

@synthesize touchPriority = touchPriority_;

+(id) spriteWithDir:(NSString *)dir location:(int)location index:(int)index
{
    return [[[self alloc] initWithDir:dir location:location index:index] autorelease];
}

-(id) initWithDir:(NSString *)dir location:(int)location index:(int)index
{
    NSString *path = [dir stringByAppendingPathComponent:[NSString stringWithFormat:@"%i_%i",location,index]];
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfFile:path]];    
    [[CCTextureCache sharedTextureCache] removeTextureForKey:path];
    if (( self = [super initWithCGImage:[image CGImage] key:path] )) {
        location_ = location;
        index_ = index;
        touchPriority_ = 0;
    }
    return self;
}

-(id) initWithFile:(NSString *)filename
{
    if (( self = [super initWithFile:filename] )) {
        location_ = -1;
        index_ = -1;
    }
    return self;
}

-(void) onEnter
{
    [super onEnter];
    [[CCDirector sharedDirector].touchDispatcher addTargetedDelegate:self priority:touchPriority_ swallowsTouches:YES];
    if (location_!=-1 && index_ != -1) {
        [[ServerPortAd sharedServerPort] postShow:location_ index:index_];
    }
}

-(void) onExit
{
    [[CCDirector sharedDirector].touchDispatcher removeDelegate:self];
    [super onExit];
}

-(BOOL) containTouch:(UITouch *)touch
{
    CGPoint p = [self convertToNodeSpace:[[CCDirector sharedDirector] convertToGL: [touch locationInView: [touch view]]]];
    CGRect rect = CGRectMake(0,0,_contentSize.width,_contentSize.height);
    return CGRectContainsPoint(rect,p);
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	if ([self containTouch:touch]) {
        selected_ = YES;
        return YES;
    }
    return NO;
}

-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	if (![self containTouch:touch]) {
		if (selected_) {
			selected_ = NO;
		}
	}
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	if ([self containTouch:touch]) {
        if (selected_) {
            if (location_ != -1 && index_ != -1) {
                [[ServerPortAd sharedServerPort] postClick:location_ index:index_];
                [[SquareDirector sharedDirector] linkToAd:location_ index:index_];
            }
            selected_ = NO;
        }
	}
}


@end
