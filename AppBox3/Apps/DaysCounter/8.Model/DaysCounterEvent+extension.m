//
//  DaysCounterEvent+management.m
//  AppBox3
//
//  Created by A3 on 5/13/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <AppBoxKit/AppBoxKit.h>
#import "DaysCounterEvent+extension.h"
#import "UIImage+Resizing.h"
#import "A3DaysCounterModelManager.h"
#import "A3AppDelegate.h"
#import "AppBoxKit/AppBoxKit-Swift.h"
@import CloudKit;

@implementation DaysCounterEvent_ (extension)

- (DaysCounterReminder_ *)reminderItem {
	return [DaysCounterReminder_ findFirstByAttribute:@"eventID" withValue:self.uniqueID];
}

- (DaysCounterFavorite_ *)favorite {
	return [DaysCounterFavorite_ findFirstByAttribute:@"eventID" withValue:self.uniqueID];
}

/*! 이것을 호출하면 startDate가 없는 경우, 항상 만든다. 있으면 만들지 않는다.
 * \param
 * \returns
 */
- (DaysCounterDate_ *)startDate {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eventID == %@ AND isStartDate == YES", self.uniqueID];
	DaysCounterDate_ *startDate = [DaysCounterDate_ findFirstWithPredicate:predicate];
	if (!startDate) {
        startDate = [[DaysCounterDate_ alloc] initWithContext:self.managedObjectContext];
		startDate.uniqueID = [[NSUUID UUID] UUIDString];
		startDate.updateDate = [NSDate date];
		startDate.eventID = self.uniqueID;
		startDate.isStartDate = @YES;
	}
	return startDate;
}

- (DaysCounterDate_ *)endDateCreateIfNotExist:(BOOL)createIfNotExist {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eventID == %@ AND isStartDate == NO", self.uniqueID];
	DaysCounterDate_ *endDate = [DaysCounterDate_ findFirstWithPredicate:predicate];
	if (!endDate && createIfNotExist) {
        endDate = [[DaysCounterDate_ alloc] initWithContext:self.managedObjectContext];
		endDate.uniqueID = [[NSUUID UUID] UUIDString];
		endDate.updateDate = [NSDate date];
		endDate.eventID = self.uniqueID;
		endDate.isStartDate = @NO;
	}
	return endDate;
}

- (void)setEndDate:(DaysCounterDate_ *)dateObject {
	DaysCounterDate_ *endDate = [self endDateCreateIfNotExist:NO ];
	endDate.year = dateObject.year;
	endDate.month = dateObject.month;
	endDate.day = dateObject.day;
	endDate.hour = dateObject.hour;
	endDate.minute = dateObject.minute;
	endDate.solarDate = dateObject.solarDate;
	endDate.isLeapMonth = dateObject.isLeapMonth;
}

- (DaysCounterEventLocation_ *)location {
	return [DaysCounterEventLocation_ findFirstByAttribute:@"eventID" withValue:self.uniqueID];
}

- (void)toggleFavorite {
	DaysCounterFavorite_ *favorite = [self favorite];
	if (!favorite) {
        favorite = [[DaysCounterFavorite_ alloc] initWithContext:self.managedObjectContext];
		favorite.uniqueID = [[NSUUID UUID] UUIDString];
		favorite.updateDate = [NSDate date];
		favorite.eventID = self.uniqueID;
		DaysCounterFavorite_ *lastFavorite = [DaysCounterFavorite_ findFirstOrderedByAttribute:@"order" ascending:NO];
		favorite.order = [NSString orderStringWithOrder:[lastFavorite.order integerValue] + 1000000];
	} else {
        [self.managedObjectContext deleteObject:favorite];
	}
}

- (NSURL *)photoURLInOriginalDirectory:(BOOL)inOriginalDirectory {
    if (!self.photoID) {
        return nil;
    }
    
	if (inOriginalDirectory) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *path = [[A3DaysCounterImageDirectory stringByAppendingPathComponent:self.photoID] pathInAppGroupContainer];
        return [NSURL fileURLWithPath:path];
	}
    return [NSURL fileURLWithPath:[self.photoID pathInTemporaryDirectory] ];
}

- (UIImage *)photoInOriginalDirectory:(BOOL)inOriginalDirectory {
    NSURL *photoURL = [self photoURLInOriginalDirectory:inOriginalDirectory];
    
    // iCloud is not available, read from the local file system
    NSData *data = [[NSData alloc] initWithContentsOfURL:photoURL];
    if (data) {
        return [UIImage imageWithData:data];
    } else {
        FNLOG(@"Failed to read data from local file system: %@", photoURL);
    }

    // Return a temporary system image if the file is not yet available
    return [UIImage systemImageNamed:@"photo"];
}

- (void)setPhoto:(UIImage *)image inOriginalDirectory:(BOOL)inOriginalDirectory {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    self.photoID = [[NSUUID UUID] UUIDString];
    NSURL *photoURL = [self photoURLInOriginalDirectory:inOriginalDirectory];
    
    // Save the file directly to the local file system
    NSError *error = nil;
    NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
    
    [fileCoordinator coordinateWritingItemAtURL:photoURL options:NSFileCoordinatorWritingForReplacing error:&error byAccessor:^(NSURL *newURL) {
        BOOL result = [UIImageJPEGRepresentation(image, 1.0) writeToURL:newURL atomically:YES];
        if (!result) {
            NSLog(@"Failed to write photo data: %@", newURL.path);
        } else {
            NSLog(@"File successfully saved locally: %@", newURL.path);
        }
    }];
    
    if (error) {
        NSLog(@"Error during file coordination for local save: %@", error.localizedDescription);
    }
    if (@available(iOS 17.0, *)) {
        if (!inOriginalDirectory) {
            return;
        }
        CloudKitMediaFileManagerWrapper *manager = [CloudKitMediaFileManagerWrapper shared];
        [manager addFileWithUrl:photoURL recordType:A3DaysCounterImageDirectory customID:self.photoID ext:nil completion:^(NSError * _Nullable error) {
            
        }];
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
    
    NSURL *photoURLInOriginalDirectory = [self photoURLInOriginalDirectory:YES];
    NSURL *photoURLInTemporaryDirectory = [self photoURLInOriginalDirectory:NO];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager copyItemAtURL:photoURLInOriginalDirectory toURL:photoURLInTemporaryDirectory error:NULL];
    
    NSString *thumbnailPath = [self thumbnailPathInOriginalDirectory:YES];
    NSString *thumbnailPathInTemp = [self thumbnailPathInOriginalDirectory:NO];
    [fileManager removeItemAtPath:thumbnailPathInTemp error:NULL];
    [fileManager copyItemAtPath:thumbnailPath toPath:thumbnailPathInTemp error:NULL];
}

- (void)moveImagesToOriginalDirectory {
	if (![self.photoID length]) {
		[self deletePhoto];
		return;
	}

    NSURL *photoURLInOriginalDirectory = [self photoURLInOriginalDirectory:YES];
    NSURL *photoURLInTemporaryDirectory = [self photoURLInOriginalDirectory:NO];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtURL:photoURLInOriginalDirectory error:NULL];
    [fileManager moveItemAtURL:photoURLInTemporaryDirectory toURL:photoURLInOriginalDirectory error:NULL];
    
    NSString *thumbnailPath = [self thumbnailPathInOriginalDirectory:YES];
    NSString *thumbnailPathInTemp = [self thumbnailPathInOriginalDirectory:NO];
    
    [fileManager removeItemAtPath:thumbnailPath error:NULL];
    [fileManager moveItemAtPath:thumbnailPathInTemp toPath:thumbnailPath error:NULL];
    
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
    
    if (@available(iOS 17.0, *)) {
        if ([CKContainer defaultContainer]) {
            CloudKitMediaFileManagerWrapper *manager = [CloudKitMediaFileManagerWrapper shared];
            // self.photoID may be nil if photo is in the process of being deleted
            [manager removeFileWithRecordType:A3DaysCounterImageDirectory customID:[photoURL lastPathComponent] completion:^(NSError * _Nullable error) {
                
            }];
        }
    }

    self.photoID = nil;
}

- (void)deleteLocation {
    NSManagedObjectContext *editingContext = self.managedObjectContext;
    NSArray *previousLocations = [DaysCounterEventLocation_ findByAttribute:@"eventID" withValue:self.uniqueID];
    for (NSManagedObject *location in previousLocations) {
        [editingContext deleteObject:location];
    }
}

@end
