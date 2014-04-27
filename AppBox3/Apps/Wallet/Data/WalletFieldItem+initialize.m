//
//  WalletFieldItem+initialize.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 4..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "WalletFieldItem+initialize.h"
#import "WalletField+initialize.h"
#import "WalletData.h"
#import "WalletFieldItemVideo.h"

@implementation WalletFieldItem (initialize)

- (void)didSave {
	if (self.isDeleted) {
		FNLOG();
		NSFileManager *fileManager = [NSFileManager defaultManager];
		if ([self.field.type isEqualToString:WalletFieldTypeImage]) {
			[fileManager removeItemAtPath:[self imageThumbnailPathInTemporary:NO] error:NULL];
			return;
		}
		if ([self.field.type isEqualToString:WalletFieldTypeVideo] && self.video)  {
			[fileManager removeItemAtPath:[self videoFilePathInTemporary:NO] error:NULL];
			[fileManager removeItemAtPath:[self videoThumbnailPathInTemporary:NO] error:NULL];
		}
	}
}

- (NSString *)imageThumbnailPathInTemporary:(BOOL)temporary {
	NSString *directory;
	if (temporary) {
		directory = NSTemporaryDirectory();
	} else {
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
		directory = [paths objectAtIndex:0];
	}
	NSString *imageThumbnail = [NSString stringWithFormat:@"%@-imageThumbnail", self.uniqueID];
	return [directory stringByAppendingPathComponent:imageThumbnail];
}

- (NSString *)videoThumbnailPathInTemporary:(BOOL)temporary {
	NSString *directory;
	if (temporary) {
		directory = NSTemporaryDirectory();
	} else {
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
		directory = [paths objectAtIndex:0];
	}
	NSString *imageThumbnail = [NSString stringWithFormat:@"%@-videoThumbnail", self.uniqueID];
	return [directory stringByAppendingPathComponent:imageThumbnail];
}

- (NSString *)videoFilePathInTemporary:(BOOL)temporary {
	if (!self.video) return nil;

	NSString *directory;
	if (temporary) {
		directory = NSTemporaryDirectory();
	} else {
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
		directory = [paths objectAtIndex:0];
	}
	NSString *filename = [NSString stringWithFormat:@"%@-video", self.uniqueID];
	filename = [filename stringByAppendingPathExtension:self.video.extension];
	return [directory stringByAppendingPathComponent:filename];
}

- (UIImage *)thumbnailImage {
	NSString *thumbnailPath = nil;
	if (self.image) {
		thumbnailPath = [self imageThumbnailPathInTemporary:NO ];
	} else if (self.video) {
		thumbnailPath = [self videoThumbnailPathInTemporary:NO ];
	}
	if (thumbnailPath) {
		return [[UIImage alloc] initWithContentsOfFile:thumbnailPath];
	}
	return nil;
}

@end
