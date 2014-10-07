//
//  A3CameraViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/3/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "A3CameraViewController.h"
#import "MWPhotoBrowser.h"

@interface A3CameraViewController () <MWPhotoBrowserDelegate>

@property (nonatomic, strong) ALAssetsGroup *assetrollGroup;
@property (nonatomic, strong) NSMutableArray *availablePhotos;

@end

@implementation A3CameraViewController

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
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
	return [_availablePhotos count];
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
	if (index == 0 && self.capturedPhotoURL) {
		return [MWPhoto photoWithURL:self.capturedPhotoURL];
	}
	NSMutableArray *assetArray = [NSMutableArray new];
	if (index < [_availablePhotos count]) {
		[_assetrollGroup enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:[_availablePhotos[index] integerValue]] options:NSEnumerationConcurrent usingBlock:^(ALAsset *result, NSUInteger i, BOOL *stop) {
			if (result != nil) {
				[assetArray addObject:result];
				*stop = YES;
			}
		}];
		if ([assetArray count]) {
			ALAsset *asset = [assetArray objectAtIndex:0];
			return [MWPhoto photoWithURL:asset.defaultRepresentation.url];
		}
	}
	return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
	if (index == 0 && self.capturedPhotoURL) {
		return [MWPhoto photoWithURL:self.capturedPhotoURL];
	}
	NSMutableArray *assetArray = [NSMutableArray new];
	if (index < [_availablePhotos count]) {
		[_assetrollGroup enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:[_availablePhotos[index] integerValue]] options:NSEnumerationConcurrent usingBlock:^(ALAsset *result, NSUInteger i, BOOL *stop) {
			if (result != nil) {
				[assetArray addObject:result];
				*stop = YES;
			}
		}];
		if ([assetArray count]) {
			ALAsset *asset = [assetArray objectAtIndex:0];
			return [MWPhoto photoWithImage:[UIImage imageWithCGImage:asset.thumbnail]];
		}
	}
	return nil;
}

//- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index {
//    MWPhoto *photo = [self.photos objectAtIndex:index];
//    MWCaptionView *captionView = [[MWCaptionView alloc] initWithPhoto:photo];
//    return [captionView autorelease];
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index {
	FNLOG(@"ACTION!");
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
	FNLOG(@"Did start viewing photo at index %lu", (unsigned long)index);
}

#pragma mark - Load Assets

- (UIImage *)cropImageWithSquare:(UIImage *)source
{
	CGSize finalsize = CGSizeMake(47,47);

	CGFloat scale = MAX(
			finalsize.width/source.size.width,
			finalsize.height/source.size.height);
	CGFloat width = source.size.width * scale;
	CGFloat height = source.size.height * scale;

	CGRect rr = CGRectMake( 0, 0, width, height);

	UIGraphicsBeginImageContextWithOptions(finalsize, NO, 0);
	[source drawInRect:rr];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}

- (void)loadFirstPhoto {
	[self.assetLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
								 usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
									 if (group != nil) {
										 [group setAssetsFilter:[ALAssetsFilter allPhotos]];
										 _assetrollGroup = group;

                                         if (![_assetrollGroup numberOfAssets]) {
                                             return;
                                         }
										 _availablePhotos = [NSMutableArray new];
										 if (self.capturedPhotoURL) {
											 [_availablePhotos addObject:@0];
										 }

										 [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [_assetrollGroup numberOfAssets] - 1)]
																 options:NSEnumerationReverse
															  usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
																  if (result) {
																	  [_availablePhotos addObject:@(index)];
																  }

															  }];
										 FNLOG(@"%@", _availablePhotos);
										 FNLOG(@"%ld", (long)[_availablePhotos count]);

										 if (self.capturedPhotoURL) {
											 [self.assetLibrary assetForURL:self.capturedPhotoURL resultBlock:^(ALAsset *asset) {
												 ALAssetRepresentation *representation = [asset defaultRepresentation];
												 UIImage *image = [UIImage imageWithCGImage:[representation fullScreenImage]];
												 [self setImageOnCameraRollButton:image];
											 } failureBlock:NULL];
										 } else {
											 if (![_availablePhotos count]) return;
											 [_assetrollGroup enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:[_availablePhotos[0] integerValue]]
																			   options:NSEnumerationConcurrent
																			usingBlock:^(ALAsset *result, NSUInteger i, BOOL *stop) {
												 if (result) {
													 ALAssetRepresentation *representation = [result defaultRepresentation];
													 UIImage *latestPhoto = [UIImage imageWithCGImage:[representation fullScreenImage]];
													 [self setImageOnCameraRollButton:latestPhoto];
												 }
											 }];
										 }
									 }
								 }
							   failureBlock:^(NSError *error) {
								   FNLOG("NO GroupSavedPhotos:%@", error);
							   }
	];
}

#pragma mark - set image icon

- (void)setImageOnCameraRollButton:(UIImage *)image {
	[_lastimageButton setBackgroundImage:[self cropImageWithSquare:image] forState:UIControlStateNormal];
}

#pragma mark - load camera roll

- (IBAction)loadCameraRoll:(id)sender {
	if (![self hasAuthorizationToAccessPhoto]) {
		return;
	}

	[self loadFirstPhoto];

	// Create browser
	MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
	browser.displayActionButton = NO;
	browser.displayNavArrows = YES;
	browser.displaySelectionButtons = NO;
	browser.alwaysShowControls = NO;
	//browser.wantsFullScreenLayout = YES; deprecated
	browser.zoomPhotosToFill = YES;
	browser.enableGrid = YES;
	browser.startOnGrid = NO;
	[browser setCurrentPhotoIndex:0];

	UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
	nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	[self presentViewController:nc animated:YES completion:^{
		[self notifyCameraShotSaveRule];
	}];
}

- (void)notifyCameraShotSaveRule {
}

- (ALAssetsLibrary *)assetLibrary {
	if (!_assetLibrary) {
		_assetLibrary = [[ALAssetsLibrary alloc] init];
	}
	return _assetLibrary;
}

- (BOOL)hasAuthorizationToAccessPhoto
{
	if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusDenied || [ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusRestricted) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"This app does not have access to your photos.", nil)
															message:NSLocalizedString(@"You can enable access in Privacy Settings.", nil)
														   delegate:nil
												  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
												  otherButtonTitles:nil];
		[alertView show];
		return NO;
	}

	return YES;
}

@end
