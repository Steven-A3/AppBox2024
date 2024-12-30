//
//  WalletFieldItem+initialize.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 4..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "WalletFieldItem+initialize.h"
#import "WalletData.h"
#import "UIImage+Resizing.h"
#import <AppBoxKit/AppBoxKit.h>
#import <AppBoxKit/AppBoxKit-Swift.h>
@import CloudKit;

@implementation WalletFieldItem_ (initialize)

- (void)didSave {
    dispatch_async(dispatch_get_main_queue(), ^{
        @autoreleasepool {
            if (self.isDeleted) {
                FNLOG();
                NSFileManager *fileManager = [NSFileManager defaultManager];
                if ([self.hasImage boolValue]) {
                    NSError *error;
                    NSFileCoordinator *coordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
                    [coordinator coordinateWritingItemAtURL:[self imageURL]
                                                    options:NSFileCoordinatorWritingForDeleting
                                                      error:&error
                                                 byAccessor:^(NSURL *newURL) {
                        [fileManager removeItemAtURL:newURL error:NULL];
                    }];
                    [fileManager removeItemAtPath:[self photoImageThumbnailPathInOriginal:YES] error:NULL];
                    if (@available(iOS 17.0, *)) {
                        if (CKContainer.defaultContainer) {
                            if ([self.uniqueID length]) {
                                CloudKitMediaFileManagerWrapper *manager = [CloudKitMediaFileManagerWrapper shared];
                                [manager removeFileWithRecordType:A3WalletImageDirectory customID:self.uniqueID  completion:^(NSError * _Nullable error) {
                                    
                                }];
                            } else {
                                FNLOG(@"WalletFieldItem uniqueID empty");
                            }
                        }
                    }
                    return;
                }
                if ([self.hasVideo boolValue])  {
                    NSError *error;
                    NSFileCoordinator *coordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
                    [coordinator coordinateWritingItemAtURL:[self videoURL]
                                                    options:NSFileCoordinatorWritingForDeleting
                                                      error:&error
                                                 byAccessor:^(NSURL *newURL)
                     {
                        NSError *removeError;
                        [fileManager removeItemAtURL:newURL error:&removeError];
                    }];
                    NSString *thumbnalePath = [self videoThumbnailPathInOriginal:YES];
                    if ([fileManager isDeletableFileAtPath:thumbnalePath]) {
                        [fileManager removeItemAtPath:thumbnalePath error:nil];
                    }
                    if (@available(iOS 17.0, *)) {
                        if (CKContainer.defaultContainer) {
                            if ([self.uniqueID length]) {
                                CloudKitMediaFileManagerWrapper *manager = [CloudKitMediaFileManagerWrapper shared];
                                [manager removeFileWithRecordType:A3WalletVideoDirectory customID:self.uniqueID completion:^(NSError * _Nullable error) {
                                    
                                }];
                            } else {
                                FNLOG(@"WalletFieldItem uniqueID empty.");
                            }
                        }
                    }
                }
            }
        }
    });
}

- (NSURL *)photoImageURLInOriginalDirectory:(BOOL)inOriginalDirectory {
	if (inOriginalDirectory) {
        return [self imageURL];
	} else {
		return [NSURL fileURLWithPath:[self.uniqueID pathInTemporaryDirectory]];
	}
}

- (UIImage *)photoImageInOriginalDirectory:(BOOL)inOriginalDirectory {
    NSURL *imageURL = [self photoImageURLInOriginalDirectory:inOriginalDirectory];
    NSFileManager *fileManager = [NSFileManager defaultManager];

    if ([fileManager fileExistsAtPath:imageURL.path]) {
        NSData *data = [NSData dataWithContentsOfURL:imageURL];
        return [UIImage imageWithData:data];
    }
    
    return nil;
}

// Set the photo image in the original directory
// The image is saved in the original directory if inOriginalDirectory is YES
- (void)setPhotoImage:(UIImage *)image inOriginalDirectory:(BOOL)inOriginalDirectory {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *fileURL = [self photoImageURLInOriginalDirectory:inOriginalDirectory];
        // iCloud is not available: handle locally
    if ([fileManager fileExistsAtPath:fileURL.path]) {
        NSError *error = nil;
        BOOL success = [fileManager removeItemAtURL:fileURL error:&error];
        NSAssert(success, @"Failed to remove existing file: %@", error.localizedDescription);
    }
    
    BOOL success = [UIImageJPEGRepresentation(image, 1.0) writeToURL:fileURL atomically:YES];
    NSAssert(success, @"Failed to save image locally.");
    
    if (@available(iOS 17.0, *)) {
        if (CKContainer.defaultContainer) {
            CloudKitMediaFileManagerWrapper *manager = [CloudKitMediaFileManagerWrapper shared];
            [manager addFileWithUrl:fileURL recordType:A3WalletImageDirectory customID:self.uniqueID ext:nil completion:^(NSError * _Nullable error) {
                
            }];
        }
    }
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
    if (![[NSFileManager defaultManager] fileExistsAtPath:[videoURL path]]) {
        return nil;
    }
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
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *localURL;

    // Determine the local file URL
    if (inOriginal) {
        localURL = [self videoURL];
    } else {
        localURL = [NSURL fileURLWithPath:[filename pathInTemporaryDirectory]];
    }

    // Check if the file exists locally
    if ([fileManager fileExistsAtPath:localURL.path]) {
        return localURL;
    }
    // Return nil if the file could not be found locally
    return nil;
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
