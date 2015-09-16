//
//  Score.h
//  YShot
//
//  Created by LIN BOYU on 4/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface JSScore : NSObject<NSCoding> {
	
	NSString * category_;
	
	NSString * name_;
	
	NSInteger value_;
	
	NSDate * date_;
}

@property(nonatomic,readwrite,retain) NSString * category;

@property(nonatomic,readwrite,retain) NSString * name;

@property(nonatomic,readwrite) NSInteger value;

@property(nonatomic,readwrite,retain) NSDate * date;

+(id) scoreWithCategory:(NSString *)c name:(NSString *)n value:(NSInteger)v;

-(id) initWithCategory:(NSString *)c name:(NSString *)n value:(NSInteger)v;

@end
