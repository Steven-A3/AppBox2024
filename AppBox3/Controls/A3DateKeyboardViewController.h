//
//  A3DateKeyboardViewController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 2/28/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuickDialog.h"

@protocol A3DateKeyboardDelegate <NSObject>
@optional
- (void)valueChanged:(NSDate *)date cell:(QEntryTableViewCell *)cell;

@end

@interface A3DateKeyboardViewController : UIViewController

@property (nonatomic, weak)	UILabel *displayLabel;
@property (nonatomic, weak)	QEntryTableViewCell *entryTableViewCell;
@property (nonatomic, weak) id<A3DateKeyboardDelegate> delegate;

@property (nonatomic, strong)	NSDate *date;

- (void)resetToDefaultState;

- (void)rotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;
@end
