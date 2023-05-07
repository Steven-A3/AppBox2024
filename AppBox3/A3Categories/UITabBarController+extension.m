//
//  UITabBarController+UITabBarController_extension.m
//  AppBox3
//
//  Created by BYEONG KWON KWAK on 2021/12/13.
//  Copyright © 2021 ALLABOUTAPPS. All rights reserved.
//

#import "UITabBarController+extension.h"
#import "A3UserDefaults+A3Addition.h"

@implementation UITabBarController (extension)
    
- (void)makeAppearanceCompatible {
    if (@available(iOS 15.0, *)) {
        UITabBarAppearance *appearance = [UITabBarAppearance new];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = [UIColor whiteColor];
        [self updateTabBarItemAppearance:appearance.compactInlineLayoutAppearance];
        [self updateTabBarItemAppearance:appearance.inlineLayoutAppearance];
        [self updateTabBarItemAppearance:appearance.stackedLayoutAppearance];
        
        self.tabBar.standardAppearance = appearance;
        self.tabBar.scrollEdgeAppearance = appearance;
    }
}

- (void)updateTabBarItemAppearance:(UITabBarItemAppearance *)appearance API_AVAILABLE(ios(13)) {
    appearance.selected.iconColor = [[A3UserDefaults standardUserDefaults] themeColor];
    appearance.normal.iconColor = [UIColor lightGrayColor];
}

@end
