//
//  A3NumberKeyboardViewController_iPhone.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/9/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3KeyboardProtocol.h"
#import "A3NumberKeyboardViewController.h"

@class A3KeyboardButton_iOS7_iPhone;

@interface A3NumberKeyboardViewController_iPhone : A3NumberKeyboardViewController

@property (nonatomic, weak) IBOutlet UIButton *bigButton1;
@property (nonatomic, weak) IBOutlet UIButton *bigButton2;
@property (nonatomic, weak) IBOutlet A3KeyboardButton_iOS7_iPhone *dotButton;
@property (nonatomic, weak) IBOutlet A3KeyboardButton_iOS7_iPhone *deleteButton;
@property (nonatomic, weak) IBOutlet A3KeyboardButton_iOS7_iPhone *prevButton;
@property (nonatomic, weak) IBOutlet A3KeyboardButton_iOS7_iPhone *nextButton;
@property (assign) BOOL needButtonsReload;   // kjh

@end
