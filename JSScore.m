//
//  Score.m
//  YShot
//
//  Created by LIN BOYU on 4/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "JSScore.h"

@implementation JSScore

@synthesize category = category_;

@synthesize name = name_;

@synthesize value = value_;

@synthesize date = date_;

+(id) scoreWithCategory:(NSString *)c name:(NSString *)n value:(NSInteger)v
{
	return [[[self alloc] initWithCategory:c name:n value:v] autorelease];
}

-(id) initWithCategory:(NSString *)c name:(NSString *)n value:(NSInteger)v
{
	if((self = [super init])){
		self.category = c;
		self.name = n;
		self.value = v;
		self.date = [NSDate date];
	}
	return self;
}

-(id) initWithCoder:(NSCoder *)decoder {
	if((self = [super init])){
		self.category = [decoder decodeObjectForKey:@"category"];
		self.name = [decoder decodeObjectForKey:@"name"];
		self.value = [decoder decodeIntForKey:@"value"];
		self.date = [decoder decodeObjectForKey:@"date"];
	}
	return self;
}

- (void) encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:self.category forKey:@"category"];
	[encoder encodeObject:self.name forKey:@"name"];
	[encoder encodeInt:self.value forKey:@"value"];
	[encoder encodeObject:self.date forKey:@"date"];
}

- (void)dealloc {
	[category_ release];
	[date_ release];
	[name_ release];
	[super dealloc];
}

@end
