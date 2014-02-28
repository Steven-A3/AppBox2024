//
//  A3DateCalcEditEventViewController.h
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 10. 14..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol A3DateCalcEditEventDelegate <NSObject>
@required
- (void)dismissEditEventViewController;
@end

@interface A3DateCalcEditEventViewController : UITableViewController
@property (nonatomic, weak) id<A3DateCalcEditEventDelegate> delegate;
@end
