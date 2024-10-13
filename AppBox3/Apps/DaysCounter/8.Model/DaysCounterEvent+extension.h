//
//  DaysCounterEvent+management.h
//  AppBox3
//
//  Created by A3 on 5/13/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

@class DaysCounterDate_;
@class DaysCounterEventLocation_;
@class DaysCounterFavorite_;
@class DaysCounterReminder_;

@interface DaysCounterEvent_ (extension)

- (DaysCounterReminder_ *)reminderItem;
- (DaysCounterFavorite_ *)favorite;
- (DaysCounterDate_ *)startDate;
- (DaysCounterDate_ *)endDateCreateIfNotExist:(BOOL)createIfNotExist;
- (void)setEndDate:(DaysCounterDate_ *)dateObject;
- (DaysCounterEventLocation_ *)location;
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
