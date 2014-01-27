//
//  A3ClockFoldingView.h
//  A3TeamWork
//
//  Created by Sanghyun Yu on 2013. 11. 27..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBTickerView.h"

@class A3ClockInfo;

@interface A3ClockFoldingView : SBTickerView

- (void)foldingWithText:(NSString*)aText;

@end
