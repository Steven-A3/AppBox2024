//
//  A3QuickDialogController
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/19/13 12:56 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface A3QuickDialogController : QuickDialogController

@property (nonatomic, weak) QEntryElement *editingElement;
@property (nonatomic, strong) NSNumberFormatter *currencyNumberFormatter, *percentNumberFormatter;
@property (nonatomic, strong) NSString *defaultCurrencyCode;

- (A3QuickDialogController *)initWithRoot:(QRootElement *)rootElement;
- (void)registerForKeyboardNotifications;

@end