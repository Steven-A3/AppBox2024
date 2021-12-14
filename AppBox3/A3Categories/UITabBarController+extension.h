//
//  UITabBarController+UITabBarController_extension.h
//  AppBox3
//
//  Created by BYEONG KWON KWAK on 2021/12/13.
//  Copyright © 2021 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITabBarController (extension)

- (void)makeAppearanceCompatible;
- (void)updateTabBarItemAppearance:(UITabBarItemAppearance *)appearance API_AVAILABLE(ios(13));

@end

NS_ASSUME_NONNULL_END
