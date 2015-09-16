//
//  SquareGame.h
//  Square
//
//  Created by LIN BOYU on 1/1/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <GameKit/GameKit.h>
#import "SquareBoardSprite.h"
#import "SquareBanner.h"
#import "SimpleAudioEngine.h"
#import "CCButton.h"
#import "CCProgressBar.h"
#import "CCCordButton.h"
#import "JSUserDefault.h"
#import "JSLocalScoreManager.h"
#import "SquareMenuLayer.h"
#import "SquareDirector.h"
#import "SquareGameLayer.h"

#define ADBANNER_TAG 1002
#define Original_Height 768
#define Original_Width 1024

#define TABLE_X 210
#define TABLE_Y 300
#define TABLE_WIDTH 600
#define TABLE_HEIGHT 300
#define TABLE_CELL_HEIGHT_SCORE 60
#define TABLE_CELL_HEIGHT_HELP 100

#define MENUBUTTON_POSITION ccp(71,124)
#define TABLEBANNER_POSITION ccp(530,336)
#define SCOREBUTTON_POSITION ccp(823,667)
#define HELPBUTTON_POSITION ccp(698,656)
#define MUSICBUTTON_POSITION ccp(571,666)
#define CORDSIGN_POSITION ccp(760,590)

enum {
    viewContentScore = 0,
    viewContentHelp
};

enum {
	labelTagRank = 1,
	labelTagName,
	labelTagScore,
	labelTagTime,
    labelTagHelpInfo
};

enum {
    gameStateWaiting = 0,
    gameStateRunning,
    gameStateOver        
};

@interface SquareGame : NSObject <UITableViewDelegate,UITableViewDataSource> {
	
	NSString * gameName_;    
	
	int gameState_;
    
    int score_;
    
    int viewContent_;
        
    NSArray * localScoreArray_;
    
//node
    UITableView * tableView_;
	
	SquareGameLayer * gameLayer_;
    
    CCSprite * gamebg_;
    
    CCSprite * topbg_;
	
    CCButton * menuButton_;
        
    CCButton * scoreButton_;
    
    CCButton * helpButton_;
    
    CCButton * musicButton_;
            
	CCCordButton * cordButton_;
    
    CCSprite * tableBanner_;
    
    CCSprite * bannerHeader_;
    
    CCSprite * animationSprite_;
    
    CCSprite * endGameMask_;
    
    SquareScoreBanner * scoreBanner_;
}


#pragma mark SquareGame - init & dealloc

//+(id) scene;

-(id) init;

-(void) dealloc;

#pragma mark SquareGame - table

-(void) addTableView;

-(void) removeTableView;

#pragma mark SquareGame - game logic

-(void) startGame;

-(void) startRound;

-(void) endRound;

-(void) overRound;

#pragma mark SquareGame - save score

-(void) saveScore:(int)scoreValue local:(NSString *)localCategory gameCenter:(NSString *)gcCategory;

#pragma mark SquareGame -  control node

-(void) moveMenuIn;

-(void) moveMenuOut;

-(void) moveGameOut;

-(void) moveGameIn;

-(void) hideTableView;

-(void) showTableView;

//-(void) removeAdBanner;
//
//-(AdBanner *) getAdBanner;

-(void) showScoreBanner;

#pragma mark SquareGame - handle button event

-(void) menuButtonClicked;

-(void) scoreButtonClicked;

-(void) helpButtonClicked;

-(void) restartButtonClicked;

-(void) leadboardButtonClicked;

-(void) cordButtonClicked;

#pragma mark SquareGame - handle touch event

-(void) touchBeganAt:(CGPoint)location;

-(void) touchMovedAt:(CGPoint)location;

-(void) touchEndedAt:(CGPoint)location;

@end
