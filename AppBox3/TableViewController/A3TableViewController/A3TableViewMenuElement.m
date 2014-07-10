//
//  A3TableViewMenuElement.m
//  AppBox3
//
//  Created by A3 on 1/5/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3TableViewMenuElement.h"
#import "A3AppDelegate+passcode.h"

@implementation A3TableViewMenuElement

- (BOOL)securitySettingsIsOn {
	if (!_needSecurityCheck) return NO;
	if ([self.title isEqualToString:@"Days Counter"]) {
		return [[A3AppDelegate instance] shouldAskPasscodeForDaysCounter];
	} else if ([self.title isEqualToString:@"Ladies Calendar"]) {
		return [[A3AppDelegate instance] shouldAskPasscodeForLadyCalendar];
	} else if ([self.title isEqualToString:@"Wallet"]) {
		return [[A3AppDelegate instance] shouldAskPasscodeForWallet];
	} else if ([self.title isEqualToString:@"Settings"]) {
		return [[A3AppDelegate instance] shouldAskPasscodeForSettings];
	}
	return NO;
}

@end
