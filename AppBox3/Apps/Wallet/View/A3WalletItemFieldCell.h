//
//  A3WalletItemFieldCell.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 23..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JVFloatLabeledTextField.h"

@interface A3WalletItemFieldCell : UITableViewCell

@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *valueTextField;
@property (strong, nonatomic) UIButton *deleteButton;

- (void)addDeleteButton;
@end
