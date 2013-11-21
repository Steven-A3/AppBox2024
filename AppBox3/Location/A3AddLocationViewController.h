//
//  A3AddLocationViewController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 05/14/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

@class FSVenue;

@protocol A3AddLocationViewControllerDelegate <NSObject>
- (void)locationSelectedWithVenue:(FSVenue *)venue;
@end

@interface A3AddLocationViewController : UIViewController
@property (nonatomic, weak) id<A3AddLocationViewControllerDelegate> delegate;

- (id)initWithVenue:(FSVenue *)venue;
@end
