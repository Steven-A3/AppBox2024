//
//  A3TableViewEntryCell.h
//  AppBox3
//
//  Created by A3 on 10/31/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3TableViewCell.h"

@interface A3TableViewEntryCell : A3TableViewCell

@property (nonatomic, strong) UITextField *textField;

- (void)calculateTextFieldFrame;
@end
