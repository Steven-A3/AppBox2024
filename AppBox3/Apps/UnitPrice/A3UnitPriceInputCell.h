//
//  A3UnitPriceInputCell.h
//  A3TeamWork
//
//  Created by kihyunkim on 2014. 1. 23..
//  Copyright (c) 2014년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3TbvCellTextInputDelegate.h"

@interface A3UnitPriceInputCell : UITableViewCell

@property (assign) id<A3TbvCellTextInputDelegate> delegate;

@property (strong, nonatomic) IBOutlet UILabel *titleLB;
@property (strong, nonatomic) IBOutlet UITextField *textField;

@end
