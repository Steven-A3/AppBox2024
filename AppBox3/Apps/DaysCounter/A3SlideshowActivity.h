//
//  A3SlideshowActivity.h
//  A3TeamWork
//
//  Created by coanyaa on 13. 10. 19..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface A3SlideshowActivity : UIActivity
@property (strong, nonatomic) void (^completionBlock)(NSDictionary *userInfo);
@end
