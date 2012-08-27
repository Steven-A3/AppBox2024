//
//  A3CalcExpressionView.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 7/23/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum __tagA3CalcExpressionViewStyle {
	CEV_FILL_BACKGROUND = 0,
	CEV_TRANSPARENT_BACKGROUND
} CalcExpressionViewStyle;

@interface A3CalcExpressionView : UIView

@property (strong, nonatomic) NSArray *expression;
@property CalcExpressionViewStyle style;

@end
