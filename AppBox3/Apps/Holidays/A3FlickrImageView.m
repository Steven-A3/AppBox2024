//
//  A3FlickrImageView.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/23/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3FlickrImageView.h"
#import "ObjectiveFlickr.h"
#import "FlickrAPIKey.h"
#import "common.h"
#import "UIImageView+AFNetworking.h"
#import "NSString+conversion.h"
#import "Reachability.h"
#import "UIImage+Resizing.h"
#import "A3UIDevice.h"
#import "UIImage+Saving.h"
#import "UIImage+Filtering.h"
#import "HolidayData.h"
#import "HolidayData+Country.h"

// NSUserDefaults
// Image will be saved with
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

@interface A3FlickrImageView () <CLLocationManagerDelegate, OFFlickrAPIRequestDelegate>

@property (nonatomic, strong) OFFlickrAPIContext *flickrContext;
@property (nonatomic, strong) OFFlickrAPIRequest *flickrRequest;
@property (nonatomic, strong) NSArray *keywords;
@property (nonatomic, copy) NSString *countryName;
@property (nonatomic, strong) NSURL *photoURL;
@property (nonatomic, strong) NSMutableArray *photoArray;

@end

@implementation A3FlickrImageView {
    NSUInteger _keywordIndex;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		// Initialization code
		_flickrContext = [[OFFlickrAPIContext alloc] initWithAPIKey:OBJECTIVE_FLICKR_API_KEY sharedSecret:OBJECTIVE_FLICKR_API_SHARED_SECRET];
		_flickrRequest = [[OFFlickrAPIRequest alloc] initWithAPIContext:_flickrContext];
		[_flickrRequest setDelegate:self];
		_keywords = @[@"sky", @"national park", @"weather", @"bridge", @"mountain"];
		_keywordIndex = arc4random_uniform([_keywords count] - 1);
        self.initialBlurLevel = 0.4;
	}
    return self;
}

- (void)displayImageWithCountryCode:(NSString *)countryCode {
	self.countryCode = countryCode;

	NSString *pathForSavedImage = [self pathForSavedImage];
	if (pathForSavedImage) {
		self.originalImage = [UIImage imageWithContentsOfFile:pathForSavedImage];
	} else {
		NSString *defaultImageFileName = @"default";
		NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		[calendar setTimeZone:[HolidayData timeZoneForCountryCode:_countryCode]];
		NSDateComponents *dateComponents = [calendar components:NSHourCalendarUnit fromDate:[NSDate date]];
		BOOL imageForDay = (dateComponents.hour >= 6 && dateComponents.hour < 18);
		FNLOG(@"%@, %d", _countryCode, dateComponents.hour);

		NSString *imageNameWithOption;
		imageNameWithOption = [defaultImageFileName stringByAppendingString:imageForDay ? @"day" : @"night"];
		if (IS_IPHONE) {
			imageNameWithOption = [NSString stringWithFormat:@"%@%@", imageNameWithOption, kA3HolidayImageiPhone];
		} else {
			imageNameWithOption = [NSString stringWithFormat:@"%@%@", imageNameWithOption, IS_LANDSCAPE ? kA3HolidayImageiPadLandScape : kA3HolidayImageiPadPortrait];
		}
		if (_useForCountryList) {
			imageNameWithOption = [imageNameWithOption stringByAppendingString:@"List"];
		}

		if (![[NSFileManager defaultManager] fileExistsAtPath:[imageNameWithOption pathInLibraryDirectory]]) {
			NSString *defaultOriginalImagePath = [[NSBundle mainBundle] pathForResource:@"day" ofType:@"jpg"];
			[self cropSetOriginalImage:[UIImage imageWithContentsOfFile:defaultOriginalImagePath] name:[defaultImageFileName stringByAppendingString:@"day"]];
			defaultOriginalImagePath = [[NSBundle mainBundle] pathForResource:@"night" ofType:@"jpg"];
			[self cropSetOriginalImage:[UIImage imageWithContentsOfFile:defaultOriginalImagePath] name:[defaultImageFileName stringByAppendingString:@"night"]];
		}
        self.originalImage = [UIImage imageWithContentsOfFile:[imageNameWithOption pathInLibraryDirectory] ];
	}
}

- (BOOL)hasUserSuppliedImageForCountry:(NSString *)code {
	return [[self imagePath] isEqualToString:@"userSupplied"];
}

- (void)startUpdate {
	if ([[self imagePath] isEqualToString:@"userSupplied"]) {
		return;
	}

	if ([[Reachability reachabilityWithHostname:@"www.flickr.com"] isReachableViaWiFi]) {
		if (!self.downloadDate || [[NSDate date] timeIntervalSinceDate:self.downloadDate] > 60 * 60 * 24) {
			NSString *countryName = [[NSLocale currentLocale] displayNameForKey:NSLocaleCountryCode value:_countryCode];
			FNLOG(@"Country name: %@", countryName);

			self.countryName = countryName;
			[self photosSearch];

			return;
		}
	}
	if ([_delegate respondsToSelector:@selector(flickrImageViewImageUpdated:)]) {
		[_delegate flickrImageViewImageUpdated:self];
	}
}

- (NSString *)pathForSavedImage {
	NSString *savedImageFilename = [[NSUserDefaults standardUserDefaults] objectForKey:self.imagePathKey];
	if ([savedImageFilename length]) {
		if (IS_IPHONE) {
			savedImageFilename = [NSString stringWithFormat:@"%@%@", savedImageFilename, kA3HolidayImageiPhone];
		} else {
			savedImageFilename = [NSString stringWithFormat:@"%@%@", savedImageFilename, IS_LANDSCAPE ? kA3HolidayImageiPadLandScape : kA3HolidayImageiPadPortrait];
		}
		if (_useForCountryList) {
			savedImageFilename = [savedImageFilename stringByAppendingString:@"List"];
		}
		NSString *filePath = [savedImageFilename pathInLibraryDirectory];
		if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
			FNLOG(@"%@", filePath);
			return filePath;
		}
	}
	return nil;
}

- (void)photosSearch {
    if ([_flickrRequest isRunning]) return;
    
	NSDictionary *arguments = @{
			@"text" : [NSString stringWithFormat:@"%@ %@", _countryName, _keywords[_keywordIndex]],
			@"sort" : @"interestingness-desc",
			@"content_type" : @"1",		// Photos only
			@"max_upload_date" : [NSString stringWithFormat:@"%.f", [[NSDate dateWithTimeInterval:-(60*60*24*365*2) sinceDate:[NSDate date]] timeIntervalSince1970] ],
			@"per_page" : @"200",
	};
	FNLOG(@"%@", arguments);
	[_flickrRequest callAPIMethodWithGET:@"flickr.photos.search" arguments:arguments];

	_keywordIndex = (_keywordIndex + 1) % [_keywords count];
}

#pragma mark - OFFlickrAPIRequestDelegate

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didCompleteWithResponse:(NSDictionary *)inResponseDictionary {
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
			NSDate *postedDate = [NSDate dateWithTimeIntervalSince1970:[obj[@"dates"][@"posted"] doubleValue] ];
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
				FNLOG(@"%@", _photoURL);
				AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:[NSURLRequest requestWithURL:_photoURL] success:^(UIImage *image) {

					if (![[self imagePath] isEqualToString:@"default"]) {
						[self deleteImage];
					}

					NSString *name = obj[@"owner"][@"realname"];
					if (![name length]) name = obj[@"owner"][@"username"];

					NSString *photoURLString = nil;
					if (obj[@"urls"] && obj[@"urls"][@"url"]) {
						NSArray *array = obj[@"urls"][@"url"];
						if ([array count]) {
							photoURLString = array[0][@"_text"];
						}
					}

					[self setImagePath:obj[@"id"]];

					[self setOwner:name];

					if (photoURLString) {
						[self setURLString:photoURLString];
					}
					[self setDownloadDate];

					self.originalImage = [self cropSetOriginalImage:image name: obj[@"id"] ];

					if ([_delegate respondsToSelector:@selector(flickrImageViewImageUpdated:)]) {
						[_delegate flickrImageViewImageUpdated:self];
					}
				}];

				[operation start];
			}
		}
	}];
}

- (void)saveUserSuppliedImage:(UIImage *)image {
	[self deleteImage];

	[self setImagePath:@"userSupplied"];

	[self cropSetOriginalImage:image name:@"userSupplied" ];
}

- (NSString *)imagePathKey {
	return [NSString stringWithFormat:@"%@%@", kA3HolidayScreenImagePath, _countryCode];
}

- (NSString *)imagePath {
	return [[NSUserDefaults standardUserDefaults] objectForKey:self.imagePathKey];
}

- (void)setImagePath:(NSString *)path {
	if (!path) {
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:self.imagePathKey];
	} else {
		[[NSUserDefaults standardUserDefaults] setObject:path forKey:self.imagePathKey];
	}
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)ownerString {
	return [[NSUserDefaults standardUserDefaults] objectForKey:self.ownerKey];
}

- (void)setOwner:(NSString *)owner {
	[[NSUserDefaults standardUserDefaults] setObject:owner forKey:self.ownerKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)urlString {
	return [[NSUserDefaults standardUserDefaults] objectForKey:self.urlKey];
}

- (void)setURLString:(NSString *)urlString {
	[[NSUserDefaults standardUserDefaults] setObject:urlString forKey:self.urlKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSDate *)downloadDate {
	return [[NSUserDefaults standardUserDefaults] objectForKey:self.dateKey];
}

- (void)setDownloadDate {
	[[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:self.dateKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)ownerKey {
	return [NSString stringWithFormat:@"%@%@", kA3HolidayScreenImageOwner, _countryCode];
}
- (NSString *)urlKey {
	return [NSString stringWithFormat:@"%@%@", kA3HolidayScreenImageURL, _countryCode];
}

- (NSString *)dateKey {
	return [NSString stringWithFormat:@"%@%@", kA3HolidayScreenImageDownloadDate, _countryCode];
}

- (void)photosGetInfo {
	NSUInteger index = arc4random_uniform([_photoArray count] - 1);
	NSDictionary *photoDict = _photoArray[index];
	_photoURL = [_flickrContext photoSourceURLFromDictionary:photoDict size:OFFlickrLargeSize];
	[_flickrRequest callAPIMethodWithGET:@"flickr.photos.getInfo" arguments:@{@"photo_id":photoDict[@"id"], @"secret":photoDict[@"secret"]}];

	[_photoArray removeObjectAtIndex:index];
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didFailWithError:(NSError *)inError {

}

- (UIImage *)cropSetOriginalImage:(UIImage *)image name:(NSString *)filename {
	UIImage *handledImage;
	if (IS_IPAD) {
		UIImage *returnedImage;
		CGRect screenBounds = [[UIScreen mainScreen] bounds];

		CGRect bounds = CGRectInset(screenBounds, -50, -50);
		NSString *path = [[NSString stringWithFormat:@"%@%@", filename, kA3HolidayImageiPadPortrait] pathInLibraryDirectory];
		returnedImage = [self saveImage:image bounds:bounds path:path usingMode:(NYXCropModeCenter)];

		if (IS_PORTRAIT) handledImage = returnedImage;

		bounds = screenBounds;
		bounds.size.height = 84;
		path = [[NSString stringWithFormat:@"%@%@", filename, kA3HolidayImageiPadPortraitList] pathInLibraryDirectory];
		[self saveImage:image bounds:bounds path:path usingMode:(NYXCropModeTopCenter)];

		bounds = screenBounds;
		bounds.size.width = screenBounds.size.height;
		bounds.size.height = screenBounds.size.width;

		bounds = CGRectInset(bounds, -50, -50);
		path = [[NSString stringWithFormat:@"%@%@", filename, kA3HolidayImageiPadLandScape] pathInLibraryDirectory];
		returnedImage = [self saveImage:image bounds:bounds path:path usingMode:(NYXCropModeCenter)];

		if (IS_LANDSCAPE) handledImage = returnedImage;

		bounds = screenBounds;
		bounds.size.width = screenBounds.size.height;
		bounds.size.height = 84;

		path = [[NSString stringWithFormat:@"%@%@", filename, kA3HolidayImageiPadLandScapeList] pathInLibraryDirectory];
		[self saveImage:image bounds:bounds path:path usingMode:(NYXCropModeTopCenter)];

	} else {
		CGRect screenBounds = [[UIScreen mainScreen] bounds];

		CGRect bounds = CGRectInset(screenBounds, -50, -50);
		NSString *path = [[NSString stringWithFormat:@"%@%@", filename, kA3HolidayImageiPhone] pathInLibraryDirectory];
		handledImage = [self saveImage:image bounds:bounds path:path usingMode:(NYXCropModeCenter)];

		bounds = screenBounds;
		bounds.size.height = 84;
		path = [[NSString stringWithFormat:@"%@%@", filename, kA3HolidayImageiPhoneList] pathInLibraryDirectory];
		[self saveImage:handledImage bounds:bounds path:path usingMode:(NYXCropModeTopCenter)];
	}
	return handledImage;
}

- (UIImage *)saveImage:(UIImage *)image bounds:(CGRect)bounds path:(NSString *)path usingMode:(NYXCropMode)cropMode {
	UIImage *scaledImage = [image scaleToCoverSize:bounds.size];
	UIImage *croppedImage = [scaledImage cropToSize:bounds.size usingMode:cropMode];
	[UIImageJPEGRepresentation(croppedImage, 0.5) writeToFile:path atomically:YES];

	return croppedImage;
}

- (void)deleteImage {
	NSString *filename = [[NSUserDefaults standardUserDefaults] objectForKey:self.imagePathKey];
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
	[defaults removeObjectForKey:self.imagePathKey];
	[defaults removeObjectForKey:self.ownerKey];
	[defaults removeObjectForKey:self.urlKey];
	[defaults removeObjectForKey:self.dateKey];
	[defaults synchronize];
}

@end
