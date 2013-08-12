//
//  A3CurrencySelectViewController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 1/18/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CurrencySelectViewControllerDelegate <NSObject>
- (void)currencySelected:(NSString *)selectedCurrencyCode;

@optional
- (void)willDismissCurrencySelectView;

@end

@interface A3CurrencySelectViewController : UITableViewController

@property (nonatomic, weak) id<CurrencySelectViewControllerDelegate> delegate;
@property (nonatomic, copy) NSString *placeHolder;
@property (nonatomic)		BOOL allowChooseFavorite;
@property (nonatomic)		BOOL shouldPopViewController;

@end
