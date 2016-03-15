//
//  A3HomeStyleMenuViewController.h
//  HexagonMenu
//
//  Created by Byeong Kwon Kwak on 2/26/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3PasscodeViewControllerProtocol.h"
#import "A3LaunchViewController.h"

@protocol A3PasscodeViewControllerDelegate;

@interface A3HomeStyleMenuViewController : A3LaunchViewController <A3PasscodeViewControllerDelegate>

@property (nonatomic, copy) NSString *selectedAppName;

- (UIView *)backgroundView;

@end
