//
//  A3BackgroundWithPatternView.h
//  AppBox3
//
//  Created by A3 on 11/29/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

typedef NS_ENUM(NSUInteger, A3BackgroundPatternStyle) {
	A3BackgroundPatternStyleLight,
	A3BackgroundPatternStyleDark
};

@interface A3BackgroundWithPatternView : UIView

@property (nonatomic, assign) A3BackgroundPatternStyle style;

- (instancetype)initWithStyle:(A3BackgroundPatternStyle)style;
@end
