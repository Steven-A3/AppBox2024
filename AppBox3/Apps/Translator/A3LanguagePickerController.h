//
//  A3LanguagePickerController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/17/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3SearchViewController.h"

@interface A3LanguagePickerController : A3SearchViewController

@property (nonatomic, copy) NSArray *selectedCodes;
@property (nonatomic, copy) NSString *currentCode;
- (instancetype)initWithLanguages:(NSArray *)languages;

@end

