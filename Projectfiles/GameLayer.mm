//
//  GameLayer.m
//  ShootEmHup
//
//  Created by Viet Nguyen on 8/1/13.
//
//

#import "GameLayer.h"
#define kNumLasers      5
#define kNumBlackShips 20


@implementation GameLayer

-(id)init
{
    if( (self=[super init]))
    {
        
        batchNode = [CCSpriteBatchNode batchNodeWithFile: @"Ikaruga.png"];
        [self addChild: batchNode];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"Ikaruga.plist"];
        [self spawnShip];
        [self scheduleUpdate];
        [self spawnEnemy];
        [self spawnLasers];
        
        self.isTouchEnabled = YES;
        
    }
    
    return self;
}

//Spawns the player's Ship
-(void)spawnShip
{
    currentShip = [CCSprite spriteWithSpriteFrameName: @"WhiteShip.png"];
    CGSize winSize = [CCDirector sharedDirector].winSize;
    currentShip.position = ccp(winSize.width*0.1, winSize.height * 0.5);
    [batchNode addChild: currentShip];
}

//Spawns all the enemies.
-(void)spawnEnemy
{
    _enemyShips = [[CCArray alloc] initWithCapacity:kNumBlackShips];
    for(int i = 0; i < kNumBlackShips; ++i) {
        CCSprite *enemy = [CCSprite spriteWithSpriteFrameName:@"BlackShip.png"];
        enemy.visible = NO;
        [batchNode addChild:enemy];
        [_enemyShips addObject:enemy];
    }
}

//Spawns the lasers
-(void)spawnLasers
{
    _shipLasers = [[CCArray alloc] initWithCapacity:kNumLasers];
    for(int i = 0; i < kNumLasers; ++i) {
        CCSprite *shipLaser = [CCSprite spriteWithSpriteFrameName:@"WhiteProjectile.png"];
        shipLaser.visible = NO;
        [batchNode addChild:shipLaser];
        [_shipLasers addObject:shipLaser];
    }
}

//Useres accelerometer to control the ship
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    
#define kFilteringFactor 0.1
#define kRestAccelX -0.6
#define kShipMaxPointsPerSec (winSize.height*0.5)
#define kMaxDiffX 0.2
    
    UIAccelerationValue rollingX, rollingY, rollingZ;
    
    rollingX = (acceleration.x * kFilteringFactor) + (rollingX * (1.0 - kFilteringFactor));
    rollingY = (acceleration.y * kFilteringFactor) + (rollingY * (1.0 - kFilteringFactor));
    rollingZ = (acceleration.z * kFilteringFactor) + (rollingZ * (1.0 - kFilteringFactor));
    
    float accelX = acceleration.x - rollingX;
    float accelY = acceleration.y - rollingY;
    float accelZ = acceleration.z - rollingZ;
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    float accelDiff = accelX - kRestAccelX;
    float accelFraction = accelDiff / kMaxDiffX;
    float pointsPerSec = kShipMaxPointsPerSec * accelFraction;
    
    currentShipPointsPerSecY = pointsPerSec;
    
}

- (float)randomValueBetween:(float)low andValue:(float)high {
    return (((float) arc4random() / 0xFFFFFFFFu) * (high - low)) + low;
}


- (void)update:(ccTime)dt
{
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    float maxY = winSize.height - currentShip.contentSize.height/2;
    float minY = currentShip.contentSize.height/2;
    
    float newY = currentShip.position.y + (currentShipPointsPerSecY * dt);
    newY = MIN(MAX(newY, minY), maxY);
    currentShip.position = ccp(currentShip.position.x, newY);
    
    double curTime = CACurrentMediaTime();
    if (curTime > nextShipSpawn)
    {
        
        float randSecs = [self randomValueBetween:0.20 andValue:1.0];
        nextShipSpawn = randSecs + curTime;
        
        float randY = [self randomValueBetween:0.0 andValue:winSize.height];
        float randDuration = [self randomValueBetween:2.0 andValue:10.0];
        
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
    }
    
    //collision
for (CCSprite *enemy in _enemyShips) {
    if (!enemy.visible) continue;
    
    for (CCSprite *shipLaser in _shipLasers) {
        if (!shipLaser.visible) continue;
        
        if (CGRectIntersectsRect(shipLaser.boundingBox, enemy.boundingBox)) {
            shipLaser.visible = NO;
            enemy.visible = NO;
            continue;
        }
    }
    
    if (CGRectIntersectsRect(currentShip.boundingBox, enemy.boundingBox)) {
        enemy.visible = NO;
        [currentShip runAction:[CCBlink actionWithDuration:1.0 blinks:9]];
        _lives--;
    }
}
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    CCSprite *shipLaser = [_shipLasers objectAtIndex:_nextShipLaser];
    _nextShipLaser++;
    if (_nextShipLaser >= _shipLasers.count) _nextShipLaser = 0;
    
    shipLaser.position = ccpAdd(currentShip.position, ccp(shipLaser.contentSize.width/2, 0));
    shipLaser.visible = YES;
    [shipLaser stopAllActions];
    [shipLaser runAction:[CCSequence actions:
                          [CCMoveBy actionWithDuration:0.5 position:ccp(winSize.width, 0)],
                          [CCCallFuncN actionWithTarget:self selector:@selector(setInvisible:)],
                          nil]];
    
}

- (void)setInvisible:(CCNode *)node
{
    node.visible = NO;
}

@end
