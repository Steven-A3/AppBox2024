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

@interface A3FlickrImageView : A3ImageView

@property (nonatomic, weak) id<A3FlickrImageViewDelegate> delegate;
- (void)displayImage;

- (void)updateImageWithCountryCode:(NSString *)country;

- (void)updateImage;

@end
