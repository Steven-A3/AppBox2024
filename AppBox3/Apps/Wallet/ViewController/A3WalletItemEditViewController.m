//
//  A3WalletItemEditViewController.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 2..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3WalletItemEditViewController.h"
#import "A3WalletCategorySelectViewController.h"
#import "A3WalletItemFieldCell.h"
#import "A3WalletItemPhotoFieldCell.h"
#import "A3WalletItemRightIconCell.h"
#import "A3WalletNoteCell.h"
#import "A3WalletDateInputCell.h"
#import "WalletData.h"
#import "WalletItem.h"
#import "WalletItem+Favorite.h"
#import "WalletFieldItem.h"
#import "WalletFieldItem+initialize.h"
#import "UIViewController+NumberKeyboard.h"
#import "UIViewController+A3Addition.h"
#import "UIImage+Extension2.h"
#import "UITableView+utility.h"
#import "WalletCategory.h"
#import "UIViewController+iPad_rightSideView.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "A3WalletItemTitleCell.h"
#import "WalletItem+initialize.h"
#import "NSString+conversion.h"
#import "NSDate+formatting.h"
#import "NSDateFormatter+A3Addition.h"
#import "WalletFavorite.h"
#import "WalletFavorite+initialize.h"
#import "A3SyncManager.h"
#import "NSMutableArray+A3Sort.h"
#import "WalletField.h"
#import "A3NavigationController.h"

#import <CoreLocation/CoreLocation.h>
#import <ImageIO/ImageIO.h>
#import <AssetsLibrary/AssetsLibrary.h>
@import AVFoundation;
@import Photos;
#import "NSManagedObject+extension.h"
#import "NSManagedObjectContext+extension.h"
#import "AppBox3-swift.h"
#import "A3UIDevice.h"
#import "A3UserDefaults+A3Addition.h"

extern NSString *const A3TableViewCellDefaultCellID;
NSString *const A3WalletItemTitleCellID = @"A3WalletTitleCell";
NSString *const A3WalletItemFieldCellID4 = @"A3WalletItemFieldCell";
NSString *const A3WalletItemPhotoFieldCellID4 = @"A3WalletItemPhotoFieldCell";
NSString *const A3WalletItemFieldTwoValueCellID4 = @"A3WalletItemFieldTwoValueCell";
NSString *const A3WalletItemFieldCateCellID4 = @"A3WalletItemFieldCateCell";
NSString *const A3WalletItemRightIconCellID4 = @"A3WalletItemRightIconCell";
NSString *const A3WalletItemNoteCellID4 = @"A3WalletNoteCell";
NSString *const A3WalletItemDateInputCellID4 = @"A3WalletDateInputCell";
NSString *const A3WalletItemDateCellID4 = @"A3WalletItemFieldCell";
NSString *const A3WalletItemFieldDeleteCellID4 = @"A3WalletItemFieldDeleteCell";

static const NSInteger ActionTag_DeleteImage = 100;
static const NSInteger ActionTag_ImagePickerMenu = 100;
static const NSInteger ActionTag_DeleteVideo = 200;
static const NSInteger ActionTag_DeleteItem = 300;
static const NSInteger ActionTag_Camera = 0;
static const NSInteger ActionTag_PhotoLibrary = 1;
static const NSInteger ActionTag_PhotoLibraryEdit = 2;

@interface A3WalletItemEditViewController () <WalletCategorySelectDelegate, UITextFieldDelegate, UIActionSheetDelegate,
		UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, CLLocationManagerDelegate,
		UIPopoverControllerDelegate, NSFileManagerDelegate>

@property (nonatomic, strong) NSMutableArray *sectionItems;
@property (nonatomic, strong) NSMutableDictionary *titleItem;
@property (nonatomic, strong) NSMutableDictionary *noteItem;
@property (nonatomic, strong) NSMutableDictionary *deleteItem;
@property (nonatomic, strong) NSMutableDictionary *dateInputItem;
@property (nonatomic, strong) UIPopoverController *popOverController;
@property (nonatomic, strong) NSMutableDictionary *categoryItem;
@property (nonatomic, strong) NSIndexPath *currentIndexPath;

@property (nonatomic, strong) WalletFieldItem *currentFieldItem;
@property (nonatomic, strong) NSIndexPath *dateInputIndexPath;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) UIViewController *rightSideViewController;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *myLocation;
@property (nonatomic, strong) NSDictionary *imageMetadata;
@property (nonatomic, weak) UIDatePicker *datePicker;
@property (nonatomic, weak) UITextField *titleTextField;
@property (nonatomic, copy) NSString *originalCategoryUniqueID;
@property (nonatomic, strong) UIActionSheet *actionSheet;
@property (nonatomic, strong) UIAlertController *alertController;

@end

@implementation A3WalletItemEditViewController {
	BOOL _isMemoCategory;
	CGFloat _keyboardHeight;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
	if (_isAddNewItem) {
		self.navigationItem.title = NSLocalizedString(@"Add Item", @"Add Item");
        
        _item = [[WalletItem alloc] initWithContext:context];
		_item.uniqueID = [[NSUUID UUID] UUIDString];
		_item.updateDate = [NSDate date];
        _item.lastOpened = [NSDate date];
		[_item assignOrder];
		_item.categoryID = _category.uniqueID;
	} else {
		self.navigationItem.title = NSLocalizedString(@"Edit Item", @"Edit Item");
        
		_category = [WalletData categoryItemWithID:_item.categoryID];
        
		[self copyThumbnailImagesToTemporaryPath];
        
		[_item verifyNULLField];
	}
    
	_originalCategoryUniqueID = _category.uniqueID;
	_isMemoCategory = [_item.categoryID isEqualToString:A3WalletUUIDMemoCategory];
    
	[self makeBackButtonEmptyArrow];
    [self rightBarButtonDoneButton];
	self.navigationItem.rightBarButtonItem.enabled = NO;
    
	[self leftBarButtonCancelButton];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorInset = A3UITableViewSeparatorInset;
	if ([self.tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
		self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
	}
	if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
		self.tableView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
	}
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.tableView.rowHeight = 74.0;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorColor = [self tableViewSeparatorColor];
	self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
	[self registerContentSizeCategoryDidChangeNotification];
	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rightSideViewWillHide) name:A3NotificationRightSideViewWillDismiss object:nil];
	}
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)applicationWillResignActive {
	if (_actionSheet) {
		[_actionSheet dismissWithClickedButtonIndex:_actionSheet.cancelButtonIndex animated:NO];
		_actionSheet = nil;
	}
	if (_imagePickerController) {
		[self dismissViewControllerAnimated:NO completion:nil];
		_imagePickerController = nil;
	}
	if (_alertController) {
		[self dismissViewControllerAnimated:NO completion:nil];
		_alertController = nil;
	}
	if (_popOverController) {
		[_popOverController dismissPopoverAnimated:NO];
		_popOverController = nil;
	}
}

- (void)removeObserver {
	[self removeContentSizeCategoryDidChangeNotification];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationRightSideViewWillDismiss object:nil];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
    
	if ([self isMovingFromParentViewController] || [self isBeingDismissed]) {
		FNLOG();
		[self removeObserver];
	}
}

- (void)dealloc {
	[self removeObserver];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
    
	if (_isAddNewItem && ![_titleTextField.text length]) {
		[_titleTextField becomeFirstResponder];
	}
	if ([self.navigationController.navigationBar isHidden]) {
		[self.navigationController setNavigationBarHidden:NO animated:NO];
	}
}

- (void)keyboardDidShow:(NSNotification *)notification {
	CGRect keyboardFrame = [[notification.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
	FNLOGRECT(keyboardFrame);
	if ([UIWindow interfaceOrientationIsPortrait]) {
		_keyboardHeight = keyboardFrame.size.height;
	} else {
		_keyboardHeight = keyboardFrame.size.width;
	}
}

- (void)copyThumbnailImagesToTemporaryPath {
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    fileManager.delegate = self;
    
    for (WalletFieldItem *fieldItem in _item.fieldItemsArraySortedByFieldOrder) {
        @autoreleasepool {
            if ([fieldItem.hasImage boolValue]) {
                NSURL *thumbnailImageURL = [NSURL fileURLWithPath:[fieldItem photoImageThumbnailPathInOriginal:YES]];
                NSURL *thumbnailImageInTempURL = [NSURL fileURLWithPath:[fieldItem photoImageThumbnailPathInOriginal:NO]];
                
                if (![fileManager fileExistsAtPath:[thumbnailImageURL path]]) {
                    // The source file does not exist and nothing to copy to temporary path.
                    continue;
                }
                NSFileCoordinator* fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
                NSError *error;
                [fileCoordinator coordinateReadingItemAtURL:thumbnailImageURL
                                                    options:NSFileCoordinatorReadingWithoutChanges
                                           writingItemAtURL:thumbnailImageInTempURL
                                                    options:NSFileCoordinatorWritingForReplacing
                                                      error:&error
                                                 byAccessor:^(NSURL *newReadingURL, NSURL *newWritingURL) {
                    BOOL result;
                    if ([fileManager fileExistsAtPath:[newWritingURL path]]) {
                        result = [fileManager removeItemAtURL:newWritingURL error:NULL];
                        NSAssert(result, @"Failed FileManager");
                    }
                    
                    result = [fileManager copyItemAtURL:newReadingURL toURL:newWritingURL error:NULL];
                    NSAssert(result, @"Failed FileManager");
                }];
                if (error) {
                    FNLOG(@"%@", error.localizedDescription);
                }
                NSAssert([fileManager fileExistsAtPath:[thumbnailImageURL path]], @"[fileManager fileExistsAtPath:[thumbnailImageURL path]]");
                NSAssert([fileManager fileExistsAtPath:[thumbnailImageInTempURL path]], @"[fileManager fileExistsAtPath:[thumbnailImageInTempURL path]]");
                
                NSURL *photoImageURLInOriginalDirectory = [fieldItem photoImageURLInOriginalDirectory:YES];
                NSURL *photoImageURLInTempDirectory = [fieldItem photoImageURLInOriginalDirectory:NO];
                [fileCoordinator coordinateReadingItemAtURL:photoImageURLInOriginalDirectory
                                                    options:NSFileCoordinatorReadingWithoutChanges
                                           writingItemAtURL:photoImageURLInTempDirectory
                                                    options:NSFileCoordinatorWritingForReplacing
                                                      error:&error
                                                 byAccessor:^(NSURL *newReadingURL, NSURL *newWritingURL) {
                    BOOL result;
                    if ([fileManager fileExistsAtPath:[newWritingURL path]]) {
                        result = [fileManager removeItemAtURL:newWritingURL error:NULL];
                        NSAssert(result, @"Failed FileManager");
                    }
                    
                    result = [fileManager copyItemAtURL:newReadingURL toURL:newWritingURL error:NULL];
                    NSAssert(result, @"Failed FileManager");
                }];
                if (error) {
                    FNLOG(@"%@", error.localizedDescription);
                }
                NSAssert([fileManager fileExistsAtPath:[photoImageURLInOriginalDirectory path]], @"[fileManager fileExistsAtPath:[photoImageURLInOriginalDirectory path]]");
                NSAssert([fileManager fileExistsAtPath:[photoImageURLInTempDirectory path]], @"[fileManager fileExistsAtPath:[photoImageURLInTempDirectory path]]");
                
                continue;
            }
            if ([fieldItem.hasVideo boolValue]) {
                NSURL *thumbnailImagePathURL = [NSURL fileURLWithPath:[fieldItem videoThumbnailPathInOriginal:YES]];
                NSURL *thumbnailImageInTempURL = [NSURL fileURLWithPath:[fieldItem videoThumbnailPathInOriginal:NO]];
                
                if (![fileManager fileExistsAtPath:[thumbnailImagePathURL path]]) {
                    // The source file does not exist and nothing to copy to temporary path.
                    continue;
                }
                NSFileCoordinator* fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
                [fileCoordinator coordinateReadingItemAtURL:thumbnailImagePathURL
                                                    options:NSFileCoordinatorReadingWithoutChanges
                                           writingItemAtURL:thumbnailImageInTempURL
                                                    options:NSFileCoordinatorWritingForReplacing
                                                      error:NULL
                                                 byAccessor:^(NSURL *newReadingURL, NSURL *newWritingURL) {
                    BOOL result;
                    if ([fileManager fileExistsAtPath:[newWritingURL path]]) {
                        result = [fileManager removeItemAtURL:newWritingURL error:NULL];
                        NSAssert(result, @"Failed FileManager");
                    }
                    
                    result = [fileManager copyItemAtURL:newReadingURL toURL:newWritingURL error:NULL];
                    NSAssert(result, @"Failed FileManager");
                }];
                
                NSAssert([fileManager fileExistsAtPath:[thumbnailImagePathURL path]], @"[fileManager fileExistsAtPath:[thumbnailImagePathURL path]]");
                NSAssert([fileManager fileExistsAtPath:[thumbnailImageInTempURL path]], @"[fileManager fileExistsAtPath:[thumbnailImageInTempURL path]]");
                
                NSURL *videoFileURL = [fieldItem videoFileURLInOriginal:YES];
                NSURL *videoFileURLInTemp = [fieldItem videoFileURLInOriginal:NO];
                [fileCoordinator coordinateReadingItemAtURL:videoFileURL
                                                    options:NSFileCoordinatorReadingWithoutChanges
                                           writingItemAtURL:videoFileURLInTemp
                                                    options:NSFileCoordinatorWritingForReplacing
                                                      error:NULL
                                                 byAccessor:^(NSURL *newReadingURL, NSURL *newWritingURL) {
                    BOOL result;
                    if ([fileManager fileExistsAtPath:[newWritingURL path]]) {
                        result = [fileManager removeItemAtURL:newWritingURL error:NULL];
                        NSAssert(result, @"Failed FileManager");
                    }
                    
                    result = [fileManager copyItemAtURL:newReadingURL toURL:newWritingURL error:NULL];
                    NSAssert(result, @"Failed FileManager");
                }];
                NSAssert([fileManager fileExistsAtPath:[videoFileURL path]], @"Failed FileManager");
                NSAssert([fileManager fileExistsAtPath:[videoFileURLInTemp path]], @"Failed FileManager");
                
                continue;
            }
        }
    }
}

- (void)moveMediaFilesToNormalPath {
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    fileManager.delegate = self;
    
	for (WalletFieldItem *fieldItem in [_item fieldItems]) {
		if (fieldItem.hasImage) {
			if ([fieldItem.hasImage boolValue]) {
				[self movePhotoFilesToOriginalDirectoryForFieldItem:fieldItem];
			} else {
				[self deletePhotoFilesForFieldItem:fieldItem];
			}
		} else if (fieldItem.hasVideo) {
			if ([fieldItem.hasVideo boolValue]) {
				[self moveVideoFilesToOriginalDirectoryForFieldItem:fieldItem];
			} else {
				[self deleteVideoFilesForFieldItem:fieldItem];
			}
		}
	}
}

- (void)movePhotoFilesToOriginalDirectoryForFieldItem:(WalletFieldItem *)fieldItem {
    @autoreleasepool {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSURL *photoImageURLInOriginalDirectory = [fieldItem photoImageURLInOriginalDirectory:YES];
        NSURL *photoImageURLInTempDirectory = [fieldItem photoImageURLInOriginalDirectory:NO];
        NSURL *thumbnailImageURL = [NSURL fileURLWithPath:[fieldItem photoImageThumbnailPathInOriginal:YES]];
        NSURL *thumbnailImageInTempURL = [NSURL fileURLWithPath:[fieldItem photoImageThumbnailPathInOriginal:NO]];
        
        NSError *error;
        
        __block BOOL result;
        NSFileCoordinator *coordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
        [coordinator coordinateReadingItemAtURL:photoImageURLInTempDirectory
                                        options:NSFileCoordinatorReadingWithoutChanges
                               writingItemAtURL:photoImageURLInOriginalDirectory
                                        options:NSFileCoordinatorWritingForReplacing
                                          error:&error
                                     byAccessor:^(NSURL *newReadingURL, NSURL *newWritingURL) {
            if ([fileManager fileExistsAtPath:[newWritingURL path]]) {
                result = [fileManager removeItemAtURL:newWritingURL error:NULL];
                NSAssert(result, @"result");
            }
            
            result = [fileManager moveItemAtURL:newReadingURL toURL:newWritingURL error:NULL];
            NSAssert(result, @"result");
        }];
        NSAssert([fileManager fileExistsAtPath:[photoImageURLInOriginalDirectory path]], @"[fileManager fileExistsAtPath:[photoImageURLInOriginalDirectory path]");
        NSAssert(![fileManager fileExistsAtPath:[photoImageURLInTempDirectory path]], @"[fileManager fileExistsAtPath:[photoImageURLInTempDirectory path]]");
        
        
        [coordinator coordinateReadingItemAtURL:thumbnailImageInTempURL
                                        options:NSFileCoordinatorReadingWithoutChanges
                               writingItemAtURL:thumbnailImageURL
                                        options:NSFileCoordinatorWritingForReplacing
                                          error:&error
                                     byAccessor:^(NSURL *newReadingURL, NSURL *newWritingURL) {
            if ([fileManager fileExistsAtPath:[newWritingURL path]]) {
                result = [fileManager removeItemAtURL:newWritingURL error:NULL];
                NSAssert(result, @"result");
            }
            
            result = [fileManager moveItemAtURL:newReadingURL toURL:newWritingURL error:NULL];
            NSAssert(result, @"result");
        }];
        NSAssert([fileManager fileExistsAtPath:[thumbnailImageURL path]], @"[fileManager fileExistsAtPath:[thumbnailImageURL path]");
        NSAssert(![fileManager fileExistsAtPath:[thumbnailImageInTempURL path]], @"[fileManager fileExistsAtPath:[thumbnailImageInTempURL path]]");
    }
}

- (void)deletePhotoFilesForFieldItem:(WalletFieldItem *)fieldItem {
    @autoreleasepool {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSURL *photoImageURLInOriginalDirectory = [fieldItem photoImageURLInOriginalDirectory:YES];
        NSURL *photoImageURLInTempDirectory = [fieldItem photoImageURLInOriginalDirectory:NO];
        NSURL *thumbnailImageURL = [NSURL fileURLWithPath:[fieldItem photoImageThumbnailPathInOriginal:YES]];
        NSURL *thumbnailImageInTempURL = [NSURL fileURLWithPath:[fieldItem photoImageThumbnailPathInOriginal:NO]];
        
        NSError *error;
        NSFileCoordinator *coordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
        [coordinator coordinateWritingItemAtURL:photoImageURLInOriginalDirectory
                                        options:NSFileCoordinatorWritingForDeleting
                                          error:&error
                                     byAccessor:^(NSURL *newURL) {
            [fileManager removeItemAtURL:newURL error:NULL];
        }];
        [fileManager removeItemAtURL:photoImageURLInTempDirectory error:NULL];
        [fileManager removeItemAtPath:[thumbnailImageURL path] error:NULL];
        [fileManager removeItemAtPath:[thumbnailImageInTempURL path] error:NULL];
    }
}

- (void)moveVideoFilesToOriginalDirectoryForFieldItem:(WalletFieldItem *)fieldItem {
    @autoreleasepool {
        if ([fieldItem.hasVideo boolValue]) {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSURL *videoFileURL = [fieldItem videoFileURLInOriginal:YES];
            NSURL *videoFileURLInTemp = [fieldItem videoFileURLInOriginal:NO];
            NSURL *thumbnailImagePath = [NSURL fileURLWithPath:[fieldItem videoThumbnailPathInOriginal:YES]];
            NSURL *thumbnailImageInTemp = [NSURL fileURLWithPath:[fieldItem videoThumbnailPathInOriginal:NO]];
            
            NSError *error;
            __block BOOL result;
            NSFileCoordinator *coordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
            [coordinator coordinateReadingItemAtURL:videoFileURLInTemp
                                            options:NSFileCoordinatorReadingWithoutChanges
                                   writingItemAtURL:videoFileURL
                                            options:NSFileCoordinatorWritingForReplacing
                                              error:&error
                                         byAccessor:^(NSURL *newReadingURL, NSURL *newWritingURL) {
                NSError *error2;
                if ([fileManager fileExistsAtPath:[newWritingURL path]]) {
                    result = [fileManager removeItemAtURL:newWritingURL error:NULL];
                    NSAssert(result, @"[fileManager removeItemAtURL:newWritingURL error:NULL]");
                }
                if (![fileManager fileExistsAtPath:[newReadingURL path]]) {
                    FNLOG(@"\n  if (![fileManager fileExistsAtPath:[newReadingURL path]]) ");
                }
                
                if ([[A3SyncManager sharedSyncManager] isCloudEnabled]) {
                    result = [fileManager setUbiquitous:YES itemAtURL:newReadingURL destinationURL:newWritingURL error:NULL];
                } else {
                    result = [fileManager moveItemAtURL:newReadingURL toURL:newWritingURL error:&error2];
                }
                if (error2) {
                    FNLOG(@"\n%@", [error2 localizedDescription]);
                }
                NSAssert(result, @"[fileManager moveItemAtURL:newReadingURL toURL:newWritingURL error:NULL]");
            }];
            NSAssert([fileManager fileExistsAtPath:[videoFileURL path]], @"[fileManager fileExistsAtPath:[videoFileURL path]]");
            NSAssert(![fileManager fileExistsAtPath:[videoFileURLInTemp path]], @"[fileManager fileExistsAtPath:[videoFileURLInTemp path]]");
            
            [coordinator coordinateReadingItemAtURL:thumbnailImageInTemp
                                            options:NSFileCoordinatorReadingWithoutChanges
                                   writingItemAtURL:thumbnailImagePath
                                            options:NSFileCoordinatorWritingForReplacing
                                              error:&error
                                         byAccessor:^(NSURL *newReadingURL, NSURL *newWritingURL) {
                if ([fileManager fileExistsAtPath:[newWritingURL path]]) {
                    result = [fileManager removeItemAtURL:newWritingURL error:NULL];
                    NSAssert(result, @"result");
                }
                
                result = [fileManager moveItemAtURL:newReadingURL toURL:newWritingURL error:NULL];
                NSAssert(result, @"[fileManager moveItemAtURL:newReadingURL toURL:newWritingURL error:NULL]");
            }];
            NSAssert([fileManager fileExistsAtPath:[thumbnailImagePath path]], @"[fileManager fileExistsAtPath:[thumbnailImagePath path]]");
            NSAssert(![fileManager fileExistsAtPath:[thumbnailImageInTemp path]], @"[fileManager fileExistsAtPath:[thumbnailImageInTemp path]]");
        }
    }
}

- (void)deleteVideoFilesForFieldItem:(WalletFieldItem *)fieldItem {
    @autoreleasepool {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *videoFileURL = [fieldItem videoFileURLInOriginal:YES];
        NSURL *videoFileURLInTemp = [fieldItem videoFileURLInOriginal:NO];
        NSURL *thumbnailImagePath = [NSURL fileURLWithPath:[fieldItem videoThumbnailPathInOriginal:YES]];
        NSURL *thumbnailImageInTemp = [NSURL fileURLWithPath:[fieldItem videoThumbnailPathInOriginal:NO]];
        NSError *error;
        NSFileCoordinator *coordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
        [coordinator coordinateWritingItemAtURL:videoFileURL
                                        options:NSFileCoordinatorWritingForDeleting
                                          error:&error
                                     byAccessor:^(NSURL *newURL) {
            [fileManager removeItemAtURL:newURL error:NULL];
        }];
        [fileManager removeItemAtURL:videoFileURLInTemp error:NULL];
        
        [fileManager removeItemAtPath:[thumbnailImagePath path] error:NULL];
        [fileManager removeItemAtPath:[thumbnailImageInTemp path] error:NULL];
    }
}

- (void)removeTempFiles {
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    fileManager.delegate = self;
    
    BOOL result;
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"walletItemID == %@", _item.uniqueID];
	NSArray *fieldItems = [WalletFieldItem findAllWithPredicate:predicate];
	for (WalletFieldItem *fieldItem in fieldItems) {
		if ([fieldItem.hasImage boolValue]) {
			NSString *thumbnailImagePathInTemp = [fieldItem photoImageThumbnailPathInOriginal:NO];
            result = [fileManager removeItemAtPath:thumbnailImagePathInTemp error:NULL];
            NSAssert(result, @"result");
			continue;
		}
		if ([fieldItem.hasVideo boolValue]) {
			NSString *thumbnailImagePathInTemp = [fieldItem videoThumbnailPathInOriginal:NO];
            result = [fileManager removeItemAtPath:thumbnailImagePathInTemp error:NULL];
            NSAssert(result, @"result");
            
			NSURL *videoFilePathInTemp = [fieldItem videoFileURLInOriginal:NO];
            result = [fileManager removeItemAtURL:videoFilePathInTemp error:NULL];
            NSAssert(result, @"result");
		}
	}
}

- (void)rightSideViewWillHide {
	[_rightSideViewController removeFromParentViewController];
	_rightSideViewController = nil;
}

- (void)contentSizeDidChange:(NSNotification *) notification
{
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *)sectionItems
{
    if (!_sectionItems) {
		NSArray *fields = [WalletField findByAttribute:@"categoryID" withValue:self.category.uniqueID andOrderBy:A3CommonPropertyOrder ascending:YES];
        _sectionItems = [[NSMutableArray alloc] initWithArray:fields];
        
		[_sectionItems insertObject:self.titleItem atIndex:0];
		[_sectionItems insertObject:self.categoryItem atIndex:1];
        
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"walletItemID == %@ AND fieldID == NULL", _item.uniqueID];
		NSArray *fieldItemsFieldEqualsNULL = [WalletFieldItem findAllWithPredicate:predicate];
		for (WalletFieldItem *fieldItem in fieldItemsFieldEqualsNULL) {
			if ([fieldItem.hasImage boolValue] || [fieldItem.hasVideo boolValue]) {
				[_sectionItems addObject:fieldItem];
			}
		}
        
		[_sectionItems addObject:self.noteItem];
    }
    
    return _sectionItems;
}

- (NSMutableDictionary *)titleItem {
	if (!_titleItem) {
		_titleItem = [@{@"title" : @"title", @"order" : @""} mutableCopy];
	}
	return _titleItem;
}

- (NSMutableDictionary *)dateInputItem
{
    if (!_dateInputItem) {
        _dateInputItem = [NSMutableDictionary dictionaryWithDictionary:@{@"title":@"dateInput", @"order":@""}];
    }
    
    return _dateInputItem;
}

- (NSMutableDictionary *)noteItem
{
    if (!_noteItem) {
        _noteItem = [NSMutableDictionary dictionaryWithDictionary:@{@"title": NSLocalizedString(@"Note", @"Note"), @"order":@""}];
    }
    
    return _noteItem;
}

- (NSMutableDictionary *)deleteItem
{
    if (!_deleteItem) {
        _deleteItem = [NSMutableDictionary dictionaryWithDictionary:@{@"title": NSLocalizedString(@"Delete", @"Delete"), @"order":@""}];
    }
    
    return _deleteItem;
}

- (NSMutableDictionary *)categoryItem
{
    if (!_categoryItem) {
		_categoryItem = [NSMutableDictionary dictionaryWithDictionary:@{@"title":@"category", @"order":@""}];
	}
	return _categoryItem;
}

- (void)favoriteButtonAction:(UIButton *)button
{
	BOOL isFavorite = ![WalletFavorite isFavoriteForItemID:_item.uniqueID];
	[_item changeFavorite:isFavorite];
    button.selected = isFavorite;
}

- (WalletFieldItem *)fieldItemForIndexPath:(NSIndexPath *)indexPath create:(BOOL)create {
	WalletField *field = _sectionItems[indexPath.row];
    
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"walletItemID == %@ AND fieldID == %@", _item.uniqueID, field.uniqueID];
	WalletFieldItem *fieldItem = [WalletFieldItem findFirstWithPredicate:predicate];
	if (fieldItem) return fieldItem;
    
	if (create) {
        NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
        fieldItem = [[WalletFieldItem alloc] initWithContext:context];
		fieldItem.uniqueID = [[NSUUID UUID] UUIDString];
		fieldItem.updateDate = [NSDate date];
		fieldItem.walletItemID = _item.uniqueID;
		fieldItem.fieldID = field.uniqueID;
		return fieldItem;
	}
	return nil;
}

- (void)dateChanged:(UIDatePicker *)sender {
    if (!self.dateInputIndexPath) {
        return;
    }
    
	WalletFieldItem *fieldItem = [self fieldItemForIndexPath:self.dateInputIndexPath create:YES];
	fieldItem.date = sender.date;
    
    [self.tableView reloadRowsAtIndexPaths:@[self.dateInputIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    [self updateDoneButtonEnabled];
}

- (void)deleteDate:(UIButton *)sender {
	NSIndexPath *indexPath = [self.tableView indexPathForCellSubview:sender];
	WalletFieldItem *fieldItem = [self fieldItemForIndexPath:indexPath create:YES];
	fieldItem.date = nil;
    
	[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
	[self updateDoneButtonEnabled];
}

- (void)updateDoneButtonEnabled {
	if ([_item.categoryID isEqualToString:A3WalletUUIDPhotoCategory]) {
		BOOL hasImage = NO;
		BOOL categoryDoesNotHaveImageField = YES;
		for (WalletFieldItem *fieldItem in _item.fieldItemsArraySortedByFieldOrder) {
			WalletField *field = [WalletData fieldOfFieldItem:fieldItem];
			if ([field.type isEqualToString:WalletFieldTypeImage]) {
				categoryDoesNotHaveImageField = NO;
				hasImage = [fieldItem.hasImage boolValue];
				if (hasImage) break;
			}
		}
		if (!categoryDoesNotHaveImageField) {
			[self.navigationItem.rightBarButtonItem setEnabled:hasImage];
			return;
		}
	} else if ([_item.categoryID isEqualToString:A3WalletUUIDVideoCategory]) {
		BOOL hasVideo = NO;
		BOOL categoryDoesNotHaveVideoField = YES;
		for (WalletFieldItem *fieldItem in _item.fieldItemsArraySortedByFieldOrder) {
			WalletField *field = [WalletData fieldOfFieldItem:fieldItem];
			if ([field.type isEqualToString:WalletFieldTypeVideo]) {
				categoryDoesNotHaveVideoField = NO;
				hasVideo = [fieldItem.hasVideo boolValue];
				if (hasVideo) break;
			}
		}
		if (!categoryDoesNotHaveVideoField) {
			[self.navigationItem.rightBarButtonItem setEnabled:hasVideo];
			return;
		}
	}
	self.navigationItem.rightBarButtonItem.enabled = [self hasChanges];
}

- (void)cancelButtonAction:(id)sender
{
	// 입력중인거 완료
	if (self.editingObject) {
		[self.editingObject resignFirstResponder];
	}
    
	[self removeTempFiles];
	
	NSString *addingItemID = [_item.uniqueID copy];
	
    NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
	if ([context hasChanges]) {
		[context rollback];
	}
	
 /**
  *  편집 중에 홈 버튼을 눌러 나갔다 온 경우, 저장이 이루어 집니다.
  *	 다시 돌아와서 Cancel을 누른 경우에는 저장된 내용을 삭제해야 합니다.
  */
	if (_isAddNewItem) {
		[self deleteWalletItemByID:addingItemID];
	}
	
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)doneButtonAction:(UIBarButtonItem *)button
{
    if (self.editingObject) {
        [self.editingObject resignFirstResponder];
    }
    
    NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
	for (WalletFieldItem *fieldItem in [_item fieldItems]) {
		if (	(!fieldItem.fieldID && !fieldItem.hasImage && !fieldItem.hasVideo ) ||
				(!fieldItem.value && !fieldItem.date && !fieldItem.hasImage && !fieldItem.hasVideo))
		{
            [context deleteObject:fieldItem];
		}
	}
    
	_item.updateDate = [NSDate date];
    _item.lastOpened = [NSDate date];

    [context saveContext];

    CredentialIdentityStoreManager *manager = [CredentialIdentityStoreManager new];
    [manager updateCredentialIdentityStore];

	[self moveMediaFilesToNormalPath];
    
//    MBProgressHUD *delayHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    delayHud.label.text = NSLocalizedString(@"Updating...", nil);
//    delayHud.minShowTime = 1;
//    delayHud.removeFromSuperViewOnHide = YES;
//    delayHud.mode = MBProgressHUDModeDeterminate;
//    delayHud.completionBlock = ^{
        if (self.alwaysReturnToOriginalCategory || [self.originalCategoryUniqueID isEqualToString:self.item.categoryID]) {
            [self dismissViewControllerAnimated:YES completion:NULL];
        } else {
            [self dismissViewControllerAnimated:YES completion:NULL];
            
            NSNotification *notification = [[NSNotification alloc] initWithName:A3WalletNotificationItemCategoryMoved
                                                                         object:nil
                                                                       userInfo:@{
                                                                           @"oldCategoryID" : self.originalCategoryUniqueID,
                                                                           @"categoryID":self.item.categoryID,
                                                                           @"itemID":self.item.uniqueID
                                                                       }];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(walletItemEdited:)]) {
            [self.delegate walletItemEdited:self.item];
        }
//    };
//    [delayHud hideAnimated:YES afterDelay:0.5];
}

- (void)mediaButtonAction:(UIButton *)sender
{
    // 다시 사진을 선택하도록 한다. (해당 테이블 셀을 눌렀을때와 동일한 프로세스로 동작하면 됨)
    NSIndexPath *ip = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    [self tableView:self.tableView didSelectRowAtIndexPath:ip];
}

- (void)deleteMediaItem {
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    fileManager.delegate = self;
    
    NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
	if ([self.sectionItems[_currentIndexPath.row] isKindOfClass:[WalletFieldItem class]]) {
		WalletFieldItem *fieldItem = _sectionItems[_currentIndexPath.row];
		if ([fieldItem.hasImage boolValue]) {
			[fileManager removeItemAtPath:[fieldItem photoImageThumbnailPathInOriginal:NO] error:NULL];
		} else {
			[fileManager removeItemAtPath:[fieldItem videoThumbnailPathInOriginal:NO] error:NULL];
		}
        [context deleteObject:fieldItem];
        
		[_sectionItems removeObjectAtIndex:_currentIndexPath.row];
		[self.tableView deleteRowsAtIndexPaths:@[_currentIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
	} else {
		WalletFieldItem *fieldItem = [self fieldItemForIndexPath:_currentIndexPath create:NO];
		if (fieldItem) {
			WalletField *field = [WalletData fieldOfFieldItem:fieldItem];;
			if ([field.type isEqualToString:WalletFieldTypeImage]) {
				[fileManager removeItemAtPath:[fieldItem photoImageThumbnailPathInOriginal:NO ] error:NULL];
			} else if ([field.type isEqualToString:WalletFieldTypeVideo]) {
				[fileManager removeItemAtURL:[fieldItem videoFileURLInOriginal:NO ] error:NULL];
				[fileManager removeItemAtPath:[fieldItem videoThumbnailPathInOriginal:NO ] error:NULL];
			}
            [context deleteObject:fieldItem];
			[self.tableView reloadRowsAtIndexPaths:@[_currentIndexPath] withRowAnimation:UITableViewRowAnimationFade];
		}
	}
	[self updateDoneButtonEnabled];
}

- (void)askDeleteImage {
	[self showDeleteImageActionSheet];
}

- (void)askDeleteVideo {
	[self showDeleteVideoActionSheet];
}

- (void)askVideoPickupWithDelete:(BOOL)deleteEnable withSender:(UITableViewCell *)cell
{
    CGRect fromRect = [self.tableView convertRect:cell.bounds fromView:cell];
    fromRect.origin.x = self.view.center.x;
    fromRect.size = CGSizeZero;

	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleActionSheet];
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        if (deleteEnable) {
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Delete Video", nil)
                                                                style:UIAlertActionStyleDestructive
                                                              handler:^(UIAlertAction * _Nonnull action) {
                [self deleteMediaItem];
            }]];
        }
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Take Video", nil)
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
            [self presentImagePickerControllerWithOption:ActionTag_Camera actionSheetTag:ActionTag_PhotoLibraryEdit];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Choose Existing", nil)
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
            [self presentImagePickerControllerWithOption:ActionTag_PhotoLibrary actionSheetTag:ActionTag_PhotoLibraryEdit];
        }]];

        UIPopoverPresentationController *presentationController = [alertController popoverPresentationController];
        if ([cell isKindOfClass:[A3WalletItemRightIconCell class]]) {
            A3WalletItemRightIconCell *typedCell = (A3WalletItemRightIconCell *)cell;
            presentationController.sourceView = typedCell.iconImgView;
            presentationController.sourceRect = typedCell.iconImgView.frame;
        }
        else if ([cell isKindOfClass:[A3WalletItemPhotoFieldCell class]]) {
            A3WalletItemPhotoFieldCell *typedCell = (A3WalletItemPhotoFieldCell *)cell;
            presentationController.sourceView = typedCell.photoButton;
            presentationController.sourceRect = typedCell.photoButton.frame;
        }

        [self presentViewController:alertController animated:YES completion:^{
            
        }];
	}
}

- (void)configureFloatingTextField:(JVFloatLabeledTextField *)txtFd
{
    txtFd.clipsToBounds = NO;
    txtFd.textColor = [UIColor colorWithRed:159.0/255.0 green:159.0/255.0 blue:159.0/255.0 alpha:1.0];
    txtFd.floatingLabelTextColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0];
    txtFd.font = [UIFont systemFontOfSize:17.0];
    txtFd.floatingLabelFont = [UIFont systemFontOfSize:14];
    txtFd.floatingLabelYPadding = 0;
    txtFd.delegate = self;
}

- (BOOL)hasChanges {
	if (_isAddNewItem) {
		return ![self isItemDataEmpty];
	}
    NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
	return [context hasChanges];
}

- (BOOL)isItemDataEmpty
{
    if ([_item.name length] || [_item.note length]) {
        return NO;
    }
    
    for (WalletFieldItem *fieldItem in _item.fieldItemsArraySortedByFieldOrder) {
		if (fieldItem.date || [fieldItem.hasImage boolValue] || [fieldItem.hasVideo boolValue] || [fieldItem.value length]) {
			return NO;
		}
    }
    
    return YES;
}

- (void)exchangeDatePickerFromIndexPath:(NSIndexPath *)from toIndexPath:(NSIndexPath *)to
{
	if ([_sectionItems containsObject:_dateInputItem]) {
		[self.tableView beginUpdates];
		NSUInteger idx = [_sectionItems indexOfObject:self.dateInputItem];
		[_sectionItems removeObject:self.dateInputItem];
		[self.tableView reloadRowsAtIndexPaths:@[self.dateInputIndexPath] withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
		self.dateInputIndexPath = nil;
		[self.tableView endUpdates];
        
		[self.tableView beginUpdates];
		if (from.row < to.row) {
			to = [NSIndexPath indexPathForRow:to.row-1 inSection:0];
		}
		self.dateInputIndexPath = to;
		[_sectionItems insertObject:self.dateInputItem atIndex:self.dateInputIndexPath.row + 1];
		[self.tableView reloadRowsAtIndexPaths:@[self.dateInputIndexPath] withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.dateInputIndexPath.row+1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView endUpdates];
	}
}

- (void)datePickerActiveFromIndexPath:(NSIndexPath *)dateIndexPath
{
    if (![_sectionItems containsObject:self.dateInputItem]) {
        [self.tableView beginUpdates];
        self.dateInputIndexPath = dateIndexPath;
        
		WalletFieldItem *fieldItem = [self fieldItemForIndexPath:self.dateInputIndexPath create:YES];
		if (fieldItem.date == nil) {
			fieldItem.date = [NSDate date];
		}
        
        [_sectionItems insertObject:self.dateInputItem atIndex:dateIndexPath.row + 1];
        [self.tableView reloadRowsAtIndexPaths:@[self.dateInputIndexPath] withRowAnimation:UITableViewRowAnimationFade];
		NSIndexPath *pickerIndexPath = [NSIndexPath indexPathForRow:dateIndexPath.row+1 inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[pickerIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
	}
}

- (void)dismissDatePicker
{
    if ([_sectionItems containsObject:self.dateInputItem]) {
        [self.tableView beginUpdates];
        
        NSUInteger idx = [_sectionItems indexOfObject:self.dateInputItem];
        [_sectionItems removeObject:self.dateInputItem];
        [self.tableView reloadRowsAtIndexPaths:@[self.dateInputIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        
        self.dateInputIndexPath = nil;
        [self.tableView endUpdates];
    }
}

- (void)changeCategory:(WalletCategory *)toCategory
{
	// 카테고리 변경
    // 같은 이름 필드는 값 입력
    // 나머지는 노트에 추가
    
    // 일반 필드는 item에 입력하고, walletFieldItem은 _editTempItems 에 저장한다.
    
    // name, order 변경안됨
    // category를 바꾼걸로
    
	_isMemoCategory = [_item.categoryID isEqualToString:A3WalletUUIDMemoCategory];
    
    // 현재 변경중인 field item 정보를, 새로운 카테고리에 해당하는 field item으로 바꾼다.
	NSArray *fieldsOfTargetCategory = [WalletField findByAttribute:@"categoryID" withValue:toCategory.uniqueID andOrderBy:A3CommonPropertyOrder ascending:YES];
    
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"walletItemID == %@ AND fieldID != NULL", _item.uniqueID];
    NSMutableArray *originalFieldItems = [[NSMutableArray alloc] initWithArray:[WalletFieldItem findAllWithPredicate:predicate]];
    NSMutableArray *addedItems = [NSMutableArray new];
    
	for (WalletField *fieldOfTargetCategory in fieldsOfTargetCategory) {
		@autoreleasepool {
			NSInteger idx = [originalFieldItems indexOfObjectPassingTest:^BOOL(WalletFieldItem *obj, NSUInteger idx, BOOL *stop) {
				WalletField *field = [WalletData fieldOfFieldItem:obj];
				return [field.name isEqualToString:fieldOfTargetCategory.name];
			}];
            
			if (idx == NSNotFound) continue;
            
			WalletFieldItem *originalFieldItem = originalFieldItems[idx];
			WalletField *originalField = [WalletData fieldOfFieldItem:originalFieldItem];
			if ([originalField.type isEqualToString:fieldOfTargetCategory.type]) {
				originalFieldItem.fieldID = fieldOfTargetCategory.uniqueID;
				[addedItems addObject:originalFieldItem];
			}
			else if (![originalField.type isEqualToString:WalletFieldTypeDate] && ![originalField.type isEqualToString:WalletFieldTypeImage] && ![originalField.type isEqualToString:WalletFieldTypeVideo]) {
				originalFieldItem.fieldID = fieldOfTargetCategory.uniqueID;
				[addedItems addObject:originalFieldItem];
			}
		}
    }
    
    [originalFieldItems removeObjectsInArray:addedItems];
    
    NSMutableString *moveToNoteString = [NSMutableString new];
	if ([[_item.note stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n\t "]] length]) {
		[moveToNoteString appendFormat:@"%@\n", _item.note];
	}
    
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if (IS_IPAD || [NSDate isFullStyleLocale]) {
        [dateFormatter setDateStyle:NSDateFormatterFullStyle];
    }
    else {
        dateFormatter.dateFormat = [dateFormatter customFullStyleFormat];
    }
    
	for (WalletFieldItem *remainItem in originalFieldItems) {
		@autoreleasepool {
			WalletField *remainingItemField = [WalletData fieldOfFieldItem:remainItem];
			if ([remainingItemField.type isEqualToString:WalletFieldTypeDate] && remainItem.date) {
				[moveToNoteString appendFormat:@"%@ : %@\n", remainingItemField.name, [dateFormatter stringFromDate:remainItem.date]];
			} else
                if (remainItem.value.length > 0) {
                    NSString *movingText = [NSString stringWithFormat:@"%@ : %@\n", remainingItemField.name, remainItem.value];
                    [moveToNoteString appendString:movingText];
                }
			remainItem.fieldID = nil;
		}
    }
    if (moveToNoteString.length > 0) {
        self.item.note = [moveToNoteString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n\t "]];
    }
	_category = toCategory;
    _item.categoryID = toCategory.uniqueID;
    
    // 정보 불러오기
    _sectionItems = nil;
	[self sectionItems];
    [self.tableView reloadData];
    
	[self updateDoneButtonEnabled];
}

#pragma mark- UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)imageEditInfo {
    NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
    WalletFieldItem *fieldItem = [[WalletFieldItem alloc] initWithContext:context];
	fieldItem.uniqueID = [[NSUUID UUID] UUIDString];
	fieldItem.updateDate = [NSDate date];
	fieldItem.walletItemID = _item.uniqueID;
	fieldItem.fieldID = _currentFieldItem.fieldID;
    
    [context deleteObject:_currentFieldItem];
	_currentFieldItem = fieldItem;
    
    BOOL result;
	NSString *mediaType = imageEditInfo[UIImagePickerControllerMediaType];
	if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
		//get the videoURL
		NSURL *movieURL = imageEditInfo[UIImagePickerControllerMediaURL];
        
		_currentFieldItem.hasVideo = @YES;
		_currentFieldItem.videoExtension = movieURL.pathExtension;
		NSURL *destinationMovieURL = [_currentFieldItem videoFileURLInOriginal:NO];
        NSError *error;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        fileManager.delegate = self;
        
        if ([fileManager fileExistsAtPath:[destinationMovieURL path]]) {
            result = [fileManager removeItemAtURL:destinationMovieURL error:&error];
            NSAssert(result, @"NSFileManager defaultManager");
        }
//		result = [fileManager moveItemAtURL:movieURL toURL:destinationMovieURL error:&error];
        result = [fileManager copyItemAtURL:movieURL toURL:destinationMovieURL error:&error];
        
        NSAssert(result, @"NSFileManager defaultManager");
        
        NSURL *assetURL = imageEditInfo[UIImagePickerControllerReferenceURL];
		if (assetURL) {
			ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
			[library assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                NSDate *mediaCreationDate = [asset valueForProperty:ALAssetPropertyDate];
                _currentFieldItem.videoCreationDate = mediaCreationDate;
			} failureBlock:^(NSError *error) {
				// error handling
			}];
		} else {
            NSError *error = [NSError new];
            NSDictionary *itemAttribute = [fileManager attributesOfItemAtPath:[destinationMovieURL path] error:&error];
            NSDate *mediaCreationDate = [itemAttribute objectForKey:NSFileCreationDate];
            _currentFieldItem.videoCreationDate = mediaCreationDate;
		}
        
		UIImage *originalImage = [WalletData videoPreviewImageOfURL:destinationMovieURL];
		[_currentFieldItem makeVideoThumbnailWithImage:originalImage inOriginalDirectory:NO];
	}
	else {
		FNLOG(@"%@", imageEditInfo);
		UIImage *originalImage = [imageEditInfo objectForKey:UIImagePickerControllerEditedImage];
		if (!originalImage) {
			originalImage = [imageEditInfo objectForKey:UIImagePickerControllerOriginalImage];
		}
        
		_currentFieldItem.hasImage = @YES;
		[_currentFieldItem setPhotoImage:originalImage inOriginalDirectory:NO];
		[_currentFieldItem makePhotoImageThumbnailWithImage:originalImage inOriginalDirectory:NO];
        
		NSURL *referenceURL = [imageEditInfo objectForKey:UIImagePickerControllerReferenceURL];
		if (referenceURL) {
			ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
			[library assetForURL:referenceURL resultBlock:^(ALAsset *asset) {
				ALAssetRepresentation *rep = [asset defaultRepresentation];
				_imageMetadata = rep.metadata;
				[self saveMetadata:_imageMetadata addLocation:NO];
			} failureBlock:^(NSError *error) {
				// error handling
			}];
		} else {
			_imageMetadata = [imageEditInfo objectForKey:UIImagePickerControllerMediaMetadata];
			[self saveMetadata:_imageMetadata addLocation:YES];
		}
	}
    
	[self.tableView reloadRowsAtIndexPaths:@[_currentIndexPath] withRowAnimation:UITableViewRowAnimationFade];
	[self updateDoneButtonEnabled];
    
	[self dismissImagePickerViewController];
}

- (void)dismissImagePickerViewController {
	if (IS_IPAD && self.popOverController) {
		[self.popOverController dismissPopoverAnimated:YES];
		self.popOverController = nil;
	}
	else {
		[_imagePickerController dismissViewControllerAnimated:YES completion:NULL];
	}
	_imagePickerController = nil;
}

- (void)saveMetadata:(NSDictionary *)metadata addLocation:(BOOL)addLocation {
	FNLOG(@"%@", _imageMetadata);
    
	if (addLocation && ![_imageMetadata valueForKey:(NSString *)kCGImagePropertyGPSDictionary] && _myLocation) {
		NSMutableDictionary *GPS = [NSMutableDictionary new];
		[GPS setObject:@(_myLocation.coordinate.latitude) forKey:@"Latitude"];
		[GPS setObject:@(_myLocation.coordinate.longitude) forKey:@"Longitude"];
		[GPS setObject:@(_myLocation.altitude) forKey:@"Altitude"];
		NSDateFormatter *dateFormatter = [NSDateFormatter new];
		[dateFormatter setDateFormat:@"yyyy:MM:dd"];
		[GPS setObject:[dateFormatter stringFromDate:[NSDate date]] forKey:@"DateStamp"];
		[dateFormatter setDateFormat:@"hh:mm:ss"];
		[GPS setObject:[dateFormatter stringFromDate:[NSDate date]] forKey:@"TimeStamp"];
		NSMutableDictionary *mutableMetadata = [_imageMetadata mutableCopy];
		[mutableMetadata setObject:GPS forKey:(NSString *)kCGImagePropertyGPSDictionary];
		_imageMetadata = mutableMetadata;
	}
    NSError *error;
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:_imageMetadata
                                                              format:NSPropertyListXMLFormat_v1_0
                                                             options:0
                                                               error:&error];
    
	_currentFieldItem.imageMetaData = data;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[self dismissImagePickerViewController];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
	[manager stopMonitoringSignificantLocationChanges];
    
	if ([locations count]) {
		self.myLocation = locations[0];
	}
}

#pragma mark - UIPopoverController Delegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
    self.imagePickerController = nil;
    self.popOverController = nil;
}

#pragma mark - UIActionSheet delegate

- (void)deleteItemByActionSheet {
	[self dismissViewControllerAnimated:NO completion:^{
		if ([self.delegate respondsToSelector:@selector(WalletItemDeleted)]) {
			[self.delegate WalletItemDeleted];
		}
		[self deleteWalletItemByID:self.item.uniqueID];
	}];
}

- (void)deleteWalletItemByID:(NSString *)itemID {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uniqueID == %@", itemID];
	NSArray *items = [WalletItem findAllWithPredicate:predicate];
    for (WalletItem *item in items) {
        [item deleteWalletItem];
    }
    NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
    [context saveContext];
}

- (void)imagePickerActionForButtonIndex:(NSInteger)myButtonIndex destructiveButtonIndex:(NSInteger)destructiveButtonIndex actionSheetTag:(NSInteger)actionSheetTag {

	if (destructiveButtonIndex >= 0)
		myButtonIndex--;
	if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		myButtonIndex++;
	}

	switch (myButtonIndex) {
		case 0:{
			AVAuthorizationStatus authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
			if (authorizationStatus != AVAuthorizationStatusAuthorized) {
				[self requestAuthorizationForCamera:NSLocalizedString(A3AppName_Wallet, nil)
							 afterAuthorizedHandler:^(BOOL granted) {
								 if (granted) {
									 [self presentImagePickerControllerWithOption:myButtonIndex actionSheetTag:actionSheetTag];
								 }
							 }];
			} else {
				[self presentImagePickerControllerWithOption:myButtonIndex actionSheetTag:actionSheetTag];
			}
			break;
		}
		case 1:
		case 2:
		{
			PHAuthorizationStatus authorizationStatus = [PHPhotoLibrary authorizationStatus];
			if (authorizationStatus != PHAuthorizationStatusAuthorized) {
				[self requestAuthorizationForPhotoLibrary:NSLocalizedString(A3AppName_Wallet, nil)
								afterAuthorizationHandler:^(BOOL granted) {
									if (granted) {
										[self presentImagePickerControllerWithOption:myButtonIndex actionSheetTag:actionSheetTag];
									}
								}];
			} else {
				[self presentImagePickerControllerWithOption:myButtonIndex actionSheetTag:actionSheetTag];
			}
			break;
		}
	}
}

- (void)presentImagePickerControllerWithOption:(NSInteger)option actionSheetTag:(NSInteger)actionSheetTag {
	_imagePickerController = [[UIImagePickerController alloc] init];
	switch (option) {
		case ActionTag_Camera:
			_imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
			_imagePickerController.allowsEditing = NO;
			_locationManager = [CLLocationManager new];
			_locationManager.delegate = self;
			[_locationManager startUpdatingLocation];
            if (actionSheetTag == ActionTag_PhotoLibraryEdit) {
                [A3UIDevice verifyAndAlertMicrophoneAvailability];
            }
			break;
		case ActionTag_PhotoLibrary:
			_imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
			_imagePickerController.allowsEditing = NO;
			break;
		case ActionTag_PhotoLibraryEdit:
			_imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
			_imagePickerController.allowsEditing = YES;
			break;
	}

	// photo
	if (actionSheetTag == ActionTag_PhotoLibrary) {
		_imagePickerController.mediaTypes = @[(NSString *) kUTTypeImage];
	}
		// video
	else if (actionSheetTag == ActionTag_PhotoLibraryEdit) {
		_imagePickerController.mediaTypes = @[(NSString *) kUTTypeMovie];
	}

	_imagePickerController.videoQuality = UIImagePickerControllerQualityTypeHigh;
	_imagePickerController.navigationBar.barStyle = UIBarStyleDefault;
	_imagePickerController.delegate = self;

	if (IS_IPAD) {
		if (_imagePickerController.sourceType == UIImagePickerControllerSourceTypeCamera) {
			_imagePickerController.showsCameraControls = YES;

			[self presentViewController:_imagePickerController animated:NO completion:NULL];
		}
		else {
			_imagePickerController.modalPresentationStyle = UIModalPresentationPopover;

			UIPopoverPresentationController *presentationController = [_imagePickerController popoverPresentationController];
			presentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
			presentationController.sourceView = [self imageViewInCellForIndexPath:_currentIndexPath];
			//CGRect rect = [self frameOfImageViewInCellForIndexPath:_currentIndexPath];

			// 이전 화면을 덮었던 ActionSheet 가 사라진 후에도 영향을 주어서, 현재의 스택을 벗어나서 실행하도록 하였습니다.
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				[self presentViewController:self.imagePickerController animated:YES completion:NULL];
			});
		}
	}
	else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:self.imagePickerController animated:NO completion:NULL];
        });
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	_actionSheet = nil;
    [self setFirstActionSheet:nil];
    
    if (buttonIndex == actionSheet.cancelButtonIndex) {
		return;
	}
    
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        if (actionSheet.tag == ActionTag_ImagePickerMenu || actionSheet.tag == ActionTag_DeleteImage || actionSheet.tag == ActionTag_DeleteVideo || actionSheet.tag == ActionTag_PhotoLibraryEdit) {
            // 삭제하기
            [self deleteMediaItem];
            return;
        }
        else if (actionSheet.tag == ActionTag_DeleteItem) {
            [self deleteItemByActionSheet];
			return;
        }
    }
    
	NSInteger myButtonIndex = buttonIndex;
    NSInteger destructiveButtonIndex = actionSheet.destructiveButtonIndex;
    NSInteger actionSheetTag = actionSheet.tag;
    
    
    [self imagePickerActionForButtonIndex:myButtonIndex destructiveButtonIndex:destructiveButtonIndex actionSheetTag:actionSheetTag];
}

#pragma mark ActionSheet Rotation Related
- (void)rotateFirstActionSheet {
    NSInteger currentActionSheetTag = [self.firstActionSheet tag];
    [super rotateFirstActionSheet];
    [self setFirstActionSheet:nil];
    
    [self showActionSheetAdaptivelyInViewWithTag:currentActionSheetTag];
}

- (void)showActionSheetAdaptivelyInViewWithTag:(NSInteger)actionSheetTag {
    switch (actionSheetTag) {
        case ActionTag_DeleteImage:
            [self showDeleteImageActionSheet];
            break;
            
        case ActionTag_DeleteVideo:
            [self showDeleteVideoActionSheet];
            break;
            
        case ActionTag_DeleteItem:
            [self showDeleteItemActionSheet];
            break;
            
        default:
            break;
    }
}

- (void)showDeleteItemActionSheet
{
	_actionSheet = [[UIActionSheet alloc] initWithTitle:nil
											   delegate:self
									  cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
								 destructiveButtonTitle:NSLocalizedString(@"Delete Item", @"Delete Item")
									  otherButtonTitles:nil];
    _actionSheet.tag = ActionTag_DeleteItem;
    [_actionSheet showInView:self.view];
	[self setFirstActionSheet:_actionSheet];
}

- (void)showDeleteImageActionSheet {
	_actionSheet = [[UIActionSheet alloc] initWithTitle:nil
											   delegate:self
									  cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
								 destructiveButtonTitle:NSLocalizedString(@"Delete Photo", nil)
									  otherButtonTitles:nil];
	_actionSheet.tag = ActionTag_DeleteImage;
	[_actionSheet showInView:self.view];
	[self setFirstActionSheet:_actionSheet];
}

- (void)showDeleteVideoActionSheet {
	_actionSheet = [[UIActionSheet alloc] initWithTitle:nil
											   delegate:self
									  cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
								 destructiveButtonTitle:NSLocalizedString(@"Delete Video", nil)
									  otherButtonTitles:nil];
	_actionSheet.tag = ActionTag_DeleteVideo;
	[_actionSheet showInView:self.view];
	[self setFirstActionSheet:_actionSheet];
}

#pragma mark - CategorySelect delegate

- (void)walletCategorySelected:(WalletCategory *) category
{
    FNLOG(@"walletCategorySelected : %@", category.name);
    
	if (IS_IPAD) {
		[self dismissRightSideView];
	}
    
    if (![_item.categoryID isEqualToString:category.uniqueID]) {
        FNLOG(@"Change category");
        
        [self changeCategory:category];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	FNLOG();
	[self dismissDatePicker];
    
	NSIndexPath *indexPath = [self.tableView indexPathForCellSubview:textField];
	FNLOG(@"current text field indexpath : %@", [indexPath description]);
    
	if ([self.sectionItems objectAtIndex:indexPath.row] == self.titleItem) {
		textField.keyboardType = UIKeyboardTypeDefault;
		textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
		if ([self isMediaCategory]) {
			textField.returnKeyType = UIReturnKeyDefault;
		} else {
			textField.returnKeyType = UIReturnKeyNext;
		}
	} else if ([self.sectionItems objectAtIndex:indexPath.row] != self.categoryItem ) {
        
		WalletField *field = _sectionItems[indexPath.row];
		if ([field.type isEqualToString:WalletFieldTypeText]) {
			textField.keyboardType = UIKeyboardTypeDefault;
			textField.clearButtonMode = UITextFieldViewModeWhileEditing;
		}
		else if ([field.type isEqualToString:WalletFieldTypeNumber]) {
			textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
			textField.clearButtonMode = UITextFieldViewModeWhileEditing;
		}
		else if ([field.type isEqualToString:WalletFieldTypePhone]) {
			textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
			textField.clearButtonMode = UITextFieldViewModeWhileEditing;
		}
		else if ([field.type isEqualToString:WalletFieldTypeURL]) {
			textField.keyboardType = UIKeyboardTypeURL;
			textField.clearButtonMode = UITextFieldViewModeWhileEditing;
		}
		else if ([field.type isEqualToString:WalletFieldTypeEmail]) {
			textField.keyboardType = UIKeyboardTypeEmailAddress;
			textField.clearButtonMode = UITextFieldViewModeWhileEditing;
		}
	}
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	FNLOG();
	self.editingObject = textField;
    
	_currentIndexPath = [self.tableView indexPathForCellSubview:textField];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)textFieldDidChange:(NSNotification *)notification {
	UITextField *textField = notification.object;
	if ([self isMediaCategory]) {
		[self updateDoneButtonEnabled];
	} else {
		self.navigationItem.rightBarButtonItem.enabled = [self hasChanges] || [textField.text length];
	}
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	FNLOG();
    if (textField == self.editingObject) {
        self.editingObject = nil;
    }
    
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    
	NSString *text = [textField.text stringByTrimmingSpaceCharacters];
	NSIndexPath *indexPath = [self.tableView indexPathForCellSubview:textField];
	FNLOG(@"%ld, %ld", (long)indexPath.section, (long)indexPath.row);
	// update
	if (_sectionItems[indexPath.row] == self.titleItem) {
		_item.name = [text length] ? text : nil;
	}
	else if (_sectionItems[indexPath.row] != self.categoryItem) {
		WalletFieldItem *fieldItem = [self fieldItemForIndexPath:indexPath create:YES];
        
		fieldItem.value = [text length] ? text : nil;
	}
}

- (BOOL)isMediaCategory {
	return [_item.categoryID isEqualToString:A3WalletUUIDPhotoCategory] || [_item.categoryID isEqualToString:A3WalletUUIDVideoCategory];
}

- (BOOL)isNonTextInputItem:(id)item {
	if (item == self.noteItem) return NO;
	if (item == self.categoryItem || item == self.titleItem) return YES;
    
	WalletField *field = item;
	return [field.type isEqualToString:WalletFieldTypeDate] ||
    [field.type isEqualToString:WalletFieldTypeImage] ||
    [field.type isEqualToString:WalletFieldTypeVideo];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	NSIndexPath *indexPath = [self.tableView indexPathForCellSubview:textField];
	if (_sectionItems[indexPath.row] == _titleItem && [self isMediaCategory]) {
		[textField resignFirstResponder];
		return YES;
	}
    
	NSUInteger startIdx;
	startIdx = (NSUInteger) (indexPath.row + 1);
	while ([self isNonTextInputItem:_sectionItems[startIdx]] && startIdx < [_sectionItems count]) startIdx++;
    
	if (startIdx >= [_sectionItems count]) return YES;
    
	if ([_sectionItems objectAtIndex:startIdx] == self.noteItem) {
		[textField resignFirstResponder];
        
		dispatch_async(dispatch_get_main_queue(), ^{
			NSIndexPath *ip = [NSIndexPath indexPathForRow:startIdx inSection:0];
			A3WalletNoteCell *noteCell = (A3WalletNoteCell *)[self.tableView cellForRowAtIndexPath:ip];
			[noteCell.textView becomeFirstResponder];
		});
	}
	else {
		NSIndexPath *ip = [NSIndexPath indexPathForRow:startIdx inSection:0];
		A3WalletItemFieldCell *inputCell = (A3WalletItemFieldCell* )[self.tableView cellForRowAtIndexPath:ip];
		[inputCell.valueTextField becomeFirstResponder];
	}
    
	return YES;
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [self dismissDatePicker];
    
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
	self.editingObject = textView;
}

- (void)textViewDidChange:(UITextView *)textView
{
	NSString *text = [textView.text stringByTrimmingSpaceCharacters];
	_item.note = [text length] ? text : nil;
	[self updateDoneButtonEnabled];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
	self.editingObject = nil;
	NSString *text = [textView.text stringByTrimmingSpaceCharacters];
	_item.note = [text length] ? text : nil;
    
    [self updateDoneButtonEnabled];
    
	UITableViewCell *cell = [self.tableView cellForCellSubview:textView];
	[cell layoutIfNeeded];
}

#pragma mark - tableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	_currentIndexPath = indexPath;
    
	if (indexPath.section == 0) {
	    if ([self.sectionItems objectAtIndex:indexPath.row] == self.categoryItem) {
			[self.editingObject resignFirstResponder];
            // category
            A3WalletCategorySelectViewController *viewController = [[A3WalletCategorySelectViewController alloc] initWithStyle:UITableViewStyleGrouped];
            viewController.selectedCategory = self.category;
            viewController.delegate = self;
            
            if (IS_IPHONE) {
                [self.navigationController pushViewController:viewController animated:YES];
            } else {
				_rightSideViewController = [[A3NavigationController alloc] initWithRootViewController:viewController];
				[self presentRightSideView:_rightSideViewController.view];
				[self.navigationController addChildViewController:_rightSideViewController];
            }
        }
		else if ([self.sectionItems[indexPath.row] isKindOfClass:[WalletFieldItem class]]) {
			[self.editingObject resignFirstResponder];
			WalletFieldItem *fieldItem = _sectionItems[indexPath.row];
			if ([fieldItem.hasImage boolValue]) {
				[self askDeleteImage];
			} else if ([fieldItem.hasVideo boolValue]) {
				[self askDeleteVideo];
			}
		}
		else if ([self.sectionItems objectAtIndex:indexPath.row] == self.noteItem) {
			A3WalletNoteCell *cell = (A3WalletNoteCell *) [self.tableView cellForRowAtIndexPath:indexPath];
			if (self.editingObject != cell.textView) {
				[self.editingObject resignFirstResponder];
				[cell.textView becomeFirstResponder];
			}
		}
        else if ([self.sectionItems objectAtIndex:indexPath.row] != self.titleItem) {
			WalletField *field = [_sectionItems objectAtIndex:indexPath.row];
			_currentFieldItem = [self fieldItemForIndexPath:indexPath create:YES];
            
			if ([field.type isEqualToString:WalletFieldTypeDate]) {
				[self.editingObject resignFirstResponder];
				if ([_sectionItems containsObject:self.dateInputItem]) {
					if ([indexPath compare:self.dateInputIndexPath] == NSOrderedSame) {
						// 현재 셀에 연결된 입력 picker
                        //						_currentFieldItem.date = _datePicker.date;
                        //						[tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                        [self dismissDatePicker];
                    }
                    else {
                        // 다른 셀에 연결된 입력 picker
						[self exchangeDatePickerFromIndexPath:self.dateInputIndexPath toIndexPath:indexPath];
                    }
                }
                else {
                    [self datePickerActiveFromIndexPath:indexPath];
                }
            }
            else if ([field.type isEqualToString:WalletFieldTypeImage]) {
				[self.editingObject resignFirstResponder];
                
                if ([_sectionItems containsObject:self.dateInputItem]) {
                    if (self.dateInputIndexPath.row < self.currentIndexPath.row) {
                        [self dismissDatePicker];
                        _currentIndexPath = [NSIndexPath indexPathForRow:_currentIndexPath.row - 1 inSection:_currentIndexPath.section];
                    }
                    else {
                        [self dismissDatePicker];
                    }
                    
                    
                    [self.tableView reloadRowsAtIndexPaths:@[self.currentIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                }
                
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                _actionSheet = [self actionSheetAskingImagePickupWithDelete:[_currentFieldItem.hasImage boolValue] delegate:self];
                _actionSheet.tag = ActionTag_ImagePickerMenu;
                
                if ([cell isKindOfClass:[A3WalletItemRightIconCell class]]) {
                    [_actionSheet showFromRect:[((A3WalletItemRightIconCell *) cell).iconImgView bounds] inView:[(A3WalletItemRightIconCell *) cell iconImgView] animated:YES];
                }
                else if ([cell isKindOfClass:[A3WalletItemPhotoFieldCell class]]) {
                    [_actionSheet showFromRect:[((A3WalletItemPhotoFieldCell *) cell).photoButton bounds] inView:[(A3WalletItemPhotoFieldCell *) cell photoButton] animated:YES];
                }
            }
            else if ([field.type isEqualToString:WalletFieldTypeVideo]) {
				[self.editingObject resignFirstResponder];
				[self dismissDatePicker];
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                [self askVideoPickupWithDelete:[_currentFieldItem.hasVideo boolValue] withSender:cell];
            }
            else {
                A3WalletItemFieldCell *inputCell = (A3WalletItemFieldCell *)[tableView cellForRowAtIndexPath:indexPath];
				if (self.editingObject != inputCell.valueTextField) {
					[self.editingObject resignFirstResponder];
					[inputCell.valueTextField becomeFirstResponder];
				}
            }
        }
    }
    else {
		[self.editingObject resignFirstResponder];
        
        // delete category
        [self showDeleteItemActionSheet];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGRect)frameOfImageViewInCellForIndexPath:(NSIndexPath *)indexPath {
	CGRect frame = CGRectZero;
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
	if ([cell isKindOfClass:[A3WalletItemRightIconCell class]]) {
		A3WalletItemRightIconCell *iconCell = (A3WalletItemRightIconCell *)cell;
		frame = [self.view convertRect:iconCell.iconImgView.bounds fromView:iconCell.iconImgView];
	}
	else if ([cell isKindOfClass:[A3WalletItemPhotoFieldCell class]]) {
		A3WalletItemPhotoFieldCell *photoCell = (A3WalletItemPhotoFieldCell *)cell;
		frame = [self.view convertRect:photoCell.photoButton.bounds fromView:photoCell.photoButton];
	}
	return frame;
}

- (UIView *)imageViewInCellForIndexPath:(NSIndexPath *)indexPath {
    UIView *imageView = nil;
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[A3WalletItemRightIconCell class]]) {
        A3WalletItemRightIconCell *iconCell = (A3WalletItemRightIconCell *)cell;
        imageView = iconCell.iconImgView;
    }
    else if ([cell isKindOfClass:[A3WalletItemPhotoFieldCell class]]) {
        A3WalletItemPhotoFieldCell *photoCell = (A3WalletItemPhotoFieldCell *)cell;
        imageView = photoCell.photoButton;
    }
    
    return imageView;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return _isAddNewItem ? 1 : 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return self.sectionItems.count;
    }
    else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if ([self.sectionItems objectAtIndex:indexPath.row] == self.noteItem) {
			return [UIViewController noteCellHeight];
        }
        else if ([self.sectionItems objectAtIndex:indexPath.row] == self.dateInputItem) {
            
            return 218;
        }
        else if (indexPath.row == 0) {
            
            return IS_RETINA ? 74.5 : 75.0;
        }
        
        return 74.0;
    }
    else {
        
        // delete
        return 44.0;
    }
}

- (float)noteHeight {
	CGFloat noteCellStartY = 247;
	CGRect screenBounds = [self screenBoundsAdjustedWithOrientation];
	return screenBounds.size.height - noteCellStartY - (IS_RETINA ? 36.5 : 37);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=nil;
	if (indexPath.section == 0) {
		NSArray *items = @[self.titleItem, self.categoryItem, self.noteItem, self.dateInputItem];
		NSUInteger itemIndex = [items indexOfObject:self.sectionItems[indexPath.row]];
		switch (itemIndex) {
			case 0:
				cell = [self getTitleCell:tableView indexPath:indexPath];
				break;
			case 1:
				cell = [self getCategoryCell:tableView indexPath:indexPath];
				break;
			case 2:
				cell = [self getNoteCell:tableView indexPath:indexPath];
				break;
			case 3:
				cell = [self getDateInputCell:tableView indexPath:indexPath];
				break;
			default:
				cell= [self getFieldTypeCell:tableView indexPath:indexPath];
				break;
		}
	}
	else {
		UITableViewCell *deleteCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemFieldDeleteCellID4 forIndexPath:indexPath];
		deleteCell.selectionStyle = UITableViewCellSelectionStyleNone;
		UILabel *textLabel = (UILabel *)[deleteCell viewWithTag:10];
		textLabel.text = NSLocalizedString(@"Delete Item", nil);
        
		cell = deleteCell;
	}
    
    return cell;
}

- (UITableViewCell *)getFieldTypeCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
	if ([_sectionItems[indexPath.row] isKindOfClass:[WalletFieldItem class]]) {
		UITableViewCell *cell;
		WalletFieldItem *fieldItem = _sectionItems[indexPath.row];
		if ([fieldItem.hasImage boolValue]	) {
			cell = [self getImageCell:tableView indexPath:indexPath fieldItem:fieldItem];
		} else if ([fieldItem.hasVideo boolValue]) {
			cell = [self getVideoCell:tableView indexPath:indexPath fieldItem:fieldItem];
		} else {
			FNLOG(@"Invalid Data has been found. WalletFieldItem field == NULL, image == NULL, video == NULL");
			UITableViewCell *defaultCell = [tableView dequeueReusableCellWithIdentifier:A3TableViewCellDefaultCellID forIndexPath:indexPath];
			cell = defaultCell;
		}
		return cell;
	}
	WalletField *field = [_sectionItems objectAtIndex:indexPath.row];
    
	WalletFieldItem *fieldItem = [self fieldItemForIndexPath:indexPath create:YES];
	UITableViewCell *cell;
	NSArray *types = @[WalletFieldTypeDate, WalletFieldTypeImage, WalletFieldTypeVideo, WalletFieldTypeText];
	NSUInteger index = [types indexOfObject:field.type];
	switch (index) {
		case 0:
			cell = [self getDateCell:tableView indexPath:indexPath fieldItem:fieldItem];
			break;
		case 1:
			cell = [self getImageCell:tableView indexPath:indexPath fieldItem:fieldItem];
			break;
		case 2:
			cell = [self getVideoCell:tableView indexPath:indexPath fieldItem:fieldItem];
			break;
		default:
			cell = [self getNormalCell:tableView indexPath:indexPath field:field fieldItem:fieldItem];
			break;
	}
	return cell;
}

- (UITableViewCell *)getNormalCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath field:(WalletField *)field fieldItem:(WalletFieldItem *)fieldItem {
	UITableViewCell *cell;
	A3WalletItemFieldCell *inputCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemFieldCellID4 forIndexPath:indexPath];
    
	inputCell.selectionStyle = UITableViewCellSelectionStyleNone;
	[self configureFloatingTextField:inputCell.valueTextField];
    
	inputCell.valueTextField.tag = 0;
	inputCell.valueTextField.placeholder = field.name;
	inputCell.valueTextField.text = fieldItem.value;
	inputCell.valueTextField.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
    inputCell.valueTextField.enabled = YES;
    
	cell = inputCell;
	return cell;
}

- (UITableViewCell *)getVideoCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath fieldItem:(WalletFieldItem *)fieldItem {
	UITableViewCell *cell;
	WalletField *field = [WalletData fieldOfFieldItem:fieldItem];
	if ([fieldItem.hasVideo boolValue]) {
        
		A3WalletItemPhotoFieldCell *photoCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemPhotoFieldCellID4 forIndexPath:indexPath];
        
		photoCell.selectionStyle = UITableViewCellSelectionStyleNone;
		[self configureFloatingTextField:photoCell.valueTextField];
        
		photoCell.valueTextField.placeholder = field.name;
		photoCell.valueTextField.enabled = NO;
        
		photoCell.valueTextField.text = @" ";
		photoCell.photoButton.hidden = NO;
        
		NSString *thumbFilePath = [fieldItem videoThumbnailPathInOriginal:NO ];
		NSData *img = [NSData dataWithContentsOfFile:thumbFilePath];
		UIImage *photo = [UIImage imageWithData:img];
		photo = [photo imageByScalingProportionallyToSize:CGSizeMake(120, 120)];
		[photoCell.photoButton setBackgroundImage:photo forState:UIControlStateNormal];
		[photoCell.photoButton addTarget:self action:@selector(mediaButtonAction:) forControlEvents:UIControlEventTouchUpInside];
		photoCell.photoButton.tag = indexPath.row;
        
		cell = photoCell;
	}
	else {
		A3WalletItemRightIconCell *iconCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemRightIconCellID4 forIndexPath:indexPath];
        
		iconCell.selectionStyle = UITableViewCellSelectionStyleNone;
		iconCell.titleLabel.text = field.name;
		iconCell.titleLabel.textColor = [UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:205.0/255.0 alpha:1.0];
		iconCell.iconImgView.image = [UIImage imageNamed:@"video"];
        
		cell = iconCell;
	}
	return cell;
}

- (UITableViewCell *)getImageCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath fieldItem:(WalletFieldItem *)fieldItem {
	UITableViewCell *cell;
	WalletField *field = [WalletData fieldOfFieldItem:fieldItem];;
	if ([fieldItem.hasImage boolValue]) {
		A3WalletItemPhotoFieldCell *photoCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemPhotoFieldCellID4 forIndexPath:indexPath];
        
		photoCell.selectionStyle = UITableViewCellSelectionStyleNone;
		[self configureFloatingTextField:photoCell.valueTextField];
        
		photoCell.valueTextField.placeholder = field.name;
		photoCell.valueTextField.enabled = NO;
        
		photoCell.valueTextField.text = @" ";
		photoCell.photoButton.hidden = NO;
        
		NSString *thumbFilePath = [fieldItem photoImageThumbnailPathInOriginal:NO];
		NSData *img = [NSData dataWithContentsOfFile:thumbFilePath];
		UIImage *photo = [UIImage imageWithData:img];
		photo = [photo imageByScalingProportionallyToSize:CGSizeMake(120, 120)];
		[photoCell.photoButton setBackgroundImage:photo forState:UIControlStateNormal];
		[photoCell.photoButton addTarget:self action:@selector(mediaButtonAction:) forControlEvents:UIControlEventTouchUpInside];
		photoCell.photoButton.tag = indexPath.row;
        
		cell = photoCell;
	}
	else {
		A3WalletItemRightIconCell *iconCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemRightIconCellID4 forIndexPath:indexPath];
        
		iconCell.selectionStyle = UITableViewCellSelectionStyleNone;
		iconCell.titleLabel.text = field.name;
		iconCell.titleLabel.textColor = [UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:205.0/255.0 alpha:1.0];
		iconCell.iconImgView.image = [UIImage imageNamed:@"camera"];
        
		cell = iconCell;
	}
	return cell;
}

- (A3WalletItemFieldCell *)getDateCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath fieldItem:(WalletFieldItem *)fieldItem {
	A3WalletItemFieldCell *inputCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemDateCellID4 forIndexPath:indexPath];
    
	inputCell.selectionStyle = UITableViewCellSelectionStyleNone;
	[self configureFloatingTextField:inputCell.valueTextField];
    
	[inputCell addDeleteButton];
	[inputCell.deleteButton setHidden:fieldItem.date == nil];
	[inputCell.deleteButton addTarget:self action:@selector(deleteDate:) forControlEvents:UIControlEventTouchUpInside];
    
	inputCell.valueTextField.enabled = NO;
	inputCell.valueTextField.placeholder = [WalletData fieldOfFieldItem:fieldItem].name;
    
	if ([fieldItem.date isKindOfClass:[NSDate class]]) {
		NSDateFormatter *df = [[NSDateFormatter alloc] init];
        if (IS_IPAD || [NSDate isFullStyleLocale]) {
            [df setDateStyle:NSDateFormatterFullStyle];
        }
        else {
            df.dateFormat = [df customFullStyleFormat];
        }
		
		inputCell.valueTextField.text = [df stringFromDate:fieldItem.date];
	}
	else {
		inputCell.valueTextField.text = @"";
	}
    
	if ([indexPath compare:self.dateInputIndexPath] == NSOrderedSame) {
        inputCell.valueTextField.textColor = [[A3UserDefaults standardUserDefaults] themeColor];
	} else {
		inputCell.valueTextField.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
	}
	return inputCell;
}

- (A3WalletDateInputCell *)getDateInputCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    // date input cell
	WalletFieldItem *fieldItem = [self fieldItemForIndexPath:[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:0] create:NO];
	A3WalletDateInputCell *dateInputCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemDateInputCellID4 forIndexPath:indexPath];
	dateInputCell.selectionStyle = UITableViewCellSelectionStyleNone;
	dateInputCell.datePicker.date = fieldItem.date ? fieldItem.date: [NSDate date];
    if (@available(iOS 13.4, *)) {
        dateInputCell.datePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
    }
	dateInputCell.datePicker.datePickerMode = UIDatePickerModeDate;
	[dateInputCell.datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
	_datePicker = dateInputCell.datePicker;
	return dateInputCell;
}

- (A3WalletNoteCell *)getNoteCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
	A3WalletNoteCell *noteCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemNoteCellID4 forIndexPath:indexPath];
	[noteCell setupTextView];
	noteCell.textView.text = _item.note;
    noteCell.textView.delegate = self;
    
	return noteCell;
}

- (A3WalletItemFieldCell *)getCategoryCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
	A3WalletItemFieldCell *inputCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemFieldCateCellID4 forIndexPath:indexPath];
    
	inputCell.selectionStyle = UITableViewCellSelectionStyleNone;
	[self configureFloatingTextField:inputCell.valueTextField];
    
	inputCell.valueTextField.floatingLabelFont = [UIFont systemFontOfSize:14];
	inputCell.valueTextField.font = [UIFont systemFontOfSize:17];
	inputCell.valueTextField.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
	inputCell.valueTextField.enabled = NO;
	inputCell.valueTextField.placeholder = NSLocalizedString(@"Category", @"Category");
	inputCell.valueTextField.text = _category.name;
	return inputCell;
}

- (A3WalletItemTitleCell *)getTitleCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
	A3WalletItemTitleCell *titleCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemTitleCellID forIndexPath:indexPath];
    
	titleCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
	titleCell.titleTextField.delegate = self;
	titleCell.titleTextField.placeholder = NSLocalizedString(@"Title", @"Title");
	titleCell.titleTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
	[titleCell.favoriteButton addTarget:self action:@selector(favoriteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	titleCell.favoriteButton.selected = [WalletFavorite isFavoriteForItemID:_item.uniqueID];
    
	titleCell.titleTextField.text = _item.name;
    
	_titleTextField = titleCell.titleTextField;
    
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	df.dateStyle = NSDateFormatterFullStyle;
    
	NSDate *date = _item.updateDate ? _item.updateDate : [NSDate date];
    if (IS_IPAD || [NSDate isFullStyleLocale]) {
        titleCell.timeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Current %@", @"Current %@"), [self fullStyleDateStringFromDate:date withShortTime:YES]];
    }
    else {
        titleCell.timeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Current %@", @"Current %@"), [self customFullStyleDateStringFromDate:date withShortTime:YES]];
    }
    
	return titleCell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return [self standardHeightForHeaderInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	BOOL isLastSection = ([self.tableView numberOfSections] - 1) == section;
	return [self standardHeightForFooterIsLastSection:isLastSection];
}

#pragma mark - NSFileManagerDelegate
- (BOOL)fileManager:(NSFileManager *)fileManager shouldRemoveItemAtPath:(NSString *)path
{
    return [fileManager fileExistsAtPath:path];
}

- (BOOL)fileManager:(NSFileManager *)fileManager shouldRemoveItemAtURL:(NSURL *)URL
{
    return [fileManager fileExistsAtPath:[URL path]];
}

-(BOOL)fileManager:(NSFileManager *)fileManager shouldProceedAfterError:(NSError *)error copyingItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath {
    FNLOG(@"%@", error);
    return NO;
}

-(BOOL)fileManager:(NSFileManager *)fileManager shouldProceedAfterError:(NSError *)error copyingItemAtURL:(NSURL *)srcURL toURL:(NSURL *)dstURL {
    FNLOG(@"%@", error);
    return NO;
}

-(BOOL)fileManager:(NSFileManager *)fileManager shouldProceedAfterError:(NSError *)error movingItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath {
    FNLOG(@"%@", error);
    return NO;
}

-(BOOL)fileManager:(NSFileManager *)fileManager shouldProceedAfterError:(NSError *)error movingItemAtURL:(NSURL *)srcURL toURL:(NSURL *)dstURL {
    FNLOG(@"%@", error);
    return NO;
}

- (BOOL)fileManager:(NSFileManager *)fileManager shouldProceedAfterError:(NSError *)error removingItemAtPath:(NSString *)path {
    FNLOG(@"%@", error);
    return NO;
}

- (BOOL)fileManager:(NSFileManager *)fileManager shouldProceedAfterError:(NSError *)error removingItemAtURL:(NSURL *)URL {
    FNLOG(@"%@", error);
    return NO;
}

@end
