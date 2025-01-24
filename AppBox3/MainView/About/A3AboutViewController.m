//
//  A3AboutViewController.m
//  AppBox3
//
//  Created by A3 on 1/18/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3AboutViewController.h"
#import "A3BasicWebViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "Reachability.h"
#import "A3LaunchViewController.h"
#import <Social/Social.h>
#import <MessageUI/MessageUI.h>
#import "UIView+SBExtras.h"
#import "FXBlurView.h"
#import "A3AppDelegate.h"
#import "A3SyncManager.h"
@import StoreKit;

@interface A3AboutViewController () <MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate>
@property (nonatomic, strong) A3LaunchViewController *whatsNewViewController;
@end

@implementation A3AboutViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	[self makeBackButtonEmptyArrow];
	if (_isLeftBarButtonAppsButton) {
		[self leftBarButtonAppsButton];
		self.navigationItem.hidesBackButton = YES;
	}

	self.tableView.separatorColor = A3UITableViewSeparatorColor;
	self.tableView.separatorInset = A3UITableViewSeparatorInset;
	if ([self.tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
		self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
	}
	if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
		self.tableView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	_whatsNewViewController = nil;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if ([self.navigationController.navigationBar isHidden]) {
		[self.navigationController setNavigationBarHidden:NO animated:NO];
	}
}

#pragma mark -- UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return [self standardHeightForHeaderInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	if (section == 2) return UITableViewAutomaticDimension;
	BOOL isLastSection = ([self.tableView numberOfSections] - 1) == section;
	return [self standardHeightForFooterIsLastSection:isLastSection];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (NSString * _Nonnull)versionInfoString {
    return [NSString stringWithFormat:@"%@(%@,%@)",
            [A3AppDelegate instance].originalAppVersion,
            [A3AppDelegate instance].removeAdsActive ? @"RemoveAds Active" : @"RemoveAds Non",
            [A3AppDelegate instance].hasAdsFreePass ? @"Subs Active" : @"Subs Non"
    ];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2 && indexPath.row == 0) {
		cell.detailTextLabel.text = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    } else if (indexPath.section == 2 && indexPath.row == 1) {
        cell.detailTextLabel.text = [self versionInfoString];
    }
}

#pragma mark -- UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	switch (indexPath.section) {
		case 0:
			[self didSelectSectionZeroAtRow:indexPath.row];
			break;
		case 1:
			[self didSelectSectionOneAtRow:indexPath.row];
			break;
		case 2:
			[self didSelectSectionTwoAtRow:indexPath.row];
			break;
	}
}

- (void)didSelectSectionZeroAtRow:(NSInteger)row {
	if (![[A3AppDelegate instance].reachability isReachable]) {
		[self alertInternetConnectionIsNotAvailable];
		return;
	}
	switch (row) {
		case 0: {
			A3BasicWebViewController *viewController = [A3BasicWebViewController new];
			viewController.url = [NSURL URLWithString:@"http://www.allaboutapps.net"];
			[self.navigationController pushViewController:viewController animated:YES];
			break;
		}
		case 1: {
            UIWindowScene *scene = (UIWindowScene *)UIApplication.sharedApplication.connectedScenes.allObjects.firstObject;
            if (scene) {
                [SKStoreReviewController requestReviewInScene:scene];
            }
			break;
		}
	}
}

- (void)openMailComposerWithSubject:(NSString *)subject withBody:(NSString *)body withRecipient:(NSString *)recipient isHTML:(BOOL)isHTML {
	MFMailComposeViewController *viewController = [[MFMailComposeViewController alloc] init];
	if (viewController) {
		viewController.mailComposeDelegate = self;

		[viewController setSubject:subject];

		// Set up recipients
		if (recipient) {
			NSArray *toRecipients = [NSArray arrayWithObject:recipient];
			[viewController setToRecipients:toRecipients];
		}
		if (body)
			[viewController setMessageBody:body isHTML:isHTML];

		[self presentViewController:viewController animated:YES completion:nil];
	}
}

- (void)didSelectSectionOneAtRow:(NSInteger)row {
	if (![[A3AppDelegate instance].reachability isReachable]) {
		[self alertInternetConnectionIsNotAvailable];
		return;
	}
	NSString *emailSubject = [NSString stringWithFormat:
			NSLocalizedString(@"AppBox Pro® V%@ Contact Support", nil),
			[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] ];

	UIDevice *currentDevice = [UIDevice currentDevice];
	NSLocale *currentLocale = [NSLocale currentLocale];
    NSString *body = [NSString stringWithFormat:@"\n\n\n\n\nModel: %@ (%@)\niOS Version: %@\n%@\nAppVersion: %@",
                      [A3UIDevice platformString], [A3UIDevice platform],
                      [currentDevice systemVersion],
                      [currentLocale displayNameForKey:NSLocaleIdentifier value:[currentLocale localeIdentifier]],
                      [self versionInfoString]
    ];
	[self openMailComposerWithSubject:emailSubject withBody:body withRecipient:@"support@allaboutapps.net" isHTML:NO ];
}

- (void)didSelectSectionTwoAtRow:(NSInteger)row {
	switch (row) {
		case 1: {
			NSURL *url;
            url = [[NSURL alloc] initWithString:@"itms-apps://itunes.com/apps/allaboutapps"];
            [[UIApplication sharedApplication] openURL:url
                                               options:@{}
                                     completionHandler:NULL];
			break;
		}
		case 2: {
            [self presentAlertWithTitle:NSLocalizedString(@"Acknowledgement", @"Acknowledgement")
                                message:NSLocalizedString(@"HOLIDAYS_ACKNOWLEDGEMENT", nil)];
			break;
		}
		case 3: {
			NSMutableString *message = [NSMutableString new];
			[message appendString:[NSString stringWithFormat:@"\n📌 %@\n\n", NSLocalizedString(A3AppName_Holidays, nil)]];
			[message appendString:[NSString stringWithFormat:@"%@\n\n", NSLocalizedString(@"DISCLAIMER_MESSAGE", nil)]];

			[message appendString:[NSString stringWithFormat:@"📌 %@\n\n", NSLocalizedString(A3AppName_LadiesCalendar, nil)]];
			[message appendString:[NSString stringWithFormat:@"%@\n\n", NSLocalizedString(@"LadyCalendarDisclaimerMsg", nil)]];

            [self presentAlertWithTitle:NSLocalizedString(@"Disclaimer", nil) message:message];
			break;
		}
	}
}

- (void)presentWebViewControllerWithURL:(NSURL *)url {
	if (![[A3AppDelegate instance].reachability isReachable]) {
		[self alertInternetConnectionIsNotAvailable];
		return;
	}
	A3BasicWebViewController *viewController = [[A3BasicWebViewController alloc] init];
	viewController.url = url;
	if (IS_IPHONE) {
		[self.navigationController pushViewController:viewController animated:YES];
	} else {
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
		[[[A3AppDelegate instance] rootViewController_iPad] presentViewController:navigationController animated:YES completion:NULL];
	}
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	[controller dismissViewControllerAnimated:YES completion:nil];
}


- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
	[controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)presentLaunchViewController {
	_whatsNewViewController = [A3LaunchViewController new];
	_whatsNewViewController.showAsWhatsNew = YES;
	[self presentViewController:_whatsNewViewController animated:YES completion:NULL];
}

@end
