//
//  A3TickerScrollView.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/18/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol A3TickerScrollViewDelegate <NSObject>

- (void)userTouch;
- (void)userDrag;
- (void)userEndTouch;

@end

@interface A3TickerScrollView : UIScrollView

@property (nonatomic, weak)	id <A3TickerScrollViewDelegate> touchDelegate;

@end
