//
//  A3OverlapedCircleView.h
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 10. 26..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3DefaultColorDefines.h"
// 정중앙 컬러
//#define COLOR_POSITIVE  [UIColor colorWithRed:76.0/255.0 green:217.0/255.0 blue:100.0/255.0 alpha:1.0]
//#define COLOR_NEGATIVE  [UIColor colorWithRed:255.0 green:45.0/255.0 blue:85.0/255.0 alpha:1.0]

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
