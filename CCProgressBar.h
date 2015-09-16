//
//  CCProgressBar.h
//  Square
//
//  Created by LIN BOYU on 1/1/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

enum {
	progressBarChildBack = 0,
	progressBarChildFront,
	progressBarChildParticle
};

@interface CCProgressBar : CCNode {
	NSString * pF_;
}

+(id) barWithBackFile:(NSString *)bF frontFile:(NSString *)fF particleFile:(NSString *)pF;

-(id) initWithBackFile:(NSString *)bF frontFile:(NSString *)fF particleFile:(NSString *)pF;

-(void) initParticle;

-(void) setProgress:(float)p;

@end
