//
//  A3CurrencySettingsViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/7/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3CurrencySettingsViewController.h"
#import "Reachability.h"
#import "NSUserDefaults+A3Defaults.h"
#import "A3UIDevice.h"

@interface A3CurrencySettingsViewController ()

@end

@implementation A3CurrencySettingsViewController

- (instancetype)initWithRoot:(QRootElement *)rootElement {
	self = [super initWithRoot:rootElement];
	if (self) {
		QRootElement *root = [[QRootElement alloc] init];
		root.title = @"Settings";
		root.grouped = YES;
		QSection *section1 = [[QSection alloc] init];

		BOOL value = [[NSUserDefaults standardUserDefaults] currencyAutoUpdate];
		QBooleanElement *autoUpdate;
		autoUpdate = [[QBooleanElement alloc] initWithTitle:@"Auto Update" BoolValue:value];
		autoUpdate.controllerAction = NSStringFromSelector(@selector(onAutoUpdate:));
		[section1 addElement:autoUpdate];
		[root addSection:section1];

		if ([A3UIDevice hasCellularNetwork]) {
			QSection *section2 = [[QSection alloc] init];
			value = [[NSUserDefaults standardUserDefaults] currencyUseCellularData];
			QBooleanElement *useCellular = [[QBooleanElement alloc] initWithTitle:@"Use Cellular Data" BoolValue:value];
			useCellular.controllerAction = NSStringFromSelector(@selector(onUseCellular:));
			[section2 addElement:useCellular];
			[root addSection:section2];
		}

		QSection *section3 = [[QSection alloc] init];
		value = [[NSUserDefaults standardUserDefaults] currencyShowNationalFlag];
		QBooleanElement *flag = [[QBooleanElement alloc] initWithTitle:@"National Flag" BoolValue:value];
		flag.controllerAction = NSStringFromSelector(@selector(onShowNationalFlag:));
		[section3 addElement:flag];
		[root addSection:section3];

		self.root = root;
	}

	return self;
}

- (void)callDelegate {
	id <A3CurrencySettingsDelegate> o = self.delegate;
	if ([o respondsToSelector:@selector(currencyConfigurationChanged)]) {
		[o currencyConfigurationChanged];
	}
}

- (void)onAutoUpdate:(QBooleanElement *)element {
	[[NSUserDefaults standardUserDefaults] setCurrencyAutoUpdate:element.boolValue];
}

- (void)onUseCellular:(QBooleanElement *)element {
	[[NSUserDefaults standardUserDefaults] setCurrencyUseCellularData:element.boolValue];
}

- (void)onShowNationalFlag:(QBooleanElement *)element {
	[[NSUserDefaults standardUserDefaults] setCurrencyShowNationalFlag:element.boolValue];
	[self callDelegate];
}

@end
