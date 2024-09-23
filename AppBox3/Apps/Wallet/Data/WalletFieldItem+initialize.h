//
//  WalletFieldItem+initialize.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 4..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "AppBox3-Swift.h"

@interface WalletFieldItem (initialize)

- (NSURL *)photoImageURLInOriginalDirectory:(BOOL)inOriginalDirectory;
- (UIImage *)photoImageInOriginalDirectory:(BOOL)inOriginalDirectory;
- (void)setPhotoImage:(UIImage *)image inOriginalDirectory:(BOOL)inOriginalDirectory;
- (NSString *)photoImageThumbnailPathInOriginal:(BOOL)original;
- (UIImage *)makePhotoImageThumbnailWithImage:(UIImage *)originalImage inOriginalDirectory:(BOOL)inOriginalDirectory;
- (NSString *)videoThumbnailPathInOriginal:(BOOL)inOriginal;
- (NSURL *)videoFileURLInOriginal:(BOOL)inOriginal;
- (UIImage *)makeVideoThumbnailWithImage:(UIImage *)originalImage inOriginalDirectory:(BOOL)inOriginalDirectory;
- (UIImage *)thumbnailImage;

@end
