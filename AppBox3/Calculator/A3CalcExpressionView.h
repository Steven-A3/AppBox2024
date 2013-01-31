//
//  A3CalcExpressionView.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 7/23/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, CalcExpressionViewStyle) {
	CEV_FILL_BACKGROUND = 0,
	CEV_TRANSPARENT_BACKGROUND
};

#define A3ExpressionAttributeFont		@"A3ExpressionAttributeFont"
#define A3ExpressionAttributeTextColor	@"A3ExpressionAttributeTextColor"

@interface A3CalcExpressionView : UIView

@property (nonatomic, strong) NSArray *expression;
@property (nonatomic, strong) NSArray *attributes;		// It's count must match with expression count.
@property CalcExpressionViewStyle style;

@end
