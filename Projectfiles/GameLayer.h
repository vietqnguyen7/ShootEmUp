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
    CCLabelTTF *tutorialLabel;
    CCLabelTTF *tutorialLabel1;
    CCLabelTTF *tutorialLabel2;
    CCLabelTTF *tutorialLabel3;
    CCLabelTTF *highScoreLabel;
    CCLabelTTF *roundLabel;
    CCDirector* director;
    b2World *_world;
    GLESDebugDraw *_debugDraw;
    NSUserDefaults *defaults;

}

@end
