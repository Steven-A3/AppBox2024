//
//  A3TranslatorMessageViewController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/14/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TranslatorHistory;

@protocol A3TranslatorMessageViewControllerDelegate <NSObject>
@optional
- (void)translatorMessageViewControllerWillDismiss:(id)viewController;
@end

@interface A3TranslatorMessageViewController : UIViewController

@property (nonatomic, weak) id<A3TranslatorMessageViewControllerDelegate> delegate;
@property (nonatomic, copy) NSString *originalTextLanguage;
@property (nonatomic, copy) NSString *translatedTextLanguage;
@property (nonatomic, strong) TranslatorHistory *selectItem;

@end
