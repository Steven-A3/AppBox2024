//
//  A3UnitPriceNoteCell.h
//  A3TeamWork
//
//  Created by kihyunkim on 2014. 1. 24..
//  Copyright (c) 2014년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3TbvCellTextInputDelegate.h"


@interface A3UnitPriceNoteCell : UITableViewCell

@property (assign) id<A3TbvCellTextInputDelegate> delegate;
@property (strong, nonatomic) IBOutlet UITextField *textFd;

@end
