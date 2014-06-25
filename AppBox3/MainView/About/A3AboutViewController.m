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

@interface A3AboutViewController () <MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate>
@property (nonatomic, strong) A3LaunchViewController *whatsNewViewController;
@end

@implementation A3AboutViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	[self makeBackButtonEmptyArrow];
	[self leftBarButtonAppsButton];
	self.navigationItem.hidesBackButton = YES;

	self.tableView.separatorColor = A3UITableViewSeparatorColor;
	self.tableView.separatorInset = A3UITableViewSeparatorInset;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	_whatsNewViewController = nil;
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
	if (indexPath.section == 0 && indexPath.row == 3 && ![MFMessageComposeViewController canSendText]) return 0;
	return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0 && indexPath.row == 3 && ![MFMessageComposeViewController canSendText]) {
		cell.accessoryType = UITableViewCellAccessoryNone;
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
			NSURL *twitterURL = [NSURL URLWithString:@"twitter://user?screen_name=AppBox_Pro"];
			if (![[UIApplication sharedApplication] canOpenURL:twitterURL]) {
				twitterURL = [NSURL URLWithString:@"https://twitter.com/AppBox_Pro"];
			}
			[[UIApplication sharedApplication] openURL:twitterURL];
			break;
		}
		case 2: {
			NSURL *facebookURL = [NSURL URLWithString:@"fb://profile/131703690193422"];
			if (![[UIApplication sharedApplication] canOpenURL:facebookURL])	{
				facebookURL = [NSURL URLWithString:@"http://www.facebook.com/AllaboutappsFan"];
			}
			[[UIApplication sharedApplication] openURL:facebookURL];
			break;
		}
		case 3: {
			MFMessageComposeViewController *viewController = [[MFMessageComposeViewController alloc] init];
			if (viewController) {
				viewController.messageComposeDelegate = self;
				NSString *messageBody = NSLocalizedString(@"tellafriend", nil);
				messageBody = [messageBody stringByAppendingString:@"\n\nhttps://itunes.apple.com/app/id318404385"];
				[viewController setBody:messageBody];

				[self presentViewController:viewController animated:YES completion:nil];
			}
			break;
		}
		case 4: {
			NSString *messageBody = NSLocalizedString(@"tellafriend", nil);
			messageBody = [messageBody stringByAppendingString:@"\n\nhttps://itunes.apple.com/app/id318404385"];
			[self openMailComposerWithSubject:NSLocalizedString(@"A friend has recommended AppBox Pro™ from the iTunes App Store", @"")
									 withBody:messageBody
								withRecipient:nil];
			break;
		}
		case 5: {
			NSString *review_url = @"itms-apps://userpub.itunes.apple.com/WebObjects/MZUserPublishing.woa/wa/addUserReview?id=318404385";
			NSURL *url = [[NSURL alloc] initWithString:review_url];
			[[UIApplication sharedApplication] openURL:url];
			break;
		}
		case 6: {
			NSURL *url = [[NSURL alloc] initWithString:@"itms-apps://itunes.apple.com/artist/allaboutapps/id307094026"];
			[[UIApplication sharedApplication] openURL:url];
			break;
		}
	}
}

- (void)openMailComposerWithSubject:(NSString *)subject withBody:(NSString *)body withRecipient:(NSString *)recipient {
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
			[viewController setMessageBody:body isHTML:NO];

		[self presentViewController:viewController animated:YES completion:nil];
	}
}

- (void)didSelectSectionOneAtRow:(NSInteger)row {
	if (![[A3AppDelegate instance].reachability isReachable]) {
		[self alertInternetConnectionIsNotAvailable];
		return;
	}
	NSString *emailSubject = [NSString stringWithFormat:
			NSLocalizedString(@"AppBox Pro™ V%@ Contact Support", nil),
			[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] ];

	UIDevice *currentDevice = [UIDevice currentDevice];
	NSLocale *currentLocale = [NSLocale currentLocale];
	NSString *body = [NSString stringWithFormat:@"\n\n\n\n\nModel: %@ (%@)\niOS Version: %@\n%@\n",
					[A3UIDevice platformString], [A3UIDevice platform],
					[currentDevice systemVersion],
					[currentLocale displayNameForKey:NSLocaleIdentifier value:[currentLocale localeIdentifier]]];
	[self openMailComposerWithSubject:emailSubject
							 withBody:body
						withRecipient:@"support@allaboutapps.net"];
}

- (void)didSelectSectionTwoAtRow:(NSInteger)row {
	switch (row) {
		case 1:{
			[self presentLaunchViewController];
			break;
		}

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
