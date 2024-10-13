//
//  A3QRCodeDataHandler.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/11/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol A3QRCodeDataHandlerDelegate <NSObject>
@optional
- (void)dataHandlerDidFailToPresentViewController;

@end

@interface A3QRCodeDataHandler : NSObject

@property (nonatomic, weak) id<A3QRCodeDataHandlerDelegate> delegate;

- (void)performActionWithData:(QRCodeHistory_ *)history inViewController:(UIViewController *)viewController;

@end
