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

@implementation WalletFieldItem (initialize)

- (void)prepareForDeletion {
	[super prepareForDeletion];
}

- (void)awakeFromInsert {
	[super awakeFromInsert];

	self.uniqueID = [[NSUUID UUID] UUIDString];
}

- (NSString *)imageThumbnailPath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *cachesDirectory = [paths objectAtIndex:0];
	NSString *imageThumbnail = [NSString stringWithFormat:@"%@-imageThumbnail", self.uniqueID];
	return [cachesDirectory stringByAppendingPathComponent:imageThumbnail];
}

- (NSString *)videoThumbnailPath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *cachesDirectory = [paths objectAtIndex:0];
	NSString *imageThumbnail = [NSString stringWithFormat:@"%@-videoThumbnail", self.uniqueID];
	return [cachesDirectory stringByAppendingPathComponent:imageThumbnail];
}

- (NSString *)videoFilePath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	NSString *libraryDirectory = [paths objectAtIndex:0];
	NSString *filename = [NSString stringWithFormat:@"%@-video", self.uniqueID];
	filename = [filename stringByAppendingPathExtension:self.videoExtension];
	return [libraryDirectory stringByAppendingPathComponent:filename];
}

- (UIImage *)thumbnailImage {
	NSString *thumbnailPath = nil;
	if ([self.field.type isEqualToString:WalletFieldTypeImage]) {
		thumbnailPath = self.imageThumbnailPath;
	} else if ([self.field.type isEqualToString:WalletFieldTypeVideo]) {
		thumbnailPath = self.videoThumbnailPath;
	}
	if (thumbnailPath) {
		return [[UIImage alloc] initWithContentsOfFile:thumbnailPath];
	}
	return nil;
}

@end
