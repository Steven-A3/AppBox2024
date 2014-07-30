//
//  A3OverlapedCircleView.h
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 10. 26..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3DefaultColorDefines.h"

typedef NS_ENUM(NSInteger, CenterColorType) {
    CenterColorType_Positive = 0,
    CenterColorType_Negative,
    CenterColorType_Neutral
};

@interface A3OverlappedCircleView : UIView

@property (assign, nonatomic) CenterColorType centerColorType;
@property (assign, nonatomic) BOOL focused;

@property (nonatomic, strong) UIColor *centerColor;

@end
