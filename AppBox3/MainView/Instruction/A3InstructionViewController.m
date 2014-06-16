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
    _isFirstInstruction = ![[NSUserDefaults standardUserDefaults] boolForKey:self.restorationIdentifier];
    
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

- (IBAction)viewTapped:(UITapGestureRecognizer *)sender {
    BOOL isShown = [[NSUserDefaults standardUserDefaults] boolForKey:self.restorationIdentifier];
    if (isShown) {
        [self disposeInstructionView];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:self.restorationIdentifier];
        
        if ([self.restorationIdentifier isEqualToString:@"Clock1"] || [self.restorationIdentifier isEqualToString:@"Clock2"]) {
            if (![[NSUserDefaults standardUserDefaults] boolForKey:@"Clock1"] || ![[NSUserDefaults standardUserDefaults] boolForKey:@"Clock2"]) {
                return;
            }
        }
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
															message:NSLocalizedString(@"To see instrustion again, double-tap with two fingers.", @"To see instrustion again, double-tap with two fingers.")
														   delegate:self
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil, nil];
        [alertView show];
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
