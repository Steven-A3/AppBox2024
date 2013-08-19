//
//  A3LanguagePickerController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/17/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class A3LanguagePickerController;
@class A3TranslatorLanguage;

@protocol A3LanguagePickerControllerDelegate <NSObject>
- (void)languagePickerController:(A3LanguagePickerController *)controller didSelectLanguage:(A3TranslatorLanguage *)language;
@end

@interface A3LanguagePickerController : UITableViewController
@property (nonatomic, weak) id<A3LanguagePickerControllerDelegate> delegate;
@property (nonatomic, strong) NSArray *languages;
@end

