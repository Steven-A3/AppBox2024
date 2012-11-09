//
//  UIDevice+systemStatus.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/19/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface A3UIDevice : NSObject

+ (double)memoryUsage;
+ (double)storageUsage;
+ (BOOL)deviceOrientationIsPortrait;

@end
