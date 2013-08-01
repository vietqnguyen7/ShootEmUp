//
//  GameLayer.m
//  ShootEmHup
//
//  Created by Viet Nguyen on 8/1/13.
//
//

#import "GameLayer.h"
#define kNumLasers      5

@implementation GameLayer

-(id)init
{
    if( (self=[super init]))
    {
        batchNode = [CCSpriteBatchNode batchNodeWithFile: @"Ikaruga.png"];
        [self addChild: batchNode];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"Ikaruga.plist"];
        
        whiteShip = [CCSprite spriteWithSpriteFrameName: @"WhiteShip.png"];
        CGSize winSize = [CCDirector sharedDirector].winSize;
        whiteShip.position = ccp(winSize.width*0.1, winSize.height * 0.5);
        [batchNode addChild: whiteShip z:1];
        [self scheduleUpdate];
        _shipLasers = [[CCArray alloc] initWithCapacity:kNumLasers];
        for(int i = 0; i < kNumLasers; ++i) {
            CCSprite *shipLaser = [CCSprite spriteWithSpriteFrameName:@"WhiteProjectile.png"];
            shipLaser.visible = NO;
            [batchNode addChild:shipLaser];
            [_shipLasers addObject:shipLaser];
        }
        
        self.isTouchEnabled = YES;
        
    }
    
    return self;
}

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
    
    whiteShipPointsPerSecY = pointsPerSec;
    
}

- (void)update:(ccTime)dt
{
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    float maxY = winSize.height - whiteShip.contentSize.height/2;
    float minY = whiteShip.contentSize.height/2;
    
    float newY = whiteShip.position.y + (whiteShipPointsPerSecY * dt);
    newY = MIN(MAX(newY, minY), maxY);
    whiteShip.position = ccp(whiteShip.position.x, newY);
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    CCSprite *shipLaser = [_shipLasers objectAtIndex:_nextShipLaser];
    _nextShipLaser++;
    if (_nextShipLaser >= _shipLasers.count) _nextShipLaser = 0;
    
    shipLaser.position = ccpAdd(whiteShip.position, ccp(shipLaser.contentSize.width/2, 0));
    shipLaser.visible = YES;
    [shipLaser stopAllActions];
    [shipLaser runAction:[CCSequence actions:
                          [CCMoveBy actionWithDuration:0.5 position:ccp(winSize.width, 0)],
                          [CCCallFuncN actionWithTarget:self selector:@selector(setInvisible:)],
                          nil]];
    
}

- (void)setInvisible:(CCNode *)node {
    node.visible = NO;
}

@end
