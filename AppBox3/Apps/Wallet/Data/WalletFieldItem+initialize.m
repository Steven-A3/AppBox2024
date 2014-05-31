//
//  WalletFieldItem+initialize.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 4..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <ImageIO/ImageIO.h>
#import "WalletFieldItem+initialize.h"
#import "WalletField+initialize.h"
#import "WalletData.h"
#import "WalletFieldItemVideo.h"
#import "NSString+conversion.h"
#import "UIImage+Resizing.h"

NSString *const A3WalletImageDirectory = @"WalletImages";		// in Library Directory
NSString *const A3WalletVideoDirectory = @"WalletVideos";		// in Library Directory
NSString *const A3WalletImageThumbnailDirectory = @"WalletImageThumbnails";	// in Caches Directory
NSString *const A3WalletVideoThumbnailDirectory = @"WalletVideoThumbnails"; // in Caches Directory

@implementation WalletFieldItem (initialize)

- (void)didSave {
	if (self.isDeleted) {
		FNLOG();
		NSFileManager *fileManager = [NSFileManager defaultManager];
		if ([self.field.type isEqualToString:WalletFieldTypeImage]) {
			[fileManager removeItemAtPath:[self photoImageThumbnailPathInOriginal:YES] error:NULL];
			return;
		}
		if ([self.field.type isEqualToString:WalletFieldTypeVideo] && self.video)  {
			[fileManager removeItemAtPath:[self videoFilePathInOriginal:YES] error:NULL];
			[fileManager removeItemAtPath:[self videoThumbnailPathInOriginal:YES] error:NULL];
		}
	}
}

- (NSString *)photoImagePathInOriginalDirectory:(BOOL)inOriginalDirectory {
	if (inOriginalDirectory) {
		return [[NSString stringWithFormat:@"%@/%@", A3WalletImageDirectory, self.uniqueID] pathInLibraryDirectory];
	} else {
		return [self.uniqueID pathInTemporaryDirectory];
	}
}

- (UIImage *)photoImageInOriginalDirectory:(BOOL)inOriginalDirectory {
	return [UIImage imageWithContentsOfFile:[self photoImagePathInOriginalDirectory:inOriginalDirectory ]];
}

- (void)setPhotoImage:(UIImage *)image inOriginalDirectory:(BOOL)inOriginalDirectory {
	[UIImageJPEGRepresentation(image, 1.0) writeToFile:[self photoImagePathInOriginalDirectory:inOriginalDirectory ] atomically:YES];
}

- (NSString *)photoImageThumbnailPathInOriginal:(BOOL)original {
	NSString *directory;
	if (original) {
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
		directory = [paths objectAtIndex:0];
	} else {
		directory = NSTemporaryDirectory();
	}
	NSString *imageThumbnail = [NSString stringWithFormat:@"%@-imageThumbnail", self.uniqueID];
	return [directory stringByAppendingPathComponent:imageThumbnail];
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

- (NSString *)videoThumbnailPathInOriginal:(BOOL)inOriginal {
	NSString *directory;
	if (inOriginal) {
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
		directory = [paths objectAtIndex:0];
	} else {
		directory = NSTemporaryDirectory();
	}
	NSString *imageThumbnail = [NSString stringWithFormat:@"%@-videoThumbnail", self.uniqueID];
	return [directory stringByAppendingPathComponent:imageThumbnail];
}

- (NSString *)videoFilePathInOriginal:(BOOL)inOriginal {
	if (!self.video) return nil;

	NSString *directory;
	if (inOriginal) {
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
		directory = [paths objectAtIndex:0];
	} else {
		directory = NSTemporaryDirectory();
	}
	NSString *filename = [NSString stringWithFormat:@"%@-video", self.uniqueID];
	filename = [filename stringByAppendingPathExtension:self.video.extension];
	return [directory stringByAppendingPathComponent:filename];
}

- (UIImage *)makeThumbnailWithImage:(UIImage *)originalImage path:(NSString *)path {
	CGSize size = CGSizeMake(160, 160);
	UIImage *thumbnailImage = [originalImage scaleToCoverSize:size];
	thumbnailImage = [thumbnailImage cropToSize:size usingMode:NYXCropModeCenter];
	[UIImageJPEGRepresentation(thumbnailImage, 1.0) writeToFile:path atomically:YES];
	return thumbnailImage;
}

- (UIImage *)makeVideoThumbnailWithImage:(UIImage *)originalImage inOriginalDirectory:(BOOL)inOriginalDirectory {
	return [self makeThumbnailWithImage:originalImage path:[self videoThumbnailPathInOriginal:inOriginalDirectory]];
}

- (UIImage *)thumbnailImage {
	NSString *thumbnailPath = nil;
	if (self.image) {
		return [self photoImageThumbnail];
	} else if (self.video) {
		thumbnailPath = [self videoThumbnailPathInOriginal:YES ];
		if (thumbnailPath) {
			return [[UIImage alloc] initWithContentsOfFile:thumbnailPath];
		}
	}
	return nil;
}

- (void)extractMetadata {
	NSString *imageFilePath = [self photoImagePathInOriginalDirectory:YES];
	NSURL *myURL = [NSURL fileURLWithPath:imageFilePath];
	CGImageSourceRef mySourceRef = CGImageSourceCreateWithURL((__bridge CFURLRef)myURL, NULL);
	NSDictionary *myMetadata = (__bridge NSDictionary *) CGImageSourceCopyPropertiesAtIndex(mySourceRef, 0, NULL);
	NSDictionary *exifDic = [myMetadata objectForKey:(NSString *)kCGImagePropertyExifDictionary];
	NSDictionary *tiffDic = [myMetadata objectForKey:(NSString *)kCGImagePropertyTIFFDictionary];
	NSLog(@"exifDic properties: %@", myMetadata); //all data
	NSLog(@"%@", exifDic);
	NSLog(@"Camera %@",[tiffDic objectForKey:(NSString *)kCGImagePropertyTIFFModel]);
	NSLog(@"Focal Length %@mm",[exifDic objectForKey:(NSString *)kCGImagePropertyExifFocalLength]);
	NSLog(@"Aperture f/%@",[exifDic objectForKey:(NSString *)kCGImagePropertyExifFNumber]);
	NSNumber *ExifISOSpeed  = [[exifDic objectForKey:(NSString*)kCGImagePropertyExifISOSpeedRatings] objectAtIndex:0];
	NSLog(@"ISO %i",[ExifISOSpeed integerValue]);
	NSLog(@"Taken %@",[exifDic objectForKey:(NSString*)kCGImagePropertyExifDateTimeDigitized]);
}

@end
