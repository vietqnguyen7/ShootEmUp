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

#define kNumShips 1000
int ship = 1; //Determines the player's Color. White = 1. Black = 2.
int kNumLasers = 50;// Number of lasers in array, able to appear on screen.
int points = 0;//Total points gained.
int life = 5;//Amount of life you have.
int shots = 50;//Amount of shots you have.
double nextSpawnTime = 0; //duration for start of the value of random for spawn time.
double startSpawnTime = 0.6;//duration for start of the value of random for spawn time.
double endSpawnTime = 0.8;//duration for end of the value of random for spawn time.
double startSpeedTime = 5;//start speed
double endSpeedTime = 7;//end speed
int shipsAbsorbed = 0;//STATS (unused)
int shipsDestoryed = 0;//STATS (unused)
int nextIncrementStartWave = 2000;
int nextIncrementEndWave = 6000;
int nextIncrement = .03;
int roundNumber = 1;

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
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *currentHighScore = [defaults objectForKey:@"highScore"];
    int hs = [currentHighScore intValue];
    scoreLabel = [CCLabelTTF labelWithString:@"Score: 0" fontName:@"Arial" fontSize:15];
    shotsLabel = [CCLabelTTF labelWithString:@"Shots: 5" fontName:@"Arial" fontSize:15];
    lifeLabel = [CCLabelTTF labelWithString:@"Life: 3" fontName:@"Arial" fontSize:15];
    roundLabel = [CCLabelTTF labelWithString:@"Prep Round" fontName:@"Arial" fontSize:18];
    highScoreLabel = [CCLabelTTF labelWithString:@"High Score:" fontName:@"Arial" fontSize:20];
    [highScoreLabel setString:[NSString stringWithFormat:@"HighScore: %i", hs]];
    roundLabel.position = ccp(50,310);
    lifeLabel.position =ccp(400,290);
    scoreLabel.position = ccp(400,310);
    shotsLabel.position = ccp(400,270);
    highScoreLabel.position = ccp(240,310);
    [self addChild:scoreLabel z:1];
    [self addChild:shotsLabel z:1];
    [self addChild:lifeLabel z:1];
    [self addChild:highScoreLabel z:1];
    [self addChild:roundLabel z:1];
}//end initHUD

//Initializes the tutorial
-(void)initTutorial
{
    tutorialLabel = [CCLabelTTF labelWithString:@"Drag to move" fontName:@"Arial" fontSize:15];
    tutorialLabel1 = [CCLabelTTF labelWithString:@"Tap here to shoot" fontName:@"Arial" fontSize:15];
    tutorialLabel2 = [CCLabelTTF labelWithString:@"Tap here to change color" fontName:@"Arial" fontSize:15];
    tutorialLabel3 = [CCLabelTTF labelWithString:@"Absorb ships to get shots" fontName:@"Arial" fontSize:15];
    tutorialLabel.position =ccp(60,140);
    tutorialLabel1.position = ccp(350,30);
    tutorialLabel2.position = ccp(350,220);
    tutorialLabel3.position = ccp(240,160);
    [tutorialLabel runAction:[CCSequence actions: [CCFadeOut actionWithDuration:25.0f], nil]];
    [tutorialLabel1 runAction:[CCSequence actions: [CCFadeOut actionWithDuration:25.0f], nil]];
    [tutorialLabel2 runAction:[CCSequence actions: [CCFadeOut actionWithDuration:25.0f], nil]];
    [tutorialLabel3 runAction:[CCSequence actions: [CCFadeOut actionWithDuration:25.0f], nil]];
    
    [self addChild: tutorialLabel z:1];
    [self addChild: tutorialLabel1 z:1];
    [self addChild: tutorialLabel2 z:1];
    [self addChild: tutorialLabel3 z:1];
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
    currentShip.position = ccp(70, winSize.height * 0.5);
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

-(void)startWave
{
    [roundLabel setString:[NSString stringWithFormat:@"Wave: %d", roundNumber]];
    roundNumber+=1;
    startSpawnTime = 0.1;//duration for start of the value of random for spawn time.
    endSpawnTime = 0.2;//duration for end of the value of random for spawn time.
    startSpeedTime = 6;//start speed
    endSpeedTime = 8;//end speed
}

-(void)endWave
{
    [roundLabel setString:[NSString stringWithFormat:@"Prep Round", roundNumber]];
    nextIncrement -= .03;
    startSpawnTime = 0.45 - nextIncrement;;//duration for start of the value of random for spawn time.
    endSpawnTime = 0.65 - nextIncrement;//duration for end of the value of random for spawn time.
    startSpeedTime = 3.5 - nextIncrement;//start speed
    endSpeedTime = 6 - nextIncrement;//end speed
}

-(void)roundTransition
{
    if(points == nextIncrementStartWave)
    {
        NSLog(@"start wave");
        nextIncrementStartWave += 7000;
        [self startWave];
    }
    else if(points == nextIncrementEndWave)
    {
        NSLog(@"end wave");
        nextIncrementEndWave += 7000;
        [self endWave];
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

-(void)restartGame
{
    [_enemyShips removeAllObjects];
    [_enemyShipsColor removeAllObjects];
    ship = 1; //Determines the player's Color. White = 1. Black = 2.
    points = 0;//Total points gained.
    life = 3;//Amount of life you have.
    shots = 5;//Amount of shots you have.
    nextSpawnTime = 0; //duration for start of the value of random for spawn time.
    startSpawnTime = 0.6;//duration for start of the value of random for spawn time.
    endSpawnTime = 0.8;//duration for end of the value of random for spawn time.
    startSpeedTime = 5;//start speed
    endSpeedTime = 7;//end speed
    shipsAbsorbed = 0;
    shipsDestoryed = 0;
}

-(void)gameOver
{
    NSLog(@"Resets game and goes back to Main Menu");
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *currentHighScore = [defaults objectForKey:@"highScore"];
    int hs = [currentHighScore intValue];
    if(hs < points)
    {
        NSNumber *highScore = [NSNumber numberWithInteger:points];
        [[NSUserDefaults standardUserDefaults] setObject:highScore forKey:@"highScore"];
    }
    [self restartGame];
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
        float randSecs = [self randomValueBetween:startSpawnTime andValue:endSpawnTime];
        nextShipSpawn = randSecs + curTime;
        
        float randY = [self randomValueBetween:20.0 andValue:winSize.height-20];
        float randDuration = [self randomValueBetween:startSpeedTime andValue:endSpeedTime];
        
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
                [self roundTransition];
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
                shots+=3;
                points+=100;
                [self updateHUD];
                [self roundTransition];
            }
            else
            {
                life--;
                [self updateHUD];
                if(life <= 0)
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