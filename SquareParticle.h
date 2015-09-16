//
//  SquareParticle.h
//  Square
//
//  Created by LIN BOYU on 1/3/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface SquareParticleTouch : CCParticleSystemQuad {

}

@end


@interface SquareJeweleryParticle : CCParticleSystemQuad {

}

+(SquareJeweleryParticle *) particleWithKind:(int)kind rangeLevel:(int)level imgFile:(NSString *)imgf;

-(id) initWithKind:(int)kind rangeLevel:(int)level imgFile:(NSString *)imgf;

@end



@interface JeweleryExplosion : NSObject {
}

+(JeweleryExplosion *) explosionWithRangeLevel:(int)level atPos:(CGPoint)p inLayer:(CCLayer *)layer;

-(id) initWithRangeLevel:(int)level atPos:(CGPoint)p inLayer:(CCLayer *)layer;

@end

        

@interface FlyBombParticle : CCParticleSystemQuad {
    
}

@end