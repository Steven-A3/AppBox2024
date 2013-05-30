//
//  A3AttributedTextView
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 5/28/13 12:27 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface A3AttributedTextView : UIView

@property (nonatomic, strong) NSArray *texts;
@property (nonatomic, strong) NSArray *attributes;	// Array of Dictionary with key for NSTextAttribute
@property (nonatomic) CGFloat space;

@end