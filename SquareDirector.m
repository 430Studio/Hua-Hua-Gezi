//
//  SquareDirector.m
//  Square
//
//  Created by LIN BOYU on 12/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SquareDirector.h"
#import "SquareMenuLayer.h"
#import "SquareCrossclear.h"
#import "SquareFlood.h"
#import "SquareLink.h"
#import "SquareFive.h"
#import "SquareJewelery.h"
#import "SquareStar.h"

@implementation SquareDirector

static SquareDirector * _sharedDirector = nil;

#pragma mark SquareDirector - share

+(SquareDirector *) sharedDirector
{
	if (!_sharedDirector) {
		_sharedDirector = [[SquareDirector alloc] init];
	}
	return _sharedDirector;
}

-(id) init
{
    if (( self = [super init] )) {
//        banner_ = nil;
//        iap_ = nil;
        currentGame_ = nil;
    }
    return self;
}

-(void) dealloc
{
//    if (banner_) {
//        [banner_ release];
//    }
//    if (iap_) {
//        [iap_ release];
//    }
    if (currentGame_) {
        [currentGame_ release];
    }
    [super dealloc];
}

#pragma mark SquareDirector - handle movie play

-(void) moviePlaybackFinished
{
	[self setRandomSeed];
    [self setLocalDirectory];
//    [self setGameCenter];
    [self startHome];
}

-(void) movieStartsPlaying
{
}

#pragma mark SquareDirector - game init

-(void) setRandomSeed
{
	srand(time(NULL));	
}

//-(void) setGameCenter
//{
//	if(NSClassFromString(@"GKLocalPlayer") != nil &&
//	   [[[UIDevice currentDevice] systemVersion] compare:@"4.1" options:NSNumericSearch] != NSOrderedAscending){
//		GKLocalPlayer * localPlayer = [GKLocalPlayer localPlayer];
//		[localPlayer authenticateWithCompletionHandler:^(NSError *error){}];
//	}
//}

-(void) setLocalDirectory
{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsDirectory = [paths objectAtIndex:0];
    NSString * path = [documentsDirectory stringByAppendingPathComponent:VERSION];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path]) {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

//-(void) setStore
//{
//    if (iap_ == nil) {
//        iap_ = [[[IAPHelper alloc] initWithProductIdentifiers:[NSSet setWithObjects:@"removeAdv", nil]] retain];
//    }
//    if (iap_.products == nil || iap_.products.count == 0) {
//        [iap_ requestProductsWithCompletion:nil];
//    }
//}

#pragma mark SquareDirector - localization

-(NSString *) getLanguageCode
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
    NSString *currentLanguage = [languages objectAtIndex:0];
    NSDictionary* temp = [NSLocale componentsFromLocaleIdentifier:currentLanguage];
    NSString * languageCode = [temp objectForKey:NSLocaleLanguageCode];
    if ([languageCode isEqualToString:@"zh"] || [languageCode isEqualToString:@"ja"]) {
        return @"zh";
    }
    return @"en";
}

#pragma mark SquareDirector - ad


-(CCAdSprite *) getAdSprite:(int)position
{
    return [[ServerPortAd sharedServerPort] getAdSprite:position];
}

//openURL
-(void) linkToAd:(int)position index:(int)index
{
    ServerPortAd * serverPort = [ServerPortAd sharedServerPort];
    UIApplication *app = [UIApplication sharedApplication];
    NSURL * URL = [serverPort getAdURL:position index:index];
    if ([app canOpenURL:URL])
    {
        NSString *pageLoc = [NSString stringWithContentsOfURL:URL encoding:NSUTF32StringEncoding error:nil];
        NSLog(@"%@",pageLoc);
        [app openURL:URL];
        return;
    }
}

//-(void) loadiAd
//{
//    if ([self isAdFree]) {
//        return;
//    }
//    if ([ADBannerView instancesRespondToSelector:@selector(initWithAdType:)]) {
//        banner_ = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
//    } else {
//        banner_ = [[ADBannerView alloc] init];
//    }
//    banner_.delegate = self;
//    banner_.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
//    [[CCDirector sharedDirector].view addSubview:banner_];
//    CGRect frame = banner_.frame;
//    frame.origin.y = [CCDirector sharedDirector].view.bounds.size.height;
//    banner_.frame = frame;
//}
//
//-(void) showiAd
//{
//    if (banner_ == nil) {
//        return;
//    }
//    CGRect frame = banner_.frame;
//    frame.origin.y = [CCDirector sharedDirector].view.bounds.size.height-frame.size.height;
//    [UIView animateWithDuration:0.25 animations:^{
//        banner_.frame = frame;
//    }];
//}
//
//-(void) hideiAd
//{
//    if (banner_ == nil) {
//        return;
//    }
//    CGRect frame = banner_.frame;
//    frame.origin.y = [CCDirector sharedDirector].view.bounds.size.height;
//    [UIView animateWithDuration:0.25 animations:^{
//        banner_.frame = frame;
//    }];
//}

//- (void)bannerViewDidLoadAd:(ADBannerView *)banner
//{
//    if (banner.hidden == YES) {
//        banner.hidden = NO;
//    }
//}
//
//- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
//{
//    if (banner.hidden == NO) {
//        banner_.hidden = YES;        
//    }
//}

#pragma mark SquareDirector - iap

//-(void) buyAdFree
//{
//    if (iap_.products == nil || iap_.products.count == 0) {
//        [iap_ requestProductsWithCompletion:^(SKProductsRequest *request, SKProductsResponse *response) {
//            [self buyAdFree];
//        }];
//        return;
//    }
//    [iap_ buyProduct:[iap_.products objectAtIndex:0] onCompletion:^(SKPaymentTransaction* transcation){
//        if (transcation.error) {
//            return;
//        }
//        AdBanner * banner = [currentGame_ getAdBanner];
//        if (banner) {
//            [banner setState:kAdBannerState_contacting game:currentGame_];
//        }        
//        NSNumber *type = [NSNumber numberWithInt:1000];
//        NSString *receipt = [[[NSString alloc] initWithData:transcation.transactionReceipt encoding:NSUTF8StringEncoding] autorelease];
//        NSString *product = transcation.payment.productIdentifier;
//        NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys:
//                                 product, @"product",
//                                 receipt, @"receipt",
//                                 nil];
//        
//        NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:
//                               type,@"type",
//                               dataDict,@"data",
//                               nil];
//        NSData * data = [NSJSONSerialization dataWithJSONObject:dict
//                                                        options:NSJSONWritingPrettyPrinted
//                                                          error:nil];
//        NSString * str = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
//        NSString * bodyStr = [@"data=" stringByAppendingString:str];
//        NSData * bodyData = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
//        NSURL * url = [NSURL URLWithString:IAP_VERIFY_URL];
//        NSMutableURLRequest * req = [NSMutableURLRequest requestWithURL:url];
//        [req setHTTPMethod:@"POST"];
//        [req setHTTPBody:bodyData];
//        [req setTimeoutInterval:60];
//        [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *res, NSData *data, NSError *err) {
//            if (err) {
//                AdBanner * banner = [currentGame_ getAdBanner];
//                if (banner) {
//                    [banner setState:kAdBannerState_showingErr game:currentGame_];
//                }
//                return;
//            }
//            NSDictionary * json = [NSJSONSerialization JSONObjectWithData:data options:nil error:nil];
//            NSNumber * type = [json objectForKey:@"type"];
//            NSNumber * error = [json objectForKey:@"err"];
//            if ([error intValue] != 0) {
//                AdBanner * banner = [currentGame_ getAdBanner];
//                if (banner) {
//                    [banner setState:kAdBannerState_showingErr game:currentGame_];
//                }
//                return;
//            }
//            if ([type intValue] == 1000) {
//                NSDictionary * dic = [json objectForKey:@"data"];
//                int status = [[dic objectForKey:@"status"] intValue];
//                if (status == 0) {
//                    [self setAdFree];
//                }else{
//                    AdBanner * banner = [currentGame_ getAdBanner];
//                    if (banner) {
//                        [banner setState:kAdBannerState_showingErr game:currentGame_];
//                    }
//                }
//            }
//        }];        
//    }];
//}

//-(void) restoreIAP
//{
//    if (iap_.products == nil || iap_.products.count == 0) {
//        [iap_ requestProductsWithCompletion:^(SKProductsRequest *request, SKProductsResponse *response) {
//            [self restoreIAP];
//        }];
//        return;
//    }
//    [iap_ restoreProductsWithCompletion:^(SKPaymentQueue *payment, NSError *error) {
//        if (error) {
//            return;
//        }
//        if (!payment.transactions || payment.transactions.count==0) {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"no_restore_title", nil)
//                                                            message:nil
//                                                           delegate:nil
//                                                  cancelButtonTitle:@"OK"
//                                                  otherButtonTitles:nil];
//            [alert show];
//            [alert release];
//            return;
//        }
//        [self setAdFree];
//    }];
//}

//-(void) setAdFree
//{
//    JSUserDefault * user = [JSUserDefault sharedUserDefault];
//    [user.dictionary setObject:[NSNumber numberWithInt:ADFREE] forKey:@"adfree"];
//    [user save];
//    
//    [self hideiAd];
//    if (currentGame_) {
//        [currentGame_ removeAdBanner];
//    }
//}

//-(BOOL) isAdFree
//{
//    JSUserDefault * user = [JSUserDefault sharedUserDefault];
//    return [(NSNumber *)[user.dictionary objectForKey:@"adfree"] intValue] == ADFREE;
//}

//-(NSString *) getAdFreePrice
//{
//    if (iap_.products != nil && iap_.products.count>0) {
//        SKProduct * product = (SKProduct *)[iap_.products objectAtIndex:0];
//        NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
//        [formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
//        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
//        [formatter setLocale:product.priceLocale];
//        NSString *localizedMoneyString = [formatter stringFromNumber:product.price];
//        return localizedMoneyString;
//    }
//    [iap_ requestProductsWithCompletion:nil];
//    return NULL;
//}


#pragma mark SquareDirector - game scene control

-(void) startHome
{
	if (currentGame_!=nil) {
		[currentGame_ release];
		currentGame_ = nil;
		[[CCDirector sharedDirector] replaceScene:[SquareMenuLayer scene]];
	}
	else {
		[[CCDirector sharedDirector] runWithScene:[SquareMenuLayer scene]];
	}
}

-(void) startCrossclear
{
	currentGame_ = [[SquareCrossclear alloc] init];
	[currentGame_ startGame];
}

-(void) startFlood
{
	currentGame_ = [[SquareFlood alloc] init];
	[currentGame_ startGame];
}

-(void) startLink
{
	currentGame_ = [[SquareLink alloc] init];
	[currentGame_ startGame];
}

-(void) startFive
{
	currentGame_ = [[SquareFive alloc] init];
	[currentGame_ startGame];
}

-(void) startJewelery
{
    currentGame_ = [[SquareJewelery alloc] init];
    [currentGame_ startGame];
}

-(void) startStar
{
    currentGame_ = [[SquareStar alloc] init];
    [currentGame_ startGame];
}
@end
