//
//  A3WhatsNewAppScreenViewController.h
//  AppBox3
//
//  Created by BYEONG KWON KWAK on 14/03/2017.
//  Copyright © 2017 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface A3WhatsNewAppScreenViewController : UIViewController

@property (nonatomic, copy) void(^nextButtonAction)();
@property (nonatomic, copy) void(^doneButtonAction)();
@property (nonatomic, weak) IBOutlet UIImageView *screenShotImageView;

- (void)showAbbreviationSnapshotView;
- (void)showKaomojiSnapshotView;

@end
