//
//  ServerPortAd.m
//  square
//
//  Created by LIN BOYU on 6/24/13.
//  Copyright (c) 2013 LIN BOYU. All rights reserved.
//

#import "ServerPortAd.h"
#import "OpenUDID.h"

@implementation ServerPortAd

static ServerPortAd * _sharedServerPort = nil;

#pragma mark ServerPortAd - alloc & init

+(ServerPortAd *) sharedServerPort
{
    if (!_sharedServerPort) {
		_sharedServerPort = [[ServerPortAd alloc] init];
	}
	return _sharedServerPort;
}

-(id) init
{
    if (( self = [super init] )) {
        ad_ = nil;
        adConfigStatus_ = kAdConfigStatusInvalid;
        queue_ = [[NSOperationQueue alloc] init];        
        NSString * userPath = [self getUserPath];
        NSFileManager * fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:userPath]) {
            user_ = [[NSMutableDictionary dictionaryWithContentsOfFile:[self getUserPath]] retain];
        }else{
            user_ = [[NSMutableDictionary dictionary] retain];
            [user_ setObject:[OpenUDID value] forKey:@"uuid"];
            [user_ writeToFile:userPath atomically:YES];
        }
    }
    return self;
}

-(void) dealloc
{
    if(ad_){
        [ad_ release];
    }
    if (queue_) {
        [queue_ release];        
    }
    if (user_) {
        [user_ release];
    }
    [super dealloc];
}


#pragma mark ServerPortAd - localization

-(NSString *) getLanguageCode
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
    NSString *currentLanguage = [languages objectAtIndex:0];
    NSDictionary* dict = [NSLocale componentsFromLocaleIdentifier:currentLanguage];
    return [dict objectForKey:NSLocaleLanguageCode];
}

#pragma mark ServerPortAd - local storage

-(NSString *)getUserPath
{
    return [[[self getAdPath] stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"user.plist"];
}

-(NSString *)getAdPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,  YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:@"ad/res"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:fullPath]) {
        [fileManager createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return fullPath;
}

#pragma mark ServerPortAd - get ad data

-(int) getConfigStatus
{
    return adConfigStatus_;
}

-(NSDictionary *)getAdObject:(int)position index:(int)index
{
    if (ad_) {
        return [[ad_ objectAtIndex:position] objectAtIndex:index];
    }
    return NULL;
}

-(int) getAdResourceStatus:(int)position index:(int)index
{
    NSDictionary * ad = [self getAdObject:position index:index];
    return [(NSNumber *)[ad objectForKey:@"status"] intValue];
}

-(NSURL *) getAdURL:(int)position index:(int)index
{
    NSDictionary * ad = [self getAdObject:position index:index];
    if(ad)
    {NSLog(@"%@",[ad objectForKey:@"link"]);}
    return [NSURL URLWithString:(NSString *)[ad objectForKey:@"link"]];
}

-(NSString *) getAdName:(int)position index:(int)index
{
    NSDictionary * ad = [self getAdObject:position index:index];
    return (NSString *)[ad objectForKey:@"name"];
}

-(CCAdSprite *) getAdSprite:(int)position
{
    if (adConfigStatus_ == kAdConfigStatusRejected) {
        [self loadConfig];
    }else if(adConfigStatus_ == kAdConfigStatusReady){
        int count = [[ad_ objectAtIndex:position] count];
        if (count>0) {
            int index = rand()%count;
            int status = [self getAdResourceStatus:position index:index];
            if(status == kAdResourceStatusReady){
                return [CCAdSprite spriteWithDir:[self getAdPath] location:position index:index];
            }else if(status == kAdResourceStatusRejected){
                [self loadAdResource:position index:index];
            }
        }
    }
    return [CCAdSprite spriteWithFile:[NSString stringWithFormat:@"ad_%i.png",position]];
}


#pragma mark ServerPortAd - load

-(void) loadConfig
{
    if (ad_) {
        [ad_ release];
        ad_ = nil;
    }
    NSURL * url = [NSURL URLWithString:[[[SERVER_URL stringByAppendingPathComponent:GAME_NAME] stringByAppendingPathComponent:[self getLanguageCode]] stringByAppendingPathComponent:@"config"]];
    NSMutableURLRequest * req = [NSMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:@"GET"];
    [NSURLConnection sendAsynchronousRequest:req queue:queue_ completionHandler:^(NSURLResponse *res, NSData *data, NSError *err) {
        if (!err) {
            NSPropertyListFormat format;
            ad_ = [[NSPropertyListSerialization propertyListWithData:data options:NSPropertyListMutableContainersAndLeaves format:&format error:nil] retain];
            adConfigStatus_ = kAdConfigStatusReady;
            [self loadAdResource];
        }else{
            adConfigStatus_ = kAdConfigStatusRejected;
        }
    }];
    adConfigStatus_ = kAdConfigStatusRequested;
}

-(void) loadAdResource
{
    if (ad_) {
        NSFileManager *fileManager = [NSFileManager defaultManager];        
        NSString * path = [self getAdPath];
        NSDirectoryEnumerator* enumerator = [fileManager enumeratorAtPath:path];
        NSString* file;
        while (file = [enumerator nextObject]) {
            [fileManager removeItemAtPath:[path stringByAppendingPathComponent:file] error:nil];
        }
        for (int p=0; p<ad_.count; p++) {
            NSArray * position = (NSArray *)[ad_ objectAtIndex:p];
            for (int i=0; i<position.count; i++) {
                NSMutableDictionary * item = (NSMutableDictionary *)[position objectAtIndex:i];
                [item setObject:[NSNumber numberWithInt:kAdResourceStatusRequested] forKey:@"status"];
                [self loadAdResource:p index:i];
            }
        }
    }
}

-(void) loadAdResource:(int)position index:(int)index
{
    NSString * res = [[[ad_ objectAtIndex:position] objectAtIndex:index] objectForKey:@"res"];    
    NSURL * url = [NSURL URLWithString:[[SERVER_URL stringByAppendingPathComponent:GAME_NAME] stringByAppendingPathComponent:res]];
    NSMutableURLRequest * req = [NSMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:@"GET"];
    [NSURLConnection sendAsynchronousRequest:req queue:queue_ completionHandler:^(NSURLResponse *res, NSData *data, NSError *err) {
        NSMutableDictionary * adItem = (NSMutableDictionary *)[[ad_ objectAtIndex:position] objectAtIndex:index];
        if (!err) {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSString * path = [[self getAdPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%i_%i",position,index]];
            [fileManager createFileAtPath:path contents:data attributes:nil];
            [adItem setObject:[NSNumber numberWithInt:kAdResourceStatusReady] forKey:@"status"];
        }else{
            [adItem setObject:[NSNumber numberWithInt:kAdResourceStatusRejected] forKey:@"status"];
        }
    }];
}

#pragma mark ServerPortAd - stats

-(void) post:(NSDictionary *)dict
{
    NSData * data = [NSJSONSerialization dataWithJSONObject:dict
                                                    options:NSJSONWritingPrettyPrinted
                                                      error:nil];
    NSString * str = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    NSString * bodyStr = [@"data=" stringByAppendingString:str];
    NSData * bodyData = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURL * url = [NSURL URLWithString:[SERVER_URL stringByAppendingPathComponent:@"stat"]];
    NSMutableURLRequest * req = [NSMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:bodyData];
    [NSURLConnection sendAsynchronousRequest:req queue:queue_ completionHandler:^(NSURLResponse *res, NSData *data, NSError *err) {
    }];
}

-(void) postActive
{
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    [dict setObject:@"active" forKey:@"type"];
    [dict setObject:GAME_NAME forKey:@"game_name"];
    [dict setObject:[user_ objectForKey:@"uuid"] forKey:@"uuid"];
    [dict setObject:[self getLanguageCode] forKey:@"location"];
    [self post:dict];
}

-(void) postShow:(int)position index:(int)index
{
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    [dict setObject:@"show" forKey:@"type"];
    [dict setObject:GAME_NAME forKey:@"game_name"];
    [dict setObject:[user_ objectForKey:@"uuid"] forKey:@"uuid"];
    [dict setObject:[self getLanguageCode] forKey:@"location"];
    [dict setObject:[[[ad_ objectAtIndex:position] objectAtIndex:index] objectForKey:@"name"] forKey:@"ad_name"];
    [self post:dict];
}


-(void) postClick:(int)position index:(int)index
{
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    [dict setObject:@"click" forKey:@"type"];
    [dict setObject:GAME_NAME forKey:@"game_name"];
    [dict setObject:[user_ objectForKey:@"uuid"] forKey:@"uuid"];
    [dict setObject:[self getLanguageCode] forKey:@"location"];
    [dict setObject:[[[ad_ objectAtIndex:position] objectAtIndex:index] objectForKey:@"name"] forKey:@"ad_name"];
    [self post:dict];
}

@end


















