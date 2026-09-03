#import "GameMap.h"

@implementation GameMap {
    TileType _tiles[MAP_COLS][MAP_ROWS];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        for (NSInteger x = 0; x < MAP_COLS; x++) {
            for (NSInteger y = 0; y < MAP_ROWS; y++) {
                _tiles[x][y] = TileTypeGrass;
            }
        }

        // Water strip down the middle, with a one-tile ford so troops can still cross.
        for (NSInteger y = 0; y < MAP_ROWS; y++) {
            if (y != MAP_ROWS / 2) {
                _tiles[MAP_COLS / 2][y] = TileTypeWater;
            }
        }

        // Small forest patch.
        _tiles[2][1] = TileTypeForest;
        _tiles[3][1] = TileTypeForest;
        _tiles[2][2] = TileTypeForest;

        // Gold resource tiles — stand a troop on one to earn bonus income.
        _tiles[3][6] = TileTypeGold;
        _tiles[8][1] = TileTypeGold;
    }
    return self;
}

- (TileType)tileTypeAtX:(NSInteger)x y:(NSInteger)y {
    if (x < 0 || x >= MAP_COLS || y < 0 || y >= MAP_ROWS) return TileTypeWater;
    return _tiles[x][y];
}

- (BOOL)isWalkableAtX:(NSInteger)x y:(NSInteger)y {
    return [self tileTypeAtX:x y:y] != TileTypeWater;
}

@end
