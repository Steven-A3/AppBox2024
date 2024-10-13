//
//  A3QRCodeDetailViewController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/10/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface A3QRCodeDetailViewController : UIViewController

@property (nonatomic, strong) QRCodeHistory_ *historyData;
@property (nonatomic, strong) NSArray<NSArray *> *sections;
@property (nonatomic, assign) BOOL showSearchOnGoogleButton;

@end
