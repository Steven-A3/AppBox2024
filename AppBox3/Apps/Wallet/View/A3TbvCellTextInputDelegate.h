//
//  A3TbvCellTextInputDelegate.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol A3TbvCellTextInputDelegate <NSObject>

- (void)didTextFieldBeActive:(UITextField *)textField inTableViewCell:(UITableViewCell *) cell;

@end
