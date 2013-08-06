//
//  A3KeyboardProtocol.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/9/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, A3NumberKeyboardType) {
	A3NumberKeyboardTypeCurrency = 0,
	A3NumberKeyboardTypePercent,
	A3NumberKeyboardTypeMonthYear,
	A3NumberKeyboardTypeInterestRate
};

@protocol A3KeyboardDelegate <NSObject>
@optional

- (void)handleBigButton1;
- (void)handleBigButton2;
- (NSString *)stringForBigButton1;
- (NSString *)stringForBigButton2;

- (void)A3KeyboardController:(id)controller clearButtonPressedTo:(UIResponder *)keyInputDelegate;
- (void)A3KeyboardController:(id)controller doneButtonPressedTo:(UIResponder *)keyInputDelegate;

- (BOOL)prevAvailableForElement:(QEntryElement *)element;
- (BOOL)nextAvailableForElement:(QEntryElement *)element;
- (void)prevButtonPressedWithElement:(QEntryElement *)element;
- (void)nextButtonPressedWithElement:(QEntryElement *)element;


@end
