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

// NSUserDefaults
// Image will be saved with
NSString *const kA3HolidayScreenImagePath = @"kA3HolidayScreenImagePath";		// USE key + country code
NSString *const kA3HolidayScreenImageOwner = @"kA3HolidayScreenImageOwner";		// USE key + country code
NSString *const kA3HolidayScreenImageURL = @"kA3HolidayScreenImageURL";			// USE key + country code
NSString *const kA3HolidayScreenImageDownloadDate = @"kA3HolidayScreenImageDownloadDate";			// USE key + country code

@interface A3FlickrImageView () <CLLocationManagerDelegate, OFFlickrAPIRequestDelegate>

@property (nonatomic, strong) OFFlickrAPIContext *flickrContext;
@property (nonatomic, strong) OFFlickrAPIRequest *flickrRequest;
@property (nonatomic, strong) NSArray *keywords;
@property (nonatomic, copy) NSString *countryName;
@property (nonatomic, strong) NSURL *photoURL;
@property (nonatomic, strong) NSMutableArray *photoArray;
@property (nonatomic, copy) NSString *countryCode;

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
		_keywords = @[@"street", @"sky", @"national park", @"street", @"street", @"bridge"];
		_keywordIndex = arc4random_uniform([_keywords count] - 1);
	}
    return self;
}

- (void)displayImageWithCountryCode:(NSString *)countryCode {
	self.countryCode = countryCode;

	NSString *pathForSavedImage = [self pathForSavedImage];
	if (pathForSavedImage) {
		[self setImage:[UIImage imageWithContentsOfFile:pathForSavedImage]];
	}
	if (!self.image) {
		NSString *defaultImageFilePath = [[NSBundle mainBundle] pathForResource:@"IMG_0277" ofType:@"JPG"];
		[self setImage:[UIImage imageWithContentsOfFile:defaultImageFilePath]];
	}
}

- (void)startUpdate {

	if ([[Reachability reachabilityWithHostname:@"www.flickr.com"] isReachableViaWiFi]) {
		if (!self.downloadDate || [[NSDate date] timeIntervalSinceDate:self.downloadDate] > 60 * 60 * 24) {
			NSString *countryName = [[NSLocale currentLocale] displayNameForKey:NSLocaleCountryCode value:_countryCode];
			FNLOG(@"Country name: %@", countryName);

			self.countryName = countryName;
			[self photosSearch];
		}
	}
}

- (NSString *)pathForSavedImage {
	NSString *savedImageFilename = [[NSUserDefaults standardUserDefaults] objectForKey:self.imagePathKey];
	if ([savedImageFilename length]) {
		NSString *filePath = [savedImageFilename pathInLibraryDirectory];
		if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
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
					NSString *pathForSavedImage = [self pathForSavedImage];
					if (pathForSavedImage) {
						NSError *error;
						[[NSFileManager defaultManager] removeItemAtPath:pathForSavedImage error:&error];
					}

					NSString *newFilePath = [obj[@"id"] pathInLibraryDirectory];
					NSData *data = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.0)];
					[data writeToFile:newFilePath atomically:YES];

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

					[self setImage:[UIImage imageWithContentsOfFile:newFilePath]];

					if ([_delegate respondsToSelector:@selector(flickrImageViewImageUpdated:)]) {
						[_delegate flickrImageViewImageUpdated:self];
					}
				}];

				[operation start];
			}
		}
	}];
}

- (NSString *)imagePathKey {
	return [NSString stringWithFormat:@"%@%@", kA3HolidayScreenImagePath, _countryCode];
}

- (NSString *)imagePath {
	return [[NSUserDefaults standardUserDefaults] objectForKey:self.imagePathKey];
}

- (void)setImagePath:(NSString *)path {
	[[NSUserDefaults standardUserDefaults] setObject:path forKey:self.imagePathKey];
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

@end
