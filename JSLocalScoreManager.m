//
//  LocalDataManager.m
//  YShot
//
//  Created by LIN BOYU on 4/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "JSLocalScoreManager.h"
#import "SquareDirector.h"

static JSLocalScoreManager * _sharedLocalScoreManager = nil;

@implementation JSLocalScoreManager

+(JSLocalScoreManager *) sharedLocalScoreManager;
{
	if (!_sharedLocalScoreManager) {
		_sharedLocalScoreManager = [[JSLocalScoreManager alloc] init];
	}
	return _sharedLocalScoreManager;
}

-(NSString *) getLocalHighScoreFilePath:(NSString *)category 
{
	NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString * documentsDirectory = [paths objectAtIndex:0];
	return [[documentsDirectory stringByAppendingPathComponent:VERSION] stringByAppendingPathComponent:category];
}

-(NSMutableArray *) getLocalHighScore:(NSString *)category
{
	NSData * data = [[NSMutableData alloc] initWithContentsOfFile:[self getLocalHighScoreFilePath:category]];
	NSKeyedUnarchiver * unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
	NSArray * highScore = [unarchiver decodeObjectForKey:@"highScore"];
    [data release];
    [unarchiver release];
	return [[[NSMutableArray alloc] initWithArray:highScore copyItems:NO] autorelease];
}

-(void)saveLocalHighScore:(NSArray *)highScoreArray category:(NSString *)category{
	NSMutableData *data = [[NSMutableData alloc] init];
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	[archiver encodeObject:highScoreArray forKey:@"highScore"];
	[archiver finishEncoding];
	[data writeToFile:[self getLocalHighScoreFilePath:category] atomically:YES];
	[archiver release];
	[data release];
}

-(void)reportScore:(JSScore *)score
{
	NSMutableArray * highScore = [self getLocalHighScore:score.category];
	if (highScore.count < HIGH_SCORE_NUM){
		[highScore addObject:score];
		NSMutableArray * sortedHighScore = [[self sortHighScoreArray:highScore] retain];
		[self saveLocalHighScore:sortedHighScore category:score.category];
		[sortedHighScore release];
	}
	else{
		NSUInteger lastIdx = HIGH_SCORE_NUM-1;
		JSScore *lastScore = [highScore objectAtIndex:lastIdx];
		if (score.value > lastScore.value){
			[highScore addObject:score];
			NSMutableArray *sortedHighScore = [[self sortHighScoreArray:highScore] retain];
			[sortedHighScore removeLastObject];
			[self saveLocalHighScore:sortedHighScore category:score.category];
			[sortedHighScore release];
		}
	}
}

-(NSMutableArray *)sortHighScoreArray:(NSMutableArray *)highScore {
	NSString * SORT_KEY = @"value_";
	NSSortDescriptor * scoreDescriptor = [[[NSSortDescriptor alloc] initWithKey:SORT_KEY ascending:NO selector:@selector(compare:)] autorelease];
	NSArray *sortDescriptors = [NSArray arrayWithObjects:scoreDescriptor, nil];
	NSArray *sortedArray = [highScore sortedArrayUsingDescriptors:sortDescriptors];
	return [[[NSMutableArray alloc] initWithArray:sortedArray copyItems:NO] autorelease];
}

@end
