//
//  UITableViewController+Extension.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 1/25/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "UITableViewController+Extension.h"
#import <objc/runtime.h>
#import "A3DefaultColorDefines.h"

@implementation UITableViewController (Extension)

static char const *const key_topWhitePaddingView					= "key_topWhitePaddingView";

-(void)setupTopWhitePaddingView
{
    [self topWhitePaddingView];
}

-(void)setTopWhitePaddingView:(UIView *)topWhitePaddingView
{
    objc_setAssociatedObject(self, key_topWhitePaddingView, topWhitePaddingView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UIView *)topWhitePaddingView
{
	UIView *view = objc_getAssociatedObject(self, key_topWhitePaddingView);
	if (nil == view) {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.0)];
        view.backgroundColor = COLOR_HEADERVIEW_BG;
        view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
        [self.tableView addSubview:view];
        
		objc_setAssociatedObject(self, key_topWhitePaddingView, view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
    
	return view;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    UIView *view = objc_getAssociatedObject(self, key_topWhitePaddingView);
    
    if (view) {
        if (scrollView.contentOffset.y < -scrollView.contentInset.top ) {
            CGRect rect = view.frame;
            rect.origin.y = -(fabs(scrollView.contentOffset.y) - scrollView.contentInset.top);
            rect.size.height = fabs(scrollView.contentOffset.y) - scrollView.contentInset.top;
            view.frame = rect;
        } else {
            CGRect rect = view.frame;
            rect.origin.y = 0.0;
            rect.size.height = 0.0;
            view.frame = rect;
        }
    }
}

@end
