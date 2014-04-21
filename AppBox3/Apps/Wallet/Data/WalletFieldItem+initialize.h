//
//  WalletFieldItem+initialize.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 4..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "WalletFieldItem.h"

@interface WalletFieldItem (initialize)

- (NSString *)imageThumbnailPathInTemporary:(BOOL)temporary;

- (NSString *)videoThumbnailPathInTemporary:(BOOL)temporary;

- (NSString *)videoFilePathInTemporary:(BOOL)temporary;

- (UIImage *)thumbnailImage;
@end
