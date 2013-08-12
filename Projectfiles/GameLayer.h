//
//  GameLayer.h
//  ShootEmHup
//
//  Created by Viet Nguyen on 8/1/13.
//
//

#import "CCLayer.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "ContactListener.h"
@interface GameLayer : CCLayer
{
    CCSprite *currentShip;
    CCSprite *blackShip;
    CCSpriteBatchNode *batchNode;
    CCArray *_shipLasers;
    int _nextShipLaser;
    CCArray *_enemyShips;
    NSMutableArray *_enemyShipsColor;
    int nextShip;
    double nextShipSpawn;
    int _lives;
    CCLabelTTF *scoreLabel;
    CCLabelTTF *shotsLabel;
    CCLabelTTF *lifeLabel;
    CCLabelTTF *distanceLabel;
    b2World* _world;
	ContactListener* _contactListener;
	GLESDebugDraw* debugDraw;
    CCDirector* director;

}

@end
