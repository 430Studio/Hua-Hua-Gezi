

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "CCButton.h"
#define Original_Height 768
#define Original_Width 1024

@interface SquareMenuLayer : CCLayer<UITextFieldDelegate> {
	
	UITextField * textField_;
    
} 

+(id) scene;

-(id) init;

-(void) dealloc;



-(void) textFieldDidBeginEditing:(UITextField *)textField;

-(BOOL) textFieldShouldReturn:(UITextField*)textField;

-(void) textFieldDidEndEditing:(UITextField*)textField;

-(void) startCrossclear;

-(void) startFlood;

-(void) startLink;

-(void) startFive;

-(void) startJewelery;

-(void) startStar;

@end
