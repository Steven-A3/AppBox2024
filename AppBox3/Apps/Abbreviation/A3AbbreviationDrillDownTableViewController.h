	//
//  A3AbbreviationDrillDownTableViewController.h
//  AppBox3
//
//  Created by Byeong-Kwon Kwak on 1/3/17.
//  Copyright © 2017 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface A3AbbreviationDrillDownTableViewController : UIViewController

@property (nonatomic, copy) NSString *contentsTitle;
@property (nonatomic, copy) NSArray<NSDictionary *> *contentsArray;

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
