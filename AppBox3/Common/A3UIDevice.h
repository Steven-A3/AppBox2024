//
//  UIDevice+systemStatus.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/19/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

#define HOT_MENU_VIEW_WIDTH					54.0
#define A3_NORMAL_ROW_HEIGHT				44.0
#define A3_MENU_TABLE_VIEW_WIDTH			256.0
#define APP_VIEW_WIDTH_iPAD                 714.0
#define APP_VIEW_WIDTH_iPHONE				320.0
#define SIDE_VIEW_WIDTH						320.0
#define NOTIFICATION_VIEW_WIDTH				320.0
#define IPAD_SCREEN_HEIGHT_PORTRAIT			1004.0
#define IPAD_SCREEN_WIDTH_PORTRAIT			768.0
#define IPAD_SCREEN_HEIGHT_LANDSCAPE		748.0
#define IPAD_SCREEN_WIDTH_LANDSCAPE			1024.0
#define A3_APP_HEADER_BAR_HEIGHT			44.0
#define A3_APP_LANDSCAPE_FULL_WIDTH			970.0

#define kSystemStatusBarHeight				20.0
#define kSearchBarHeight					40.0
#define A3_IPAD_PORTRAIT_KEYBOARD_HEIGHT	264.0
#define	A3_IPAD_LANDSCAPE_KEYBOARD_HEIGHT	352.0

#define A3_TABLE_VIEW_ROW_HEIGHT_IPAD		58.0
#define A3_TABLE_VIEW_ROW_HEIGHT_IPHONE		44.0
#define PICKER_VIEW_HEIGHT					216.0

#define A3_TEXT_COLOR_DISABLED              [UIColor colorWithRed:194.0/255.0 green:194.0/255.0 blue:194.0/255.0 alpha:1.0]
#define A3_TEXT_COLOR_DEFAULT				[UIColor blackColor]

#define IS_IPAD    	([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define IS_IPHONE   ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
#define IS_IPHONE35 ([[UIScreen mainScreen] bounds].size.height == 480)

#define IS_LANDSCAPE	(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
#define IS_PORTRAIT		(UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]))
#define CURRENT_ORIENTATION        [[UIApplication sharedApplication] statusBarOrientation]

#define IS_RETINA	([[UIScreen mainScreen] scale] == 2)

#define	LANGUAGE_KOREAN	[[NSLocale preferredLanguages][0] isEqualToString:@"ko"]

#define APP_THEME_COLOR		[[A3AppDelegate instance].window tintColor]

@interface A3UIDevice : NSObject

+ (CGRect)screenBoundsAdjustedWithOrientation;

+ (double)memoryUsage;
+ (double)storageUsage;
+ (UIInterfaceOrientation)deviceOrientation;
+ (BOOL)deviceOrientationIsPortrait;
+ (CGFloat)applicationHeightForCurrentOrientation;

+ (CGRect)appFrame;

+ (BOOL)hasCellularNetwork;

// KJH
+ (NSString *)platform;
+ (NSString *)platformString;
#pragma mark - Methods
+ (NSString *)totalDiskSpace;
+ (NSString *)freeDiskSpace;
+ (NSString *)usedDiskSpace;

+ (NSString *)capacity;
@end
