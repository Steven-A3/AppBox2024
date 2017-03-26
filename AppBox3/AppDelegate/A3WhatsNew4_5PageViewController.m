//
//  A3WhatsNew4_5PageViewController.m
//  AppBox3
//
//  Created by BYEONG KWON KWAK on 3/15/17.
//  Copyright © 2017 ALLABOUTAPPS. All rights reserved.
//

#import "A3WhatsNew4_5PageViewController.h"
#import "A3WhatsNewAppScreenViewController.h"
#import "A3WhatsNewFirstPageViewController.h"

@interface A3WhatsNew4_5PageViewController () <UIPageViewControllerDelegate, UIPageViewControllerDataSource>

@end

@implementation A3WhatsNew4_5PageViewController {
    NSInteger _numberOfPages;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _numberOfPages = 3;
    self.delegate = self;
    self.dataSource = self;

    [self setViewControllers:@[[self zeroPageViewController]]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:NO
                  completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIViewController *)viewControllerAtPage:(NSInteger)page {
    switch (page) {
        case 0:
            return [self zeroPageViewController];
        case 1:
            return [self onePageViewController];
        case 2:
            return [self twoViewController];
    }
    return nil;
}

- (UIViewController *)zeroPageViewController {
    A3WhatsNewFirstPageViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Zero"];
    viewController.nextButtonAction = ^{
        [self showNextPage];
    };
    viewController.view.tag = 0;
    return viewController;
}

- (UIViewController *)onePageViewController {
    A3WhatsNewAppScreenViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"One"];
    [viewController showAbbreviationSnapshotView];
    viewController.view.tag = 1;
    viewController.nextButtonAction = ^{
        [self showNextPage];
    };
    return viewController;
}

- (UIViewController *)twoViewController {
    A3WhatsNewAppScreenViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Two"];
    [viewController showKaomojiSnapshotView];
    viewController.view.tag = 2;
    viewController.nextButtonAction = ^{
        [self showNextPage];
    };
    viewController.doneButtonAction = ^{
        _dismissBlock();
    };
    return viewController;
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSInteger currentPage = pageViewController.viewControllers[0].view.tag;
    if (currentPage > 0) {
        return [self viewControllerAtPage:currentPage - 1];
    }
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSInteger currentPage = pageViewController.viewControllers[0].view.tag;
    if (currentPage < (_numberOfPages - 1)) {
        return [self viewControllerAtPage:currentPage + 1];
    }
    return nil;
}

- (void)showNextPage {
    NSInteger currentPage = [self currentPage];
    if (currentPage < _numberOfPages - 1) {
        [self setViewControllers:@[[self viewControllerAtPage:currentPage + 1]]
                       direction:UIPageViewControllerNavigationDirectionForward
                        animated:YES
                      completion:nil];
    }
}

- (NSInteger)currentPage {
    return self.viewControllers[0].view.tag;
}

@end
