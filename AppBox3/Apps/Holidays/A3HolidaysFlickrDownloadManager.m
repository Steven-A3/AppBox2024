//
//  A3HolidaysFlickrDownloadManager.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 9/16/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3HolidaysFlickrDownloadManager.h"
#import "ObjectiveFlickr.h"
#import "FlickrAPIKey.h"
#import "A3UIDevice.h"
#import "common.h"
#import "UIImage+Resizing.h"
#import "NSString+conversion.h"
#import "Reachability.h"
#import "AFImageRequestOperation.h"
#import "HolidayData.h"
#import "HolidayData+Country.h"

NSString *A3HolidaysFlickrDownloadManagerDownloadComplete = @"A3HolidaysFlickrDownloadManagerDownloadComplete";
NSString *const kA3HolidayScreenImagePath = @"kA3HolidayScreenImagePath";		// USE key + country code
NSString *const kA3HolidayScreenImageOwner = @"kA3HolidayScreenImageOwner";		// USE key + country code
NSString *const kA3HolidayScreenImageURL = @"kA3HolidayScreenImageURL";			// USE key + country code
NSString *const kA3HolidayScreenImageDownloadDate = @"kA3HolidayScreenImageDownloadDate";			// USE key + country code

NSString *const kA3HolidayImageiPadLandScape = @"ipadLandscape";
NSString *const kA3HolidayImageiPadPortrait = @"ipadProtrait";
NSString *const kA3HolidayImageiPhone = @"iPhone";
NSString *const kA3HolidayImageiPadLandScapeList = @"ipadLandscapeList";
NSString *const kA3HolidayImageiPadPortraitList = @"ipadProtraitList";
NSString *const kA3HolidayImageiPhoneList = @"iPhoneList";

@interface A3HolidaysFlickrDownloadManager () <OFFlickrAPIRequestDelegate>

@property (atomic, strong) NSMutableArray *downloadQueue;
@property (atomic, strong) NSMutableArray *deleteQueue;
@property (nonatomic, strong) OFFlickrAPIContext *flickrContext;
@property (nonatomic, strong) OFFlickrAPIRequest *flickrRequest;
@property (nonatomic, strong) NSArray *keywords;
@property (nonatomic, strong) NSMutableArray *photoArray;
@property (nonatomic, strong) NSURL *photoURL;

@end

@implementation A3HolidaysFlickrDownloadManager {
	NSUInteger _keywordIndex;
	BOOL _downloadInProgress;
}

+ (instancetype)sharedInstance {
    static A3HolidaysFlickrDownloadManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [A3HolidaysFlickrDownloadManager new];
    });
    
    return _sharedInstance;
}

- (id)init {
	self = [super init];
	if (self) {
		_downloadQueue = [NSMutableArray new];
		_deleteQueue = [NSMutableArray new];
		_flickrContext = [[OFFlickrAPIContext alloc] initWithAPIKey:OBJECTIVE_FLICKR_API_KEY sharedSecret:OBJECTIVE_FLICKR_API_SHARED_SECRET];
		_flickrRequest = [[OFFlickrAPIRequest alloc] initWithAPIContext:_flickrContext];
		[_flickrRequest setDelegate:self];
		_keywords = @[@"nature", @"bridge"];
		_keywordIndex = arc4random_uniform([_keywords count] - 1);
		_downloadInProgress = NO;
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
	FNLOG(@"%@, %d", countryCode, dateComponents.hour);

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

		if ([_downloadQueue containsObject:countryCode]) return;

		NSDate *downloadDate = [self downloadDateForCountryCode:countryCode];
		if (!downloadDate || [[NSDate date] timeIntervalSinceDate:downloadDate] > 60 * 60 * 24) {
			[_downloadQueue addObject:countryCode];
		}
		dispatch_async(dispatch_get_main_queue(), ^{
			[self startDownload];
		});
	}
}

- (void)startDownload {
	@autoreleasepool {
		if (_downloadInProgress || ![_downloadQueue count]) {
			return;
		}
		if ([[Reachability reachabilityWithHostname:@"www.flickr.com"] isReachableViaWiFi]) {
			_downloadInProgress = YES;
			[self photosSearch];
		}
	}
}

- (void)photosSearch {
	@autoreleasepool {
		FNLOG();
		if ([_flickrRequest isRunning]) {
			FNLOG(@"이 경우는 발생해서는 안됩니다. Flickr 리퀘스트가 진행중인데 또 요청이 들어오는 경우가 있으면 안됩니다. 원인을 찾아서 수정해야 합니다.");
			return;
		}

		NSString *countryCode = _downloadQueue[0];
		NSString *countryName = [[NSLocale currentLocale] displayNameForKey:NSLocaleCountryCode value:countryCode];

		NSDictionary *arguments = @{
				@"text" : [NSString stringWithFormat:@"%@ %@", countryName, _keywords[_keywordIndex]],
				@"sort" : @"interestingness-desc",
				@"content_type" : @"1",		// Photos only
				@"max_upload_date" : [NSString stringWithFormat:@"%.f", [[NSDate dateWithTimeInterval:-(60*60*24*365*2) sinceDate:[NSDate date]] timeIntervalSince1970] ],
				@"per_page" : @"200",
		};
		FNLOG(@"%@", arguments);
		[_flickrRequest callAPIMethodWithGET:@"flickr.photos.search" arguments:arguments];

		_keywordIndex = (_keywordIndex + 1) % [_keywords count];
	}
}

- (void)photosGetInfo {
	@autoreleasepool {
		NSUInteger index = arc4random_uniform([_photoArray count] - 1);
		NSDictionary *photoDict = _photoArray[index];
		_photoURL = [_flickrContext photoSourceURLFromDictionary:photoDict size:OFFlickrLargeSize];
		[_flickrRequest callAPIMethodWithGET:@"flickr.photos.getInfo" arguments:@{@"photo_id":photoDict[@"id"], @"secret":photoDict[@"secret"]}];

		[_photoArray removeObjectAtIndex:index];
	}
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didCompleteWithResponse:(NSDictionary *)inResponseDictionary {
	FNLOG();
	@autoreleasepool {
		NSString *countryCode = _downloadQueue[0];
		if ([_deleteQueue containsObject:countryCode]) {
			[_downloadQueue removeObject:countryCode];
			[_deleteQueue removeObject:countryCode];

			[self deleteImageForCountryCode:countryCode];

			_downloadInProgress = NO;

			[self startDownload];
			return;
		}

		[inResponseDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
			if ([key isEqualToString:@"photos"]) {
				_photoArray = [[obj valueForKeyPath:@"photo"] mutableCopy];

				FNLOG(@"number of photos: %d", [_photoArray count]);

				if ([_photoArray count]) {
					[self photosGetInfo];
				} else {
					[self photosSearch];
				}
			} else if ([key isEqualToString:@"photo"]) {
				NSDate *postedDate = [NSDate dateWithTimeIntervalSince1970:[obj[@"dates"][@"posted"] doubleValue]];
				FNLOG(@"%@", postedDate);
				NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:postedDate];
				if (interval >= 60 * 60 * 24 * 365 * 3) {
					if ([_photoArray count]) {
						[self photosGetInfo];
					} else {
						[self photosSearch];
					}
				} else {
					FNLOG(@"%@", obj);
					AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:[NSURLRequest requestWithURL:_photoURL] success:^(UIImage *image) {
						NSString *countryCode = _downloadQueue[0];

						NSString *name = obj[@"owner"][@"realname"];
						if (![name length]) name = obj[@"owner"][@"username"];

						NSString *photoURLString = nil;
						if (obj[@"urls"] && obj[@"urls"][@"url"]) {
							NSArray *array = obj[@"urls"][@"url"];
							if ([array count]) {
								photoURLString = array[0][@"_text"];
							}
						}

						NSString *imageName = [NSString stringWithFormat:@"Downloaded_%@", countryCode];
						[self setImageName:imageName forCountryCode:countryCode];

						[self setOwner:name forCountryCode:countryCode];

						if (photoURLString) {
							[self setURLString:photoURLString forCountryCode:countryCode];
						}
						[self setDownloadDateForCountryCode:countryCode];

						[self cropSetOriginalImage:image name:imageName];

						[[NSNotificationCenter defaultCenter] postNotificationName:A3HolidaysFlickrDownloadManagerDownloadComplete object:self userInfo:@{@"CountryCode" : countryCode}];

						_downloadInProgress = NO;
						[_downloadQueue removeObjectAtIndex:0];

						[self startDownload];
					}];

					[operation start];
				}
			}
		}];
	}
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didFailWithError:(NSError *)inError {
	@autoreleasepool {
		_downloadInProgress = NO;
		FNLOG(@"%@,%@,%@,%@", inError.localizedDescription, inError.localizedRecoveryOptions, inError.localizedRecoverySuggestion, inError.localizedFailureReason);
	}
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

- (NSString *)dateKeyForCountryCode:(NSString *)countryCode {
	return [NSString stringWithFormat:@"%@%@", kA3HolidayScreenImageDownloadDate, countryCode];
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

		if ([_downloadQueue containsObject:countryCode]) {
			if (_downloadInProgress && [_downloadQueue indexOfObject:countryCode] == 0) {
				[_deleteQueue addObject:countryCode];
				return;
			} else {
				[_downloadQueue removeObject:countryCode];
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
