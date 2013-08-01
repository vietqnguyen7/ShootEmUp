//
//  GameLayer.h
//  ShootEmHup
//
//  Created by Viet Nguyen on 8/1/13.
//
//

#import "CCLayer.h"

@interface GameLayer : CCLayer
{
    CCSprite *whiteShip;
    CCSprite *blackShip;
    CCSpriteBatchNode *batchNode;
    float whiteShipPointsPerSecY;
    CCArray *_shipLasers;
    int _nextShipLaser;
    CCArray *_enemyShips;
    int nextShip;
    double nextShipSpawn;
    int _lives;
}

@end
