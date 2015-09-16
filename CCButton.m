
//  JSButton.m
//  Created by LIN BOYU

#import "CCButton.h"
#import "SimpleAudioEngine.h"

@implementation CCButton

@synthesize enabled = enabled_;

@synthesize selected = selected_;

@synthesize touchPriority = touchPriority_;

#pragma mark ConstructButton - init & dealloc

+(id) buttonWithTarget:(id)r selector:(SEL)s normalFrame:(NSString *)nF selectedFrame:(NSString *)sF
{
	return [[[self alloc] initWithTarget:r selector:s normalFrame:nF selectedFrame:sF] autorelease];
}

-(id) initWithTarget:(id)r selector:(SEL)s normalFrame:(NSString *)nF selectedFrame:(NSString *)sF
{
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"button.plist"];
	if(( self = [super initWithSpriteFrameName:nF] )) {
		if( r && s ) {
			NSMethodSignature * sig = [r methodSignatureForSelector:s];
			invocation = [NSInvocation invocationWithMethodSignature:sig];
			[invocation setTarget:r];
			[invocation setSelector:s];
			[invocation retain];
			normalFrameName_ = [[NSString stringWithString:nF] retain];
			selectedFrameName_ = [[NSString stringWithString:sF] retain];
		}
		enabled_ = YES;
		selected_ = NO;
        touchPriority_ = 0;
	}
	return self;
}

-(id) init
{
	if (( self = [super init] )) {
		enabled_ = YES;
		selected_ = NO;
        touchPriority_ = 0;
	}
	return self;
}

-(void) dealloc
{
	[invocation release];
	[normalFrameName_ release];
	[selectedFrameName_ release];
	[super dealloc];
}

#pragma mark ConstructButton - enable & disable

-(void) enable
{
	if (!self.enabled) {
		self.enabled = YES;
		self.visible = YES;
	}
	return;
}

-(void) disable
{
	if (self.enabled) {
		self.enabled = NO;
		self.visible = NO;
	}
	return;
}

#pragma mark ConstructButton - onExit & onEnter

-(void) onEnter
{
	[super onEnter];
	[[CCDirector sharedDirector].touchDispatcher addTargetedDelegate:self priority:touchPriority_ swallowsTouches:YES];
}

-(void) onExit
{
	[[CCDirector sharedDirector].touchDispatcher removeDelegate:self];
	[super onExit];
}

#pragma mark ConstructButton - touch event handling

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint location = [touch locationInView:[touch view]];
	location = [[CCDirector sharedDirector] convertToGL:location];
	if (self.enabled && [self containPoint:location]) {
        self.position = ccpAdd(self.position,ccp(JSBUTTON_MOVE_X, JSBUTTON_MOVE_Y));
		[self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:selectedFrameName_]];
		selected_ = YES;
		return YES;
	}
	return NO;
}

-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint location = [touch locationInView:[touch view]];
	location = [[CCDirector sharedDirector] convertToGL:location];
	if (![self containPoint:location]) {
		if (selected_) {
			selected_ = NO;
            self.position = ccpAdd(self.position,ccp(-JSBUTTON_MOVE_X, -JSBUTTON_MOVE_Y));
			[self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:normalFrameName_]];
		}
	}
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint location = [touch locationInView:[touch view]];
	location = [[CCDirector sharedDirector] convertToGL:location];
	if (enabled_ && selected_ && [self containPoint:location]) {
		[[SimpleAudioEngine sharedEngine] playEffect:@"buttonclick.mp3"];
        selected_ = NO;
		[self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:normalFrameName_]];
        self.position = ccpAdd(self.position,ccp(-JSBUTTON_MOVE_X, -JSBUTTON_MOVE_Y));
		[invocation invoke];
	}
}

-(BOOL) containPoint:(CGPoint)p
{
	CGPoint location = [self convertToNodeSpace:p];
	return [self containNodePoint:location];
}

-(BOOL) containNodePoint:(CGPoint)p
{
	CGRect rect = CGRectMake(0,0,_contentSize.width,_contentSize.height);
	if (CGRectContainsPoint(rect,p)) {
		return YES;
	}
	else {
		return NO;
	}
}
@end

