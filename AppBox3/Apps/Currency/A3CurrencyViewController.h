//
//  A3CurrencyViewController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/29/15.
//  Copyright © 2015 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface A3CurrencyViewController : UIViewController

@property (nonatomic, strong) UISegmentedControl *viewTypeSegmentedControl;
@property (nonatomic, strong) UIBarButtonItem *historyBarButton;
@property (nonatomic, strong) UIView *moreMenuView;

- (void)dismissMoreMenu;
- (void)enableControls:(BOOL)enable;

@end
