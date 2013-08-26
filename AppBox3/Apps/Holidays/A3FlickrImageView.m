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

// NSUserDefaults
// Image will be saved with
NSString *const kA3HolidayScreenImagePath = @"kA3HolidayScreenImagePath";
NSString *const kA3HolidayScreenImageOwner = @"kA3HolidayScreenImageOwner";
NSString *const kA3HolidayScreenImageURL = @"kA3HolidayScreenImageURL";

@interface A3FlickrImageView () <CLLocationManagerDelegate, OFFlickrAPIRequestDelegate>

@property (nonatomic, strong) OFFlickrAPIContext *flickrContext;
@property (nonatomic, strong) OFFlickrAPIRequest *flickrRequest;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSArray *keywords;
@property (nonatomic, copy) NSString *administrativeArea;
@property (nonatomic, copy) NSString *cityName;
@property (nonatomic, strong) NSURL *photoURL;
@property (nonatomic, strong) NSMutableArray *photoArray;
@property (nonatomic, strong) UILabel *photoLabel;

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

- (void)displayImage {
	NSString *pathForSavedImage = [self pathForSavedImage];
	if (pathForSavedImage) {
		[self setImage:[UIImage imageWithContentsOfFile:pathForSavedImage]];
	}
	if (!self.image) {
		NSString *defaultImageFilePath = [[NSBundle mainBundle] pathForResource:@"IMG_0277" ofType:@"JPG"];
		[self setImage:[UIImage imageWithContentsOfFile:defaultImageFilePath]];
	}
}

- (void)updateImageWithCountryCode:(NSString *)country {
	NSString *countryName = [[NSLocale currentLocale] displayNameForKey:NSLocaleCountryCode value:country];
	FNLOG(@"Country name: %@", countryName);

	self.cityName = countryName;
	[self photosSearch];
}

- (void)updateImage {
	[self startAskLocation];
}

- (NSString *)pathForSavedImage {
	NSString *savedImageFilename = [[NSUserDefaults standardUserDefaults] objectForKey:kA3HolidayScreenImagePath];
	if ([savedImageFilename length]) {
		NSString *filePath = [savedImageFilename pathInLibraryDirectory];
		if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
			return filePath;
		}
	}
	return nil;
}

- (void)startAskLocation {
	_locationManager = [[CLLocationManager alloc] init];
	[_locationManager setDesiredAccuracy:kCLLocationAccuracyKilometer];
	[_locationManager setDelegate:self];
	[_locationManager startUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [manager stopUpdatingLocation];

	CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
	[geoCoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placeMarks, NSError *error) {
		for (CLPlacemark *placeMark in placeMarks) {

//			FNLOG(@"%@", [placeMarks description]);
//			FNLOG(@"address Dictionary: %@", placeMark.addressDictionary);
			FNLOG(@"Administrative Area: %@", placeMark.administrativeArea);
//			FNLOG(@"areas of Interest: %@", placeMark.areasOfInterest);
			FNLOG(@"locality: %@", placeMark.locality);
//			FNLOG(@"name: %@", placeMark.name);
//			FNLOG(@"subLocality: %@", placeMark.subLocality);
//
			[self setCityName:placeMark.locality];
            [self setAdministrativeArea:placeMark.administrativeArea];
		}

		if (_cityName) {
			[self photosSearch];
		}
	}];
}

- (void)photosSearch {
    if ([_flickrRequest isRunning]) return;
    
	NSDictionary *arguments = @{
			@"text" : [NSString stringWithFormat:@"%@ %@", _cityName, _keywords[_keywordIndex]],
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
            if ([_photoArray count] < 50) {
                self.cityName = self.administrativeArea;
            }
            
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

					[[NSUserDefaults standardUserDefaults] setObject:obj[@"id"] forKey:kA3HolidayScreenImagePath];
					[[NSUserDefaults standardUserDefaults] setObject:name forKey:kA3HolidayScreenImageOwner];
					if (photoURLString) {
						[[NSUserDefaults standardUserDefaults] setObject:photoURLString forKey:kA3HolidayScreenImageURL];
					}
					[[NSUserDefaults standardUserDefaults] synchronize];

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
