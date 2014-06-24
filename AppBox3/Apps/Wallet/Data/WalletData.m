//
//  WalletData.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 11..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "WalletData.h"
#import "WalletFieldItem+initialize.h"
#import "NSString+conversion.h"
#import <AVFoundation/AVFoundation.h>

NSString *const WalletFieldTypeText			= @"Text";
NSString *const WalletFieldTypeNumber		= @"Number";
NSString *const WalletFieldTypePhone		= @"Phone";
NSString *const WalletFieldTypeURL			= @"URL";
NSString *const WalletFieldTypeEmail		= @"Email";
NSString *const WalletFieldTypeDate			= @"Date";
NSString *const WalletFieldTypeImage		= @"Image";
NSString *const WalletFieldTypeVideo		= @"Video";

NSString *const WalletFieldStyleNormal		= @"Normal";
NSString *const WalletFieldStylePassword	= @"Password";
NSString *const WalletFieldStyleAccount		= @"Account";
NSString *const WalletFieldStyleHidden		= @"Hidden";

NSString *const WalletFieldNativeType 		= @"NativeType";
NSString *const WalletFieldNativeTypeText	= @"Text";
NSString *const WalletFieldNativeTypeImage	= @"Image";
NSString *const WalletFieldNativeTypeVideo	= @"Video";
NSString *const WalletFieldTypeID			= @"Name";

@implementation WalletData

+ (NSArray *)typeList
{
    return @[@{WalletFieldTypeID : WalletFieldTypeText, WalletFieldNativeType : WalletFieldNativeTypeText},
             @{WalletFieldTypeID : WalletFieldTypeNumber, WalletFieldNativeType : WalletFieldTypeNumber},
             @{WalletFieldTypeID : WalletFieldTypePhone, WalletFieldNativeType : WalletFieldTypePhone},
             @{WalletFieldTypeID : WalletFieldTypeURL, WalletFieldNativeType : WalletFieldTypeURL},
             @{WalletFieldTypeID : WalletFieldTypeEmail, WalletFieldNativeType : WalletFieldTypeEmail},
             @{WalletFieldTypeID : WalletFieldTypeDate, WalletFieldNativeType : WalletFieldTypeDate},
             @{WalletFieldTypeID : WalletFieldTypeImage, WalletFieldNativeType : WalletFieldTypeImage},
             @{WalletFieldTypeID : WalletFieldTypeVideo, WalletFieldNativeType : WalletFieldTypeVideo}];
}

+ (NSDictionary *)styleList
{
    return @{
			WalletFieldNativeTypeText : @[
					WalletFieldStyleNormal,
					WalletFieldStylePassword,
					WalletFieldStyleAccount,
					WalletFieldStyleHidden
			],
			WalletFieldNativeTypeImage : @[],
			WalletFieldNativeTypeVideo : @[]};
}

+ (NSArray *)categoryPresetData
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"WalletCategoryPreset" ofType:@"plist"];
    return [[NSArray alloc] initWithContentsOfFile:filePath];
}

+ (float)getDurationOfMovie:(NSURL *)fileURL
{
    AVURLAsset* audioAsset = [AVURLAsset URLAssetWithURL:fileURL options:nil];
    CMTime duration = audioAsset.duration;
    float durationSeconds = CMTimeGetSeconds(duration);
    
    return durationSeconds;
}

+ (NSDate *)getCreateDateOfMovie:(NSURL *)fileURL
{
    AVURLAsset* audioAsset = [AVURLAsset URLAssetWithURL:fileURL options:nil];
    NSArray *metas = audioAsset.commonMetadata;
    
    for (AVMetadataItem *metaItem in metas) {
        if ([metaItem.commonKey isEqualToString:AVMetadataCommonKeyCreationDate]) {
            return metaItem.dateValue;
        }
    }
    return nil;
}

+ (UIImage *)videoPreviewImageOfURL:(NSURL *)videoUrl
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoUrl options:nil];
    AVAssetImageGenerator *generateImg = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generateImg.appliesPreferredTrackTransform = YES;
    NSError *error = NULL;
    CMTime time = CMTimeMake(1, 65);
    CGImageRef refImg = [generateImg copyCGImageAtTime:time actualTime:NULL error:&error];
    FNLOG(@"error==%@, Refimage==%@", error, refImg);
    
    UIImage *FrameImage= [[UIImage alloc] initWithCGImage:refImg];
    
    return FrameImage;
}

+ (void)createDirectories {
	NSFileManager *fileManager = [NSFileManager defaultManager];

	NSString *imagePath = [A3WalletImageDirectory pathInLibraryDirectory];
	if (![fileManager fileExistsAtPath:imagePath])
		[fileManager createDirectoryAtPath:imagePath withIntermediateDirectories:YES attributes:nil error:NULL];

	NSString *videoPath = [A3WalletVideoDirectory pathInLibraryDirectory];
	if (![fileManager fileExistsAtPath:videoPath])
		[fileManager createDirectoryAtPath:videoPath withIntermediateDirectories:YES attributes:nil error:NULL];

	NSString *imageThumbnailDirectory = [A3WalletImageThumbnailDirectory pathInCachesDirectory];
	if (![fileManager fileExistsAtPath:imageThumbnailDirectory])
		[fileManager createDirectoryAtPath:imageThumbnailDirectory withIntermediateDirectories:YES attributes:nil error:NULL];

	NSString *videoThumbnailDirectory = [A3WalletVideoThumbnailDirectory pathInCachesDirectory];
	if (![fileManager fileExistsAtPath:videoThumbnailDirectory])
		[fileManager createDirectoryAtPath:videoThumbnailDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
}

@end
