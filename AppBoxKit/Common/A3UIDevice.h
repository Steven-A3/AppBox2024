//
//  UIDevice+systemStatus.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/19/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AppBoxKit/A3UIDevice.h>

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

#define A3_TEXT_COLOR_DISABLED              [UIColor colorWithRed:201.0/255.0 green:201.0/255.0 blue:201.0/255.0 alpha:1.0]
#define A3_TEXT_COLOR_DEFAULT				[UIColor blackColor]

#define IS_IOS7			([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0)
#define IS_IOS_GREATER_THAN_7	([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define IS_IOS9			([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)
#define IS_IOS10			([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0)
#define IS_LANDSCAPE	(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
#define IS_PORTRAIT		(UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]))
#define CURRENT_ORIENTATION        [[UIApplication sharedApplication] statusBarOrientation]

#define IS_IPAD    	([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define IS_IPAD_PRO	(!IS_IOS7 && [[UIScreen mainScreen] nativeBounds].size.height == 2732.0)
#define IS_IPHONE   ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
#define IS_IPHONE35 ([A3UIDevice screenBoundsAdjustedWithOrientation].size.height == 480.0)

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define IS_RETINA	([[UIScreen mainScreen] scale] >= 2)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_3_5_INCH (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)			// iPhone 4, 4s
#define IS_IPHONE_4_INCH (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)			// iPhone 5, 5s, SE
#define IS_IPHONE_4_7_INCH (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)		// iPhone 6, 7
#define IS_IPHONE_5_5_INCH (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)		// iPhone 6 Plus, 7 Plus
#define IS_IPAD_12_9_INCH (IS_IPAD && SCREEN_MAX_LENGTH == 1366.)			// iPad Pro 12.9 inch

#define	LANGUAGE_KOREAN	[[NSLocale preferredLanguages][0] hasPrefix:@"ko"]

extern NSString *const A3AnimationIDKeyboardWillShow;

@interface A3UIDevice : NSObject

+ (CGRect)screenBoundsAdjustedWithOrientation;

+ (CGFloat)scaleToOriginalDesignDimension;

+ (CGFloat)statusBarHeight;
+ (CGFloat)statusBarHeightPortrait;
+ (double)memoryUsage;
+ (double)storageUsage;
+ (UIInterfaceOrientation)deviceOrientation;
+ (BOOL)deviceOrientationIsPortrait;
+ (CGFloat)applicationHeightForCurrentOrientation;
+ (CGRect)appFrame;
+ (BOOL)hasCellularNetwork;
+ (BOOL)hasTorch;
+ (BOOL)canAccessCamera;

// KJH
+ (NSString *)platform;
+ (BOOL)canVibrate;
+ (NSString *)modelNameFromDeviceInfo:(NSDictionary *)rootDictionary;
+ (NSDictionary *)deviceInformationDictionary;
+ (NSDictionary *)remainingTimeDictionary;
+ (NSString *)platformString;
#pragma mark - Methods
+ (NSString *)totalDiskSpace;
+ (NSString *)freeDiskSpace;
+ (NSString *)usedDiskSpace;
+ (NSString *)capacity;
+ (void)verifyAndAlertMicrophoneAvailability;
+ (BOOL)shouldUseImageForPrevNextButton;
+ (BOOL)shouldSupportLunarCalendar;
+ (BOOL)useKoreanLunarCalendar;
+ (BOOL)useKoreanLunarCalendarForConversion;
+ (NSString *)systemCurrencyCode;

+ (BOOL)isLanguageLikeCJK;
@end
