//
//  A3FlickrImageView.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/23/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3ImageView.h"

@class A3FlickrImageView;

@protocol A3FlickrImageViewDelegate <NSObject>
- (void)flickrImageViewImageUpdated:(A3FlickrImageView *)view;
@end

@interface A3FlickrImageView : DKLiveBlurView

@property (nonatomic, weak) id<A3FlickrImageViewDelegate> delegate;
@property (nonatomic, copy) NSString *countryCode;
@property (nonatomic, readonly, copy) NSString *ownerString;
@property (nonatomic, readonly, copy) NSString *urlString;
@property (nonatomic) BOOL useForCountryList;

- (void)displayImageWithCountryCode:(NSString *)countryCode;

- (BOOL)hasUserSuppliedImageForCountry:(NSString *)code;

- (void)startUpdate;

- (void)saveUserSuppliedImage:(UIImage *)image;

- (void)deleteImage;
@end
