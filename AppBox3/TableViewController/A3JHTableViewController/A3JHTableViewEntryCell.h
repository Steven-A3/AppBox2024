//
//  A3JHTableViewEntryCell.h
//  AppBox3
//
//  Created by A3 on 10/31/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3JHTableViewCell.h"

@interface A3JHTableViewEntryCell : A3JHTableViewCell

@property (nonatomic, strong) UITextField *textField;

- (void)calculateTextFieldFrame;
@end
