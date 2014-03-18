//
//  A3DaysCounterSlideshowViewController.h
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 11..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface A3DaysCounterSlideshowViewController : UIViewController<UIAlertViewDelegate>{
    NSInteger currentIndex;
    NSTimer *slideTimer;
}

@property (strong, nonatomic) NSDictionary *optionDict;
@end
