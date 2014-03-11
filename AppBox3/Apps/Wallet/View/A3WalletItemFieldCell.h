//
//  A3WalletItemFieldCell.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 23..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3TbvCellTextInputDelegate.h"
#import "JVFloatLabeledTextField.h"

@interface A3WalletItemFieldCell : UITableViewCell

@property (assign) id<A3TbvCellTextInputDelegate> delegate;
@property (strong, nonatomic) IBOutlet JVFloatLabeledTextField *valueTextField;

@end
