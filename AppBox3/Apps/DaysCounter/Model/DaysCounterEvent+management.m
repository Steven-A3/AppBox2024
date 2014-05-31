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

NSString *const A3DaysCounterImageDirectory = @"DaysCounterImages";

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

- (NSString *)photoPathInOriginalDirectory:(BOOL)inOriginalDirectory {
	if (inOriginalDirectory) {
		return [[NSString stringWithFormat:@"%@/%@", A3DaysCounterImageDirectory, self.uniqueID] pathInLibraryDirectory];
	} else {
		return [self.uniqueID pathInTemporaryDirectory];
	}
}

- (UIImage *)photoInOriginalDirectory:(BOOL)inOriginalDirectory {
	return [UIImage imageWithContentsOfFile:[self photoPathInOriginalDirectory:inOriginalDirectory]];
}

- (void)setPhoto:(UIImage *)image inOriginalDirectory:(BOOL)inOriginalDirectory {
	[UIImageJPEGRepresentation(image, 1.0) writeToFile:[self photoPathInOriginalDirectory:inOriginalDirectory] atomically:YES];
}

- (UIImage *)thumbnailImageInOriginalDirectory:(BOOL)inOriginalDirectory {
	if (![self.hasPhoto boolValue]) return nil;
	NSString *filePath = [self thumbnailPathInOriginalDirectory:inOriginalDirectory];
	if (inOriginalDirectory && ![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
		NSString *originalPath = [self photoPathInOriginalDirectory:YES];
		if ([[NSFileManager defaultManager] fileExistsAtPath:originalPath]) {
			UIImage *image = [UIImage imageWithContentsOfFile:originalPath];
			return [self saveThumbnailForImage:image inOriginalDirectory:YES];
		}
	}
	return [UIImage imageWithContentsOfFile:[self thumbnailPathInOriginalDirectory:inOriginalDirectory]];
}

- (UIImage *)saveThumbnailForImage:(UIImage *)originalImage inOriginalDirectory:(BOOL)inOriginalDirectory {
	NSString *thumbnailPath = [self thumbnailPathInOriginalDirectory:inOriginalDirectory];
	CGSize size = CGSizeMake(64, 64);
	UIImage *thumbnailImage = [originalImage scaleToCoverSize:size];
	thumbnailImage = [thumbnailImage cropToSize:size usingMode:NYXCropModeCenter];
	[UIImageJPEGRepresentation(thumbnailImage, 1.0) writeToFile:thumbnailPath atomically:YES];

	return thumbnailImage;
}

- (NSString *)thumbnailPathInOriginalDirectory:(BOOL)inOriginalDirectory {
	NSString *directory;
	if (inOriginalDirectory) {
		directory = [A3DaysCounterModelManager thumbnailDirectory];
	} else {
		directory = NSTemporaryDirectory();
	}
	NSString *imageThumbnail = [NSString stringWithFormat:@"%@-imageThumbnail", self.uniqueID];
	return [directory stringByAppendingPathComponent:imageThumbnail];
}

- (void)copyImagesToTemporaryDirectory {
	if (![self.hasPhoto boolValue]) {
		return;
	}
	NSFileManager *fileManager = [NSFileManager defaultManager];

	NSString *photoPathInOriginalDirectory = [self photoPathInOriginalDirectory:YES];
	NSString *photoPathInTemporaryDirectory = [self photoPathInOriginalDirectory:NO];
	[fileManager removeItemAtPath:photoPathInTemporaryDirectory error:NULL];
	[fileManager copyItemAtPath:photoPathInOriginalDirectory toPath:photoPathInTemporaryDirectory error:NULL];

	NSString *thumbnailPath = [self thumbnailPathInOriginalDirectory:YES];
	NSString *thumbnailPathInTemp = [self thumbnailPathInOriginalDirectory:NO];
	[fileManager removeItemAtPath:thumbnailPathInTemp error:NULL];
	[fileManager copyItemAtPath:thumbnailPath toPath:thumbnailPathInTemp error:NULL];
}

- (void)moveImagesToOriginalDirectory {
	if (![self.hasPhoto boolValue]) {
		[self deletePhoto];
		return;
	}
	NSFileManager *fileManager = [NSFileManager defaultManager];

	NSString *photoPathInOriginalDirectory = [self photoPathInOriginalDirectory:YES];
	NSString *photoPathInTemporaryDirectory = [self photoPathInOriginalDirectory:NO];

	[fileManager removeItemAtPath:photoPathInOriginalDirectory error:NULL];
	[fileManager moveItemAtPath:photoPathInTemporaryDirectory toPath:photoPathInOriginalDirectory error:NULL];

	NSString *thumbnailPath = [self thumbnailPathInOriginalDirectory:YES];
	NSString *thumbnailPathInTemp = [self thumbnailPathInOriginalDirectory:NO];

	[fileManager removeItemAtPath:thumbnailPath error:NULL];
	[fileManager moveItemAtPath:thumbnailPathInTemp toPath:thumbnailPath error:NULL];
}

- (void)deletePhoto {
	self.hasPhoto = @NO;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	[fileManager removeItemAtPath:[self photoPathInOriginalDirectory:YES] error:NULL];
	[fileManager removeItemAtPath:[self photoPathInOriginalDirectory:NO] error:NULL];

	[fileManager removeItemAtPath:[self thumbnailPathInOriginalDirectory:YES] error:NULL];
	[fileManager removeItemAtPath:[self thumbnailPathInOriginalDirectory:NO] error:NULL];
}

@end
