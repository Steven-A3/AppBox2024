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

	NSArray *menuTypes = [[A3AppDelegate instance] availableMenuTypes];
	NSString *style = [[NSUserDefaults standardUserDefaults] objectForKey:kA3SettingsMainMenuStyle];
	NSInteger idx = [menuTypes indexOfObject:style];
	switch (idx) {
		case 0:
			[self listButtonSelected:nil];
			break;
		case 1:
			[self hexagonButtonSelected:nil];
			break;
		case 2:
			[self gridButtonSelected:nil];
			break;
		default:
			[self hexagonButtonSelected:nil];
			break;
	}
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)listButtonSelected:(id)sender {
	_listTitleButton.layer.borderColor = [[A3AppDelegate instance] themeColor].CGColor;
	_hexagonTitleButton.layer.borderColor = [UIColor clearColor].CGColor;
	_gridTitleButton.layer.borderColor = [UIColor clearColor].CGColor;

	if (sender) {
		[[NSUserDefaults standardUserDefaults] setObject:A3SettingsMainMenuStyleTable forKey:kA3SettingsMainMenuStyle];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	[_tableView reloadData];
}

- (IBAction)hexagonButtonSelected:(id)sender {
	_listTitleButton.layer.borderColor = [UIColor clearColor].CGColor;
	_hexagonTitleButton.layer.borderColor = [[A3AppDelegate instance] themeColor].CGColor;
	_gridTitleButton.layer.borderColor = [UIColor clearColor].CGColor;

	if (sender) {
		[[NSUserDefaults standardUserDefaults] setObject:A3SettingsMainMenuStyleHexagon forKey:kA3SettingsMainMenuStyle];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	[_tableView reloadData];
}

- (IBAction)gridButtonSelected:(id)sender {
	_listTitleButton.layer.borderColor = [UIColor clearColor].CGColor;
	_hexagonTitleButton.layer.borderColor = [UIColor clearColor].CGColor;
	_gridTitleButton.layer.borderColor = [[A3AppDelegate instance] themeColor].CGColor;

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

@end
