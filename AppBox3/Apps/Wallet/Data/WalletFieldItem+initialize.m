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
#import "NSString+conversion.h"
#import "UIImage+Resizing.h"
#import "A3AppDelegate.h"

NSString *const A3WalletImageDirectory = @"WalletImages";		// in Library Directory
NSString *const A3WalletVideoDirectory = @"WalletVideos";		// in Library Directory
NSString *const A3WalletImageThumbnailDirectory = @"WalletImageThumbnails";	// in Caches Directory
NSString *const A3WalletVideoThumbnailDirectory = @"WalletVideoThumbnails"; // in Caches Directory

@implementation WalletFieldItem (initialize)

- (void)didSave {
	if (self.isDeleted) {
		FNLOG();
		NSFileManager *fileManager = [NSFileManager defaultManager];
		WalletField *field = [WalletField MR_findFirstByAttribute:@"uniqueID" withValue:self.fieldID];
		if ([field.type isEqualToString:WalletFieldTypeImage]) {
			NSError *error;
			NSFileCoordinator *coordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
			[coordinator coordinateWritingItemAtURL:[self photoImageURLInOriginalDirectory:YES]
											options:NSFileCoordinatorWritingForDeleting
											  error:&error
										 byAccessor:^(NSURL *newURL) {
											 [fileManager removeItemAtURL:newURL error:NULL];
										 }];
			[fileManager removeItemAtPath:[self photoImageThumbnailPathInOriginal:YES] error:NULL];
			return;
		}
		if ([field.type isEqualToString:WalletFieldTypeVideo] && [self.hasVideo boolValue])  {
			NSError *error;
			NSFileCoordinator *coordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
			[coordinator coordinateWritingItemAtURL:[self videoFileURLInOriginal:YES]
											options:NSFileCoordinatorWritingForDeleting
											  error:&error
										 byAccessor:^(NSURL *newURL) {
											 [fileManager removeItemAtURL:newURL error:NULL];
										 }];
			[fileManager removeItemAtPath:[self videoThumbnailPathInOriginal:YES] error:NULL];
		}
	}
}

- (NSURL *)baseURL {
	if ([[[A3AppDelegate instance] ubiquityStoreManager] cloudEnabled]) {
		return [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
	} else {
		return [NSURL fileURLWithPath:NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0]];
	}
}

- (NSURL *)photoImageURLInOriginalDirectory:(BOOL)inOriginalDirectory {
	if (inOriginalDirectory) {
		NSURL *baseURL;
		baseURL = [[self baseURL] URLByAppendingPathComponent:A3WalletImageDirectory];
		return [baseURL URLByAppendingPathComponent:self.uniqueID];
	} else {
		return [NSURL fileURLWithPath:[self.uniqueID pathInTemporaryDirectory]];
	}
}

- (UIImage *)photoImageInOriginalDirectory:(BOOL)inOriginalDirectory {
	NSData *data = [[NSData alloc] initWithContentsOfURL:[self photoImageURLInOriginalDirectory:inOriginalDirectory]];
	return [UIImage imageWithData:data];
}

- (void)setPhotoImage:(UIImage *)image inOriginalDirectory:(BOOL)inOriginalDirectory {
    BOOL result;
    NSURL *fileURL = [self photoImageURLInOriginalDirectory:inOriginalDirectory];
    if ([[NSFileManager defaultManager] fileExistsAtPath:[fileURL path]]) {
        result = [[NSFileManager defaultManager] removeItemAtURL:fileURL error:NULL];
        NSAssert(result, @"removeItemAtURL");
    }
	result = [UIImageJPEGRepresentation(image, 1.0) writeToURL:[self photoImageURLInOriginalDirectory:inOriginalDirectory] atomically:YES];
    NSAssert(result, @"setPhotoImage");
}

- (NSString *)photoImageThumbnailPathInOriginal:(BOOL)original {
	NSString *filename = [NSString stringWithFormat:@"%@-imageThumbnail", self.uniqueID];
	if (original) {
		NSString *path = [A3WalletImageThumbnailDirectory stringByAppendingPathComponent:filename];
		return [path pathInCachesDirectory];
	} else {
		return [filename pathInTemporaryDirectory];
	}
}

- (UIImage *)makePhotoImageThumbnailWithImage:(UIImage *)originalImage inOriginalDirectory:(BOOL)inOriginalDirectory {
	return [self makeThumbnailWithImage:originalImage path:[self photoImageThumbnailPathInOriginal:inOriginalDirectory]];
}

- (UIImage *)photoImageThumbnail {
	NSString *thumbnailImagePath = [self photoImageThumbnailPathInOriginal:YES];
	if ([[NSFileManager defaultManager] fileExistsAtPath:thumbnailImagePath]) {
		return [UIImage imageWithContentsOfFile:thumbnailImagePath];
	}
	UIImage *originalImage = [self photoImageInOriginalDirectory:YES];
	if (originalImage) {
		return [self makePhotoImageThumbnailWithImage:originalImage inOriginalDirectory:YES];
	}
	return nil;
}

- (UIImage *)videoThumbnail {
	NSString *thumbnailImagePath = [self videoThumbnailPathInOriginal:YES];
	if ([[NSFileManager defaultManager] fileExistsAtPath:thumbnailImagePath]) {
		return [UIImage imageWithContentsOfFile:thumbnailImagePath];
	}
	NSURL *videoURL = [self videoFileURLInOriginal:YES];
	UIImage *originalImage = [WalletData videoPreviewImageOfURL:videoURL];
	[self makeVideoThumbnailWithImage:originalImage inOriginalDirectory:YES];
	return [UIImage imageWithContentsOfFile:thumbnailImagePath];
}

- (NSString *)videoThumbnailPathInOriginal:(BOOL)inOriginal {
	NSString *filename = [NSString stringWithFormat:@"%@-videoThumbnail", self.uniqueID];
	if (inOriginal) {
		NSString *path = [A3WalletVideoThumbnailDirectory stringByAppendingPathComponent:filename];
		return [path pathInCachesDirectory];
	} else {
		return [filename pathInTemporaryDirectory];
	}
}

- (NSURL *)videoFileURLInOriginal:(BOOL)inOriginal {
	NSString *filename = [NSString stringWithFormat:@"%@-video.%@", self.uniqueID, self.videoExtension];
	if (inOriginal) {
		NSURL *baseURL = [[self baseURL] URLByAppendingPathComponent:A3WalletVideoDirectory];
		return [baseURL URLByAppendingPathComponent:filename];
	} else {
		return [NSURL fileURLWithPath:[filename pathInTemporaryDirectory]];
	}
}

- (UIImage *)makeThumbnailWithImage:(UIImage *)originalImage path:(NSString *)path {
	CGSize size = CGSizeMake(160, 160);
	UIImage *thumbnailImage = [originalImage scaleToCoverSize:size];
	thumbnailImage = [thumbnailImage cropToSize:size usingMode:NYXCropModeCenter];
    
    BOOL result;
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        result = [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
        NSAssert(result, @"removeItemAtURL");
    }
    
	result = [UIImageJPEGRepresentation(thumbnailImage, 1.0) writeToFile:path atomically:YES];
    NSAssert(result, @"writeToFile");
	return thumbnailImage;
}

- (UIImage *)makeVideoThumbnailWithImage:(UIImage *)originalImage inOriginalDirectory:(BOOL)inOriginalDirectory {
	return [self makeThumbnailWithImage:originalImage path:[self videoThumbnailPathInOriginal:inOriginalDirectory]];
}

- (UIImage *)thumbnailImage {
	if ([self.hasImage boolValue]) {
		return [self photoImageThumbnail];
	} else if ([self.hasVideo boolValue]) {
		return [self videoThumbnail];
	}
	return nil;
}

@end
