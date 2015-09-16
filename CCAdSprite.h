//
//  CCAdSprite.h
//  square
//
//  Created by LIN BOYU on 6/22/13.
//  Copyright (c) 2013 LIN BOYU. All rights reserved.
//

#import "cocos2d.h"

@interface CCAdSprite : CCSprite<CCTouchOneByOneDelegate>

{
    int location_;
    int index_;
    int touchPriority_;
    BOOL selected_;
}

@property(nonatomic,readwrite) int touchPriority;

+(id) spriteWithDir:(NSString *)dir location:(int)location index:(int)index;

-(id) initWithDir:(NSString *)dir location:(int)location index:(int)index;

-(BOOL) containTouch:(UITouch *)touch;


@end
