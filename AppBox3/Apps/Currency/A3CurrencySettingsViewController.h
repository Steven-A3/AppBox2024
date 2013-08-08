//
//  A3CurrencySettingsViewController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/7/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol A3CurrencySettingsDelegate	<NSObject>

- (void)currencyConfigurationChanged;

@end

@interface A3CurrencySettingsViewController : QuickDialogController

@property (nonatomic, weak) id<A3CurrencySettingsDelegate>	delegate;

- (instancetype)initWithRoot:(QRootElement *)rootElement;
@end
