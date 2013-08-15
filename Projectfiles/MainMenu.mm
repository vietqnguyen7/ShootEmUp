//
//  MainMenu.m
//  Ikaruga
//
//  Created by Viet Nguyen on 8/1/13.
//
//

#import "MainMenu.h"
#import "GameLayer.h"
#import "HighScore.h"

@implementation MainMenu
{
    CCMenu *startMenu;
    CCMenuItem *startButton;
}

-(void) setMenu
{
    CCMenuItemImage *menuItem1 = [CCMenuItemImage itemWithNormalImage:@"menu-button.png"
                                                        selectedImage: @"menu-button.png"
                                                               target:self
                                                             selector:@selector(doSomethingOne:)];
    CCMenuItemImage *menuItem2 = [CCMenuItemImage itemWithNormalImage:@"menu-button.png"
                                                        selectedImage: @"menu-button.png"
                                                               target:self
                                                             selector:@selector(doSomethingTwo:)];
    
    CCMenu * myMenu = [CCMenu menuWithItems:menuItem1,menuItem2, nil];
    [myMenu alignItemsVertically];
    
    // add the menu to your scene
    [self addChild:myMenu];
    
}

- (void) doSomethingOne: (CCMenuItem  *) menuItem
{
    [[CCDirector sharedDirector] replaceScene: (CCScene*)[[GameLayer alloc] init]];
}

-(void) doSomethingTwo: (CCMenuItem *)menuItem
{
    [[CCDirector sharedDirector] replaceScene: (CCScene*)[[HighScore alloc] init]];
}

-(id)init
{
    if(self = [super init])
    {
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        CCSprite *background = [CCSprite spriteWithFile:@"tempbackground.png"];
        background.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:background];
        [self setMenu];
    }
    return self;
}

@end
