//
//  A3NumberKeyboardViewController_iPhone.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/9/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3KeyboardProtocol.h"

@class A3KeyboardButton_iPhone;

@interface A3NumberKeyboardViewController_iPhone : UIViewController

@property (nonatomic, weak) UIResponder<UIKeyInput> *keyInputDelegate;		// TextField, TextView, ... responder
@property (nonatomic, weak) QEntryTableViewCell *entryTableViewCell;		// Handling Prev, Next button
@property (nonatomic, weak) QEntryElement *element;
@property (nonatomic) 		A3NumberKeyboardType keyboardType;
@property (nonatomic, strong) NSString *currencySymbol;
@property (nonatomic, strong) NSString *currencyCode;
@property (nonatomic, weak) id<A3NumberKeyboardDelegate> delegate;			// Handle big button one and two

@property (nonatomic, weak) IBOutlet A3KeyboardButton_iPhone *bigButton1;
@property (nonatomic, weak) IBOutlet A3KeyboardButton_iPhone *bigButton2;
@property (nonatomic, weak) IBOutlet A3KeyboardButton_iPhone *dotButton;
@property (nonatomic, weak) IBOutlet A3KeyboardButton_iPhone *deleteButton;
@property (nonatomic, weak) IBOutlet A3KeyboardButton_iPhone *prevButton;
@property (nonatomic, weak) IBOutlet A3KeyboardButton_iPhone *nextButton;

- (void)reloadPrevNextButtons;

@end
