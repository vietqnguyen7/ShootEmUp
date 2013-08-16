//
//  HighScore.m
//  ShootEmHup
//
//  Created by Viet Nguyen on 8/15/13.
//
//

#import "HighScore.h"
#import "MainMenu.h"

@implementation HighScore
{
    CCMenuItem *exitButton;
}

-(void) setMenu
{
    CCMenuItemImage *menuItem1 = [CCMenuItemImage itemWithNormalImage:@"menu-button.png"
                                                        selectedImage: @"menu-button.png"
                                                               target:self
                                                             selector:@selector(doSomethingOne:)];
    
    CCMenu * myMenu = [CCMenu menuWithItems:menuItem1, nil];
    [myMenu alignItemsVertically];
    
    // add the menu to your scene
    [self addChild:myMenu];
    
}

- (void) doSomethingOne: (CCMenuItem  *) menuItem
{
    [[CCDirector sharedDirector] replaceScene: (CCScene*)[[MainMenu alloc] init]];
}

-(void)printHighScore
{
    firstLabel = [CCLabelTTF labelWithString:@"1:" fontName:@"Arial" fontSize:24];
    firstLabel.position =ccp(240,220);
    [self addChild:firstLabel z:1];
    [self updateHighScore];
}

-(void)updateHighScore
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSNumber * highScores = [defaults objectForKey:@"highScore"];
    [firstLabel setString:[NSString stringWithFormat:@"1: %@", highScores]];
}

-(id)init
{
    if(self = [super init])
    {
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        CCSprite *background = [CCSprite spriteWithFile:@"tempbackground.png"];
        background.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:background];
        [self printHighScore];
        [self setMenu];
        
    }
    return self;
}

@end
