//
//  UIDevice+systemStatus.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/19/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <mach/vm_statistics.h>
#import <mach/mach_host.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "A3UIDevice.h"
#import "common.h"
#import "A3UserDefaultsKeys.h"
#import "A3UserDefaults.h"
#import "NSString+conversion.h"
#import <sys/types.h>
#import <sys/sysctl.h>
#import <AVFoundation/AVFoundation.h>

NSString *const A3AnimationIDKeyboardWillShow = @"A3AnimationIDKeyboardWillShow";

@implementation A3UIDevice

+ (CGRect)screenBoundsAdjustedWithOrientation {
	CGRect bounds = [[UIScreen mainScreen] bounds];
	#ifdef __IPHONE_8_0
	if (IS_IOS7 && IS_LANDSCAPE) {
		CGFloat width = bounds.size.width;
		bounds.size.width = bounds.size.height;
		bounds.size.height = width;
	}
	#else
	if (IS_LANDSCAPE) {
		CGFloat width = bounds.size.width;
		bounds.size.width = bounds.size.height;
		bounds.size.height = width;
	}
	#endif
	return bounds;
}

+ (CGFloat)statusBarHeight {
	CGRect frame = [[UIApplication sharedApplication] statusBarFrame];
	#ifdef __IPHONE_8_0
	if (IS_IOS7) {
		return IS_LANDSCAPE ? frame.size.width : frame.size.height;
	}
	return frame.size.height;
	#else
	return IS_LANDSCAPE ? frame.size.width : frame.size.height;
	#endif
}

+ (double)memoryUsage {
	vm_statistics_data_t	vm_stat;
	mach_msg_type_number_t	count;
	kern_return_t		error;
	error = host_statistics(mach_host_self(), HOST_VM_INFO,
			(host_info_t)&vm_stat, &count);
	double lastValidMemoryStat = 0.0;
	if (error == KERN_SUCCESS) {
		double total = (double)(vm_stat.free_count + vm_stat.wire_count + vm_stat.active_count + vm_stat.inactive_count);
		lastValidMemoryStat = (total - (double)vm_stat.free_count) / total;
	}
	return lastValidMemoryStat;
}

+ (double)storageUsage {
	NSDictionary*fileAttributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSTemporaryDirectory() error:NULL];

	return ([[fileAttributes objectForKey:NSFileSystemSize] doubleValue] - [[fileAttributes objectForKey:NSFileSystemFreeSize] doubleValue]) / [[fileAttributes objectForKey:NSFileSystemSize] doubleValue];
}

+ (UIInterfaceOrientation)deviceOrientation {
	return [[UIApplication sharedApplication] statusBarOrientation];
}

+ (BOOL)deviceOrientationIsPortrait; {
	return UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]);
}

+ (CGFloat)applicationHeightForCurrentOrientation {
	CGRect applicationFrame = [UIScreen mainScreen].applicationFrame;
	return UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]) ? applicationFrame.size.height : applicationFrame.size.width - kSystemStatusBarHeight;
}

+ (CGRect)appFrame {
	CGRect screenBounds = [[UIScreen mainScreen] bounds];
	if (![self deviceOrientationIsPortrait]) {
		CGFloat height = screenBounds.size.width;
		screenBounds.size.width = screenBounds.size.height;
		screenBounds.size.height = height;
	}
	if (IS_IPAD) {
		screenBounds.size.width = APP_VIEW_WIDTH_iPAD;
	}
	screenBounds.size.height -= 44.0 + 20.0;
	return screenBounds;
}

+ (BOOL)hasCellularNetwork {
	CTTelephonyNetworkInfo *ctInfo = [[CTTelephonyNetworkInfo alloc] init];
	CTCarrier *carrier = ctInfo.subscriberCellularProvider;
	return (carrier != nil);
}

+ (BOOL)hasTorch {
#if !TARGET_IPHONE_SIMULATOR
	for ( AVCaptureDevice *device in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] ) {
		if ( device.hasTorch ) {
			return YES;
		}
	}
#endif
    return NO;
}

+ (BOOL)canAccessCamera {
	if (IS_IOS7) return YES;
	return [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusAuthorized;
}

/////////////////
// KJH

+ (NSString *)platform {
	size_t size;
	sysctlbyname("hw.machine", NULL, &size, NULL, 0);
	char *machine = malloc(size);
	sysctlbyname("hw.machine", machine, &size, NULL, 0);
	NSString *platform = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
	free(machine);
	return platform;
}

NSString *const A3DeviceInformationFilename = @"device_information.json";
NSString *const A3DeviceInformationKey = @"deviceInformation";
NSString *const A3DeviceInformationPlatformKey = @"platform";
NSString *const A3DeviceInformationRemainingTimeKey = @"remainingTimeInfo";

+ (NSString *)dataFilePathFromBundle {
	NSArray *components = [A3DeviceInformationFilename componentsSeparatedByString:@"."];
	return [[NSBundle mainBundle] pathForResource:components[0] ofType:components[1]];
}

+ (NSString *)deviceInfoFilepath {
	NSString *dataFilePath = [A3DeviceInformationFilename pathInCachesDataDirectory];
	if (![[NSFileManager defaultManager] fileExistsAtPath:dataFilePath]) {
		return [A3UIDevice dataFilePathFromBundle];
	}
	return dataFilePath;
}

+ (NSString *)modelNameFromDeviceInfo:(NSDictionary *)rootDictionary {
	NSString *platformString = [A3UIDevice platform];
	NSDictionary *platformDatabase = rootDictionary[A3DeviceInformationPlatformKey];
	NSString *modelName = platformDatabase[platformString];
	if (!modelName) {
		NSRange range = [platformString rangeOfString:@"iPhone"];
		if (range.location != NSNotFound) {
			modelName = @"iPhone (Latest)";
		} else {
			range = [platformString rangeOfString:@"iPad"];
			if (range.location != NSNotFound) {
				modelName = @"iPad (Latest)";
			} else {
				modelName = @"iPod (Latest)";
			}
		}
	}
	return modelName;
}

+ (NSDictionary *)deviceInformationDictionary {
	NSData *rawTextData;

	NSString *dataFilePath = [A3UIDevice deviceInfoFilepath];

	rawTextData = [NSData dataWithContentsOfFile:dataFilePath];

	NSError * error;
	NSDictionary *rootDictionary = [NSJSONSerialization JSONObjectWithData:rawTextData options:NSJSONReadingMutableContainers error:&error];

	if (error) {
		rawTextData = [NSData dataWithContentsOfFile:[A3UIDevice dataFilePathFromBundle]];
		rootDictionary = [NSJSONSerialization JSONObjectWithData:rawTextData options:NSJSONReadingMutableContainers error:&error];
	}

	NSString *modelName = [A3UIDevice modelNameFromDeviceInfo:rootDictionary];
	NSDictionary * deviceInfoDatabase = rootDictionary[A3DeviceInformationKey];
	NSDictionary *deviceInfo = deviceInfoDatabase[modelName];
	return deviceInfo;
}

+ (NSDictionary *)remainingTimeDictionary {
	NSData *rawTextData;

	NSString *dataFilePath = [A3UIDevice deviceInfoFilepath];

	rawTextData = [NSData dataWithContentsOfFile:dataFilePath];

	NSError * error;
	NSDictionary *rootDictionary = [NSJSONSerialization JSONObjectWithData:rawTextData options:NSJSONReadingMutableContainers error:&error];

	if (error) {
		rawTextData = [NSData dataWithContentsOfFile:[A3UIDevice dataFilePathFromBundle]];
		rootDictionary = [NSJSONSerialization JSONObjectWithData:rawTextData options:NSJSONReadingMutableContainers error:&error];
	}
	NSString *modelName = [A3UIDevice modelNameFromDeviceInfo:rootDictionary];
	NSDictionary *remainingTimeInfoDatabase = rootDictionary[A3DeviceInformationRemainingTimeKey];
	NSDictionary *remainingTimeInfo = remainingTimeInfoDatabase[modelName];
	return remainingTimeInfo;
}

/*******************
 
 장비 모델 확인 및 목록
 - https://github.com/kluivers/model-identifiers
 - https://github.com/kluivers/model-identifiers/blob/master/model-identifiers.plist
 
 *********************/
+ (NSString *)platformString {
	NSDictionary *deviceInfo = [A3UIDevice deviceInformationDictionary];
    return deviceInfo[@"Model"];
}

/******************
https://github.com/andrealufino/ALSystemUtilities/blob/develop/ALSystemUtilities/ALSystemUtilities/ALDisk/ALDisk.m
******************/
#pragma mark - Formatter

#define MB (1024*1024)
#define GB (MB*1024)

+ (NSString *)memoryFormatter:(double)diskSpace {
    NSString *formatted;
    double bytes = 1.0 * diskSpace;
    double megabytes = bytes / MB;
    double gigabytes = bytes / GB;
    if (gigabytes >= 1.0)
        formatted = [NSString stringWithFormat:@"%.2f GB", gigabytes];
    else if (megabytes >= 1.0)
        formatted = [NSString stringWithFormat:@"%.2f MB", megabytes];
    else
        formatted = [NSString stringWithFormat:@"%.2f bytes", bytes];
    
    return formatted;
}

#pragma mark - Methods

+ (NSString *)totalDiskSpace {
    double space = [[[[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil] objectForKey:NSFileSystemSize] doubleValue];
	FNLOG(@"%f", space);
    return [[self class] memoryFormatter:space];
}

+ (NSString *)freeDiskSpace {
    double freeSpace = [[[[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil] objectForKey:NSFileSystemFreeSize] doubleValue];
	FNLOG(@"%f", freeSpace);
    return [[self class] memoryFormatter:freeSpace];
}

+ (NSString *)usedDiskSpace {
    return [[self class] memoryFormatter:[self usedDiskSpaceInBytes]];
}

+ (double)totalDiskSpaceInBytes {
    double space = [[[[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil] objectForKey:NSFileSystemSize] doubleValue];
    return space;
}

+ (double)freeDiskSpaceInBytes {
    double freeSpace = [[[[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil] objectForKey:NSFileSystemFreeSize] doubleValue];
    return freeSpace;
}

+ (double)usedDiskSpaceInBytes {
    double usedSpace = [self totalDiskSpaceInBytes] - [self freeDiskSpaceInBytes];
    return usedSpace;
}

+ (NSString *)capacity {
	double space = [[[[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil] objectForKey:NSFileSystemSize] doubleValue];
	if (space > 64.0 * 1024 * 1024 * 1024) {
		return @"128GB";
	} else if (space > 32.0 * 1024 * 1024 * 1024) {
		return @"64GB";
	} else if (space > 16.0 * 1024 * 1024 * 1024) {
		return @"32GB";
	} else if (space > 8.0 * 1024 * 1024 * 1024) {
		return @"16GB";
	}
	return @"8GB";
}

+ (void)verifyAndAlertMicrophoneAvailability {
	AVCaptureDevice *audioDevice;
	NSArray *audioDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio];
	if ([audioDevices count])
		audioDevice = [audioDevices objectAtIndex:0];  // use the first audio device
	if (audioDevice) {
		NSError *error;
		AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
		if (!deviceInput) {
			dispatch_async(dispatch_get_main_queue(), ^{
				NSString *message = [NSString stringWithFormat:NSLocalizedString(@"microphone access denied", @"microphone access denied"), [[UIDevice currentDevice] model ] ];
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert") message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
				[alertView show];
			});
		}
	}
}

+ (BOOL)shouldUseImageForPrevNextButton {
	if (IS_IPAD) return NO;
	NSString *languageCode = [NSLocale preferredLanguages][0];
	NSArray *languagesNotUsingImage = @[@"en", @"kr", @"zh-Hans", @"zh-Hant"];
	return [languagesNotUsingImage indexOfObject:languageCode] == NSNotFound;
}

+ (BOOL)shouldSupportLunarCalendar {
	// Language 가 한글 혹은 중국어인 경우
	NSArray *languageCodes = @[@"ko", @"zh-hans", @"zh-hant"];
	if ([languageCodes indexOfObject:[NSLocale preferredLanguages][0]] != NSNotFound) return YES;

	NSLocale *currentLocale = [NSLocale currentLocale];
	NSArray *countryCodes = @[@"KR", @"TW", @"CN", @"HK", @"MO", @"SG"];
	return [countryCodes indexOfObject:[currentLocale objectForKey:NSLocaleCountryCode]] != NSNotFound;
}

+ (BOOL)useKoreanLunarCalendar {
	return [[NSLocale preferredLanguages][0] isEqualToString:@"ko"] || [[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode] isEqualToString:@"KR"];
}

+ (BOOL)useKoreanLunarCalendarForConversion {
	NSNumber *setting = [[A3UserDefaults standardUserDefaults] objectForKey:A3SettingsUseKoreanCalendarForLunarConversion];
	if (setting) {
		return [setting boolValue];
	}
	return [A3UIDevice useKoreanLunarCalendar];
}

+ (NSString *)systemCurrencyCode {
	NSString *systemCurrencyCode = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencyCode];
	if (!systemCurrencyCode) {
		systemCurrencyCode = @"USD";
	}
	return systemCurrencyCode;
}

@end
