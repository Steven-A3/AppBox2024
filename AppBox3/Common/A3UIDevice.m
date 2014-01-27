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

@implementation A3UIDevice

+ (CGRect)screenBoundsAdjustedWithOrientation {
	CGRect bounds = [[UIScreen mainScreen] bounds];
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

@end
