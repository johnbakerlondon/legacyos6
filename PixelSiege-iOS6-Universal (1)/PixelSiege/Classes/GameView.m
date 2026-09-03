#import "GameView.h"
#import "GameMap.h"
#import "Troop.h"
#import "Keep.h"
#import <QuartzCore/QuartzCore.h>
#import <math.h>

typedef NS_ENUM(NSInteger, GameState) {
    GameStatePlaying,
    GameStateWon,
    GameStateLost
};

static const NSInteger kMaxTroopsPerTeam = 16;
static const CGFloat kSwordsmanCost = 10.0f;
static const CGFloat kArcherCost = 15.0f;

@interface GameView ()
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) GameMap *map;
@property (nonatomic, strong) NSMutableArray *troops;
@property (nonatomic, strong) Keep *playerKeep;
@property (nonatomic, strong) Keep *enemyKeep;
@property (nonatomic, assign) CGFloat playerGold;
@property (nonatomic, assign) NSTimeInterval lastTimestamp;
@property (nonatomic, assign) CGFloat enemySpawnTimer;
@property (nonatomic, weak) Troop *selectedTroop;
@property (nonatomic, assign) GameState state;

@property (nonatomic, strong) UIImage *imgGrass;
@property (nonatomic, strong) UIImage *imgForest;
@property (nonatomic, strong) UIImage *imgWater;
@property (nonatomic, strong) UIImage *imgGold;
@property (nonatomic, strong) UIImage *imgSwordsmanBlue;
@property (nonatomic, strong) UIImage *imgSwordsmanRed;
@property (nonatomic, strong) UIImage *imgArcherBlue;
@property (nonatomic, strong) UIImage *imgArcherRed;
@property (nonatomic, strong) UIImage *imgKeepBlue;
@property (nonatomic, strong) UIImage *imgKeepRed;
@end

@implementation GameView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.multipleTouchEnabled = NO;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        _map = [[GameMap alloc] init];
        _troops = [NSMutableArray array];
        _playerKeep = [Keep keepForTeam:TeamPlayer atX:0 y:MAP_ROWS - 1];
        _enemyKeep = [Keep keepForTeam:TeamEnemy atX:MAP_COLS - 1 y:0];
        _playerGold = 50.0f;
        _enemySpawnTimer = 4.0f;
        _state = GameStatePlaying;

        [self loadImages];

        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick:)];
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    return self;
}

- (void)loadImages {
    self.imgGrass = [UIImage imageNamed:@"tile_grass.png"];
    self.imgForest = [UIImage imageNamed:@"tile_forest.png"];
    self.imgWater = [UIImage imageNamed:@"tile_water.png"];
    self.imgGold = [UIImage imageNamed:@"tile_gold.png"];
    self.imgSwordsmanBlue = [UIImage imageNamed:@"troop_swordsman_blue.png"];
    self.imgSwordsmanRed = [UIImage imageNamed:@"troop_swordsman_red.png"];
    self.imgArcherBlue = [UIImage imageNamed:@"troop_archer_blue.png"];
    self.imgArcherRed = [UIImage imageNamed:@"troop_archer_red.png"];
    self.imgKeepBlue = [UIImage imageNamed:@"keep_blue.png"];
    self.imgKeepRed = [UIImage imageNamed:@"keep_red.png"];
}

- (void)dealloc {
    [_displayLink invalidate];
}

#pragma mark - Layout helpers (resolution independent: iPhone + iPad, portrait + landscape)

- (CGFloat)hudHeight {
    CGFloat h = self.bounds.size.height * 0.09f;
    if (h < 56.0f) h = 56.0f;
    if (h > 96.0f) h = 96.0f;
    return h;
}

- (CGFloat)tileSize {
    CGFloat availableHeight = self.bounds.size.height - [self hudHeight];
    CGFloat wByCols = self.bounds.size.width / MAP_COLS;
    CGFloat hByRows = availableHeight / MAP_ROWS;
    return MIN(wByCols, hByRows);
}

- (CGPoint)mapOrigin {
    CGFloat ts = [self tileSize];
    CGFloat availableHeight = self.bounds.size.height - [self hudHeight];
    CGFloat mapWidthPx = ts * MAP_COLS;
    CGFloat mapHeightPx = ts * MAP_ROWS;
    CGFloat originX = (self.bounds.size.width - mapWidthPx) / 2.0f;
    CGFloat originY = (availableHeight - mapHeightPx) / 2.0f;
    if (originY < 0) originY = 0;
    return CGPointMake(originX, originY);
}

- (CGPoint)screenPointForGridX:(CGFloat)gx y:(CGFloat)gy {
    CGFloat ts = [self tileSize];
    CGPoint origin = [self mapOrigin];
    return CGPointMake(origin.x + gx * ts, origin.y + gy * ts);
}

#pragma mark - Game loop

- (void)tick:(CADisplayLink *)link {
    NSTimeInterval now = link.timestamp;
    if (self.lastTimestamp == 0) {
        self.lastTimestamp = now;
    }
    CGFloat dt = (CGFloat)(now - self.lastTimestamp);
    self.lastTimestamp = now;
    if (dt > 0.25f) dt = 0.25f;

    if (self.state == GameStatePlaying) {
        [self updateEconomy:dt];
        [self updateTroops:dt];
        [self updateEnemyAI:dt];
        [self checkWinLose];
    }

    [self setNeedsDisplay];
}

- (void)updateEconomy:(CGFloat)dt {
    self.playerGold += 2.0f * dt;
    for (Troop *t in self.troops) {
        if (t.team == TeamPlayer &&
            [self.map tileTypeAtX:(NSInteger)roundf(t.gridX) y:(NSInteger)roundf(t.gridY)] == TileTypeGold) {
            self.playerGold += 1.0f * dt;
        }
    }
}

- (Troop *)nearestEnemyTo:(Troop *)troop {
    Troop *best = nil;
    CGFloat bestDist = CGFLOAT_MAX;
    for (Troop *other in self.troops) {
        if (other.team == troop.team || other.health <= 0) continue;
        CGFloat dx = other.gridX - troop.gridX;
        CGFloat dy = other.gridY - troop.gridY;
        CGFloat dist = sqrtf(dx * dx + dy * dy);
        if (dist < bestDist) {
            bestDist = dist;
            best = other;
        }
    }
    return best;
}

- (Keep *)enemyKeepFor:(TeamID)team {
    return team == TeamPlayer ? self.enemyKeep : self.playerKeep;
}

- (void)updateTroops:(CGFloat)dt {
    NSMutableArray *dead = [NSMutableArray array];

    for (Troop *t in self.troops) {
        if (t.health <= 0) {
            [dead addObject:t];
            continue;
        }

        if (t.attackCooldown > 0) t.attackCooldown -= dt;

        Troop *targetTroop = [self nearestEnemyTo:t];
        Keep *targetKeep = [self enemyKeepFor:t.team];

        CGFloat distToTroop = targetTroop ? sqrtf(powf(targetTroop.gridX - t.gridX, 2.0f) + powf(targetTroop.gridY - t.gridY, 2.0f)) : CGFLOAT_MAX;
        CGFloat distToKeep = sqrtf(powf(targetKeep.gridX - t.gridX, 2.0f) + powf(targetKeep.gridY - t.gridY, 2.0f));

        if (targetTroop && distToTroop <= t.attackRange) {
            if (t.attackCooldown <= 0) {
                targetTroop.health -= t.damage;
                t.attackCooldown = t.attackInterval;
            }
        } else if (targetKeep.health > 0 && distToKeep <= t.attackRange) {
            if (t.attackCooldown <= 0) {
                targetKeep.health -= t.damage;
                t.attackCooldown = t.attackInterval;
            }
        } else if (t.hasMoveOrder) {
            [self stepTroopTowardTarget:t dt:dt];
        }
    }

    if (dead.count > 0) {
        [self.troops removeObjectsInArray:dead];
        if (self.selectedTroop && [dead containsObject:self.selectedTroop]) {
            self.selectedTroop = nil;
        }
    }
}

- (void)stepTroopTowardTarget:(Troop *)t dt:(CGFloat)dt {
    CGFloat dx = t.targetGridX - t.gridX;
    CGFloat dy = t.targetGridY - t.gridY;
    CGFloat dist = sqrtf(dx * dx + dy * dy);
    if (dist < 0.05f) {
        t.hasMoveOrder = NO;
        return;
    }
    CGFloat step = t.moveSpeed * dt;
    if (step >= dist) {
        t.gridX = t.targetGridX;
        t.gridY = t.targetGridY;
        t.hasMoveOrder = NO;
    } else {
        t.gridX += (dx / dist) * step;
        t.gridY += (dy / dist) * step;
    }
}

- (void)updateEnemyAI:(CGFloat)dt {
    self.enemySpawnTimer -= dt;
    if (self.enemySpawnTimer <= 0) {
        self.enemySpawnTimer = 6.0f;
        NSInteger enemyCount = 0;
        for (Troop *t in self.troops) {
            if (t.team == TeamEnemy) enemyCount++;
        }
        if (enemyCount < kMaxTroopsPerTeam) {
            TroopType type = (arc4random_uniform(2) == 0) ? TroopTypeSwordsman : TroopTypeArcher;
            Troop *t = [Troop troopWithType:type team:TeamEnemy atX:self.enemyKeep.gridX y:self.enemyKeep.gridY];
            t.targetGridX = self.playerKeep.gridX;
            t.targetGridY = self.playerKeep.gridY;
            t.hasMoveOrder = YES;
            [self.troops addObject:t];
        }
    }
}

- (void)checkWinLose {
    if (self.enemyKeep.health <= 0 && self.state == GameStatePlaying) {
        self.state = GameStateWon;
        [self showEndGameAlertWithTitle:@"Victory!" message:@"You destroyed the enemy keep."];
    } else if (self.playerKeep.health <= 0 && self.state == GameStatePlaying) {
        self.state = GameStateLost;
        [self showEndGameAlertWithTitle:@"Defeat" message:@"Your keep has fallen."];
    }
}

- (void)showEndGameAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                      message:message
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    [alert show];
}

#pragma mark - Touch handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.state != GameStatePlaying) return;

    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self];

    if (p.y >= self.bounds.size.height - [self hudHeight]) {
        [self handleHUDTapAt:p];
        return;
    }

    CGFloat ts = [self tileSize];
    CGPoint origin = [self mapOrigin];
    NSInteger gx = (NSInteger)((p.x - origin.x) / ts);
    NSInteger gy = (NSInteger)((p.y - origin.y) / ts);

    if (gx < 0 || gx >= MAP_COLS || gy < 0 || gy >= MAP_ROWS) return;

    for (Troop *t in self.troops) {
        if (t.team != TeamPlayer) continue;
        if ((NSInteger)roundf(t.gridX) == gx && (NSInteger)roundf(t.gridY) == gy) {
            self.selectedTroop = t;
            return;
        }
    }

    if (self.selectedTroop && [self.map isWalkableAtX:gx y:gy]) {
        self.selectedTroop.targetGridX = gx;
        self.selectedTroop.targetGridY = gy;
        self.selectedTroop.hasMoveOrder = YES;
    }
}

- (void)handleHUDTapAt:(CGPoint)p {
    CGFloat buttonWidth = self.bounds.size.width / 2.0f;
    if (p.x < buttonWidth) {
        [self trainTroopOfType:TroopTypeSwordsman cost:kSwordsmanCost];
    } else {
        [self trainTroopOfType:TroopTypeArcher cost:kArcherCost];
    }
}

- (void)trainTroopOfType:(TroopType)type cost:(CGFloat)cost {
    NSInteger playerCount = 0;
    for (Troop *t in self.troops) {
        if (t.team == TeamPlayer) playerCount++;
    }
    if (self.playerGold < cost || playerCount >= kMaxTroopsPerTeam) return;

    self.playerGold -= cost;
    Troop *t = [Troop troopWithType:type team:TeamPlayer atX:self.playerKeep.gridX y:self.playerKeep.gridY];
    [self.troops addObject:t];
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [self drawMapInContext:ctx];
    [self drawKeep:self.playerKeep image:self.imgKeepBlue inContext:ctx];
    [self drawKeep:self.enemyKeep image:self.imgKeepRed inContext:ctx];
    for (Troop *t in self.troops) {
        [self drawTroop:t inContext:ctx];
    }
    [self drawHUDInContext:ctx];
}

- (void)drawMapInContext:(CGContextRef)ctx {
    CGFloat ts = [self tileSize];
    for (NSInteger x = 0; x < MAP_COLS; x++) {
        for (NSInteger y = 0; y < MAP_ROWS; y++) {
            CGPoint pt = [self screenPointForGridX:x y:y];
            CGRect r = CGRectMake(pt.x, pt.y, ts, ts);
            UIImage *img = self.imgGrass;
            switch ([self.map tileTypeAtX:x y:y]) {
                case TileTypeGrass: img = self.imgGrass; break;
                case TileTypeForest: img = self.imgForest; break;
                case TileTypeWater: img = self.imgWater; break;
                case TileTypeGold: img = self.imgGold; break;
            }
            if (img) {
                [img drawInRect:r];
            } else {
                CGContextSetRGBFillColor(ctx, 0.2, 0.6, 0.2, 1.0);
                CGContextFillRect(ctx, r);
            }
        }
    }
}

- (void)drawKeep:(Keep *)keep image:(UIImage *)image inContext:(CGContextRef)ctx {
    if (keep.health <= 0) return;
    CGFloat ts = [self tileSize];
    CGPoint pt = [self screenPointForGridX:keep.gridX y:keep.gridY];
    CGRect r = CGRectMake(pt.x, pt.y, ts, ts);
    if (image) {
        [image drawInRect:r];
    }
    [self drawHealthBarAt:CGPointMake(pt.x, pt.y - 6) width:ts fraction:keep.health / keep.maxHealth inContext:ctx];
}

- (void)drawTroop:(Troop *)t inContext:(CGContextRef)ctx {
    CGFloat ts = [self tileSize];
    CGPoint pt = [self screenPointForGridX:t.gridX y:t.gridY];
    CGRect r = CGRectMake(pt.x + ts * 0.15f, pt.y + ts * 0.15f, ts * 0.7f, ts * 0.7f);

    UIImage *img = nil;
    if (t.type == TroopTypeSwordsman) {
        img = (t.team == TeamPlayer) ? self.imgSwordsmanBlue : self.imgSwordsmanRed;
    } else {
        img = (t.team == TeamPlayer) ? self.imgArcherBlue : self.imgArcherRed;
    }
    if (img) {
        [img drawInRect:r];
    }

    if (t == self.selectedTroop) {
        CGContextSetRGBStrokeColor(ctx, 1.0, 1.0, 0.0, 1.0);
        CGContextSetLineWidth(ctx, 2.0f);
        CGContextStrokeEllipseInRect(ctx, CGRectInset(r, -3, -3));
    }

    [self drawHealthBarAt:CGPointMake(pt.x, pt.y - 4) width:ts fraction:t.health / t.maxHealth inContext:ctx];
}

- (void)drawHealthBarAt:(CGPoint)origin width:(CGFloat)width fraction:(CGFloat)fraction inContext:(CGContextRef)ctx {
    if (fraction < 0) fraction = 0;
    if (fraction > 1) fraction = 1;
    CGFloat barHeight = 4.0f;
    CGContextSetRGBFillColor(ctx, 0.2, 0.0, 0.0, 1.0);
    CGContextFillRect(ctx, CGRectMake(origin.x, origin.y, width, barHeight));
    CGContextSetRGBFillColor(ctx, 0.2, 0.9, 0.2, 1.0);
    CGContextFillRect(ctx, CGRectMake(origin.x, origin.y, width * fraction, barHeight));
}

- (void)drawHUDInContext:(CGContextRef)ctx {
    CGFloat hudHeight = [self hudHeight];
    CGRect hudRect = CGRectMake(0, self.bounds.size.height - hudHeight, self.bounds.size.width, hudHeight);
    CGContextSetRGBFillColor(ctx, 0.1, 0.1, 0.1, 0.95);
    CGContextFillRect(ctx, hudRect);

    CGFloat buttonWidth = self.bounds.size.width / 2.0f;
    CGContextSetRGBFillColor(ctx, 0.15, 0.15, 0.4, 1.0);
    CGContextFillRect(ctx, CGRectMake(2, hudRect.origin.y + 2, buttonWidth - 4, hudHeight - 4));
    CGContextSetRGBFillColor(ctx, 0.4, 0.15, 0.15, 1.0);
    CGContextFillRect(ctx, CGRectMake(buttonWidth + 2, hudRect.origin.y + 2, buttonWidth - 4, hudHeight - 4));

    UIFont *labelFont = [UIFont boldSystemFontOfSize:15];
    [[UIColor whiteColor] set];
    NSString *swordLabel = [NSString stringWithFormat:@"Swordsman - %d gold", (int)kSwordsmanCost];
    NSString *archerLabel = [NSString stringWithFormat:@"Archer - %d gold", (int)kArcherCost];
    [swordLabel drawInRect:CGRectMake(8, hudRect.origin.y + hudHeight * 0.32f, buttonWidth - 16, 20) withFont:labelFont];
    [archerLabel drawInRect:CGRectMake(buttonWidth + 8, hudRect.origin.y + hudHeight * 0.32f, buttonWidth - 16, 20) withFont:labelFont];

    NSString *goldText = [NSString stringWithFormat:@"Gold: %d", (int)self.playerGold];
    [[UIColor yellowColor] set];
    [goldText drawAtPoint:CGPointMake(8, hudRect.origin.y - 20) withFont:[UIFont boldSystemFontOfSize:14]];
}

@end
