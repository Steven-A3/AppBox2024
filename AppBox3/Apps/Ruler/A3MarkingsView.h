//
//  A3MarkingsView.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 2015. 2. 28..
//  Copyright (c) 2015년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, A3MarkingsType) {
	A3MarkingsCentimeters = 0,
	A3MarkingsInches
};

typedef NS_ENUM(NSUInteger, A3MarkingsDirection) {
	A3MarkingsDirectionLeft = 0,
	A3MarkingsDirectionRight
};

@interface A3MarkingsView : UIView

@property (assign) A3MarkingsType markingsType;
@property (assign) A3MarkingsDirection markingsDirection;

@end
