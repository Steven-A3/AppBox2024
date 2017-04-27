//
//  A3KaomojiDrillDownViewController.h
//  AppBox3
//
//  Created by Byeong-Kwon Kwak on 2/7/17.
//  Copyright © 2017 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3DrillDownDataSourceProtocols.h"

@class A3KaomojiDataManager;

@interface A3KaomojiDrillDownViewController : UIViewController

@property (nonatomic, copy) NSString *contentsTitle;
@property (nonatomic, weak) A3KaomojiDataManager *dataManager;
@property (nonatomic, strong) NSMutableArray *contentsArray;
@property (nonatomic, assign) BOOL isFavoritesList;
@property (nonatomic, weak) id<A3DrillDownDataSource> dataSource;

+ (A3KaomojiDrillDownViewController *)storyboardInstance;

@end
