//
//  SquareParticle.m
//  Square
//
//  Created by LIN BOYU on 1/3/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SquareParticle.h"


@implementation SquareParticleTouch

-(id) init
{
	if (( self = [super initWithTotalParticles:20] )) {
		self.duration = 0.1;
		self.emissionRate = 200;
		self.life = 0.5;
		self.lifeVar = 0.3;
		self.emitterMode = kCCParticleModeGravity;
		self.gravity = ccp(0,0);
		self.posVar = ccp(0,0);
		self.speed = 100;
		self.speedVar = 0;
		self.angle = 0;
		self.angleVar = 360;
		self.radialAccel = -10;
		self.radialAccelVar = 3;
		self.tangentialAccel = 0;
		self.tangentialAccelVar = 0;
		self.startSpin = 0;
		self.endSpin = 360;
		self.startSize = 5.0f;
		self.startSizeVar = 0.0f;
		self.endSize = 8.0f;
		self.startColor = (ccColor4F){1.0f,1.0f,1.0f,1.0f};
		self.startColorVar = (ccColor4F){0.0f,0.0f,0.0f,0.0f};
		self.endColor = (ccColor4F){1.0f,1.0f,1.0f,0.0f};
		self.endColorVar =  (ccColor4F){0.0f,0.0f,0.0f,0.0f};
		self.texture = [[CCTextureCache sharedTextureCache] addImage: @"crosscleartimebarparticle.png"];
		self.blendAdditive = NO;
		self.autoRemoveOnFinish = YES;
	}
	return self;
}

@end



@implementation SquareJeweleryParticle

+(SquareJeweleryParticle *) particleWithKind:(int)kind rangeLevel:(int)level imgFile:(NSString *)imgf
{
    return [[[self alloc] initWithKind:kind rangeLevel:level imgFile:imgf] autorelease];
}

-(id) initWithKind:(int)kind rangeLevel:(int)level imgFile:(NSString *)imgf
{
    int totalparticles = 1;
    float size;
    switch (level) {
        case 0: { 
            totalparticles = 10;
            break;
        }
        case 1: {       
            totalparticles = 20;        
            break;
        }
        case 2: {   
            totalparticles = 30;           
            break;
        }
        case 3: { 
            totalparticles = 45;
            break;
        }
        default:
            break;
    }
    switch (kind) {
        case 1: {       
            size = 54;
            break;
        }
        case 2: {   
            size = 54;           
            break;
        }
        case 3: { 
            size = 5;
            totalparticles += 30;
            break;
        }
        default:
            break;
    }
    if (( self = [super initWithTotalParticles:totalparticles] )) {
		self.duration = 0.1;
		self.emissionRate = totalparticles/_life;
		self.emitterMode = kCCParticleModeGravity;
		self.gravity = ccp(0,0);
		self.posVar = ccp(0,0);
		self.angle = 0;
		self.angleVar = 360;
		self.radialAccel = 0;
		self.radialAccelVar = 3;
		self.tangentialAccel = 0;
		self.tangentialAccelVar = 0;
		self.startSpin = 0;
		self.endSpin = 360;
		self.startSize = size;
		self.startSizeVar = 10.0f;
		self.endSize = size;
        self.endSizeVar = 10.0f;
        switch (level) {
            case 0: {                
                self.life = 1.2;
                self.lifeVar = 0.3;
                self.speed = 30;
                self.speedVar = 0;
                break;
            }
            case 1: {                
                self.life = 1.0;
                self.lifeVar = 0.0;
                self.speed = 60;
                self.speedVar = 60;
                break;
            }
            case 2: {                
                self.life = 1.0;
                self.lifeVar = 0.5;
                self.speed = 80;
                self.speedVar = 80;
                break;
            }
            case 3: {                
                self.life = 1.2;
                self.lifeVar = 0.5;
                self.speed = 100;
                self.speedVar = 100;
                break;
            }
            default:
                break;
        }
		self.startColor = (ccColor4F){1.0f,1.0f,1.0f,1.0f};
		self.startColorVar = (ccColor4F){0.0f,0.0f,0.0f,0.0f};
		self.endColor = (ccColor4F){1.0f,1.0f,1.0f,0.0f};
		self.endColorVar =  (ccColor4F){0.0f,0.0f,0.0f,0.0f};
		self.texture = [[CCTextureCache sharedTextureCache] addImage:imgf];
		self.blendAdditive = NO;
		self.autoRemoveOnFinish = YES;
	}
	return self;
}



@end




@implementation JeweleryExplosion

+(JeweleryExplosion *) explosionWithRangeLevel:(int)level atPos:(CGPoint)p inLayer:(CCLayer *)layer
{
    return [[[self alloc] initWithRangeLevel:level atPos:p inLayer:layer] autorelease];
}

-(id) initWithRangeLevel:(int)level atPos:(CGPoint)p inLayer:(CCLayer *)layer
{
    if ( (self = [super init]) ) {
        SquareJeweleryParticle * particle1 = [SquareJeweleryParticle particleWithKind:1 rangeLevel:level imgFile:[NSString stringWithFormat:@"particle1%d.png",level]];
        particle1.position = p;
        [layer addChild:particle1 z:5];
        SquareJeweleryParticle * particle2 = [SquareJeweleryParticle particleWithKind:2 rangeLevel:level imgFile:[NSString stringWithFormat:@"particle2%d.png",level]];
        particle2.position = p;
        [layer addChild:particle2 z:5];
        SquareJeweleryParticle * particle3 = [SquareJeweleryParticle particleWithKind:3 rangeLevel:level imgFile:[NSString stringWithFormat:@"particle3%d.png",level]];
        particle3.position = p;
        [layer addChild:particle3 z:5];
    }
    return self;
}

@end



@implementation FlyBombParticle

-(id) init
{
	if (( self = [super initWithTotalParticles:75] )) {
		self.duration = 0.1;
		self.emissionRate = 200;
		self.life = 1.5;
		self.lifeVar = 0.3;
		self.emitterMode = kCCParticleModeGravity;
		self.gravity = ccp(0,0);
		self.posVar = ccp(0,0);
		self.speed = 60;
		self.speedVar = 20;
		self.angle = 0;
		self.angleVar = 360;
		self.radialAccel = -10;
		self.radialAccelVar = 3;
		self.tangentialAccel = 0;
		self.tangentialAccelVar = 0;
		self.startSpin = 0;
		self.endSpin = 360;
		self.startSize = 8.0f;
		self.startSizeVar = 5.0f;
		self.endSize = 5.0f;
		self.startColor = (ccColor4F){1.0f,1.0f,1.0f,1.0f};
		self.startColorVar = (ccColor4F){0.0f,0.0f,0.0f,0.0f};
		self.endColor = (ccColor4F){1.0f,1.0f,1.0f,0.0f};
		self.endColorVar =  (ccColor4F){0.0f,0.0f,0.0f,0.0f};
		self.texture = [[CCTextureCache sharedTextureCache] addImage: @"flybombparticle.png"];
		self.blendAdditive = NO;
		self.autoRemoveOnFinish = YES;
	}
	return self;
}

@end
