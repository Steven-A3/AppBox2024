//
//  WalletData.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 11..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "WalletData.h"
#import <AVFoundation/AVFoundation.h>

@implementation WalletData

+ (NSArray *)typeList
{
    return @[@{@"Name": @"Text", @"Type" : @"Character"},
             @{@"Name": @"Number", @"Type" : @"Character"},
             @{@"Name": @"Phone", @"Type" : @"Character"},
             @{@"Name": @"URL", @"Type" : @"Character"},
             @{@"Name": @"Email", @"Type" : @"Character"},
             @{@"Name": @"Date", @"Type" : @"Character"},
             @{@"Name": @"Image", @"Type" : @"Image"},
             @{@"Name": @"Video", @"Type" : @"Video"}];
}

+ (NSDictionary *)styleList
{
    return @{@"Character": @[@"Normal",
                             @"Password",
                             @"Account",
                             @"Hidden"],
             @"Image" : @[],
             @"Video" : @[]};
}

+ (NSArray *)categoryPresetData
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"WalletCategoryPreset" ofType:@"plist"];
    return [[NSArray alloc] initWithContentsOfFile:filePath];
}

+ (NSString *)thumbImgPathOfImgPath:(NSString *)imagePath
{
    NSString *extenstion = [imagePath pathExtension];
    imagePath = [[[imagePath stringByDeletingPathExtension] stringByAppendingString:@"_thumb"] stringByAppendingPathExtension:extenstion];
    
    return imagePath;
}

+ (NSString *)thumbImgPathOfVideoPath:(NSString *)videoPath
{
    NSString *imagePath = [[[videoPath stringByDeletingPathExtension] stringByAppendingString:@"_thumb"] stringByAppendingPathExtension:@"jpg"];
    
    return imagePath;
}

+ (void)deleteFileAtPath:(NSString *)filePath
{
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if (filePath && [fm fileExistsAtPath:filePath]) {
        [fm removeItemAtPath:filePath error:nil];
    }
}

+ (float)getDurationOfMovie:(NSString *)filePath
{
    AVURLAsset* audioAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:filePath] options:nil];
    CMTime duration = audioAsset.duration;
    float durationSeconds = CMTimeGetSeconds(duration);
    
    return durationSeconds;
}

+ (NSDate *)getCreateDateOfMovie:(NSString *)filePath
{
    AVURLAsset* audioAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:filePath] options:nil];
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
    NSLog(@"error==%@, Refimage==%@", error, refImg);
    
    UIImage *FrameImage= [[UIImage alloc] initWithCGImage:refImg];
    
    return FrameImage;
}

@end
