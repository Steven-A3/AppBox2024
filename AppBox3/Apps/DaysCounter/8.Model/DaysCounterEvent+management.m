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
#import "A3AppDelegate.h"

NSString *const A3DaysCounterImageDirectory = @"DaysCounterImages";
NSString *const A3DaysCounterImageThumbnailDirectory = @"DaysCounterPhotoThumbnail";

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

- (NSURL *)photoURLInOriginalDirectory:(BOOL)inOriginalDirectory {
	if (inOriginalDirectory) {
		if ([[A3AppDelegate instance].ubiquityStoreManager cloudEnabled]) {
			NSURL *ubiquityContainerURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
			NSString *filePath = [A3DaysCounterImageDirectory stringByAppendingPathComponent:self.uniqueID];
			return [ubiquityContainerURL URLByAppendingPathComponent:filePath];
		} else {
			NSString *path = [[A3DaysCounterImageDirectory stringByAppendingPathComponent:self.uniqueID] pathInLibraryDirectory];
			return [NSURL fileURLWithPath:path];
		}
	} else {
		return [NSURL fileURLWithPath:[self.uniqueID pathInTemporaryDirectory] ];
	}
}

- (UIImage *)photoInOriginalDirectory:(BOOL)inOriginalDirectory {
	NSData *data = [[NSData alloc] initWithContentsOfURL:[self photoURLInOriginalDirectory:inOriginalDirectory]];
	return [UIImage imageWithData:data];
}

- (void)setPhoto:(UIImage *)image inOriginalDirectory:(BOOL)inOriginalDirectory {
	[UIImageJPEGRepresentation(image, 1.0) writeToURL:[self photoURLInOriginalDirectory:inOriginalDirectory] atomically:YES];
}

- (UIImage *)thumbnailImageInOriginalDirectory:(BOOL)inOriginalDirectory {
	if (![self.hasPhoto boolValue]) return nil;
	NSString *filePath = [self thumbnailPathInOriginalDirectory:inOriginalDirectory];
	if (inOriginalDirectory && ![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
		UIImage *image = [self photoInOriginalDirectory:YES];
		return [self saveThumbnailForImage:image inOriginalDirectory:YES];
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

	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
		NSURL *photoURLInOriginalDirectory = [self photoURLInOriginalDirectory:YES];
		NSURL *photoURLInTemporaryDirectory = [self photoURLInOriginalDirectory:NO];

		NSFileManager *fileManager = [[NSFileManager alloc] init];
		NSFileCoordinator* fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
		NSError *error;
		[fileCoordinator coordinateReadingItemAtURL:photoURLInOriginalDirectory
											options:NSFileCoordinatorReadingWithoutChanges
								   writingItemAtURL:photoURLInTemporaryDirectory
											options:NSFileCoordinatorWritingForReplacing
											  error:&error byAccessor:^(NSURL *newReadingURL, NSURL *newWritingURL) {
			[fileManager copyItemAtURL:newReadingURL toURL:newWritingURL error:NULL];
		}];
		NSString *thumbnailPath = [self thumbnailPathInOriginalDirectory:YES];
		NSString *thumbnailPathInTemp = [self thumbnailPathInOriginalDirectory:NO];
		[fileManager removeItemAtPath:thumbnailPathInTemp error:NULL];
		[fileManager copyItemAtPath:thumbnailPath toPath:thumbnailPathInTemp error:NULL];
	});
}

- (void)moveImagesToOriginalDirectory {
	if (![self.hasPhoto boolValue]) {
		[self deletePhoto];
		return;
	}

	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
		NSURL *photoURLInOriginalDirectory = [self photoURLInOriginalDirectory:YES];
		NSURL *photoURLInTemporaryDirectory = [self photoURLInOriginalDirectory:NO];

		NSFileManager *fileManager = [[NSFileManager alloc] init];

		NSFileCoordinator* fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
		NSError *error;
		[fileCoordinator coordinateReadingItemAtURL:photoURLInTemporaryDirectory
											options:NSFileCoordinatorReadingWithoutChanges
								   writingItemAtURL:photoURLInOriginalDirectory
											options:NSFileCoordinatorWritingForReplacing
											  error:&error
										 byAccessor:^(NSURL *newReadingURL, NSURL *newWritingURL) {
											 [fileManager setUbiquitous:YES itemAtURL:newReadingURL destinationURL:newWritingURL error:NULL];
										 }];
		if (error) {
			FNLOG(@"%@", error.localizedDescription);
		}
		NSString *thumbnailPath = [self thumbnailPathInOriginalDirectory:YES];
		NSString *thumbnailPathInTemp = [self thumbnailPathInOriginalDirectory:NO];

		[fileManager removeItemAtPath:thumbnailPath error:NULL];
		[fileManager moveItemAtPath:thumbnailPathInTemp toPath:thumbnailPath error:NULL];
	});

}

- (void)deletePhoto {
	self.hasPhoto = @NO;

	NSFileManager *fileManager = [[NSFileManager alloc] init];
	NSURL *photoURL = [self photoURLInOriginalDirectory:YES];
	NSFileCoordinator* fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
	NSError *error;
	[fileCoordinator coordinateWritingItemAtURL:photoURL
										options:NSFileCoordinatorWritingForDeleting
										  error:&error
									 byAccessor:^(NSURL *newURL) {
										 [fileManager removeItemAtURL:newURL error:NULL];
									 }];
	[fileManager removeItemAtURL:[self photoURLInOriginalDirectory:NO] error:NULL];
	
	[fileManager removeItemAtPath:[self thumbnailPathInOriginalDirectory:YES] error:NULL];
	[fileManager removeItemAtPath:[self thumbnailPathInOriginalDirectory:NO] error:NULL];
}

@end
