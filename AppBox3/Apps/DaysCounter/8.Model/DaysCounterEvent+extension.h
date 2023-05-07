//
//  DaysCounterEvent+management.h
//  AppBox3
//
//  Created by A3 on 5/13/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "DaysCounterEvent.h"

@class DaysCounterDate;
@class DaysCounterEventLocation;
@class DaysCounterFavorite;
@class DaysCounterReminder;

@interface DaysCounterEvent (extension)

- (DaysCounterReminder *)reminderItem;
- (DaysCounterFavorite *)favorite;
- (DaysCounterDate *)startDate;
- (DaysCounterDate *)endDateCreateIfNotExist:(BOOL)createIfNotExist;
- (void)setEndDate:(DaysCounterDate *)dateObject;
- (DaysCounterEventLocation *)location;
- (void)toggleFavorite;
- (NSURL *)photoURLInOriginalDirectory:(BOOL)inOriginalDirectory;
- (UIImage *)photoInOriginalDirectory:(BOOL)inOriginalDirectory;
- (void)setPhoto:(UIImage *)image inOriginalDirectory:(BOOL)inOriginalDirectory;
- (UIImage *)thumbnailImageInOriginalDirectory:(BOOL)inOriginalDirectory;
- (UIImage *)saveThumbnailForImage:(UIImage *)originalImage inOriginalDirectory:(BOOL)inOriginalDirectory;
- (void)copyImagesToTemporaryDirectory;
- (void)moveImagesToOriginalDirectory;
- (void)deletePhoto;
- (void)deleteLocation;

@end
