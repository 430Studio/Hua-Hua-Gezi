//
//  JSUserDefault.m
//  Square
//
//  Created by LIN BOYU on 12/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "JSUserDefault.h"
#import "SquareDirector.h"

@implementation JSUserDefault

@synthesize dictionary = dictionary_;

static JSUserDefault * _sharedUserDefault = nil;

+(JSUserDefault *) sharedUserDefault
{
	if (!_sharedUserDefault) {
		_sharedUserDefault = [[JSUserDefault alloc] init];
	}
	return _sharedUserDefault;
}

-(id) init
{
	if (( self = [super init] )) {
		NSString * filePath = [self getUserDefaultPath];
        NSFileManager * fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:filePath]) {
            dictionary_ = [[NSMutableDictionary dictionaryWithContentsOfFile:filePath] retain];
        }else {
            dictionary_ = [[NSMutableDictionary dictionary] retain];
            [dictionary_ setObject:@"" forKey:@"username"];
            [dictionary_ setObject:[NSNumber numberWithInt:0] forKey:@"adfree"];
            [dictionary_ writeToFile:filePath atomically:YES];
        }
	}
	return self;
}

-(void) dealloc
{
	[dictionary_ release];
	[super dealloc];
}

-(NSString *) getUserDefaultPath
{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsDirectory = [paths objectAtIndex:0];
    return [[documentsDirectory stringByAppendingPathComponent:VERSION] stringByAppendingPathComponent:@"userdefault.plist"];
}

-(void) save
{
	NSString * filePath = [self getUserDefaultPath];
	[dictionary_ writeToFile:filePath atomically:YES];
}

@end
