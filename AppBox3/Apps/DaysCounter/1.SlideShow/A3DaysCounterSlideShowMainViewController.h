//
//  A3DaysCounterViewController.h
//  A3TeamWork
//
//  Created by coanyaa on 13. 10. 17..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3CenterViewDelegate.h"
@class A3DaysCounterModelManager;
@interface A3DaysCounterSlideShowMainViewController : UIViewController<A3CenterViewDelegate, UIPopoverControllerDelegate, UIGestureRecognizerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>{
    NSInteger currentIndex;
}
@property (strong, nonatomic) A3DaysCounterModelManager *sharedManager;
@property (strong, nonatomic) IBOutlet UIToolbar *topToolbar;
@property (strong, nonatomic) IBOutlet UIToolbar *bottomToolbar;
@property (strong, nonatomic) IBOutlet UIView *naviRightButtonView;
@property (strong, nonatomic) IBOutlet UIView *noPhotoView;
@property (strong, nonatomic) IBOutlet UIButton *addEventButton;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UIView *naviRightButtonViewiPhone;

- (IBAction)detailAction:(id)sender;
- (IBAction)calendarViewAction:(id)sender;
- (IBAction)addEventAction:(id)sender;
- (IBAction)reminderAction:(id)sender;
- (IBAction)favoriteAction:(id)sender;
- (IBAction)shareOtherAction:(id)sender;
@end