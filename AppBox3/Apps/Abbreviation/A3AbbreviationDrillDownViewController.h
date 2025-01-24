	//
//  A3AbbreviationDrillDownViewController.h
//  AppBox3
//
//  Created by Byeong-Kwon Kwak on 1/3/17.
//  Copyright © 2017 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3AbbreviationDataManager.h"

@interface A3AbbreviationDrillDownViewController : UIViewController

@property (nonatomic, copy) NSString *contentsTitle;
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *contentsArray;
@property (nonatomic, weak) A3AbbreviationDataManager *dataManager;
@property (nonatomic, assign) BOOL isFavoritesList;
@property (nonatomic, weak) id<A3DrillDownDataSource> dataSource;

/* Expected Dictionary
(
 {
	 abbreviation = B4N;
	 meaning = "Bye For Now ";
	 tags = Top24;
 },
 .... 생략
 )
*/

+ (NSString *)storyboardID;

@end

