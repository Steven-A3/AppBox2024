//
//  DaysCounterEvent+management.h
//  AppBox3
//
//  Created by A3 on 5/13/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "DaysCounterEvent.h"

@interface DaysCounterEvent (management)

- (void)toggleFavorite;

- (UIImage *)thumbnailImageInTemporaryDirectory:(BOOL)temporary;

- (void)saveThumbnailInTemporaryDirectory;

- (void)copyThumbnailImageToTemporaryDirectory;

- (void)moveThumbnailImageToCachesDirectory;

- (void)deleteThumbnailImageInTemporary;

- (void)deletePhoto;
@end
