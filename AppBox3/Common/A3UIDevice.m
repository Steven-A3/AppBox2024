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
#import <sys/types.h>
#import <sys/sysctl.h>
#import <AVFoundation/AVFoundation.h>

NSString *const A3AnimationIDKeyboardWillShow = @"A3AnimationIDKeyboardWillShow";

@implementation A3UIDevice

+ (CGRect)screenBoundsAdjustedWithOrientation {
	CGRect bounds = [[UIScreen mainScreen] bounds];
	FNLOGRECT(bounds);
	if (IS_LANDSCAPE) {
		CGFloat width = bounds.size.width;
		bounds.size.width = bounds.size.height;
		bounds.size.height = width;
	}
	return bounds;
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

/*******************
 
 장비 모델 확인 및 목록
 - https://github.com/kluivers/model-identifiers
 - https://github.com/kluivers/model-identifiers/blob/master/model-identifiers.plist
 
 *********************/
+ (NSString *)platformString {
	NSString *platform = [self platform];
	if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 1G";
	if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
	if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
    
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4";        // "iPhone4 GSM";
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4";        // "iPhone4 GSM Rev A";
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4";        // "iPhone4 CDMA"
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4s";       // "iPhone4S GSM+CDMA"
    
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5";          // "iPhone5 GSM"
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5";          // "iPhone5 GSM+CDMA"
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c";       // GSM
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c";       // Global
//    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c";       // Global
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s";       // GSM
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s";       // Global

	if ([platform isEqualToString:@"i386"])   return @"iPhone Simulator";
    if ([platform isEqualToString:@"x86_64"])   return @"iPhone Simulator";
    
	if ([platform isEqualToString:@"iPod1,1"])   return @"iPod Touch 1G";
	if ([platform isEqualToString:@"iPod2,1"])   return @"iPod Touch 2G";
	if ([platform isEqualToString:@"iPod3,1"])   return @"iPod Touch 3G";
	if ([platform isEqualToString:@"iPod4,1"])   return @"iPod Touch 4G";
	if ([platform isEqualToString:@"iPod5,1"])   return @"iPod Touch (5th generation)";
    
	if ([platform isEqualToString:@"iPad2,1"])   return @"iPad 2 (Wi-Fi)";      // iPad2 WiFi
	if ([platform isEqualToString:@"iPad2,2"])   return @"iPad 2";       // iPad2 GSM
	if ([platform isEqualToString:@"iPad2,3"])   return @"iPad 2";     // iPad2 CDMAV
	if ([platform isEqualToString:@"iPad2,4"])   return @"iPad 2 (Wi-Fi)";     // iPad2 Mid 2012 CDMAS WiFi

	if ([platform isEqualToString:@"iPad3,1"])   return @"iPad (3rd generation, Wi-Fi)";      // WiFi
	if ([platform isEqualToString:@"iPad3,2"])   return @"iPad (3rd generation)";      // CDMA
	if ([platform isEqualToString:@"iPad3,3"])   return @"iPad (3rd generation)";      // GSM
    
	if ([platform isEqualToString:@"iPad3,4"])   return @"iPad (4th generation, Wi-Fi)";      // WiFi
	if ([platform isEqualToString:@"iPad3,5"])   return @"iPad (4th generation)";      // GSM
	if ([platform isEqualToString:@"iPad3,6"])   return @"iPad (4th generation)";      // Cellular
    
	if ([platform isEqualToString:@"iPad4,1"])   return @"iPad Air (Wi-Fi)";      // WiFi
	if ([platform isEqualToString:@"iPad4,2"])   return @"iPad Air";      // Cellular
    
	if ([platform isEqualToString:@"iPad2,5"])   return @"iPad mini (Wi-Fi)";      // WiFi
	if ([platform isEqualToString:@"iPad2,6"])   return @"iPad mini";      // GSM
	if ([platform isEqualToString:@"iPad2,7"])   return @"iPad mini";      // Cellular
	if ([platform isEqualToString:@"iPad4,4"])   return @"iPad mini with Retina display (Wi-Fi)";      // Retina, WiFi
	if ([platform isEqualToString:@"iPad4,5"])   return @"iPad mini with Retina display";      // Retina, Cellular
    
    // 최신 디바이스라서 못찾은 경우.
    if ([platform rangeOfString:@"iPhone"].location != NSNotFound) return @"iPhone (Latest)";
    if ([platform rangeOfString:@"iPod"].location != NSNotFound) return @"iPod (Latest)";
    if ([platform rangeOfString:@"iPad"].location != NSNotFound) return @"iPad (Latest)";

    return nil;
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

@end
