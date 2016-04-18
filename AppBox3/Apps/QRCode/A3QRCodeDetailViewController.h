//
//  A3QRCodeDetailViewController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/10/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QRCodeHistory;

@interface A3QRCodeDetailViewController : UIViewController

@property (nonatomic, strong) QRCodeHistory *historyData;
@property (nonatomic, strong) NSArray<NSArray *> *sections;
@property (nonatomic, assign) BOOL showSearchOnGoogleButton;

@end
