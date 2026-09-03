//
//  GameMap.h
//  The tile grid the battle plays out on.
//

#import <Foundation/Foundation.h>
#import "GameTypes.h"

#define MAP_COLS 12
#define MAP_ROWS 8

@interface GameMap : NSObject

- (TileType)tileTypeAtX:(NSInteger)x y:(NSInteger)y;
- (BOOL)isWalkableAtX:(NSInteger)x y:(NSInteger)y;

@end
