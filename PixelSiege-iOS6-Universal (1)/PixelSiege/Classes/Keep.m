#import "Keep.h"

@implementation Keep

+ (instancetype)keepForTeam:(TeamID)team atX:(NSInteger)x y:(NSInteger)y {
    Keep *k = [[Keep alloc] init];
    k.team = team;
    k.gridX = x;
    k.gridY = y;
    k.maxHealth = 200.0f;
    k.health = k.maxHealth;
    return k;
}

@end
