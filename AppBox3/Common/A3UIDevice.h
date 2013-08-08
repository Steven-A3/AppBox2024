//
//  UIDevice+systemStatus.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/19/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

#define IS_IPAD    	([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define IS_IPHONE   ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)

@interface A3UIDevice : NSObject

+ (double)memoryUsage;
+ (double)storageUsage;
+ (UIInterfaceOrientation)deviceOrientation;
+ (BOOL)deviceOrientationIsPortrait;
+ (CGFloat)applicationHeightForCurrentOrientation;

+ (CGRect)appFrame;

+ (BOOL)hasCellularNetwork;
@end
