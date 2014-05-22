//
//  A3HolidaysFlickrDownloadManager.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 9/16/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3HolidaysFlickrDownloadManager.h"
#import "A3UIDevice.h"
#import "common.h"
#import "UIImage+Resizing.h"
#import "NSString+conversion.h"
#import "Reachability.h"
#import "HolidayData.h"
#import "HolidayData+Country.h"

NSString *A3HolidaysFlickrDownloadManagerDownloadComplete = @"A3HolidaysFlickrDownloadManagerDownloadComplete";
NSString *const kA3HolidayScreenImagePath = @"kA3HolidayScreenImagePath";		// USE key + country code
NSString *const kA3HolidayScreenImageOwner = @"kA3HolidayScreenImageOwner";		// USE key + country code
NSString *const kA3HolidayScreenImageURL = @"kA3HolidayScreenImageURL";			// USE key + country code
NSString *const kA3HolidayScreenImageID = @"kA3HolidayScreenImageID";			// USE key + country code
NSString *const kA3HolidayScreenImageLicense = @"kA3HolidayScreenImageLicense";			// USE key + country code
NSString *const kA3HolidayScreenImageDownloadDate = @"kA3HolidayScreenImageDownloadDate";			// USE key + country code

@interface A3HolidaysFlickrDownloadManager () <NSURLSessionDelegate>

@property (atomic, strong) NSMutableArray *downloadQueue;
@property (atomic, strong) NSMutableArray *deleteQueue;
@property (atomic, strong) NSDictionary *photoInfo;
@property (nonatomic) NSURLSession *session;
@property (atomic) BOOL downloadInProgress;

@end

@implementation A3HolidaysFlickrDownloadManager {
}

+ (instancetype)sharedInstance {
    static A3HolidaysFlickrDownloadManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [A3HolidaysFlickrDownloadManager new];
    });
    
    return _sharedInstance;
}

- (NSURLSession *)backgroundSession
{
/*
 Using dispatch_once here ensures that multiple background sessions with the same identifier are not created in this instance of the application. If you want to support multiple background sessions within a single process, you should create each session with its own identifier.
 */
	static NSURLSession *session = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:@"net.allaboutapps.BackgroundTransfer.BackgroundSession"];
		session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
	});
	return session;
}

- (id)init {
	self = [super init];
	if (self) {
		self.downloadQueue = [NSMutableArray new];
		self.deleteQueue = [NSMutableArray new];
		self.downloadInProgress = NO;
		self.session = [self backgroundSession];
	}

	return self;
}

- (UIImage *)imageForCountryCode:(NSString *)countryCode orientation:(UIInterfaceOrientation)orientation forList:(BOOL)forList {
	NSString *imagePath = [self holidayImagePathForCountryCode:countryCode orientation:orientation forList:forList];
	return [imagePath length] ? [UIImage imageWithContentsOfFile:imagePath] : nil;
}

- (NSString *)holidayImagePathForCountryCode:(NSString *)countryCode orientation:(UIInterfaceOrientation)orientation forList:(BOOL)forList {
	NSString *savedImageFilename = [[NSUserDefaults standardUserDefaults] objectForKey:[self imageNameKeyForCountryCode:countryCode]];
	if ([savedImageFilename length]) {
		return [savedImageFilename pathInLibraryDirectory];
	}
	return nil;
}

- (BOOL)isDayForCountryCode:(NSString *)countryCode {
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[calendar setTimeZone:[HolidayData timeZoneForCountryCode:countryCode]];
	NSDateComponents *dateComponents = [calendar components:NSHourCalendarUnit fromDate:[NSDate date]];
	return (dateComponents.hour >= 6 && dateComponents.hour < 18);
}

- (BOOL)hasUserSuppliedImageForCountry:(NSString *)code {
	return [[self imageNameForCountryCode:code] isEqualToString:[self userSuppliedImageNameForCountryCode:code]];
}

- (UIImageView *)thumbnailOfUserSuppliedImageForCountryCode:(NSString *)countryCode {
	if ([self hasUserSuppliedImageForCountry:countryCode]) {
		NSString *path = [self holidayImagePathForCountryCode:countryCode orientation:CURRENT_ORIENTATION forList:NO];
		if (path) {
			UIImage *image = [UIImage imageWithContentsOfFile:path];
			CGSize size = CGSizeMake(30, 30);
			image = [image scaleToCoverSize:size];
			image = [image cropToSize:size usingMode:NYXCropModeCenter];
			return [[UIImageView alloc] initWithImage:image];
		}
	}
	return nil;
}

- (void)addDownloadTaskForCountryCode:(NSString *)countryCode {
	if ([self hasUserSuppliedImageForCountry:countryCode]) {
		return;
	}

	if ([self.downloadQueue containsObject:countryCode]) return;

	NSDate *downloadDate = [self downloadDateForCountryCode:countryCode];
	if (!downloadDate || [[NSDate date] timeIntervalSinceDate:downloadDate] > 5) {
		[self.downloadQueue addObject:countryCode];
	}

	[self startDownload];
}

- (void)startDownload {
	if (self.downloadInProgress || ![self.downloadQueue count]) {
		return;
	}
	if ([[Reachability reachabilityWithHostname:@"www.flickr.com"] isReachableViaWiFi]) {
		self.downloadInProgress = YES;

		NSString *filePath = [[NSBundle mainBundle] pathForResource:@"FlickrRecommendation" ofType:@"json"];
		NSError *error;
		NSArray *candidates = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:filePath] options:0 error:&error];
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"country == %@", self.downloadQueue[0]];
		candidates = [candidates filteredArrayUsingPredicate:predicate];
		if ([candidates count]) {
			static NSUInteger photoIndex = 0;

			NSString *prevPhotoID = [self imageIDForCountryCode:self.downloadQueue[0]];
			if (prevPhotoID) {
				[candidates enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
					if ([prevPhotoID isEqualToString:obj[@"photo_id"]]) {
						photoIndex = (idx + 1) % [candidates count];
						*stop = YES;
					}
				}];
			}

			self.photoInfo = candidates[photoIndex];
			NSURL *photoURL = [NSURL URLWithString:self.photoInfo[@"url"]];

			NSURLRequest *request = [NSURLRequest requestWithURL:photoURL];
			self.downloadTask = [self.session downloadTaskWithRequest:request];
			self.downloadTask.taskDescription = self.downloadQueue[0];
			[self.downloadTask resume];
		} else {
			self.downloadInProgress = NO;
			[self.downloadQueue removeObjectAtIndex:0];

			[self startDownload];
		}
	}
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)downloadURL {
    FNLOG(@"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$");
    FNLOG(@"%d, %@", self.downloadInProgress, self.downloadQueue);
    FNLOG(@"%@", downloadTask.taskDescription);
    NSString *countryCode = downloadTask.taskDescription;
    
    NSString *imageName = [NSString stringWithFormat:@"Downloaded_%@", countryCode];
    [self setImageName:imageName forCountryCode:countryCode];
    
    [self setImageID:self.photoInfo[@"photo_id"] forCountryCode:countryCode];
    [self setOwner:self.photoInfo[@"owner"] forCountryCode:countryCode];
    [self setURLString:self.photoInfo[@"flickr_url"] forCountryCode:countryCode];
    [self setLicenseString:@"cc" forCountryCode:countryCode];
    
    [self setDownloadDateForCountryCode:countryCode];
    
    NSData *data = [NSData dataWithContentsOfURL:downloadURL];
    UIImage *image = [UIImage imageWithData:data];

	[UIImageJPEGRepresentation(image, 1.0) writeToFile:[imageName pathInLibraryDirectory] atomically:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:A3HolidaysFlickrDownloadManagerDownloadComplete object:self userInfo:@{@"CountryCode" : countryCode}];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    FNLOG(@"*******************************************************************************************************************************************************");
    FNLOG(@"%d, %@", self.downloadInProgress, self.downloadQueue);
    self.downloadTask = nil;

	self.downloadInProgress = NO;
    if ([self.downloadQueue count]) {
        [self.downloadQueue removeObjectAtIndex:0];
    }

    [self startDownload];

}

- (void)saveUserSuppliedImage:(UIImage *)image forCountryCode:(NSString *)countryCode {
	[self deleteImageForCountryCode:countryCode];

	NSString *imageName = [self userSuppliedImageNameForCountryCode:countryCode];
	[self setImageName:imageName forCountryCode:countryCode];
	[UIImageJPEGRepresentation(image, 1.0) writeToFile:[imageName pathInLibraryDirectory] atomically:YES];
}

- (NSString *)userSuppliedImageNameForCountryCode:(NSString *)countryCode {
	return [NSString stringWithFormat:@"userSupplied_%@", countryCode];
}

- (NSString *)imageNameKeyForCountryCode:(NSString *)countryCode {
	return [NSString stringWithFormat:@"%@%@", kA3HolidayScreenImagePath, countryCode];
}

- (NSString *)imageNameForCountryCode:(NSString *)countryCode {
	return [[NSUserDefaults standardUserDefaults] objectForKey:[self imageNameKeyForCountryCode:countryCode]];
}

- (void)setImageName:(NSString *)path forCountryCode:(NSString *)countryCode {
	if (!path) {
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:[self imageNameKeyForCountryCode:countryCode]];
	} else {
		[[NSUserDefaults standardUserDefaults] setObject:path forKey:[self imageNameKeyForCountryCode:countryCode]];
	}
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)ownerStringForCountryCode:(NSString *)countryCode {
	return [[NSUserDefaults standardUserDefaults] objectForKey:[self ownerKeyForCountryCode:countryCode]];
}

- (void)setOwner:(NSString *)owner forCountryCode:(NSString *)countryCode {
	[[NSUserDefaults standardUserDefaults] setObject:owner forKey:[self ownerKeyForCountryCode:countryCode]];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)urlStringForCountryCode:(NSString *)countryCode {
	return [[NSUserDefaults standardUserDefaults] objectForKey:[self urlKeyForCountryCode:countryCode]];
}

- (void)setURLString:(NSString *)urlString forCountryCode:(NSString *)countryCode {
	[[NSUserDefaults standardUserDefaults] setObject:urlString forKey:[self urlKeyForCountryCode:countryCode]];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)licenseStringForCountryCode:(NSString *)countryCode {
	return [[NSUserDefaults standardUserDefaults] objectForKey:[self licenseKeyForCountryCode:countryCode]];
}

- (void)setLicenseString:(NSString *)urlString forCountryCode:(NSString *)countryCode {
	[[NSUserDefaults standardUserDefaults] setObject:urlString forKey:[self licenseKeyForCountryCode:countryCode]];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)imageIDForCountryCode:(NSString *)countryCode {
	return [[NSUserDefaults standardUserDefaults] objectForKey:[self idKeyForCountryCode:countryCode]];
}

- (void)setImageID:(NSString *)urlString forCountryCode:(NSString *)countryCode {
	[[NSUserDefaults standardUserDefaults] setObject:urlString forKey:[self idKeyForCountryCode:countryCode]];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSDate *)downloadDateForCountryCode:(NSString *)countryCode {
	return [[NSUserDefaults standardUserDefaults] objectForKey:[self dateKeyForCountryCode:countryCode]];
}

- (void)setDownloadDateForCountryCode:(NSString *)countryCode {
	[[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:[self dateKeyForCountryCode:countryCode]];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)ownerKeyForCountryCode:(NSString *)countryCode {
	return [NSString stringWithFormat:@"%@%@", kA3HolidayScreenImageOwner, countryCode];
}

- (NSString *)urlKeyForCountryCode:(NSString *)countryCode {
	return [NSString stringWithFormat:@"%@%@", kA3HolidayScreenImageURL, countryCode];
}

- (NSString *)licenseKeyForCountryCode:(NSString *)countryCode {
	return [NSString stringWithFormat:@"%@%@", kA3HolidayScreenImageLicense, countryCode];
}

- (NSString *)dateKeyForCountryCode:(NSString *)countryCode {
	return [NSString stringWithFormat:@"%@%@", kA3HolidayScreenImageDownloadDate, countryCode];
}

- (NSString *)idKeyForCountryCode:(NSString *)countryCode {
	return [NSString stringWithFormat:@"%@%@", kA3HolidayScreenImageID, countryCode];
}

- (void)deleteImageForCountryCode:(NSString *)countryCode {
	FNLOG(@"Delete for %@, downloadQueue %@, deleteQueue %@", countryCode, _downloadQueue, _deleteQueue);
	if ([self.downloadQueue containsObject:countryCode]) {
		if (self.downloadInProgress && [self.downloadQueue indexOfObject:countryCode] == 0) {
			[self.downloadTask cancel];
			if (![self.deleteQueue containsObject:countryCode])
				[self.deleteQueue addObject:countryCode];
			return;
		} else {
			[self.downloadQueue removeObject:countryCode];
		}
	}
	NSString *filename = [[NSUserDefaults standardUserDefaults] objectForKey:[self imageNameKeyForCountryCode:countryCode]];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	[fileManager removeItemAtPath:[filename pathInLibraryDirectory] error:NULL];

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults removeObjectForKey:[self imageNameKeyForCountryCode:countryCode]];
	[defaults removeObjectForKey:[self ownerKeyForCountryCode:countryCode]];
	[defaults removeObjectForKey:[self urlKeyForCountryCode:countryCode]];
	[defaults removeObjectForKey:[self dateKeyForCountryCode:countryCode]];
	[defaults synchronize];
}

@end
