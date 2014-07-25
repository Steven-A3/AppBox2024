//
//  DaysCounterEvent+management.m
//  AppBox3
//
//  Created by A3 on 5/13/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "DaysCounterEvent+extension.h"
#import "DaysCounterFavorite.h"
#import "NSString+conversion.h"
#import "UIImage+Resizing.h"
#import "A3DaysCounterModelManager.h"
#import "A3AppDelegate.h"
#import "DaysCounterDate.h"
#import "DaysCounterDate.h"
#import "DaysCounterEventLocation.h"
#import "DaysCounterReminder.h"
#import "DaysCounterReminder.h"
#import "A3SyncManager.h"

NSString *const A3DaysCounterImageDirectory = @"DaysCounterImages";
NSString *const A3DaysCounterImageThumbnailDirectory = @"DaysCounterPhotoThumbnail";

@implementation DaysCounterEvent (extension)

- (DaysCounterReminder *)reminder {
	return [DaysCounterReminder MR_findFirstByAttribute:@"eventID" withValue:self.uniqueID];
}

- (DaysCounterFavorite *)favorite {
	return [DaysCounterFavorite MR_findFirstByAttribute:@"eventID" withValue:self.uniqueID];
}

/*! 이것을 호출하면 startDate가 없는 경우, 항상 만든다. 있으면 만들지 않는다.
 * \param
 * \returns
 */
- (DaysCounterDate *)startDate {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eventID == %@ AND isStartDate == YES", self.uniqueID];
	DaysCounterDate *startDate = [DaysCounterDate MR_findFirstWithPredicate:predicate inContext:self.managedObjectContext];
	if (!startDate) {
		startDate = [DaysCounterDate MR_createEntityInContext:self.managedObjectContext];
		startDate.uniqueID = [[NSUUID UUID] UUIDString];
		startDate.updateDate = [NSDate date];
		startDate.eventID = self.uniqueID;
		startDate.isStartDate = @YES;
	}
	return startDate;
}

- (DaysCounterDate *)endDateCreateIfNotExist:(BOOL)createIfNotExist {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eventID == %@ AND isStartDate == NO", self.uniqueID];
	DaysCounterDate *endDate = [DaysCounterDate MR_findFirstWithPredicate:predicate inContext:self.managedObjectContext];
	if (!endDate && createIfNotExist) {
		endDate = [DaysCounterDate MR_createEntityInContext:self.managedObjectContext];
		endDate.uniqueID = [[NSUUID UUID] UUIDString];
		endDate.updateDate = [NSDate date];
		endDate.eventID = self.uniqueID;
		endDate.isStartDate = @NO;
	}
	return endDate;
}

- (void)setEndDate:(DaysCounterDate *)dateObject {
	DaysCounterDate *endDate = [self endDateCreateIfNotExist:NO ];
	endDate.year = dateObject.year;
	endDate.month = dateObject.month;
	endDate.day = dateObject.day;
	endDate.hour = dateObject.hour;
	endDate.minute = dateObject.minute;
	endDate.solarDate = dateObject.solarDate;
	endDate.isLeapMonth = dateObject.isLeapMonth;
}

- (DaysCounterEventLocation *)location {
	return [DaysCounterEventLocation MR_findFirstByAttribute:@"eventID" withValue:self.uniqueID];
}

- (void)toggleFavorite {
	DaysCounterFavorite *favorite = [self favorite];
	if (!favorite) {
		favorite = [DaysCounterFavorite MR_createEntity];
		favorite.uniqueID = self.uniqueID;
		favorite.updateDate = [NSDate date];
		favorite.eventID = self.uniqueID;
		DaysCounterFavorite *lastFavorite = [DaysCounterFavorite MR_findFirstOrderedByAttribute:@"order" ascending:NO];
		favorite.order = [NSString orderStringWithOrder:[lastFavorite.order integerValue] + 1000000];
	} else {
		[favorite MR_deleteEntity];
	}
}

- (NSURL *)photoURLInOriginalDirectory:(BOOL)inOriginalDirectory {
    if (!self.photoID) {
        return nil;
    }
    
	if (inOriginalDirectory) {
		NSString *path = [[A3DaysCounterImageDirectory stringByAppendingPathComponent:self.photoID] pathInLibraryDirectory];
		FNLOG(@"\nphotoOriginalPath: %@", path);
		return [NSURL fileURLWithPath:path];
	} else {
        FNLOG(@"\nphotoTempPath: %@", [self.photoID pathInTemporaryDirectory]);
		return [NSURL fileURLWithPath:[self.photoID pathInTemporaryDirectory] ];
	}
}

- (UIImage *)photoInOriginalDirectory:(BOOL)inOriginalDirectory {
	NSData *data = [[NSData alloc] initWithContentsOfURL:[self photoURLInOriginalDirectory:inOriginalDirectory]];
	return [UIImage imageWithData:data];
}

- (void)setPhoto:(UIImage *)image inOriginalDirectory:(BOOL)inOriginalDirectory {
	self.photoID = [[NSUUID UUID] UUIDString];
    BOOL result = [UIImageJPEGRepresentation(image, 1.0) writeToURL:[self photoURLInOriginalDirectory:inOriginalDirectory] atomically:YES];
    if (!result) {
        FNLOG(@"\nFailed to write photo data: %@", [[self photoURLInOriginalDirectory:inOriginalDirectory] path]);
    }
}

- (UIImage *)thumbnailImageInOriginalDirectory:(BOOL)inOriginalDirectory {
	if (![self.photoID length]) return nil;
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
    if (!self.photoID) {
        return nil;
    }
    
	NSString *directory;
	if (inOriginalDirectory) {
		directory = [A3DaysCounterModelManager thumbnailDirectory];
	} else {
		directory = NSTemporaryDirectory();
	}
	NSString *imageThumbnail = [NSString stringWithFormat:@"%@-imageThumbnail", self.photoID];
	return [directory stringByAppendingPathComponent:imageThumbnail];
}

- (void)copyImagesToTemporaryDirectory {
	if (![self.photoID length]) {
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
											  error:&error
                                         byAccessor:^(NSURL *newReadingURL, NSURL *newWritingURL) {
                                             [fileManager copyItemAtURL:newReadingURL toURL:newWritingURL error:NULL];
                                         }];
		if (error) {
			FNLOG(@"%@", error.localizedDescription);
		}
        
		NSString *thumbnailPath = [self thumbnailPathInOriginalDirectory:YES];
		NSString *thumbnailPathInTemp = [self thumbnailPathInOriginalDirectory:NO];
		[fileManager removeItemAtPath:thumbnailPathInTemp error:NULL];
		[fileManager copyItemAtPath:thumbnailPath toPath:thumbnailPathInTemp error:NULL];
	});
}

- (void)moveImagesToOriginalDirectory {
	if (![self.photoID length]) {
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
                                             [fileManager removeItemAtURL:newWritingURL error:NULL];
											 [fileManager moveItemAtURL:newReadingURL toURL:newWritingURL error:NULL];
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

	self.photoID = nil;
}

@end
