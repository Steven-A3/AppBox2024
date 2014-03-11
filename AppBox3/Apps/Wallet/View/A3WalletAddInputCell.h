//
//  A3WalletAddInputCell.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 17..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3TbvCellTextInputDelegate.h"

@class JVFloatLabeledTextField;

@interface A3WalletAddInputCell : UITableViewCell

@property (strong, nonatomic) IBOutlet JVFloatLabeledTextField *textField;
@property (assign) id<A3TbvCellTextInputDelegate> delegate;

@end
