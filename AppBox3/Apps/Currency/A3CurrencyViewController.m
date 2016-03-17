//
//  A3CurrencyViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/29/15.
//  Copyright © 2015 ALLABOUTAPPS. All rights reserved.
//

#import "A3CurrencyViewController.h"
#import "UIViewController+A3Addition.h"
#import "A3CurrencyTableViewController.h"
#import "A3CurrencyPickerStyleViewController.h"
#import "A3CurrencyDataManager.h"
#import "CurrencyHistory.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3CurrencySettingsViewController.h"
#import "UIViewController+iPad_rightSideView.h"
#import "UIViewController+MMDrawerController.h"
#import "A3CurrencyHistoryViewController.h"
#import "A3AppDelegate.h"

NSString *const A3CurrencyConverterSelectedViewIndex = @"A3CurrencyConverterSelectedViewIndex";

@interface A3CurrencyViewController () <A3CurrencySettingsDelegate>

@property (nonatomic, strong) A3CurrencyPickerStyleViewController *pickerStyleViewController;
@property (nonatomic, strong) A3CurrencyTableViewController *listStyleViewController;
@property (nonatomic, strong) A3CurrencyDataManager *dataManager;
@property (nonatomic, strong) NSArray *moreMenuButtons;
@property (nonatomic, strong) A3CurrencySettingsViewController *settingsViewController;
@property (nonatomic, strong) UINavigationController *modalNavigationController;
@property (nonatomic, strong) A3CurrencyHistoryViewController *historyViewController;

@end

@implementation A3CurrencyViewController {
	BOOL	_isShowMoreMenu;
}

- (void)viewDidLoad {
    [super viewDidLoad];

	self.automaticallyAdjustsScrollViewInsets = NO;
	self.view.backgroundColor = [UIColor whiteColor];
	
    [A3CurrencyDataManager setupFavorites];

    [self makeBackButtonEmptyArrow];
    if (IS_IPAD || IS_PORTRAIT) {
        [self leftBarButtonAppsButton];
    } else {
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.hidesBackButton = YES;
    }

    self.navigationItem.hidesBackButton = YES;

	if (IS_IPHONE) {
		[self rightButtonMoreButton];
	} else {
		self.navigationItem.hidesBackButton = YES;
		
		UIBarButtonItem *share = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"share"] style:UIBarButtonItemStylePlain target:self action:@selector(shareButtonAction:)];
		share.tag = A3RightBarButtonTagShareButton;
		UIBarButtonItem *settings = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"general"] style:UIBarButtonItemStylePlain target:self action:@selector(settingsButtonAction:)];
		settings.tag = A3RightBarButtonTagSettingsButton;
		UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
		self.historyBarButton = [self historyBarButton:[CurrencyHistory class]];
		self.historyBarButton.tag = A3RightBarButtonTagHistoryButton;
		space.width = 24.0;
		UIBarButtonItem *help = [self instructionHelpBarButton];
		help.tag = A3RightBarButtonTagHelpButton;
		self.navigationItem.rightBarButtonItems = @[settings, space, self.historyBarButton, space, share, space, help];
	}

    NSInteger selectedViewIndex = [[NSUserDefaults standardUserDefaults] integerForKey:A3CurrencyConverterSelectedViewIndex];
    [self.viewTypeSegmentedControl setSelectedSegmentIndex:selectedViewIndex];
    self.navigationItem.titleView = self.viewTypeSegmentedControl;

    [self loadSelectedViewController];

	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rightSideViewWillDismiss) name:A3NotificationRightSideViewWillDismiss object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuViewDidHide) name:A3NotificationMainMenuDidHide object:nil];
	}
}

- (void)mainMenuViewDidHide {
	[self enableControls:YES];
}

- (void)rightSideViewWillDismiss {
	[self enableControls:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UISegmentedControl *)viewTypeSegmentedControl {
    if (!_viewTypeSegmentedControl) {
        _viewTypeSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[[UIImage imageNamed:@"currency_picker"], [UIImage imageNamed:@"currency_list"] ] ];
        [_viewTypeSegmentedControl setWidth:IS_IPAD ? 150:85 forSegmentAtIndex:0];
        [_viewTypeSegmentedControl setWidth:IS_IPAD ? 150:85 forSegmentAtIndex:1];
        [_viewTypeSegmentedControl addTarget:self action:@selector(viewTypeSegmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _viewTypeSegmentedControl;
}

- (void)viewTypeSegmentedControlValueChanged:(UISegmentedControl *)control {
	if (IS_IPHONE && _isShowMoreMenu) {
		_isShowMoreMenu = NO;

		[self.view removeGestureRecognizer:[[self.view gestureRecognizers] lastObject]];
		[self rightButtonMoreButton];
		UIView *pullDownView;
		if (control.selectedSegmentIndex == 0) {
			pullDownView = _listStyleViewController.tableView;
		} else {
			pullDownView = _pickerStyleViewController.view;
		}
		[self dismissMoreMenuView:_moreMenuView pullDownView:pullDownView completion:^{
		}];
	}

	[[NSUserDefaults standardUserDefaults] setInteger:control.selectedSegmentIndex forKey:A3CurrencyConverterSelectedViewIndex];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
    [self loadSelectedViewController];
}

- (void)loadSelectedViewController {
    if (self.viewTypeSegmentedControl.selectedSegmentIndex == 0) {
        // Load picker style
        if (_listStyleViewController.parentViewController == self) {
            [_listStyleViewController.view removeFromSuperview];
            [_listStyleViewController removeFromParentViewController];
        }
        [self.view addSubview:self.pickerStyleViewController.view];
        [self addChildViewController:_pickerStyleViewController];
		
		[self.pickerStyleViewController.view remakeConstraints:^(MASConstraintMaker *make) {
			make.edges.equalTo(self.view);
		}];
    } else {
        // Load list style
        if (_pickerStyleViewController.parentViewController == self) {
            [_pickerStyleViewController.view removeFromSuperview];
            [_pickerStyleViewController removeFromParentViewController];
		}
        [self.view addSubview:self.listStyleViewController.view];
        [self addChildViewController:_listStyleViewController];

		[_listStyleViewController.view remakeConstraints:^(MASConstraintMaker *make) {
			make.edges.equalTo(self.view);
		}];
    }
}

- (A3CurrencyPickerStyleViewController *)pickerStyleViewController {
    if (!_pickerStyleViewController) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"A3CurrencyPickerStyle" bundle:nil];
		_pickerStyleViewController = [storyboard instantiateViewControllerWithIdentifier:IS_IPHONE ? @"CurrencyPickerStyle_iPhone" : @"CurrencyPickerStyle_iPad"];
        _pickerStyleViewController.currencyDataManager = self.dataManager;
		_pickerStyleViewController.mainViewController = self;
    }
    return _pickerStyleViewController;
}

- (A3CurrencyTableViewController *)listStyleViewController {
    if (!_listStyleViewController) {
        _listStyleViewController = [A3CurrencyTableViewController new];
        _listStyleViewController.currencyDataManager = self.dataManager;
		_listStyleViewController.mainViewController = self;
    }
    return _listStyleViewController;
}

- (A3CurrencyDataManager *)dataManager {
    if (!_dataManager) {
        _dataManager = [A3CurrencyDataManager new];
    }
    return _dataManager;
}

- (void)appsButtonAction:(UIBarButtonItem *)barButtonItem {
	if (self.viewTypeSegmentedControl.selectedSegmentIndex == 0) {
		[_pickerStyleViewController resetIntermediateState];
	} else {
		[_listStyleViewController resetIntermediateState];
	}

	if (IS_IPHONE) {
		if ([[A3AppDelegate instance] isMainMenuStyleList]) {
			[self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
		} else {
			UINavigationController *navigationController = [A3AppDelegate instance].currentMainNavigationController;
			[navigationController popViewControllerAnimated:YES];
			[navigationController setToolbarHidden:YES];
		}

		if ([_moreMenuView superview]) {
			[self dismissMoreMenu];
			[self rightButtonMoreButton];
		}
	} else {
		A3RootViewController_iPad *rootViewController = [[A3AppDelegate instance] rootViewController_iPad];
		[self enableControls: rootViewController.showLeftView ];
		[[[A3AppDelegate instance] rootViewController_iPad] toggleLeftMenuViewOnOff];
	}
}

#pragma mark - More Menu

- (void)moreButtonAction:(UIBarButtonItem *)button {
	if (self.viewTypeSegmentedControl.selectedSegmentIndex == 0) {
		[_pickerStyleViewController resetIntermediateState];
	} else {
		[_listStyleViewController resetIntermediateState];
	}

	[self rightBarButtonDoneButton];

	_moreMenuButtons = @[[self instructionHelpButton], self.shareButton, [self historyButton:[CurrencyHistory class] ], self.settingsButton];
	_moreMenuView = [self presentMoreMenuWithButtons:_moreMenuButtons pullDownView:[self pullDownView]];
	_isShowMoreMenu = YES;
}

- (void)doneButtonAction:(id)button {
	[self dismissMoreMenu];
}

- (void)dismissMoreMenu {
	if ( !_isShowMoreMenu || IS_IPAD ) return;
	
	[self moreMenuDismissAction:[[self.view gestureRecognizers] lastObject] ];
}

- (void)moreMenuDismissAction:(UITapGestureRecognizer *)gestureRecognizer {
	if (!_isShowMoreMenu) return;
	
	_isShowMoreMenu = NO;
	
	[self.view removeGestureRecognizer:gestureRecognizer];
	[self rightButtonMoreButton];
	[self dismissMoreMenuView:_moreMenuView pullDownView:[self pullDownView] completion:^{
	}];
}

- (UIView *)pullDownView {
	if (self.viewTypeSegmentedControl.selectedSegmentIndex == 0) {
		return _pickerStyleViewController.view;
	} else {
		return _listStyleViewController.view;
	}
}

- (void)settingsButtonAction:(UIButton *)button {
	[self dismissMoreMenu];
	
	if (self.viewTypeSegmentedControl.selectedSegmentIndex == 1) {
		[_listStyleViewController resetIntermediateState];
	}
	
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"A3CurrencySettings" bundle:nil];
	_settingsViewController = [storyboard instantiateInitialViewController];
	_settingsViewController.delegate = self;
	
	if (IS_IPHONE) {
		_modalNavigationController = [[UINavigationController alloc] initWithRootViewController:_settingsViewController];
		[self presentViewController:_modalNavigationController animated:YES completion:NULL];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsViewControllerDidDismiss) name:A3NotificationChildViewControllerDidDismiss object:_settingsViewController];
		
	} else {
		[self enableControls:NO];
		[[[A3AppDelegate instance] rootViewController_iPad] presentRightSideViewController:_settingsViewController];
	}
}

- (void)settingsViewControllerDidDismiss {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationChildViewControllerDidDismiss object:_settingsViewController];
	_settingsViewController = nil;
	_modalNavigationController = nil;
}

- (void)currencyConfigurationChanged {
	[_pickerStyleViewController.pickerView reloadAllComponents];
	[_listStyleViewController.tableView reloadData];
}

- (void)shareButtonAction:(id)sender {
	[self dismissMoreMenu];
	
	if (self.viewTypeSegmentedControl.selectedSegmentIndex == 0) {
		[_pickerStyleViewController shareButtonAction:sender];
	} else {
		[_listStyleViewController shareButtonAction:sender];
	}
}

- (void)historyButtonAction:(UIButton *)button {
	[self dismissMoreMenu];
	
	if (self.viewTypeSegmentedControl.selectedSegmentIndex == 0) {
		[_pickerStyleViewController resetIntermediateState];
	} else {
		[_listStyleViewController resetIntermediateState];
	}

	_historyViewController = [[A3CurrencyHistoryViewController alloc] initWithNibName:nil bundle:nil];
	
	if (IS_IPHONE) {
		_modalNavigationController = [[UINavigationController alloc] initWithRootViewController:_historyViewController];
		[self presentViewController:_modalNavigationController animated:YES completion:NULL];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(historyViewControllerDidDismiss) name:A3NotificationChildViewControllerDidDismiss object:_historyViewController];
	} else {
		[self enableControls:NO];
		[[[A3AppDelegate instance] rootViewController_iPad] presentRightSideViewController:_historyViewController];
	}
}

- (void)historyViewControllerDidDismiss {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationChildViewControllerDidDismiss object:_historyViewController];
	_modalNavigationController = nil;
	_historyViewController = nil;
}

- (void)enableControls:(BOOL)enable {
	if (!IS_IPAD) return;

	[self.navigationItem.leftBarButtonItem setEnabled:enable];

	if (enable) {
		[self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem *barButtonItem, NSUInteger idx, BOOL *stop) {
			switch (barButtonItem.tag) {
				case A3RightBarButtonTagHistoryButton:
					[barButtonItem setEnabled:[CurrencyHistory MR_countOfEntities] > 0];
					break;
				case A3RightBarButtonTagShareButton:
				case A3RightBarButtonTagSettingsButton:
				case A3RightBarButtonTagHelpButton:
					[barButtonItem setEnabled:YES];
					break;
			}
		}];
	} else {
		[self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem *barButtonItem, NSUInteger idx, BOOL *stop) {
			[barButtonItem setEnabled:NO];
		}];
	}
	if (self.viewTypeSegmentedControl.selectedSegmentIndex == 0) {

	} else {
		[_listStyleViewController enableControls:enable];
	}
}

- (void)instructionHelpButtonAction:(id)sender {
	[self dismissMoreMenu];
	if (self.viewTypeSegmentedControl.selectedSegmentIndex == 0) {
		[_pickerStyleViewController showInstructionView];
	} else {
		[_listStyleViewController showInstructionView];
	}
}

@end
