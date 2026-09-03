//
//  Keep.h
//  Each team's home base. Destroy the enemy's to win.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "GameTypes.h"

@interface Keep : NSObject

@property (nonatomic, assign) TeamID team;
@property (nonatomic, assign) NSInteger gridX;
@property (nonatomic, assign) NSInteger gridY;
@property (nonatomic, assign) CGFloat health;
@property (nonatomic, assign) CGFloat maxHealth;

+ (instancetype)keepForTeam:(TeamID)team atX:(NSInteger)x y:(NSInteger)y;

@end
