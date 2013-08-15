//
//  GameLayer.m
//  ShootEmHup
//
//  Created by Viet Nguyen on 8/1/13.
//
//

#import "GameLayer.h"
#import "MainMenu.h"
#import "HighScore.h"

#define kNumShips 100
int ship = 1; //Determines the player's Color. White = 1. Black = 2.
int kNumLasers = 50;// Number of lasers in array, able to appear on screen.
int points = 0;//Total points gained.
int life = 3;//Amount of life you have.
int shots = 5;//Amount of shots you have.
double nextSpawnTime = .01;
int nextIncrement = points;


@implementation GameLayer

-(id)init
{
    if( (self=[super init]))
    {
        director = [CCDirector sharedDirector];
        CGSize size = [[CCDirector sharedDirector] winSize];
        CGPoint center = CGPointMake(size.width / 2, size.height / 2);
        [self initBG];
        [self initTutorial];
        batchNode = [CCSpriteBatchNode batchNodeWithFile: @"Ships.png"];
        [self addChild: batchNode];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"Ships.plist"];
        [self initHUD];
        [self spawnShip];
        [self scheduleUpdate];
        [self spawnEnemyShip];
        [self spawnLasers];
        self.accelerometerEnabled = YES;
        self.touchEnabled = YES;
    }
    
    return self;
}

//Initialized the HUD
-(void)initHUD
{
    scoreLabel = [CCLabelTTF labelWithString:@"Score: 0" fontName:@"Arial" fontSize:24];
    shotsLabel = [CCLabelTTF labelWithString:@"Shots: 5" fontName:@"Arial" fontSize:24];
    lifeLabel = [CCLabelTTF labelWithString:@"Life: 3" fontName:@"Arial" fontSize:24];
    lifeLabel.position =ccp(400,280);
    scoreLabel.position = ccp(400,310);
    shotsLabel.position = ccp(400,250);
    [self addChild:scoreLabel z:1];
    [self addChild:shotsLabel z:1];
    [self addChild:lifeLabel z:1];
    
}//end initHUD

//Initializes the tutorial
-(void)initTutorial
{
    tutorialLabel = [CCLabelTTF labelWithString:@"Drag ship to move" fontName:@"Arial" fontSize:15];
    tutorialLabel1 = [CCLabelTTF labelWithString:@"Tap here to shoot" fontName:@"Arial" fontSize:15];
    tutorialLabel2 = [CCLabelTTF labelWithString:@"Tap here to change ship color" fontName:@"Arial" fontSize:15];
    tutorialLabel.position =ccp(60,140);
    tutorialLabel1.position = ccp(350,30);
    tutorialLabel2.position = ccp(350,220);
    [tutorialLabel runAction:[CCSequence actions: [CCFadeOut actionWithDuration:10.0f], nil]];
    [tutorialLabel1 runAction:[CCSequence actions: [CCFadeOut actionWithDuration:10.0f], nil]];
    [tutorialLabel2 runAction:[CCSequence actions: [CCFadeOut actionWithDuration:10.0f], nil]];
    [self addChild: tutorialLabel z:1];
    [self addChild: tutorialLabel1 z:1];
    [self addChild: tutorialLabel2 z:1];
}//end tutorial

//Initializes the background
-(void)initBG
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CCSprite *background = [CCSprite spriteWithFile:@"tempbackground.png"];
    background.position = ccp(winSize.width/2, winSize.height/2);
    [self addChild:background];
}//end background

//Spawns the player's Ship
-(void)spawnShip
{
    currentShip = [CCSprite spriteWithSpriteFrameName: @"WhitePlayerShip.png"];
    CGSize winSize = [CCDirector sharedDirector].winSize;
    currentShip.position = ccp(winSize.width*0.1, winSize.height * 0.5);
    [batchNode addChild: currentShip];
}//end spawnship


//Spawns all the enemies.
-(void)spawnEnemyShip
{
    _enemyShipsColor = [[NSMutableArray alloc] initWithCapacity:kNumShips];
    _enemyShips = [[CCArray alloc] initWithCapacity:kNumShips];
    for(int i = 0; i < kNumShips; ++i)
    {
        //Randomizes the color between white and black.
        float whiteOrBlack = [self randomValueBetween:1.0 andValue: 2.0];
        if(whiteOrBlack <= 1.5)
        {
            int color = 1;
            CCSprite *enemy = [CCSprite spriteWithSpriteFrameName:@"WhiteShip.png"];
            enemy.visible = NO;
            [batchNode addChild:enemy];
            [_enemyShips addObject:enemy];
            [_enemyShipsColor addObject:[NSNumber numberWithInt:color]];
        }
        else
        {
            int color = 2;
            CCSprite *enemy = [CCSprite spriteWithSpriteFrameName:@"BlackShip.png"];
            enemy.visible = NO;
            [batchNode addChild:enemy];
            [_enemyShips addObject:enemy];
            [_enemyShipsColor addObject:[NSNumber numberWithInt:color]];
        }
    }
}

//Spawns the lasers
-(void)spawnLasers
{
    _shipLasers = [[CCArray alloc] initWithCapacity:kNumLasers];
    for(int i = 0; i < kNumLasers; ++i)
    {
        CCSprite *shipLaser = [CCSprite spriteWithSpriteFrameName:@"WhiteProjectile.png"];
        shipLaser.visible = NO;
        [batchNode addChild:shipLaser];
        [_shipLasers addObject:shipLaser];
    }
}


- (float)randomValueBetween:(float)low andValue:(float)high {
    return (((float) arc4random() / 0xFFFFFFFFu) * (high - low)) + low;
}

-(void)updateHUD
{
    [scoreLabel setString:[NSString stringWithFormat:@"Score: %i", points]];
    [shotsLabel setString:[NSString stringWithFormat:@"Shots: %i", shots]];
    [lifeLabel setString:[NSString stringWithFormat:@"Life: %i", life]];
}

-(void)gameOver
{
    NSLog(@"Resets game and goes back to Main Menu");
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *highScores = [NSMutableArray arrayWithArray:[defaults arrayForKey:@"scores"]];
    for(int i = 0; i < [highScores count]; i++)
    {
        if(points > [[highScores objectAtIndex:i] intValue])
        {
            [highScores insertObject:[NSNumber numberWithInt:points] atIndex:i];
            [highScores removeLastObject];
            [defaults setObject:highScores forKey:@"scores"];
            [defaults synchronize];
            break;
        }
    }
    [_enemyShips removeAllObjects];
    [_enemyShipsColor removeAllObjects];
    points = 0;
    life = 3;
    shots = 5;
    [[CCDirector sharedDirector] replaceScene: (CCScene*)[[MainMenu alloc] init]];
}

-(void) moveSpriteWithTouch:(UITouch*)touch
{
    CGPoint location = [director convertToGL:[touch locationInView:director.openGLView]];
    if(location.x - 100 < 30)
    {
        currentShip.position = CGPointMake(70, location.y);
    }
}

-(void) changeShipColorWithTouch:(UITouch*)touch
{
    CGPoint location = [director convertToGL:[touch locationInView:director.openGLView]];
    if(location.x > 180 && location.y > 160)
    {
        
        if(ship == 1)
        {
            ship++;
            [currentShip setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"BlackPlayerShip.png"]];
        }//changes to black
        else
        {
            ship--;
            [currentShip setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"WhitePlayerShip.png"]];
        }//changes to white
    }//end if to see if it will change color.
}

-(void) shootLasersWithTouch:(UITouch*)touch
{
    CGPoint location = [director convertToGL:[touch locationInView:director.openGLView]];
    if(location.x > 180 && location.y < 160)
    {
        if(shots > 0)
        {
            shots--;
            [self updateHUD];
            CGSize winSize = [CCDirector sharedDirector].winSize;
            
            CCSprite *shipLaser = [_shipLasers objectAtIndex:_nextShipLaser];
            _nextShipLaser++;
            if (_nextShipLaser >= _shipLasers.count) _nextShipLaser = 0;
            if(ship == 1)
            {
                [shipLaser setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"WhiteProjectile.png"]];
            }//Changes the laser color to white.
            else
            {
                [shipLaser setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"BlackProjectile.png"]];
            }//Changes the laser color to black.
            
            shipLaser.position = ccpAdd(currentShip.position, ccp(shipLaser.contentSize.width/2, 0));
            shipLaser.visible = YES;
            [shipLaser stopAllActions];
            [shipLaser runAction:[CCSequence actions:
                                  [CCMoveBy actionWithDuration:0.5 position:ccp(winSize.width, 0)],
                                  [CCCallFuncN actionWithTarget:self selector:@selector(setInvisible:)],
                                  nil]];
        }
    }//ends the else to see if it will shoot a laser.
}

-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self moveSpriteWithTouch:[touches anyObject]];
    [self changeShipColorWithTouch:[touches anyObject]];
    [self shootLasersWithTouch:[touches anyObject]];
}

-(void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self moveSpriteWithTouch:[touches anyObject]];
}


- (void)update:(ccTime)dt
{
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    //Spawns the Enemy.
    double curTime = CACurrentMediaTime();
    if (curTime > nextShipSpawn)
    {
        if(points == nextIncrement)
        {
            nextSpawnTime +=.05;
            nextIncrement = points + 100;
        }
        float randSecs = [self randomValueBetween:0.4 andValue:.6-nextSpawnTime];
        nextShipSpawn = randSecs + curTime;
        
        float randY = [self randomValueBetween:0.0 andValue:winSize.height];
        float randDuration = [self randomValueBetween:(8.0) andValue:(10.0)];
        
        CCSprite *enemy = [_enemyShips objectAtIndex:nextShip];
        nextShip++;
        if (nextShip >= _enemyShips.count) nextShip = 0;
        
        [enemy stopAllActions];
        enemy.position = ccp(winSize.width+enemy.contentSize.width/2, randY);
        enemy.visible = YES;
        [enemy runAction:[CCSequence actions:
                          [CCMoveBy actionWithDuration:randDuration position:ccp(-winSize.width-enemy.contentSize.width, 0)],
                          [CCCallFuncN actionWithTarget:self selector:@selector(setInvisible:)],
                          nil]];
    }//ends if for spawning enemies.
    
    //Collision
    for (CCSprite *enemy in _enemyShips)
    {
        if (!enemy.visible) continue;
        
        for (CCSprite *shipLaser in _shipLasers)
        {
            if (!shipLaser.visible) continue;
            
            if (CGRectIntersectsRect(shipLaser.boundingBox, enemy.boundingBox))
            {
                shipLaser.visible = NO;
                enemy.visible = NO;
                points += 100;
                [self updateHUD];
                continue;
            }//end if to see if the laser hits the enemy.
        }//end for to see if theres any lasers being shot.
        
        if (CGRectIntersectsRect(currentShip.boundingBox, enemy.boundingBox))
        {
            enemy.visible = NO;
            int enemyInt = [_enemyShips indexOfObject:(enemy)];
            NSInteger colorOfEnemy = [[_enemyShipsColor objectAtIndex:(enemyInt)] integerValue];
            if(ship == colorOfEnemy)
            {
                shots++;
                points+=100;
                [self updateHUD];
            }
            else
            {
                life--;
                points-=300;
                [self updateHUD];
                if(life == 0)
                {
                    [self gameOver];
                }
            }
            
        }//end if to see if player ship collides with enemys
    }//end for loop for collision
}//ends the update

- (void)setInvisible:(CCNode *)node
{
    node.visible = NO;
}

@end