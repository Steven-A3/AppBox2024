//
//  A3LaunchSceneViewController.m
//  AppBox3
//
//  Created by A3 on 3/17/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3LaunchSceneViewController.h"
#import "A3LaunchViewController.h"
#import "A3AppDelegate.h"
#import "A3AppDelegate+appearance.h"

@interface A3LaunchSceneViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) MASConstraint *topOffsetConstraint, *leftOffsetConstraint;
@property (weak, nonatomic) IBOutlet UILabel *lunarLabel;
@property (weak, nonatomic) IBOutlet UIImageView *lunarImage;
@property (weak, nonatomic) IBOutlet UIView *lunarLineView;

@end

@implementation A3LaunchSceneViewController

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

	if (self.imageView) {
		[self.imageView makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(self.view.left);
			make.right.equalTo(self.view.right);
			make.top.equalTo(self.view.top);
			make.bottom.equalTo(self.view.bottom);
		}];
		[self setBackgroundImage];
	}

	if (self.contentView) {
		[self.contentView makeConstraints:^(MASConstraintMaker *make) {
			self.topOffsetConstraint = make.top.equalTo(self.contentView.superview.top).with.offset(self.topOffset);
			self.leftOffsetConstraint = make.left.equalTo(self.contentView.superview.left).with.offset(self.leftOffset);
		}];
	}
	if (self.singleButton) {
		[self.singleButton makeConstraints:^(MASConstraintMaker *make) {
			make.bottom.equalTo(self.view.bottom);
			make.height.equalTo(@44);
			make.left.equalTo(self.view.left);
			make.right.equalTo(self.view.right);
		}];
	}
	if (self.leftButton) {
		[self.leftButton makeConstraints:^(MASConstraintMaker *make) {
			make.bottom.equalTo(self.view.bottom);
			make.height.equalTo(@44);
			make.left.equalTo(self.view.left);
			make.right.equalTo(self.view.centerX).with.offset(-1);
		}];
	}
	if (self.rightButton) {
		[self.rightButton makeConstraints:^(MASConstraintMaker *make) {
			make.bottom.equalTo(self.view.bottom);
			make.height.equalTo(@44);
			make.left.equalTo(self.view.centerX).with.offset(1);
			make.right.equalTo(self.view.right);
		}];
	}

	if (_showAsWhatsNew) {
		[self.leftButton setTitle:NSLocalizedString(@"Close", @"Close") forState:UIControlStateNormal];
		[self.rightButton setTitle:NSLocalizedString(@"Continue", @"Continue") forState:UIControlStateNormal];
		FNLOG(@"%ld", (long)_sceneNumber);
	}
	
	if (self.lunarLabel && ![A3UIDevice shouldSupportLunarCalendar]) {
		[self.lunarLabel setHidden:YES];
		[self.lunarImage setHidden:YES];
		[self.lunarLineView setHidden:YES];
	}
	for (UIView *view in self.contentView.subviews) {
		for (NSLayoutConstraint *constraint in view.constraints) {
			if (constraint.firstItem == view && constraint.firstAttribute == NSLayoutAttributeHeight && constraint.constant <= 1) {
				constraint.constant = 1/[[UIScreen mainScreen] scale];
			}
		}
	}
}

- (CGFloat)topOffset {
	CGFloat offset;
	if (IS_IPHONE) {
		offset = IS_IPHONE35 ? 16 : 64;
		if (IS_IPHONE35) {
			offset = _sceneNumber == 2 ? 16 : 36;
		} else {
			offset = 64;
		}
	} else {
		offset = [UIWindow interfaceOrientationIsPortrait] ? 106 : 0;
	}
	return offset;
}

- (CGFloat)leftOffset {
	CGFloat offset;
	if (IS_IPHONE) {
		offset = 0;
	} else {
		offset = [UIWindow interfaceOrientationIsLandscape] ? 128 : 0;
	}
	return offset;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
	[super willMoveToParentViewController:parent];

	[self.view makeConstraints:^(MASConstraintMaker *make) {
		make.edges.equalTo(self.view.superview);
	}];

	[self.view.superview layoutIfNeeded];
	
	FNLOGRECT(self.imageView.frame);
}

- (void)viewWillLayoutSubviews {
	if (self.imageView) {
		[self setBackgroundImage];
	}
}

- (void)setBackgroundImage {
	NSString *imageName= [[A3AppDelegate instance] getLaunchImageNameForOrientation:[UIWindow interfaceOrientationIsPortrait]];
	[self.imageView setImage:[UIImage imageNamed:imageName]];
	return;
}

- (IBAction)useiCloudButtonAction:(UIButton *)sender {
	if (!_showAsWhatsNew) {
		[self.delegate useICloudButtonPressedInViewController:self];
	} else {
		[self.delegate continueButtonPressedInViewController:self];
	}
}

- (IBAction)useAppBoxProAction:(UIButton *)sender {
	[self.delegate useAppBoxButtonPressedInViewController:self];
}

- (IBAction)continueButtonAction:(UIButton *)sender {
	if (_showAsWhatsNew && _sceneNumber == 1) {
		[self.delegate useAppBoxButtonPressedInViewController:self];
	} else {
		[self.delegate continueButtonPressedInViewController:self];
	}
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];

	if (self.contentView) {
		self.topOffsetConstraint.with.offset(self.topOffset);
		self.leftOffsetConstraint.with.offset(self.leftOffset);
	}

	[self.view layoutIfNeeded];

	[self setBackgroundImage];

	FNLOGRECT(self.view.frame);
	FNLOGRECT(self.imageView.frame);
}

- (void)hideButtons {
	[self.singleButton setHidden:YES];
	[self.leftButton setHidden:YES];
	[self.rightButton setHidden:YES];
}

- (void)showButtons {
	[self.singleButton setHidden:NO];
	[self.leftButton setHidden:NO];
	[self.rightButton setHidden:NO];
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

@end
