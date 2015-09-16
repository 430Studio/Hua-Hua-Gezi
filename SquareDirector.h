//
//  SquareDirector.h
//  Square
//
//  Created by LIN BOYU on 12/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoPlayer.h"
//#import <GameKit/GameKit.h>
//#import <iAd/iAd.h>
//#import "IAPHelper.h"
#import "ServerPortAd.h"
#import "SquareBanner.h"
#import "CCAdSprite.h"


#define FONT_NAME @"FZY4JW--GB1-0"
#define FONT_NAME_FT @"FZHLFW--GB1-0"
//#define ADFREE 20110511
#define VERSION @"v1_0"
//#define IAP_VERIFY_URL @"http://4dian30.com:1600"
//#define IAP_VERIFY_URL @"http://192.168.1.103:1600"

@class SquareGame;

//@interface SquareDirector : NSObject<ADBannerViewDelegate,VideoPlayerDelegate> {
@interface SquareDirector : NSObject<VideoPlayerDelegate> {
	
	SquareGame * currentGame_;
	    
//    ADBannerView * banner_;
//    
//    IAPHelper * iap_;
    
}

#pragma mark SquareDirector - share

+(SquareDirector *) sharedDirector;

-(id) init;

-(void) dealloc;

#pragma mark SquareDirector - handle movie play

-(void) moviePlaybackFinished;

-(void) movieStartsPlaying;

#pragma mark SquareDirector - game init

-(void) setRandomSeed;

//-(void) setGameCenter;

//-(void) setStore;

-(void) setLocalDirectory;

#pragma mark SquareDirector - localization

-(NSString *) getLanguageCode;

#pragma mark SquareDirector - ad

-(CCAdSprite *) getAdSprite:(int)position;
-(void) linkToAd:(int)position index:(int)index;
//-(void) loadiAd;
//-(void) showiAd;
//-(void) hideiAd;

#pragma mark SquareDirector - iap
//-(void) buyAdFree;
//-(void) restoreIAP;
//-(void) setAdFree;
//-(BOOL) isAdFree;
//-(NSString *) getAdFreePrice;

#pragma mark SquareDirector - game scene control

-(void) startHome;

-(void) startCrossclear;

-(void) startFlood;

-(void) startLink;

-(void) startFive;

-(void) startJewelery;

-(void) startStar;

@end
