//
//  A3InstructionViewController.m
//  AppBox3
//
//  Created by kimjeonghwan on 6/5/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3InstructionViewController.h"
#import "A3AppDelegate+appearance.h"
#import "UIImage+imageWithColor.h"

NSString *const StoryBoardID_BatteryStatus = @"BatteryStatus";
NSString *const StoryBoardID_Calcualtor = @"Calcualtor";
@interface A3InstructionViewController () <UIAlertViewDelegate>

@end

@implementation A3InstructionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    CALayer *backgroundLayer = [CALayer layer];
//    backgroundLayer.frame = self.view.bounds;
//    backgroundLayer.backgroundColor = [[UIColor blackColor] CGColor];
//    backgroundLayer.opacity = 0.7;
//    [self.view.layer addSublayer:backgroundLayer];
    
    [self.childImageViews enumerateObjectsUsingBlock:^(UIImageView *imageView, NSUInteger idx, BOOL *stop) {
        imageView.image = [imageView.image tintedImageWithColor:[A3AppDelegate instance].themeColor];
        [self.view bringSubviewToFront:imageView];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)viewTapped:(UITapGestureRecognizer *)sender {
    BOOL isShown = [[NSUserDefaults standardUserDefaults] boolForKey:self.restorationIdentifier];
    if (isShown) {
        [self disposeInstructionView];
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"To see instrustion again, double-tap with two fingers." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:self.restorationIdentifier];
    }
}

- (void)disposeInstructionView
{
    if ([_delegate respondsToSelector:@selector(dismissInstructionViewController:)]) {
        [UIView animateWithDuration:0.3 animations:^{
            self.view.alpha = 0.0;
        } completion:^(BOOL finished) {
            [_delegate dismissInstructionViewController:self.view];
        }];
    }
}

-(void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self disposeInstructionView];
}


@end
