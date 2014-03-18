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
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property (weak, nonatomic) IBOutlet UIView *contentBackgroundView;

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
		self.imageView.image = [UIImage imageNamed:imageName];
	}

//	if (self.contentBackgroundView) {
//		[self.contentBackgroundView makeConstraints:^(MASConstraintMaker *make) {
//			make.left.equalTo(self.view.left);
//			make.right.equalTo(self.view.right);
//			make.top.equalTo(self.view.top);
//			make.bottom.equalTo(self.view.bottom).with.offset(-44);
//		}];
//	}
	if (self.contentView) {
		[self.contentView makeConstraints:^(MASConstraintMaker *make) {
			make.centerX.equalTo(self.view.centerX);
			make.centerY.equalTo(self.view.centerY).with.offset(-22);
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
