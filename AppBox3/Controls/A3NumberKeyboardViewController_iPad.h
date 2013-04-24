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

@property (nonatomic, weak) IBOutlet UIButton *bigButton1;
@property (nonatomic, weak) IBOutlet UIButton *bigButton2;
@property (nonatomic, weak) IBOutlet A3KeyboardButton *dotButton;
@property (nonatomic, weak) IBOutlet A3KeyboardButton *deleteButton;
@property (nonatomic, weak) IBOutlet A3KeyboardButton *prevButton;
@property (nonatomic, weak) IBOutlet A3KeyboardButton *nextButton;

- (void)rotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;

@end
