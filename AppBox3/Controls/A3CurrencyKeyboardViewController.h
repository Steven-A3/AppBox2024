//
//  A3CurrencyKeyboardViewController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 12/21/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuickDialog.h"

typedef NS_ENUM(NSInteger, A3CurrencyKeyboardType) {
	A3CurrencyKeyboardTypeCurrency = 0,
	A3CurrencyKeyboardTypePercent
};

@interface A3CurrencyKeyboardViewController : UIViewController

@property (nonatomic, weak) UIResponder<UIKeyInput> *keyInputDelegate;
@property (nonatomic, weak) QEntryTableViewCell *entryTableViewCell;
@property (nonatomic) 		A3CurrencyKeyboardType keyboardType;
@property (nonatomic, strong) NSString *currencySymbol;
@property (nonatomic, strong) NSString *currencyCode;

@end
