
#import "SquareMenuLayer.h"
#import "JSUserDefault.h"
#import "SimpleAudioEngine.h"
#import "SquareDirector.h"


@implementation SquareMenuLayer

#pragma mark SquareMenuLayer - scene

+(id) scene
{
	CCScene * scene = [CCScene node];
//    [scene setContentSize:CGSizeMake(1024, 768)];
//    CGSize screenSize = [[CCDirector sharedDirector] winSize];
//    float height = screenSize.height/Original_Height;
//    [scene setScale:1024.0/height];
	SquareMenuLayer * menuLayer = [SquareMenuLayer node];
	[scene addChild:menuLayer z:0];
	return scene;
}

#pragma mark SquareMenuLayer - init & dealloc

-(id) init
{
	if (( self = [super init] )) {
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
//        CGPoint pos = CGPointMake(-0.5*(Original_Width-screenSize.width), -0.5*(Original_Height-screenSize.height));
//        [self setPosition:pos];
//        [self setContentSize:CGSizeMake(1024, 768)];
		CCSprite * bgSprite = [CCSprite spriteWithFile:@"menubg.png"];
        bgSprite.position = ccp(0.5*Original_Width,0.5*Original_Height);
		[self addChild:bgSprite z:0];
		
        
        NSString * languageCode = [[SquareDirector sharedDirector] getLanguageCode];

        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"menubutton.plist"];
		CCButton * linkButton = [CCButton buttonWithTarget:self 
												  selector:@selector(startLink)
											   normalFrame:[NSString stringWithFormat:@"linkbutton_%@.png",languageCode] 
											 selectedFrame:[NSString stringWithFormat:@"linkbutton1_%@.png",languageCode]];
		linkButton.position = ccp(919,411);
		[self addChild:linkButton z:1];
        
        CCButton * fiveButton = [CCButton buttonWithTarget:self
                                                  selector:@selector(startFive)
                                               normalFrame:[NSString stringWithFormat:@"fivebutton_%@.png",languageCode]
                                             selectedFrame:[NSString stringWithFormat:@"fivebutton1_%@.png",languageCode]];
        fiveButton.position = ccp(798, 250);
        [self addChild:fiveButton z:1];
        
        CCButton * jeweleryButton = [CCButton buttonWithTarget:self
                                                      selector:@selector(startJewelery) 
                                                   normalFrame:[NSString stringWithFormat:@"jewelerybutton_%@.png",languageCode] 
                                                 selectedFrame:[NSString stringWithFormat:@"jewelerybutton1_%@.png",languageCode]];
		jeweleryButton.position = ccp(669,368);
		[self addChild:jeweleryButton z:1];
		
		CCButton * crossclearButton = [CCButton buttonWithTarget:self
														selector:@selector(startCrossclear)
													 normalFrame:[NSString stringWithFormat:@"crossclearbutton_%@.png",languageCode]
												   selectedFrame:[NSString stringWithFormat:@"crossclearbutton1_%@.png",languageCode]];
		crossclearButton.position = ccp(775,517);
		[self addChild:crossclearButton z:1];
		
		CCButton * floodButton = [CCButton buttonWithTarget:self
												   selector:@selector(startFlood) 
												normalFrame:[NSString stringWithFormat:@"floodbutton_%@.png",languageCode]
											  selectedFrame:[NSString stringWithFormat:@"floodbutton1_%@.png",languageCode]];
		floodButton.position = ccp(904,626);
		[self addChild:floodButton z:1];
        
        CCButton * starButton = [CCButton buttonWithTarget:self
												   selector:@selector(startStar)
												normalFrame:[NSString stringWithFormat:@"starbutton_%@.png",languageCode]
											  selectedFrame:[NSString stringWithFormat:@"starbutton1_%@.png",languageCode]];
		starButton.position = ccp(630,584);
		[self addChild:starButton z:1];
        
        
        CCSprite * nameSprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"name_%@.png",languageCode]];
        [nameSprite setPosition:ccp(123, 702)];
        [self addChild:nameSprite z:1];
        
		JSUserDefault * userDefault = [JSUserDefault sharedUserDefault];
		NSString * userName = [userDefault.dictionary objectForKey:@"username"];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
        NSString *currentLanguage = [languages objectAtIndex:0];
        NSString * FontName = FONT_NAME_FT;
        if ([currentLanguage isEqualToString:@"zh-Hans"]) {
            FontName = FONT_NAME;
        }
        
        textField_ = [[UITextField alloc] initWithFrame:CGRectMake(100, 50*(screenSize.height/Original_Height), 148*(screenSize.height/Original_Height), 30*(screenSize.height/Original_Height))];
		[textField_ setDelegate:self];
		[textField_ setTextAlignment:UITextAlignmentCenter];
        [textField_ setFont:[UIFont fontWithName:FontName size:24*(screenSize.height/Original_Height)]];
		[textField_ setTextColor:[UIColor blackColor]];
		if ([userName isEqualToString:@""]) {
            [textField_ setText:NSLocalizedString(@"hermit", nil)];
		}
		else {
			[textField_ setText:userName];
		}
		//[textField_ becomeFirstResponder];
		[[CCDirector sharedDirector].view addSubview:textField_];
        
        CCAdSprite * adSprite = [[SquareDirector sharedDirector] getAdSprite:0];
        adSprite.position = ccp(312,420);
        [self addChild:adSprite z:1];
        
        if (![[SimpleAudioEngine sharedEngine] isBackgroundMusicPlaying]) {
			[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"bgmusic1.mp3"];
		}
	}
    return self;
}

-(void) dealloc
{
	[textField_ release];
	[super dealloc];
}

-(void) onExit
{
    [textField_ removeFromSuperview];
    [super onExit];
}


#pragma mark SquareMenuLayer - control nickname input

-(void) textFieldDidBeginEditing:(UITextField *)textField
{
	[textField setText:@""];
}

-(BOOL) textFieldShouldReturn:(UITextField*)textField
{
	[textField_ resignFirstResponder];
	return YES;
}

-(void) textFieldDidEndEditing:(UITextField*)textField 
{
	if ([textField.text isEqualToString:@""]) {
		JSUserDefault * userDefault = [JSUserDefault sharedUserDefault];
		NSString * userName = [userDefault.dictionary objectForKey:@"username"];
		if ([userName isEqualToString:@""]) {
			[textField_ setText:NSLocalizedString(@"hermit", nil)];
		}
		else {
			[textField_ setText:userName];
		}
	}
	else {
		NSString * userName = textField.text;
		JSUserDefault * userDefault = [JSUserDefault sharedUserDefault];
		[userDefault.dictionary setObject:userName forKey:@"username"];
		[userDefault save];
	}
}

#pragma mark SquareMenuLayer - handle button event

-(void) startCrossclear
{
	[[SquareDirector sharedDirector] startCrossclear];
}

-(void) startFlood
{
	[[SquareDirector sharedDirector] startFlood];
}

-(void) startLink
{
	[[SquareDirector sharedDirector] startLink];
}

-(void) startFive
{
    [[SquareDirector sharedDirector] startFive];
}

-(void) startJewelery
{
    [[SquareDirector sharedDirector] startJewelery];
}

-(void) startStar
{
    [[SquareDirector sharedDirector] startStar];
}

@end