	//
//  A3AbbreviationDrillDownTableViewController.h
//  AppBox3
//
//  Created by Byeong-Kwon Kwak on 1/3/17.
//  Copyright © 2017 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3AbbreviationDataManager.h"

@protocol A3AbbreviationDrillDownDataSource;

@interface A3AbbreviationDrillDownTableViewController : UIViewController

@property (nonatomic, copy) NSString *contentsTitle;
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *contentsArray;
@property (nonatomic, weak) A3AbbreviationDataManager *dataManager;
@property (nonatomic, assign) BOOL allowsEditing;
@property (nonatomic, weak) id<A3AbbreviationDrillDownDataSource> dataSource;

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

@protocol A3AbbreviationDrillDownDataSource <NSObject>

- (void)deleteItemForContent:(id)content;
- (void)moveItemForContent:(id)content fromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;

@end
