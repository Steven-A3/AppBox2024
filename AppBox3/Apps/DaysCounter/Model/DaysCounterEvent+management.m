//
//  DaysCounterEvent+management.m
//  AppBox3
//
//  Created by A3 on 5/13/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "DaysCounterEvent+management.h"
#import "DaysCounterFavorite.h"
#import "NSString+conversion.h"
#import "UIImage+Resizing.h"
#import "A3DaysCounterModelManager.h"

@implementation DaysCounterEvent (management)

- (void)toggleFavorite {
	if (!self.favorite) {
		DaysCounterFavorite *favorite = [DaysCounterFavorite MR_createEntity];
		favorite.event = self;
		DaysCounterFavorite *lastFavorite = [DaysCounterFavorite MR_findFirstOrderedByAttribute:@"order" ascending:NO];
		favorite.order = [NSString orderStringWithOrder:[lastFavorite.order integerValue] + 1000000];
	} else {
		[self.favorite MR_deleteEntity];
	}
}

- (UIImage *)thumbnailImageInTemporaryDirectory:(BOOL)temporary {
	if (!self.photo) return nil;
	return [UIImage imageWithContentsOfFile:[self thumbnailPathInTemporary:temporary]];
}

- (void)saveThumbnailInTemporaryDirectory {
	NSString *thumbnailPathInTemporary = [self thumbnailPathInTemporary:YES];
	CGSize size = CGSizeMake(64, 64);
	UIImage *thumbnailImage = [self.photo scaleToCoverSize:size];
	thumbnailImage = [thumbnailImage cropToSize:size usingMode:NYXCropModeCenter];
	[UIImageJPEGRepresentation(thumbnailImage, 1.0) writeToFile:thumbnailPathInTemporary atomically:YES];
}

- (NSString *)thumbnailPathInTemporary:(BOOL)temporary {
	NSString *directory;
	if (temporary) {
		directory = NSTemporaryDirectory();
	} else {
		directory = [A3DaysCounterModelManager thumbnailDirectory];
	}
	NSString *imageThumbnail = [NSString stringWithFormat:@"%@-imageThumbnail", self.uniqueID];
	return [directory stringByAppendingPathComponent:imageThumbnail];
}

- (void)copyThumbnailImageToTemporaryDirectory {
	if (!self.photo) {
		return;
	}
	NSString *thumbnailPath = [self thumbnailPathInTemporary:NO];
	NSString *thumbnailPathInTemp = [self thumbnailPathInTemporary:YES];
	[[NSFileManager defaultManager] removeItemAtPath:thumbnailPathInTemp error:NULL];
	[[NSFileManager defaultManager] copyItemAtPath:thumbnailPath toPath:thumbnailPathInTemp error:NULL];
}

- (void)moveThumbnailImageToCachesDirectory {
	if (!self.photo) {
		[self deletePhoto];
		return;
	}
	NSString *thumbnailPath = [self thumbnailPathInTemporary:NO];
	NSString *thumbnailPathInTemp = [self thumbnailPathInTemporary:YES];
	[[NSFileManager defaultManager] removeItemAtPath:thumbnailPath error:NULL];
	[[NSFileManager defaultManager] moveItemAtPath:thumbnailPathInTemp toPath:thumbnailPath error:NULL];
}

- (void)deleteThumbnailImageInTemporary {
	NSString *thumbnailPathInTemp = [self thumbnailPathInTemporary:YES];
	[[NSFileManager defaultManager] removeItemAtPath:thumbnailPathInTemp error:NULL];
}

- (void)deletePhoto {
	self.photo = nil;
	NSString *thumbnailPath = [self thumbnailPathInTemporary:NO];
	[[NSFileManager defaultManager] removeItemAtPath:thumbnailPath error:NULL];

	[self deleteThumbnailImageInTemporary];
}

@end
