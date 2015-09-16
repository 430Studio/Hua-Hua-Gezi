//
//  JSUserDefault.h
//  Square
//
//  Created by LIN BOYU on 12/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSUserDefault : NSObject {
	
	NSMutableDictionary * dictionary_;
}

@property(nonatomic,readwrite,retain) NSMutableDictionary * dictionary;

+(id) sharedUserDefault;

-(id) init;

-(void) dealloc;

-(NSString *) getUserDefaultPath;

-(void) save;

@end
