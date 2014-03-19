//
//  A3LaunchSceneViewController.m
//  AppBox3
//
//  Created by A3 on 3/17/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3LaunchSceneViewController.h"
#import "A3LaunchViewController.h"

@interface A3LaunchSceneViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *singleButton;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (strong, nonatomic) MASConstraint *topOffsetConstraint, *leftOffsetConstraint;

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
		offset = IS_PORTRAIT ? 106 : 0;
	}
	return offset;
}

- (CGFloat)leftOffset {
	CGFloat offset;
	if (IS_IPHONE) {
		offset = 0;
	} else {
		offset = IS_LANDSCAPE ? 128 : 0;
	}
	return offset;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
	[super didMoveToParentViewController:parent];

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
	NSString *imageName;
	if (IS_IPHONE) {
		if (IS_IPHONE35) {
			imageName = @"LaunchImage-700@2x.png";
		} else {
			imageName = @"LaunchImage-700-568h@2x.png";
		}

	} else {
		if (IS_LANDSCAPE) {
			if (IS_RETINA) {
				imageName = @"LaunchImage-700-Landscape@2x~ipad.png";
			} else {
				imageName = @"LaunchImage-700-Landscape~ipad.png";
			}
		} else {
			if (IS_RETINA) {
				imageName = @"LaunchImage-700-Portrait@2x~ipad.png";
			} else {
				imageName = @"LaunchImage-700-Portrait~ipad.png";
			}
		}
	}
	FNLOG(@"%@", imageName);
	[self.imageView setImage:[UIImage imageNamed:imageName]];
	return;
}


- (IBAction)useiCloudButtonAction:(UIButton *)sender {
	[self.delegate useICloudButtonPressedInViewController:self];
}

- (IBAction)useAppBoxProAction:(UIButton *)sender {
	[self.delegate useAppBoxButtonPressedInViewController:self];
}

- (IBAction)continueButtonAction:(UIButton *)sender {
	[self.delegate continueButtonPressedInViewController:self];
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
