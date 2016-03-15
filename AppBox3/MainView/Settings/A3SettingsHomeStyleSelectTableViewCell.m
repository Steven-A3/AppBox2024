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

@interface A3SettingsHomeStyleSelectTableViewCell ()

@property (nonatomic, weak) IBOutlet UIButton *listTitleButton;
@property (nonatomic, weak) IBOutlet UIButton *hexagonTitleButton;
@property (nonatomic, weak) IBOutlet UIButton *gridTitleButton;

@end

@implementation A3SettingsHomeStyleSelectTableViewCell

- (void)awakeFromNib {
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
}

- (IBAction)hexagonButtonSelected:(id)sender {
	if (sender) {
		[[NSUserDefaults standardUserDefaults] setObject:A3SettingsMainMenuStyleHexagon forKey:kA3SettingsMainMenuStyle];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	[_tableView reloadData];
}

- (IBAction)gridButtonSelected:(id)sender {
	if (sender) {
		[[NSUserDefaults standardUserDefaults] setObject:A3SettingsMainMenuStyleIconGrid forKey:kA3SettingsMainMenuStyle];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	[_tableView reloadData];
}

- (void)setupBorderStyle:(UIButton *)button {
	button.layer.cornerRadius = 10;
	button.layer.borderWidth = 1.0;
}

- (void)reloadButtonBorderColor {
	NSArray *menuTypes = [[A3AppDelegate instance] availableMenuTypes];
	NSString *style = [[NSUserDefaults standardUserDefaults] objectForKey:kA3SettingsMainMenuStyle];
	if (!style) style = A3SettingsMainMenuStyleHexagon;
	NSInteger idx = [menuTypes indexOfObject:style];

	switch (idx) {
		case 0:
			_listTitleButton.layer.borderColor = [[A3AppDelegate instance] themeColor].CGColor;
			_hexagonTitleButton.layer.borderColor = [UIColor clearColor].CGColor;
			_gridTitleButton.layer.borderColor = [UIColor clearColor].CGColor;
			break;
		case 1:
			_listTitleButton.layer.borderColor = [UIColor clearColor].CGColor;
			_hexagonTitleButton.layer.borderColor = [[A3AppDelegate instance] themeColor].CGColor;
			_gridTitleButton.layer.borderColor = [UIColor clearColor].CGColor;
			break;
		case 2:
			_listTitleButton.layer.borderColor = [UIColor clearColor].CGColor;
			_hexagonTitleButton.layer.borderColor = [UIColor clearColor].CGColor;
			_gridTitleButton.layer.borderColor = [[A3AppDelegate instance] themeColor].CGColor;
			break;
		default:
			break;
	}
}

@end
