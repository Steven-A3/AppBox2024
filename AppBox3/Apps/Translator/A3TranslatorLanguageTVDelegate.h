//
//  A3TranslatorLanguageTVDelegate.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/17/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class A3TranslatorLanguage;

@protocol A3TranslatorLanguageTVDelegateDelegate <NSObject>
- (void)tableView:(UITableView *)tableView didSelectLanguage:(A3TranslatorLanguage *)language;
@end

@interface A3TranslatorLanguageTVDelegate : NSObject<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)	NSArray *languages;
@property (nonatomic, weak) id<A3TranslatorLanguageTVDelegateDelegate>	delegate;

@end
