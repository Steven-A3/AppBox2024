//
//  A3NumberKeyboardViewController_iPad.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 12/21/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuickDialog.h"
#import "A3KeyboardButton.h"
#import "A3KeyboardProtocol.h"
#import "A3NumberKeyboardViewController.h"

@interface A3NumberKeyboardViewController_iPad : A3NumberKeyboardViewController

@property (nonatomic, strong) IBOutlet A3KeyboardButton *bigButton1;
@property (nonatomic, strong) IBOutlet A3KeyboardButton *bigButton2;
@property (nonatomic, strong) IBOutlet A3KeyboardButton *dotButton;
@property (nonatomic, strong) IBOutlet A3KeyboardButton *deleteButton;
@property (nonatomic, strong) IBOutlet A3KeyboardButton *prevButton;
@property (nonatomic, strong) IBOutlet A3KeyboardButton *nextButton;

- (void)rotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;

@end
