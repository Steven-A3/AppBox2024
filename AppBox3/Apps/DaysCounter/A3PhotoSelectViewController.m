//
//  A3PhotoSelectViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 13. 10. 21..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3PhotoSelectViewController.h"
#import "A3DaysCounterDefine.h"
#import "A3DaysCounterModelManager.h"
#import "UIViewController+A3Addition.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>

@interface A3PhotoSelectViewController ()
@property (strong, nonatomic) NSMutableArray *groupArray;
@property (strong, nonatomic) ALAssetsLibrary *assetsLibrary;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
- (void)cancelAction:(UIBarButtonItem*)button;
@end

@implementation A3PhotoSelectViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Choose Photo";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction:)];
    [self rightBarButtonDoneButton];
    
    self.groupArray = [NSMutableArray array];
    [_collectionView registerNib:[UINib nibWithNibName:@"A3PhotoSelectCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"imageCell"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_groupArray removeAllObjects];
    
    self.assetsLibrary = [[ALAssetsLibrary alloc] init];
    [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if( group != nil ){
            [_groupArray addObject:group];
        }
        else{
            [_collectionView reloadData];
        }
    } failureBlock:^(NSError *error) {
        
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.assetsLibrary = nil;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [_groupArray count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    ALAssetsGroup *group = [_groupArray objectAtIndex:section];

    return [group numberOfAssets];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"imageCell" forIndexPath:indexPath];

    ALAssetsGroup *group = [_groupArray objectAtIndex:indexPath.section];
    [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:indexPath.row] options:NSEnumerationConcurrent usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if( result != nil ){
            UIImageView *imageView = (UIImageView*)[cell viewWithTag:10];
            imageView.image = [UIImage imageWithCGImage:result.thumbnail];
            if( self.selectedIndexPath && (indexPath.section == self.selectedIndexPath.section && indexPath.row == self.selectedIndexPath.row) ){
                imageView.layer.borderColor = [[UIColor redColor] CGColor];
                imageView.layer.borderWidth = 2.0;
            }
            else{
                imageView.layer.borderColor = [[UIColor clearColor] CGColor];
                imageView.layer.borderWidth = 0.0;
            }
            [imageView setNeedsDisplay];
        }
    }];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndexPath = indexPath;
    ALAssetsGroup *group = [_groupArray objectAtIndex:indexPath.section];
    [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:indexPath.row] options:NSEnumerationConcurrent usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if( result != nil ){
            self.item = result;
            if( self.delegate && [self.delegate respondsToSelector:@selector(photoSelectViewController:didSelectItem:)])
                [self.delegate photoSelectViewController:self didSelectItem:self.item];
        }
    }];
    
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if( cell ){
        UIImageView *imageView = (UIImageView*)[cell viewWithTag:10];
        imageView.layer.borderColor = [[UIColor redColor] CGColor];
        imageView.layer.borderWidth = 2.0;
        [imageView setNeedsDisplay];
    }
}


- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if( cell ){
        UIImageView *imageView = (UIImageView*)[cell viewWithTag:10];
        imageView.layer.borderColor = [[UIColor clearColor] CGColor];
        imageView.layer.borderWidth = 0.0;
        [imageView setNeedsDisplay];
    }
}

#pragma mark - action method
- (void)doneButtonAction:(UIBarButtonItem *)button
{
    if( self.delegate && [self.delegate respondsToSelector:@selector(photoSelectViewControllerDidDone:)])
        [self.delegate photoSelectViewControllerDidDone:self];
}

- (void)cancelAction:(UIBarButtonItem *)button
{
    if( self.delegate && [self.delegate respondsToSelector:@selector(photoSelectViewControllerDidCancel:)])
        [self.delegate photoSelectViewControllerDidCancel:self];
    else
        [self dismissViewControllerAnimated:YES completion:nil];
}

@end
