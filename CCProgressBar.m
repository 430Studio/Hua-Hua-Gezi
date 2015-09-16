//
//  CCProgressBar.m
//  Square
//
//  Created by LIN BOYU on 1/1/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CCProgressBar.h"


@implementation CCProgressBar

#pragma mark CCProgressBar - init

+(id) barWithBackFile:(NSString *)bF frontFile:(NSString *)fF particleFile:(NSString *)pF
{
	return [[[CCProgressBar alloc] initWithBackFile:bF frontFile:fF particleFile:pF] autorelease];
}

-(id) initWithBackFile:(NSString *)bF frontFile:(NSString *)fF particleFile:(NSString *)pF
{
	if (( self = [super init] )) {
		CCSprite * backSprite = [CCSprite spriteWithFile:bF];
		backSprite.anchorPoint = ccp(0,0.5);
		backSprite.position = ccp(0,0);
		[self addChild:backSprite z:0 tag:progressBarChildBack];
		
		CCSprite * frontSprite = [CCSprite spriteWithFile:fF];
		frontSprite.anchorPoint = ccp(0,0.5);
		frontSprite.position = ccp(0,0);
		[self addChild:frontSprite z:1 tag:progressBarChildFront];
		
		if (pF) {
            pF_ = [pF retain];
			[self initParticle];
		}
	}
	return self;
}

-(void) initParticle
{
    CCParticleSystemQuad * particle = [[[CCParticleSystemQuad alloc] initWithTotalParticles:20] autorelease];
    particle.duration = kCCParticleDurationInfinity;
    particle.emissionRate = 5;
    particle.life = 1;
    particle.lifeVar = 0.5;
    particle.emitterMode = kCCParticleModeGravity;
    particle.gravity = ccp(0,20);
    particle.position = ccp(0,0);
    particle.posVar = ccp(0,0.5*self.contentSize.height);
    particle.speed = 50;
    particle.speedVar = 10;
    particle.angle = 10;
    particle.angleVar = 45;
    particle.radialAccel = 10;
    particle.radialAccelVar = 10;
    particle.tangentialAccel = 0;
    particle.tangentialAccelVar = 0;
    particle.startSpin = 0;
    particle.endSpin = 360;
    particle.startSize = 5.0f;
    particle.startSizeVar = 2.0f;
    particle.endSize = 8.0f;
    particle.startColor = (ccColor4F){1.0f,1.0f,1.0f,1.0f};
    particle.startColorVar = (ccColor4F){0.0f,0.0f,0.0f,0.0f};
    particle.endColor = particle.startColor;
    particle.endColorVar = particle.startColorVar;
    particle.texture = [[CCTextureCache sharedTextureCache] addImage: pF_];
    particle.blendAdditive = NO;
    [self addChild:particle z:2 tag:progressBarChildParticle];
}

#pragma mark CCProgressBar - set progress

-(void) setProgress:(float)p
{
	CCSprite * frontSprite = (CCSprite *)[self getChildByTag:progressBarChildFront];
	CCSprite * backSprite = (CCSprite *)[self getChildByTag:progressBarChildBack];
	CCParticleSystemQuad * particle = (CCParticleSystemQuad *)[self getChildByTag:progressBarChildParticle];
	if (p<0) {
		p = 0;
	}
	else if(p>1){
		p = 1;
	}
	CGRect rect = CGRectMake(0, 0, p*frontSprite.contentSize.width, backSprite.contentSize.height);
	[backSprite setTextureRect:rect];
	if(particle){
		particle.position = ccp(rect.size.width,0);
		if (p==0) {
			[self removeChildByTag:progressBarChildParticle cleanup:YES];
		}
	}else {
        [self initParticle];
    }
}

@end
