//
//  A3KeyboardButton_iOS7_iPhone.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 7/25/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3KeyboardButton_iOS7.h"

@interface A3KeyboardButton_iOS7_iPhone : A3KeyboardButton_iOS7

@property (nonatomic, strong) CALayer *highlightedMarkLayer;
@property (nonatomic, strong) NSString *markInsetsString;
@property (assign) NSUInteger *identifier;

@end
