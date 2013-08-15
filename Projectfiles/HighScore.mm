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
    secondLabel = [CCLabelTTF labelWithString:@"2:" fontName:@"Arial" fontSize:24];
    thirdLabel = [CCLabelTTF labelWithString:@"3:" fontName:@"Arial" fontSize:24];
    fourthLabel = [CCLabelTTF labelWithString:@"4:" fontName:@"Arial" fontSize:24];
    fifthLabel = [CCLabelTTF labelWithString:@"5:" fontName:@"Arial" fontSize:24];
    firstLabel.position =ccp(240,220);
    secondLabel.position = ccp(240,200);
    thirdLabel.position = ccp(240,180);
    fourthLabel.position = ccp(240,160);
    fifthLabel.position = ccp(240,140);
    [self addChild:firstLabel z:1];
    [self addChild:secondLabel z:1];
    [self addChild:thirdLabel z:1];
    [self addChild:fourthLabel z:1];
    [self addChild:fifthLabel z:1];
    [self updateHighScore];
}

-(void)updateHighScore
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray * highScores = [defaults objectForKey:@"high_scores"];
    [firstLabel setString:[NSString stringWithFormat:@"1: %i", [[highScores objectAtIndex:1] intValue]]];
    [secondLabel setString:[NSString stringWithFormat:@"2: %i", [[highScores objectAtIndex:2] intValue]]];
    [thirdLabel setString:[NSString stringWithFormat:@"3: %i", [[highScores objectAtIndex:3] intValue]]];
    [fourthLabel setString:[NSString stringWithFormat:@"4: %i", [[highScores objectAtIndex:4] intValue]]];
    [fifthLabel setString:[NSString stringWithFormat:@"5: %i", [[highScores objectAtIndex:5] intValue]]];
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
        //[self setMenu];
        
    }
    return self;
}

@end
