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

/**
 *  암호를 물어봐야 하는 앱을 선택했을때, 암호를 물어보며, 현재 암호를 물어본 앱이 무엇인지를 저장해 둔다.
 */
@property (nonatomic, copy) NSString *selectedAppName;

/**
 *  현재 실행되고 있는 앱의 이름을 저장한다.
 *  Home으로 돌아온 경우에는 반드시 초기화가 되어야 한다.
 */
@property (nonatomic, copy) NSString *activeAppName;

- (UIView *)backgroundView;

@end
