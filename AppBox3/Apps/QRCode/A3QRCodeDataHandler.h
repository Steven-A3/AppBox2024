//
//  A3QRCodeDataHandler.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/11/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QRCodeHistory.h"

@interface A3QRCodeDataHandler : NSObject

- (void)performActionWithData:(QRCodeHistory *)history inViewController:(UIViewController *)viewController;

@end
