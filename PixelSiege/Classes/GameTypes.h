//
//  GameTypes.h
//  Pixel Siege — shared enums used across the game.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TeamID) {
    TeamPlayer,
    TeamEnemy
};

typedef NS_ENUM(NSInteger, TroopType) {
    TroopTypeSwordsman,
    TroopTypeArcher
};

typedef NS_ENUM(NSInteger, TileType) {
    TileTypeGrass,
    TileTypeForest,
    TileTypeWater,
    TileTypeGold
};
