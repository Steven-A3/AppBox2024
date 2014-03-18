//
//  A3PhotoSelectViewController.h
//  A3TeamWork
//
//  Created by coanyaa on 13. 10. 21..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol A3PhotoSelectViewControllerDelegate;
@interface A3PhotoSelectViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>{

}

@property (weak, nonatomic) id<A3PhotoSelectViewControllerDelegate> delegate;
@property (strong, nonatomic) id item;

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@end

@protocol A3PhotoSelectViewControllerDelegate <NSObject>
@optional
- (void)photoSelectViewControllerDidCancel:(A3PhotoSelectViewController*)viewCtrl;
- (void)photoSelectViewController:(A3PhotoSelectViewController *)viewCtrl didSelectItem:(id)item;
- (void)photoSelectViewControllerDidDone:(A3PhotoSelectViewController*)viewCtrl;

@end