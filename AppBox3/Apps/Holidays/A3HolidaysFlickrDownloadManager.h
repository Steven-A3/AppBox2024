//
//  A3HolidaysFlickrDownloadManager.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 9/16/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kA3HolidayScreenImagePath;
extern NSString *const kA3HolidayScreenImageLicense;
extern NSString *const kA3HolidayScreenImageOwner;
extern NSString *const kA3HolidayScreenImageURL;

extern NSString *A3HolidaysFlickrDownloadManagerDownloadComplete;

@interface A3HolidaysFlickrDownloadManager : NSObject

@property (nonatomic) NSURLSessionDownloadTask *downloadTask;

+ (instancetype)sharedInstance;

- (UIImage *)imageForCountryCode:(NSString *)countryCode;
- (BOOL)isDayForCountryCode:(NSString *)countryCode;
- (BOOL)hasUserSuppliedImageForCountry:(NSString *)code;
- (UIImageView *)thumbnailOfUserSuppliedImageForCountryCode:(NSString *)countryCode;
- (void)addDownloadTaskForCountryCode:(NSString *)countryCode;
- (void)saveUserSuppliedImage:(UIImage *)image forCountryCode:(NSString *)countryCode;
- (void)deleteImageForCountryCode:(NSString *)countryCode;

@end
