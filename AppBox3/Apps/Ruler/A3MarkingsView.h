//
//  A3MarkingsView.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 2015. 2. 28..
//  Copyright (c) 2015년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, A3MarkingsType) {
	A3MarkingsTypeCentimeters = 0,
	A3MarkingsTypeInches
};

typedef NS_ENUM(NSUInteger, A3MarkingsDirection) {
	A3MarkingsDirectionLeft = 0,
	A3MarkingsDirectionRight
};

typedef NS_ENUM(NSUInteger, A3MarkingsVerticalDirection) {
	A3MarkingsVerticalDirectionUp = 0,
	A3MarkingsVerticalDirectionDown
};

@interface A3MarkingsView : UIView

@property (assign) A3MarkingsType markingsType;
@property (assign) A3MarkingsDirection horizontalDirection;
@property (assign) A3MarkingsVerticalDirection verticalDirection;
@property (assign) BOOL drawPortrait;

@end
