//
//  A3CurrencyViewController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/29/15.
//  Copyright © 2015 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface A3CurrencyViewController : UIViewController

@property (nonatomic, strong) UIBarButtonItem *historyBarButton;

- (void)enableControls:(BOOL)enable;
@end
