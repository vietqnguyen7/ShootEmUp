//
//  GameLayer.m
//  ShootEmHup
//
//  Created by Viet Nguyen on 8/1/13.
//
//

#import "GameLayer.h"
#define kNumShips 100
int ship = 1; //Determines the player's Color. White = 1. Black = 2.
int kNumLasers = 15;// Number of lasers in array, able to appear on screen.
int points = 0;//Total points gained.
int life = 3;//Amount of life you have.
int shots = 5;//Amount of shots you have.


@implementation GameLayer

-(id)init
{
    if( (self=[super init]))
    {
        director = [CCDirector sharedDirector];
        [self initBG];
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
    
}

-(void)initBG
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CCSprite *background = [CCSprite spriteWithFile:@"tempbackground.png"];
    background.position = ccp(winSize.width/2, winSize.height/2);
    [self addChild:background];
}

//Spawns the player's Ship
-(void)spawnShip
{
    currentShip = [CCSprite spriteWithSpriteFrameName: @"WhitePlayerShip.png"];
    CGSize winSize = [CCDirector sharedDirector].winSize;
    currentShip.position = ccp(winSize.width*0.1, winSize.height * 0.5);
    [batchNode addChild: currentShip];
}


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

-(void) moveSpriteWithTouch:(UITouch*)touch
{
	CGPoint location = [director convertToGL:[touch locationInView:director.openGLView]];
    if(location.x - 100 < 30)
    {
        currentShip.position = CGPointMake(30, location.y);

    }
    
}

-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self moveSpriteWithTouch:[touches anyObject]];
}

-(void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self moveSpriteWithTouch:[touches anyObject]];
}


- (void)update:(ccTime)dt
{
    //Changes ship color if pressed on left. If on right then shoots a laser.
    KKInput* input = [KKInput sharedInput];
    CGPoint pos = [input locationOfAnyTouchInPhase:KKTouchPhaseAny];
    
    if ([KKInput sharedInput].anyTouchBeganThisFrame)
    {
        //Changes color if pressed on the left side of the screen.
        if(pos.x > 180 && pos.y > 160)
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
        //Shoots a laser if tapped on the right side of the screen.
        else if(pos.x > 180 && pos.y < 160)
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
    }//Ends the touch phase
    
    
    //Updates the ships location.
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    //Spawns the Enemy.
    double curTime = CACurrentMediaTime();
    if (curTime > nextShipSpawn)
    {
        float randSecs = [self randomValueBetween:0.10 andValue:.15];
        nextShipSpawn = randSecs + curTime;
        
        float randY = [self randomValueBetween:0.0 andValue:winSize.height];
        float randDuration = [self randomValueBetween:(5.0) andValue:(10.0)];
        
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
            }
            
        }//end if to see if player ship collides with enemys
    }//end for loop for collision
}//ends the update

- (void)setInvisible:(CCNode *)node
{
    node.visible = NO;
}

@end