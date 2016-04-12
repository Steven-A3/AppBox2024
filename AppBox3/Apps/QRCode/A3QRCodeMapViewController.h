//
//  A3QRCodeMapViewController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/11/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3PlaceAnnotation.h"

@interface A3QRCodeMapViewController : UIViewController

@property (nonatomic) CLLocationCoordinate2D centerLocation;
@property (nonatomic, strong) A3PlaceAnnotation *annotation;

@end
