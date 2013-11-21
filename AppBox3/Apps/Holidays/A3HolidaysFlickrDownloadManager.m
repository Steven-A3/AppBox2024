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

NSString *const kA3HolidayImageiPadLandScape = @"ipadLandscape";
NSString *const kA3HolidayImageiPadPortrait = @"ipadProtrait";
NSString *const kA3HolidayImageiPhone = @"iPhone";
NSString *const kA3HolidayImageiPadLandScapeList = @"ipadLandscapeList";
NSString *const kA3HolidayImageiPadPortraitList = @"ipadProtraitList";
NSString *const kA3HolidayImageiPhoneList = @"iPhoneList";

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
 Using disptach_once here ensures that multiple background sessions with the same identifier are not created in this instance of the application. If you want to support multiple background sessions within a single process, you should create each session with its own identifier.
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
	return [UIImage imageWithContentsOfFile:imagePath];
}

- (NSString *)holidayImagePathForCountryCode:(NSString *)countryCode orientation:(UIInterfaceOrientation)orientation forList:(BOOL)forList {
	NSString *savedImageFilename = [[NSUserDefaults standardUserDefaults] objectForKey:[self imageNameKeyForCountryCode:countryCode]];
	if ([savedImageFilename length]) {
		if (IS_IPHONE) {
			savedImageFilename = [NSString stringWithFormat:@"%@%@", savedImageFilename, kA3HolidayImageiPhone];
		} else {
			savedImageFilename = [NSString stringWithFormat:@"%@%@", savedImageFilename, UIInterfaceOrientationIsLandscape(orientation) ? kA3HolidayImageiPadLandScape : kA3HolidayImageiPadPortrait];
		}
		if (forList) {
			savedImageFilename = [savedImageFilename stringByAppendingString:@"List"];
		}
		NSString *filePath = [savedImageFilename pathInLibraryDirectory];
		if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
			FNLOG(@"%@", filePath);
			return filePath;
		}
	}
	return [self defaultImagePathForCountryCode:countryCode orientation:orientation forList:forList];
}

- (NSString *)defaultImagePathForCountryCode:(NSString *)countryCode orientation:(UIInterfaceOrientation)orientation forList:(BOOL)forList {
	NSString *defaultImageFileName = @"default";
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[calendar setTimeZone:[HolidayData timeZoneForCountryCode:countryCode]];
	NSDateComponents *dateComponents = [calendar components:NSHourCalendarUnit fromDate:[NSDate date]];
	BOOL imageForDay = (dateComponents.hour >= 6 && dateComponents.hour < 18);
	FNLOG(@"%@, %ld", countryCode, (long)dateComponents.hour);

	NSString *imageNameWithOption;
	imageNameWithOption = [defaultImageFileName stringByAppendingString:imageForDay ? @"day" : @"night"];
	if (IS_IPHONE) {
		imageNameWithOption = [NSString stringWithFormat:@"%@%@", imageNameWithOption, kA3HolidayImageiPhone];
	} else {
		imageNameWithOption = [NSString stringWithFormat:@"%@%@", imageNameWithOption, UIInterfaceOrientationIsLandscape(orientation) ? kA3HolidayImageiPadLandScape : kA3HolidayImageiPadPortrait];
	}
	if (forList) {
		imageNameWithOption = [imageNameWithOption stringByAppendingString:@"List"];
	}

	NSString *filePath = [imageNameWithOption pathInLibraryDirectory];
	if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
		NSString *defaultOriginalImagePath = [[NSBundle mainBundle] pathForResource:@"day" ofType:@"jpg"];
		[self cropSetOriginalImage:[UIImage imageWithContentsOfFile:defaultOriginalImagePath] name:[defaultImageFileName stringByAppendingString:@"day"]];
		defaultOriginalImagePath = [[NSBundle mainBundle] pathForResource:@"night" ofType:@"jpg"];
		[self cropSetOriginalImage:[UIImage imageWithContentsOfFile:defaultOriginalImagePath] name:[defaultImageFileName stringByAppendingString:@"night"]];
	}
	return filePath;
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
	@autoreleasepool {
		if ([self hasUserSuppliedImageForCountry:countryCode]) {
			return;
		}

		if ([self.downloadQueue containsObject:countryCode]) return;

		NSDate *downloadDate = [self downloadDateForCountryCode:countryCode];
		if (!downloadDate || [[NSDate date] timeIntervalSinceDate:downloadDate] > 60 * 5) {
			[self.downloadQueue addObject:countryCode];
		}
        
        [self startDownload];
	}
}

- (void)startDownload {
	@autoreleasepool {
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
    [self setLicenseString:self.photoInfo[@"type"] forCountryCode:countryCode];
    
    [self setDownloadDateForCountryCode:countryCode];
    
    NSData *data = [NSData dataWithContentsOfURL:downloadURL];
    UIImage *image = [UIImage imageWithData:data];
    [self cropSetOriginalImage:image name:imageName];
    
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
	@autoreleasepool {
		[self deleteImageForCountryCode:countryCode];

		NSString *imageName = [self userSuppliedImageNameForCountryCode:countryCode];
		[self setImageName:imageName forCountryCode:countryCode];

		UIImage *rotatedImage = [self rotateImage:image];
		[self cropSetOriginalImage:rotatedImage name:imageName];
	}
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
	@autoreleasepool {
		if (!path) {
			[[NSUserDefaults standardUserDefaults] removeObjectForKey:[self imageNameKeyForCountryCode:countryCode]];
		} else {
			[[NSUserDefaults standardUserDefaults] setObject:path forKey:[self imageNameKeyForCountryCode:countryCode]];
		}
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

- (NSString *)ownerStringForCountryCode:(NSString *)countryCode {
	return [[NSUserDefaults standardUserDefaults] objectForKey:[self ownerKeyForCountryCode:countryCode]];
}

- (void)setOwner:(NSString *)owner forCountryCode:(NSString *)countryCode {
	@autoreleasepool {
		[[NSUserDefaults standardUserDefaults] setObject:owner forKey:[self ownerKeyForCountryCode:countryCode]];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

- (NSString *)urlStringForCountryCode:(NSString *)countryCode {
	return [[NSUserDefaults standardUserDefaults] objectForKey:[self urlKeyForCountryCode:countryCode]];
}

- (void)setURLString:(NSString *)urlString forCountryCode:(NSString *)countryCode {
	@autoreleasepool {
		[[NSUserDefaults standardUserDefaults] setObject:urlString forKey:[self urlKeyForCountryCode:countryCode]];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

- (NSString *)licenseStringForCountryCode:(NSString *)countryCode {
	return [[NSUserDefaults standardUserDefaults] objectForKey:[self licenseKeyForCountryCode:countryCode]];
}

- (void)setLicenseString:(NSString *)urlString forCountryCode:(NSString *)countryCode {
	@autoreleasepool {
		[[NSUserDefaults standardUserDefaults] setObject:urlString forKey:[self licenseKeyForCountryCode:countryCode]];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

- (NSString *)imageIDForCountryCode:(NSString *)countryCode {
	return [[NSUserDefaults standardUserDefaults] objectForKey:[self idKeyForCountryCode:countryCode]];
}

- (void)setImageID:(NSString *)urlString forCountryCode:(NSString *)countryCode {
	@autoreleasepool {
		[[NSUserDefaults standardUserDefaults] setObject:urlString forKey:[self idKeyForCountryCode:countryCode]];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

- (NSDate *)downloadDateForCountryCode:(NSString *)countryCode {
	return [[NSUserDefaults standardUserDefaults] objectForKey:[self dateKeyForCountryCode:countryCode]];
}

- (void)setDownloadDateForCountryCode:(NSString *)countryCode {
	@autoreleasepool {
		[[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:[self dateKeyForCountryCode:countryCode]];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
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

- (UIImage *)rotateImage:(UIImage *)image {
	UIImage *imageCopy=nil;
	@autoreleasepool {
		UIImageOrientation translatedOrientation = image.imageOrientation;
		switch (image.imageOrientation) {
			case UIImageOrientationUp:
				translatedOrientation = UIImageOrientationDownMirrored;
				break;
			case UIImageOrientationDown:
				translatedOrientation = UIImageOrientationUpMirrored;
				break;
			case UIImageOrientationLeft:
				translatedOrientation = UIImageOrientationLeftMirrored;
				break;
			case UIImageOrientationRight:
				translatedOrientation = UIImageOrientationRightMirrored;
				break;
			case UIImageOrientationUpMirrored:
				translatedOrientation = UIImageOrientationUp;
				break;
			case UIImageOrientationDownMirrored:
				translatedOrientation = UIImageOrientationDown;
				break;
			case UIImageOrientationLeftMirrored:
				translatedOrientation = UIImageOrientationLeft;
				break;
			case UIImageOrientationRightMirrored:
				translatedOrientation = UIImageOrientationRight;
				break;
		}

		CGImageRef imgRef = image.CGImage;

		CGFloat width = CGImageGetWidth(imgRef);
		CGFloat height = CGImageGetHeight(imgRef);

		CGAffineTransform transform;
		CGRect bounds = CGRectMake(0, 0, width, height);
		CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
		CGFloat boundHeight;
		switch (translatedOrientation) {
			case UIImageOrientationUp: //EXIF = 1
				transform = CGAffineTransformIdentity;
				break;

			case UIImageOrientationUpMirrored: //EXIF = 2
				transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
				transform = CGAffineTransformScale(transform, -1.0, 1.0);
				break;

			case UIImageOrientationDown: //EXIF = 3
				transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
				transform = CGAffineTransformRotate(transform, M_PI);
				break;

			case UIImageOrientationDownMirrored: //EXIF = 4
				transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
				transform = CGAffineTransformScale(transform, 1.0, -1.0);
				break;

			case UIImageOrientationLeftMirrored: //EXIF = 5
				boundHeight = bounds.size.height;
				bounds.size.height = bounds.size.width;
				bounds.size.width = boundHeight;
				transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
				transform = CGAffineTransformScale(transform, -1.0, 1.0);
				transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
				break;

			case UIImageOrientationLeft: //EXIF = 6
				boundHeight = bounds.size.height;
				bounds.size.height = bounds.size.width;
				bounds.size.width = boundHeight;
				transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
				transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
				break;

			case UIImageOrientationRightMirrored: //EXIF = 7
				boundHeight = bounds.size.height;
				bounds.size.height = bounds.size.width;
				bounds.size.width = boundHeight;
				transform = CGAffineTransformMakeScale(-1.0, 1.0);
				transform = CGAffineTransformRotate(transform, M_PI / 2.0);
				break;

			case UIImageOrientationRight: //EXIF = 8
				boundHeight = bounds.size.height;
				bounds.size.height = bounds.size.width;
				bounds.size.width = boundHeight;
				transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
				transform = CGAffineTransformRotate(transform, M_PI / 2.0);
				break;

			default:
				[NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];

		}

		UIGraphicsBeginImageContext(bounds.size);

		CGContextRef context = UIGraphicsGetCurrentContext();

		CGContextConcatCTM(context, transform);

		CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
		imageCopy = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
	}

	return imageCopy;
}

- (UIImage *)cropSetOriginalImage:(UIImage *)originalImage name:(NSString *)filename {
	UIImage *handledImage;
	@autoreleasepool {
		CGFloat interpolationFactor = 10;

		if (IS_IPAD) {
			UIImage *returnedImage;
			CGRect screenBounds = [[UIScreen mainScreen] bounds];

			CGRect bounds = CGRectInset(screenBounds, -interpolationFactor, -interpolationFactor);
			NSString *path = [[NSString stringWithFormat:@"%@%@", filename, kA3HolidayImageiPadPortrait] pathInLibraryDirectory];
			returnedImage = [self saveImage:originalImage bounds:bounds path:path usingMode:(NYXCropModeCenter)];

			if (IS_PORTRAIT) handledImage = returnedImage;

			bounds = screenBounds;
			bounds.size.height = 84;
			path = [[NSString stringWithFormat:@"%@%@", filename, kA3HolidayImageiPadPortraitList] pathInLibraryDirectory];
			[self saveImage:returnedImage bounds:bounds path:path usingMode:(NYXCropModeTopCenter)];

			bounds = screenBounds;
			bounds.size.width = screenBounds.size.height;
			bounds.size.height = screenBounds.size.width;

			bounds = CGRectInset(bounds, -interpolationFactor, -interpolationFactor);
			path = [[NSString stringWithFormat:@"%@%@", filename, kA3HolidayImageiPadLandScape] pathInLibraryDirectory];
			returnedImage = [self saveImage:originalImage bounds:bounds path:path usingMode:(NYXCropModeCenter)];

			if (IS_LANDSCAPE) handledImage = returnedImage;

			bounds = screenBounds;
			bounds.size.width = screenBounds.size.height;
			bounds.size.height = 84;

			path = [[NSString stringWithFormat:@"%@%@", filename, kA3HolidayImageiPadLandScapeList] pathInLibraryDirectory];
			[self saveImage:returnedImage bounds:bounds path:path usingMode:(NYXCropModeTopCenter)];

		} else {
			CGRect screenBounds = [[UIScreen mainScreen] bounds];

			CGRect bounds = CGRectInset(screenBounds, -interpolationFactor, -interpolationFactor);
			NSString *path = [[NSString stringWithFormat:@"%@%@", filename, kA3HolidayImageiPhone] pathInLibraryDirectory];
			handledImage = [self saveImage:originalImage bounds:bounds path:path usingMode:(NYXCropModeCenter)];

			bounds = screenBounds;
			bounds.size.height = 84;
			path = [[NSString stringWithFormat:@"%@%@", filename, kA3HolidayImageiPhoneList] pathInLibraryDirectory];
			[self saveImage:handledImage bounds:bounds path:path usingMode:(NYXCropModeTopCenter)];
		}
	}
	return handledImage;
}

- (UIImage *)saveImage:(UIImage *)image bounds:(CGRect)bounds path:(NSString *)path usingMode:(NYXCropMode)cropMode {
	UIImage *croppedImage=nil;
	@autoreleasepool {
		CGSize newSize = CGSizeMake(CGRectGetWidth(bounds), CGRectGetHeight(bounds));
		FNLOG(@"%f, %f", newSize.width, newSize.height);
		UIImage *scaledImage = [image scaleToCoverSize:newSize];

		croppedImage = [scaledImage cropToSize:newSize usingMode:cropMode];
		[UIImagePNGRepresentation(croppedImage) writeToFile:path atomically:YES];
	}

	return croppedImage;
}

- (void)deleteImageForCountryCode:(NSString *)countryCode {
    FNLOG(@"Delete for %@, downloadQueue %@, deleteQueue %@", countryCode, _downloadQueue, _deleteQueue);
	@autoreleasepool {
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
		if (IS_IPAD) {
			NSString *path = [[NSString stringWithFormat:@"%@%@", filename, kA3HolidayImageiPadPortrait] pathInLibraryDirectory];
			[fileManager removeItemAtPath:path error:nil];
			path = [[NSString stringWithFormat:@"%@%@", filename, kA3HolidayImageiPadLandScape] pathInLibraryDirectory];
			[fileManager removeItemAtPath:path error:nil];
		} else {
			NSString *path = [[NSString stringWithFormat:@"%@%@", filename, kA3HolidayImageiPhone] pathInLibraryDirectory];
			[fileManager removeItemAtPath:path error:nil];
		}

		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults removeObjectForKey:[self imageNameKeyForCountryCode:countryCode]];
		[defaults removeObjectForKey:[self ownerKeyForCountryCode:countryCode]];
		[defaults removeObjectForKey:[self urlKeyForCountryCode:countryCode]];
		[defaults removeObjectForKey:[self dateKeyForCountryCode:countryCode]];
		[defaults synchronize];
	}
}

@end
