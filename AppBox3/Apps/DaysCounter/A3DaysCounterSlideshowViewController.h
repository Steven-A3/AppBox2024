//
//  A3DaysCounterSlideshowViewController.h
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 11..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class A3DaysCounterModelManager;
@interface A3DaysCounterSlideshowViewController : UIViewController<UIAlertViewDelegate>{
    NSInteger currentIndex;
    NSTimer *slideTimer;
}
@property (weak, nonatomic) A3DaysCounterModelManager *sharedManager;
@property (strong, nonatomic) NSDictionary *optionDict;
@property (strong, nonatomic) void (^completionBlock)(void);
@end
