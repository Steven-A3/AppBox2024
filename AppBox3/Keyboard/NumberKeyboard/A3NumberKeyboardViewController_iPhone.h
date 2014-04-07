//
//  A3NumberKeyboardViewController_iPhone.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/9/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3KeyboardDelegate.h"
#import "A3NumberKeyboardViewController.h"

@class A3KeyboardButton_iOS7_iPhone;

@interface A3NumberKeyboardViewController_iPhone : A3NumberKeyboardViewController

@property (nonatomic, weak) IBOutlet UIButton *dotButton;
@property (nonatomic, weak) IBOutlet UIButton *deleteButton;
@property (nonatomic, weak) IBOutlet UIButton *prevButton;
@property (nonatomic, weak) IBOutlet UIButton *nextButton;
@property (nonatomic, weak) IBOutlet UIButton *clearButton;
@property (assign) BOOL needButtonsReload;   // kjh

@end
