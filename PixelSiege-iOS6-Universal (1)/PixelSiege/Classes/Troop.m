#import "Troop.h"

@implementation Troop

+ (instancetype)troopWithType:(TroopType)type team:(TeamID)team atX:(NSInteger)x y:(NSInteger)y {
    Troop *t = [[Troop alloc] init];
    t.type = type;
    t.team = team;
    t.gridX = x;
    t.gridY = y;
    t.targetGridX = x;
    t.targetGridY = y;
    t.hasMoveOrder = NO;
    t.attackCooldown = 0;

    switch (type) {
        case TroopTypeSwordsman:
            t.maxHealth = 30.0f;
            t.damage = 8.0f;
            t.attackRange = 1.1f;
            t.attackInterval = 1.0f;
            t.moveSpeed = 1.5f;
            break;
        case TroopTypeArcher:
            t.maxHealth = 18.0f;
            t.damage = 5.0f;
            t.attackRange = 3.0f;
            t.attackInterval = 1.2f;
            t.moveSpeed = 1.2f;
            break;
    }
    t.health = t.maxHealth;
    return t;
}

@end
