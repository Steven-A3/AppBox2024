//
//  A3WalletItemFieldCell.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 23..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JVFloatLabeledTextField.h"

@class WalletFieldItem;
@class WalletField;

@interface A3WalletItemFieldCell : UITableViewCell

@property (nonatomic, weak) WalletFieldItem *fieldItem;
@property (nonatomic, copy) NSString *fieldStyle;
@property (nonatomic, weak) IBOutlet JVFloatLabeledTextField *valueTextField;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UIButton *showHideButton;
@property (nonatomic, weak) NSMutableDictionary *fieldStyleStatus;

- (void)addDeleteButton;

- (void)addShowHideButton;
@end
