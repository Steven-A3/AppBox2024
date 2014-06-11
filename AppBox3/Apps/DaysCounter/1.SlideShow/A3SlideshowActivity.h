//
//  A3SlideshowActivity.h
//  A3TeamWork
//
//  Created by coanyaa on 13. 10. 19..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
@class A3DaysCounterModelManager;
@interface A3SlideshowActivity : UIActivity
@property (weak, nonatomic) A3DaysCounterModelManager *sharedManager;
@property (strong, nonatomic) void (^completionBlock)(NSDictionary *userInfo, UIActivity *activity);
@end
