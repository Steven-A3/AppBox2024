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

@end

@interface A3CurrencySelectViewController : UIViewController <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) id<CurrencySelectViewControllerDelegate> delegate;

@end
