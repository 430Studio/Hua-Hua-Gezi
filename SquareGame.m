//
//  SquareGame.m
//  Square
//
//  Created by LIN BOYU on 1/1/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SquareGame.h"

@implementation SquareGame

#pragma mark SquareGame - init & dealloc



-(id) init
{
    if ((self = [super init])) {
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
        gameState_ = gameStateWaiting;
        
        score_ = 0;
        
        viewContent_ = viewContentHelp;

		
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"menures.plist"];
        
		      
		gameLayer_ = [[SquareGameLayer layerWithGame:self] retain];
        
		topbg_ = [CCSprite spriteWithFile:@"topbottom.png"];
		topbg_.position = ccpMult(ccp(screenSize.width,screenSize.height), 0.5);
		[gameLayer_ addChild:topbg_ z:0];
        
        gamebg_ = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%@bottom.png",gameName_]];
        gamebg_.position = ccpMult(ccp(screenSize.width,screenSize.height), 0.5);
		[gameLayer_ addChild:gamebg_ z:-1];
        
        endGameMask_ = [CCSprite spriteWithFile:@"endgamemask.png"];
        endGameMask_.position = ccpMult(ccp(screenSize.width,screenSize.height), 0.5);
        endGameMask_.visible = NO;
        [gameLayer_ addChild:endGameMask_ z:6];
           
		tableBanner_ = [[CCSprite spriteWithFile:@"tablebanner.png"] retain];
		tableBanner_.position = TABLEBANNER_POSITION;
		[gameLayer_ addChild:tableBanner_ z:1];
        
        NSString * languageCode = [[SquareDirector sharedDirector] getLanguageCode];
        bannerHeader_ = [[CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"helpbanner_%@.png",languageCode]] retain];
        bannerHeader_.position = ccp(385, 440);
        [tableBanner_ addChild:bannerHeader_];
        
        scoreBanner_ = nil;
		
        menuButton_ = [[CCButton buttonWithTarget:self
										 selector:@selector(menuButtonClicked)
									  normalFrame:[NSString stringWithFormat:@"backbutton_%@.png",languageCode]
									selectedFrame:[NSString stringWithFormat:@"backbutton_%@.png",languageCode]] retain];
		menuButton_.position = MENUBUTTON_POSITION;
		[gameLayer_ addChild:menuButton_ z:1];

        scoreButton_ = [[CCButton buttonWithTarget:self
                                          selector:@selector(scoreButtonClicked)
                                       normalFrame:@"leaderboardbutton.png"
                                     selectedFrame:@"leaderboardbutton.png"] retain];
        scoreButton_.position = SCOREBUTTON_POSITION;
		[gameLayer_ addChild:scoreButton_ z:1];
        
        helpButton_ = [[CCButton buttonWithTarget:self
                                         selector:@selector(helpButtonClicked)
                                      normalFrame:@"helpbutton.png"
                                    selectedFrame:@"helpbutton.png"] retain];
        helpButton_.position = HELPBUTTON_POSITION;
        [gameLayer_ addChild:helpButton_ z:1];
		
        musicButton_ = [[CCButton buttonWithTarget:self
                                          selector:@selector(musicButtonClicked) 
                                       normalFrame:@"musicbutton.png"
                                     selectedFrame:@"musicbutton.png"] retain];
        musicButton_.position = MUSICBUTTON_POSITION;
        if ([[SimpleAudioEngine sharedEngine] mute]) {
			[musicButton_ setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"mutebutton.png"]];
		}
		else {
			[musicButton_ setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"musicbutton.png"]];
		}
        [gameLayer_ addChild:musicButton_ z:1];
          
		cordButton_ = [[CCCordButton buttonWithTarget:self selector:@selector(cordButtonClicked) frameName:@"cordbutton.png"] retain];
		cordButton_.position = ccp(screenSize.width-50,screenSize.height+100);
        cordButton_.scale = 0.8;
		[gameLayer_ addChild:cordButton_ z:1];
        
        CCAnimation * animation = [CCAnimation animation];
        for (int i=0; i<2; i++) {
            NSString * frameName = [NSString stringWithFormat:@"bird%d.png",i];
            CCSpriteFrame * frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
            [animation addSpriteFrame:frame];
        }
        animation.delayPerUnit = 0.2f;
        id aniAction = [CCAnimate actionWithAnimation:animation];
        id repeatAction = [CCRepeatForever actionWithAction:aniAction];
        animationSprite_ = [CCSprite spriteWithSpriteFrameName:@"bird0.png"];
        animationSprite_.position = ccp(54, 43);
        [cordButton_ addChild:animationSprite_];
        [animationSprite_ runAction:repeatAction];
        
        tableView_ = nil;
        
        if ([[SimpleAudioEngine sharedEngine] isBackgroundMusicPlaying]) {
			[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
		}
        
        //data
        localScoreArray_ = [[[JSLocalScoreManager sharedLocalScoreManager] getLocalHighScore:gameName_] retain];

//        [[SquareDirector sharedDirector] loadiAd];
	}
    return self;
}

-(void) dealloc
{
	[gameLayer_ release];
    [tableBanner_ release];
	[menuButton_ release];
	[scoreButton_ release];
	[helpButton_ release];
    [musicButton_ release];
	[cordButton_ release];
    [tableView_ release];
	[super dealloc];
}

#pragma mark SquareGame - table

-(void) addTableView
{
    if (tableView_ == nil) {
        tableView_ = [[[UITableView alloc] initWithFrame:CGRectMake(TABLE_X,TABLE_Y,TABLE_WIDTH,TABLE_HEIGHT)] retain];
        [tableView_ setBackgroundColor:[UIColor clearColor]];
        [tableView_ setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        tableView_.dataSource = self;
        tableView_.delegate = self;
        [[CCDirector sharedDirector].view addSubview:tableView_];
    }
}

-(void) removeTableView
{
    if (tableView_) {
        [tableView_ removeFromSuperview];
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    if (viewContent_ == viewContentScore) {
        return localScoreArray_.count;
    }
	else if(viewContent_ == viewContentHelp) {
        return 3;
    }
	return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (viewContent_ == viewContentScore) {
        return TABLE_CELL_HEIGHT_SCORE;
    }
	else if(viewContent_ == viewContentHelp) {
        return TABLE_CELL_HEIGHT_HELP;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger row = indexPath.row;
	static NSString *localScoreCell = @"leaderboardCell";
    static NSString *helpCell = @"helpCell";
	UILabel *rankLabel, *nameLabel, *scoreLabel, *timeLabel ,*helpInfoLabel;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
    NSString *currentLanguage = [languages objectAtIndex:0];
    NSString * FontName = FONT_NAME_FT;
    if ([currentLanguage isEqualToString:@"zh-Hans"]) {
        FontName = FONT_NAME;
    }
    
	UITableViewCell *cell;
    if (viewContent_ == viewContentScore) {
        cell = [tableView dequeueReusableCellWithIdentifier:localScoreCell];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:localScoreCell] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            
            rankLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, TABLE_CELL_HEIGHT_SCORE-5)] autorelease];
            rankLabel.tag = labelTagRank;
            rankLabel.contentMode = UIViewContentModeCenter;
            rankLabel.font = [UIFont fontWithName:FontName size:25];
            rankLabel.textAlignment = UITextAlignmentCenter;
            rankLabel.textColor = [UIColor colorWithRed:0.24 green:0.24 blue:0.24 alpha:1.0];
            rankLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
            [cell.contentView addSubview:rankLabel];
            
            nameLabel = [[[UILabel alloc] initWithFrame:CGRectMake(60, 0, 120, TABLE_CELL_HEIGHT_SCORE-5)] autorelease];
            nameLabel.tag = labelTagName;
            nameLabel.contentMode = UIViewContentModeCenter;
            nameLabel.font = [UIFont fontWithName:FontName size:25];
            nameLabel.textAlignment = UITextAlignmentLeft;
            nameLabel.textColor = [UIColor colorWithRed:0.24 green:0.24 blue:0.24 alpha:1.0];
            nameLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
            [cell.contentView addSubview:nameLabel];
            
            scoreLabel = [[[UILabel alloc] initWithFrame:CGRectMake(200, 0, 120, TABLE_CELL_HEIGHT_SCORE-5)] autorelease];
            scoreLabel.tag = labelTagScore;
            scoreLabel.contentMode = UIViewContentModeCenter;
            scoreLabel.font = [UIFont fontWithName:FontName size:25];
            scoreLabel.textAlignment = UITextAlignmentCenter;
            scoreLabel.textColor = [UIColor colorWithRed:0.24 green:0.24 blue:0.24 alpha:1.0];
            scoreLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
            [cell.contentView addSubview:scoreLabel];
            
            timeLabel = [[[UILabel alloc] initWithFrame:CGRectMake(350, 0, TABLE_WIDTH-350, TABLE_CELL_HEIGHT_SCORE-5)] autorelease];
            timeLabel.tag = labelTagTime;
            timeLabel.contentMode = UIViewContentModeCenter;
            timeLabel.font = [UIFont fontWithName:FontName size:25];
            timeLabel.textAlignment = UITextAlignmentCenter;
            timeLabel.textColor = [UIColor colorWithRed:0.24 green:0.24 blue:0.24 alpha:1.0];
            timeLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
            [cell.contentView addSubview:timeLabel];
            
            UIImageView * seperatorImage = [[[UIImageView alloc] initWithFrame:CGRectMake(0,TABLE_CELL_HEIGHT_SCORE-5,TABLE_WIDTH,5)] autorelease];
            seperatorImage.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
            seperatorImage.image = [UIImage imageNamed:@"scorelayerseperator.png"];
            [cell.contentView addSubview:seperatorImage];
        }
        else{
            rankLabel = (UILabel *)[cell.contentView viewWithTag:labelTagRank];
            nameLabel = (UILabel *)[cell.contentView viewWithTag:labelTagName];
            scoreLabel = (UILabel *)[cell.contentView viewWithTag:labelTagScore];
            timeLabel = (UILabel *)[cell.contentView viewWithTag:labelTagTime];
        }
        rankLabel.text = [NSString stringWithFormat:@"%d",row+1];
        JSScore * s = (JSScore *)[localScoreArray_ objectAtIndex:row];
        nameLabel.text = [s.name isEqualToString:@""]?NSLocalizedString(@"hermit", nil):s.name;
        scoreLabel.text = [NSString stringWithFormat:@"%d",s.value];
        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];	
        timeLabel.text = [dateFormatter stringFromDate:s.date];
    }
    else if(viewContent_ == viewContentHelp) {
        cell = [tableView dequeueReusableCellWithIdentifier:helpCell];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:helpCell] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            
            helpInfoLabel = [[[UILabel alloc] initWithFrame:CGRectMake(30, 6, TABLE_WIDTH-60, TABLE_CELL_HEIGHT_HELP-16)] autorelease];
            helpInfoLabel.tag = labelTagHelpInfo;
            helpInfoLabel.numberOfLines = 0;
            helpInfoLabel.contentMode = UIViewContentModeCenter;
            helpInfoLabel.font = [UIFont fontWithName:FontName size:24];
            helpInfoLabel.textColor = [UIColor colorWithRed:0.24 green:0.24 blue:0.24 alpha:1.0];
            helpInfoLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
            [cell.contentView addSubview:helpInfoLabel];
            
            UIImageView * seperatorImage = [[[UIImageView alloc] initWithFrame:CGRectMake(0,TABLE_CELL_HEIGHT_HELP-5,TABLE_WIDTH,5)] autorelease];
            seperatorImage.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
            seperatorImage.image = [UIImage imageNamed:@"scorelayerseperator.png"];
            [cell.contentView addSubview:seperatorImage];
        }
        else{
            helpInfoLabel = (UILabel *)[cell.contentView viewWithTag:labelTagHelpInfo];
        }
        NSString * key = [NSString stringWithFormat:@"%@_help_%i",gameName_,row];
        helpInfoLabel.text = NSLocalizedString(key, nil);
    }
	return cell;
}


#pragma mark SquareGame - game logic

-(void) startGame
{
	CCScene * scene = [CCScene node];
    
    
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    CGSize winSize = [[CCDirector sharedDirector] winSizeInPixels];
    NSLog(@"%@", [NSString stringWithFormat:@"winsize %f, %f", winSize.width, winSize.height]);
    float height =screenSize.height/Original_Height;
    [scene setScale:height];
    //SquareGameLayer * gameLayer_ = [SquareGameLayer node];
    
    
	[scene addChild:gameLayer_];
	[[CCDirector sharedDirector] replaceScene:scene];
}

-(void) startRound 
{
//    [[SquareDirector sharedDirector] hideiAd];
	gameState_ = gameStateRunning;
    endGameMask_.visible = NO;
}

-(void) endRound
{
	gameState_ = gameStateWaiting;
    endGameMask_.visible = NO;
}

-(void) overRound
{
    gameState_ = gameStateOver;
    endGameMask_.visible = YES;
    /*
    JSUserDefault * user = [JSUserDefault sharedUserDefault];
    NSNumber * number = (NSNumber *)[user.dictionary objectForKey:@"adfree"];
    CGSize screenSize = [[CCDirector sharedDirector] winSize];

    if ([number intValue] != ADFREE) {
        [[SquareDirector sharedDirector] showiAd];
        
        AdBanner * adBanner = [AdBanner bannerWithGame:self];
        adBanner.position = ccp(0.5*screenSize.width,-0.5*adBanner.contentSize.height);
        [gameLayer_ addChild:adBanner z:NSIntegerMax tag:ADBANNER_TAG];
        [adBanner runAction:
         [CCSequence actionOne:[CCDelayTime actionWithDuration:1]
                           two:[CCEaseBackOut actionWithAction:[CCMoveTo actionWithDuration:0.5 position:ccp(0.5*screenSize.width,400)]]]];
    }else{
        [self showScoreBanner];
    }*/
    [self showScoreBanner];
}

#pragma mark SqureCrossclear - save score

-(void) saveScore:(int)scoreValue local:(NSString *)localCategory gameCenter:(NSString *)gcCategory
{
	JSUserDefault * userDefault = [JSUserDefault sharedUserDefault];
	NSString * userName = [userDefault.dictionary objectForKey:@"username"];
    JSScore * score = [JSScore scoreWithCategory:localCategory name:userName value:scoreValue];
    [[JSLocalScoreManager sharedLocalScoreManager] reportScore:score];
//    if(NSClassFromString(@"GKLocalPlayer") != nil &&
//       [[[UIDevice currentDevice] systemVersion] compare:@"4.1" options:NSNumericSearch] != NSOrderedAscending &&
//       [GKLocalPlayer localPlayer].authenticated) {
//        GKScore *scoreReporter = [[[GKScore alloc] initWithCategory:gcCategory] autorelease];
//        scoreReporter.value = scoreValue;
//        [scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {
//            if (error != nil){
//            }
//        }];
//    }
    if(localScoreArray_ != nil){
        [localScoreArray_ release];
        localScoreArray_ = [[[JSLocalScoreManager sharedLocalScoreManager] getLocalHighScore:gameName_] retain];
    }
}

#pragma mark SquareGame - control node
 
-(void) moveMenuOut
{
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    [self hideTableView];
    [tableBanner_ runAction:[CCMoveTo actionWithDuration:0.2 position:ccpAdd(TABLEBANNER_POSITION,ccp(0,screenSize.height))]];
    [menuButton_ runAction:[CCMoveTo actionWithDuration:0.2 position:ccpAdd(MENUBUTTON_POSITION,ccp(0,screenSize.height))]];
    [helpButton_ runAction:[CCMoveTo actionWithDuration:0.2 position:ccpAdd(HELPBUTTON_POSITION,ccp(0,screenSize.height))]];
    [scoreButton_ runAction:[CCMoveTo actionWithDuration:0.2 position:ccpAdd(SCOREBUTTON_POSITION,ccp(0,screenSize.height))]];
    [musicButton_ runAction:[CCMoveTo actionWithDuration:0.2 position:ccpAdd(MUSICBUTTON_POSITION,ccp(0,screenSize.height))]];
}

-(void) moveMenuIn
{
    [tableBanner_ runAction:[CCSequence actions:
                             [CCMoveTo actionWithDuration:0.2 position:TABLEBANNER_POSITION],
                             [CCCallFunc actionWithTarget:self selector:@selector(showTableView)],nil]];
    [menuButton_ runAction:[CCMoveTo actionWithDuration:0.2 position:MENUBUTTON_POSITION]];
    [helpButton_ runAction:[CCMoveTo actionWithDuration:0.2 position:HELPBUTTON_POSITION]];
    [scoreButton_ runAction:[CCMoveTo actionWithDuration:0.2 position:SCOREBUTTON_POSITION]];
    [musicButton_ runAction:[CCMoveTo actionWithDuration:0.2 position:MUSICBUTTON_POSITION]];
}

-(void) moveGameIn
{
    
}

-(void) moveGameOut
{
    
}

-(void) showTableView
{
    if(tableView_.hidden){
        tableView_.hidden = NO;
    }
    [tableView_ reloadData];
}

-(void) hideTableView
{
    if(!tableView_.hidden){
        tableView_.hidden = YES;
    }
}

//-(void) removeAdBanner
//{
//    if ([self getAdBanner]!=nil) {
//        [gameLayer_ removeChildByTag:ADBANNER_TAG cleanup:YES];
//        [self showScoreBanner];
//    }
//}
//
//-(AdBanner *) getAdBanner
//{
//    return (AdBanner *)[gameLayer_ getChildByTag:ADBANNER_TAG];
//}

-(void) showScoreBanner
{
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    scoreBanner_ = [SquareScoreBanner bannerWithGame:self score:score_];
    scoreBanner_.position = ccp(0.5*screenSize.width,screenSize.height+0.5*scoreBanner_.contentSize.height);
	[gameLayer_ addChild:scoreBanner_ z:NSIntegerMax-1];
    [scoreBanner_ runAction:
     [CCSequence actionOne:[CCDelayTime actionWithDuration:0.3]
                       two:[CCEaseBackOut actionWithAction:[CCMoveTo actionWithDuration:0.5 position:ccp(0.5*screenSize.width,0.5*screenSize.height)]]]];
    
}

#pragma mark SquareGame - hanlde button event

-(void) restartButtonClicked
{
    if(scoreBanner_ != nil){
        [scoreBanner_ removeFromParentAndCleanup:YES];
    }
    [self startRound];
}

-(void) leadboardButtonClicked
{
    viewContent_ = viewContentScore;
    NSString * languageCode = [[SquareDirector sharedDirector] getLanguageCode];
    [bannerHeader_ setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"topbanner_%@.png",languageCode]]];
    gameState_ = gameStateWaiting;
    [topbg_ runAction:[CCFadeIn actionWithDuration:0.5]];
    [cordButton_ setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@cordbutton.png",gameName_]]];
    animationSprite_.visible = NO;
    endGameMask_.visible = NO;
    [self moveMenuIn];
    [self moveGameOut];
    if(scoreBanner_ != nil){
        [scoreBanner_ removeFromParentAndCleanup:YES];
    }
}

-(void) cordButtonClicked
{
    if(gameState_ == gameStateWaiting){
        [topbg_ runAction:[CCFadeOut actionWithDuration:0.5]];
        [cordButton_ setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@cordbutton.png",gameName_]]];
        animationSprite_.visible = NO;
        
        [self moveMenuOut];
        [self moveGameIn];
        [self startRound];
    }
    else if(gameState_ == gameStateRunning){
        [topbg_ runAction:[CCFadeIn actionWithDuration:0.5]];
        [cordButton_ setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"cordbutton.png"]];
        animationSprite_.visible = YES;
        [self endRound];
        [self moveMenuIn];
        [self moveGameOut];
    }
    else if(gameState_ == gameStateOver){
    }
}

-(void) menuButtonClicked
{
//    [[SquareDirector sharedDirector] hideiAd];
    [self removeTableView];
	[[SquareDirector sharedDirector] startHome];
}

-(void) scoreButtonClicked
{
    viewContent_ = viewContentScore;
    NSString * languageCode = [[SquareDirector sharedDirector] getLanguageCode];
    [bannerHeader_ setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"topbanner_%@.png",languageCode]]];
    [tableView_ reloadData];
}

-(void) helpButtonClicked
{
    viewContent_ = viewContentHelp;
    NSString * languageCode = [[SquareDirector sharedDirector] getLanguageCode];
    [bannerHeader_ setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"helpbanner_%@.png",languageCode]]];
    [tableView_ reloadData];
}

-(void) musicButtonClicked
{
    SimpleAudioEngine * audioEngine = [SimpleAudioEngine sharedEngine];
	if ([audioEngine mute]) {
		[audioEngine setMute:NO];
		[musicButton_ setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"musicbutton.png"]];
	}
	else {
		[audioEngine setMute:YES];
		[musicButton_ setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"mutebutton.png"]];
	}
}

#pragma mark SquareGame - handle touch event

-(void) touchBeganAt:(CGPoint)location
{
	return;
}

-(void) touchMovedAt:(CGPoint)location
{
	return;
}

-(void) touchEndedAt:(CGPoint)location
{
	return;
}

@end
