//
//  A3SettingsHomeStyleSelectTableViewCell.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 3/9/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import "A3SettingsHomeStyleSelectTableViewCell.h"
#import "A3UserDefaultsKeys.h"
#import "A3AppDelegate.h"
#import "A3UserDefaults+A3Addition.h"

@interface A3SettingsHomeStyleSelectTableViewCell ()

@property (nonatomic, weak) IBOutlet UIButton *listTitleButton;
@property (nonatomic, weak) IBOutlet UIButton *hexagonTitleButton;
@property (nonatomic, weak) IBOutlet UIButton *gridTitleButton;

@end

@implementation A3SettingsHomeStyleSelectTableViewCell

- (void)awakeFromNib {
	[super awakeFromNib];
	
    // Initialization code
	[self setupBorderStyle:_listTitleButton];
	[self setupBorderStyle:_hexagonTitleButton];
	[self setupBorderStyle:_gridTitleButton];

	[self reloadButtonBorderColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)listButtonSelected:(id)sender {
	if (sender) {
		[[NSUserDefaults standardUserDefaults] setObject:A3SettingsMainMenuStyleTable forKey:kA3SettingsMainMenuStyle];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	[_tableView reloadData];
	[_tableView scrollRectToVisible:self.frame animated:YES];
}

- (IBAction)hexagonButtonSelected:(id)sender {
	if (sender) {
		[[NSUserDefaults standardUserDefaults] setObject:A3SettingsMainMenuStyleHexagon forKey:kA3SettingsMainMenuStyle];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	[_tableView reloadData];
	[_tableView scrollRectToVisible:self.frame animated:YES];
}

- (IBAction)gridButtonSelected:(id)sender {
	if (sender) {
		[[NSUserDefaults standardUserDefaults] setObject:A3SettingsMainMenuStyleIconGrid forKey:kA3SettingsMainMenuStyle];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	[_tableView reloadData];
	[_tableView scrollRectToVisible:self.frame animated:YES];
}

- (void)setupBorderStyle:(UIButton *)button {
	button.layer.cornerRadius = 10;
	button.layer.borderWidth = 1.0;
}

- (void)reloadButtonBorderColor {
	NSArray *menuTypes = [[A3AppDelegate instance] availableMenuTypes];
	NSString *style = [[NSUserDefaults standardUserDefaults] objectForKey:kA3SettingsMainMenuStyle];
	NSInteger idx = [menuTypes indexOfObject:style];

    UIColor *themeColor = [[A3UserDefaults standardUserDefaults] themeColor];
	switch (idx) {
		case 0:
			_listTitleButton.layer.borderColor = themeColor.CGColor;
			_hexagonTitleButton.layer.borderColor = [UIColor clearColor].CGColor;
			_gridTitleButton.layer.borderColor = [UIColor clearColor].CGColor;
			break;
		case 1:
			_listTitleButton.layer.borderColor = [UIColor clearColor].CGColor;
			_hexagonTitleButton.layer.borderColor = themeColor.CGColor;
			_gridTitleButton.layer.borderColor = [UIColor clearColor].CGColor;
			break;
		case 2:
			_listTitleButton.layer.borderColor = [UIColor clearColor].CGColor;
			_hexagonTitleButton.layer.borderColor = [UIColor clearColor].CGColor;
			_gridTitleButton.layer.borderColor = themeColor.CGColor;
			break;
		default:
			break;
	}
}

@end
