//
//  A3WalletAllTopView.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 14..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3WalletSegmentedControl.h"


@interface A3WalletAllTopView : UIView

@property (strong, nonatomic) IBOutlet UILabel *cateLabel;
@property (strong, nonatomic) IBOutlet UILabel *itemsLabel;
@property (strong, nonatomic) IBOutlet UILabel *updatedLabel;
@property (strong, nonatomic) IBOutlet A3WalletSegmentedControl *sortingSegment;

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *horLines;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *vertLines;

- (void)make1LinePixel;

@end
