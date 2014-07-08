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

NSString *const A3StoryboardInstruction_iPhone = @"Instruction_iPhone";
NSString *const A3StoryboardInstruction_iPad = @"Instruction_iPad";

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
    [self disposeInstructionView];
}

- (void)disposeInstructionView
{
    if ([_delegate respondsToSelector:@selector(dismissInstructionViewController:)]) {
        if (_disableAnimation) {
            [_delegate dismissInstructionViewController:self.view];
            return;
        }

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
