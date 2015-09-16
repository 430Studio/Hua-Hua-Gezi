//
//  ServerPortAd.h
//  square
//
//  Created by LIN BOYU on 6/24/13.
//  Copyright (c) 2013 LIN BOYU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCAdSprite.h"

#define SERVER_URL @"write your server URL here"

#define GAME_NAME @"square"


typedef enum{
    kAdResourceStatusRequested = 0
    ,kAdResourceStatusReady
    ,kAdResourceStatusRejected
}AdResourceStatus;

typedef enum{
    kAdConfigStatusRequested = 0
    ,kAdConfigStatusReady
    ,kAdConfigStatusRejected
    ,kAdConfigStatusInvalid
}AdConfigStatus;

@interface ServerPortAd : NSObject
{
    NSArray * ad_;
    int adConfigStatus_;
    NSOperationQueue * queue_;    
    NSMutableDictionary * user_;
}

#pragma mark ServerPortAd - alloc & init

+(id) sharedServerPort;

-(id) init;

-(void) dealloc;

#pragma mark ServerPortAd - localization

-(NSString *) getLanguageCode;

#pragma mark ServerPortAd - local storage

-(NSString *) getAdPath;

#pragma mark ServerPortAd - get ad data

-(int) getConfigStatus;

-(NSDictionary *) getAdObject:(int)position index:(int)index;

-(int) getAdResourceStatus:(int)position index:(int)index;

-(NSURL *) getAdURL:(int)position index:(int)index;

-(NSString *) getAdName:(int)position index:(int)index;

-(CCAdSprite *) getAdSprite:(int)position;

#pragma mark ServerPortAd - load

-(void) loadConfig;

-(void) loadAdResource;

-(void) loadAdResource:(int)position index:(int)index;

#pragma mark ServerPortAd - stats

-(void) post:(NSDictionary *)dict;

-(void) postActive;

-(void) postShow:(int)position index:(int)index;

-(void) postClick:(int)position index:(int)index;

@end