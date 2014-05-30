//
//  WalletData.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 11..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "WalletData.h"
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

NSString *const WalletCategoryTypePhoto		= @"Photos";
NSString *const WalletCategoryTypeVideo		= @"Video";

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
