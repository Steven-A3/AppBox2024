//
//  A3ActionMenuViewController_iPad.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 2/8/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3ActionMenuViewController_iPad.h"
#import "A3ActionMenuViewControllerDelegate.h"
#import "common.h"

@interface A3ActionMenuViewController_iPad ()

@end

@implementation A3ActionMenuViewController_iPad

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)settingsAction {
	if ([_delegate respondsToSelector:@selector(settingsAction)]) {
		[_delegate settingsAction];
	}
}

- (IBAction)emailAction {
	if ([_delegate respondsToSelector:@selector(emailAction)]) {
		[_delegate emailAction];
	}
}

- (IBAction)messageAction {
	if ([_delegate respondsToSelector:@selector(messageAction)]) {
		[_delegate messageAction];
	}
}

- (IBAction)twitterAction {
	if ([_delegate respondsToSelector:@selector(twitterAction)]) {
		[_delegate twitterAction];
	}
}

- (IBAction)facebookAction {
	if ([_delegate respondsToSelector:@selector(facebookAction)]) {
		[_delegate facebookAction];
	}
}

- (void)setImage:(NSString *)name selector:(SEL)selector atIndex:(NSUInteger)index {
	UIImage *image = [UIImage imageNamed:name];
	NSArray *buttons = @[_button1, _button2, _button3, _button4, _button5];
	UIButton *theButton = buttons[index];

	[theButton setImage:image forState:UIControlStateNormal];

	for (NSString *actionName in [theButton actionsForTarget:_delegate forControlEvent:UIControlEventTouchUpInside]) {
		FNLOG(@"%@", actionName);
		[theButton removeTarget:_delegate action:NSSelectorFromString(actionName) forControlEvents:UIControlEventTouchUpInside];
	}
	[theButton addTarget:_delegate action:selector forControlEvents:UIControlEventTouchUpInside];
}

- (void)setText:(NSString *)text atIndex:(NSUInteger)index {
	NSArray *labels = @[_label1, _label2, _label3, _label4, _label5];
	UILabel *label = labels[index];
	label.text = text;
}

@end
