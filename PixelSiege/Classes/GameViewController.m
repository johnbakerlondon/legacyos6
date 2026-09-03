#import "GameViewController.h"
#import "GameView.h"

@implementation GameViewController

- (void)loadView {
    self.view = [[GameView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // iOS 6-era status bar API (UIViewController-based status bar management
    // doesn't exist until iOS 7, so this is the correct call for our target).
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate {
    return YES;
}

@end
