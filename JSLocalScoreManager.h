//  LocalDataManager.h
//  YShot
//  Created by LIN BOYU on 4/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.

#import <Foundation/Foundation.h>
#import "JSScore.h"

#define HIGH_SCORE_NUM 10

@interface JSLocalScoreManager : NSObject {

}
+(JSLocalScoreManager *) sharedLocalScoreManager;

-(NSString *) getLocalHighScoreFilePath:(NSString *)category;

-(NSMutableArray *) getLocalHighScore:(NSString *)category;

-(void) saveLocalHighScore:(NSArray *)highScoreArray category:(NSString *)category;

-(void) reportScore:(JSScore *)score;

-(NSMutableArray *) sortHighScoreArray:(NSMutableArray *)highScores;

@end
