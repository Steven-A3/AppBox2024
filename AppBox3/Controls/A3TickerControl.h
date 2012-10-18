//
//  A3TickerControl.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/18/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3TickerScrollView.h"

@interface A3TickerControl : UIControl
<UIScrollViewDelegate, A3TickerScrollViewDelegate>

@property (nonatomic, strong) NSArray *marqueeItems;	// Array of views

- (void)startAnimation;

@end
