//
//  UITableViewController+Extension.h
//  A3TeamWork
//
//  Created by jeonghwan kim on 1/25/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableViewController (Extension)

@property (strong, nonatomic) UIView *topWhitePaddingView;

-(void)setupTopWhitePaddingView;
-(void)scrollViewDidScroll:(UIScrollView *)scrollView;
@end
