//
//  Troop.h
//  A single unit (swordsman or archer) belonging to a team.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "GameTypes.h"

@interface Troop : NSObject

@property (nonatomic, assign) TroopType type;
@property (nonatomic, assign) TeamID team;

@property (nonatomic, assign) CGFloat gridX;
@property (nonatomic, assign) CGFloat gridY;
@property (nonatomic, assign) NSInteger targetGridX;
@property (nonatomic, assign) NSInteger targetGridY;
@property (nonatomic, assign) BOOL hasMoveOrder;

@property (nonatomic, assign) CGFloat health;
@property (nonatomic, assign) CGFloat maxHealth;
@property (nonatomic, assign) CGFloat damage;
@property (nonatomic, assign) CGFloat attackRange;
@property (nonatomic, assign) CGFloat attackCooldown;
@property (nonatomic, assign) CGFloat attackInterval;
@property (nonatomic, assign) CGFloat moveSpeed;

+ (instancetype)troopWithType:(TroopType)type team:(TeamID)team atX:(NSInteger)x y:(NSInteger)y;

@end
