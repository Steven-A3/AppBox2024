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
#import "WalletCategory.h"
#import "WalletData.h"
#import "WalletItem.h"
#import "WalletItem+Favorite.h"
#import "WalletFieldItem.h"
#import "WalletFieldItem+initialize.h"
#import "WalletCategory+initialize.h"
#import "WalletField.h"
#import "A3AppDelegate+appearance.h"
#import "UIViewController+NumberKeyboard.h"
#import "UIViewController+A3Addition.h"
#import "UIImage+Extension2.h"
#import "UITableView+utility.h"
#import "UIViewController+iPad_rightSideView.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "A3WalletItemTitleCell.h"
#import "WalletFieldItemVideo.h"
#import "WalletFieldItemImage.h"
#import "WalletItem+initialize.h"
#import "NSString+conversion.h"
#import "NSDate+formatting.h"
#import "NSDateFormatter+A3Addition.h"

#import <CoreLocation/CoreLocation.h>
#import <ImageIO/ImageIO.h>
#import <AssetsLibrary/AssetsLibrary.h>

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

@interface A3WalletItemEditViewController () <WalletCatogerySelectDelegate, UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, CLLocationManagerDelegate>

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

	if (_isAddNewItem) {
		self.navigationItem.title = @"Add Item";

		_item = [WalletItem MR_createEntity];
		_item.uniqueID = [[NSUUID UUID] UUIDString];
		[_item assignOrder];
		_item.category = _walletCategory;
	} else {
		self.navigationItem.title = @"Edit Item";

		_walletCategory = _item.category;

		[self copyThumbnailImagesToTemporaryPath];

		[_item verifyNULLField];
	}

	_originalCategoryUniqueID = _walletCategory.uniqueID;
	_isMemoCategory = [_item.category.uniqueID isEqualToString:A3WalletUUIDMemoCategory];

	[self makeBackButtonEmptyArrow];
    [self rightBarButtonDoneButton];
	self.navigationItem.rightBarButtonItem.enabled = NO;

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonAction:)];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, (IS_IPAD)?28:15, 0, 0);
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
}

- (void)removeObserver {
	[self removeContentSizeCategoryDidChangeNotification];
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
}

- (void)keyboardDidShow:(NSNotification *)notification {
	CGRect keyboardFrame = [[notification.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
	FNLOGRECT(keyboardFrame);
	if (IS_PORTRAIT) {
		_keyboardHeight = keyboardFrame.size.height;
	} else {
		_keyboardHeight = keyboardFrame.size.width;
	}
}

- (void)copyThumbnailImagesToTemporaryPath {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	for (WalletFieldItem *fieldItem in _item.fieldItems) {
		if (fieldItem.image) {
			NSString *thumbnailImagePath = [fieldItem photoImageThumbnailPathInOriginal:YES];
			NSString *thumbnailImageInTemp = [fieldItem photoImageThumbnailPathInOriginal:NO];
			[fileManager copyItemAtPath:thumbnailImagePath toPath:thumbnailImageInTemp error:NULL];
			continue;
		}
		if (fieldItem.video) {
			NSString *thumbnailImagePath = [fieldItem videoThumbnailPathInOriginal:YES];
			NSString *thumbnailImageInTemp = [fieldItem videoThumbnailPathInOriginal:NO];
			[fileManager copyItemAtPath:thumbnailImagePath toPath:thumbnailImageInTemp error:NULL];
			continue;
		}
	}
}

- (void)moveMediaFilesToNormalPath {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	for (WalletFieldItem *fieldItem in _item.fieldItems) {
		if (![fieldItem.field.type isEqualToString:WalletFieldTypeImage] && ![fieldItem.field.type isEqualToString:WalletFieldTypeVideo])
			continue;

		if ([fieldItem.field.type isEqualToString:WalletFieldTypeImage]) {
			NSString *photoImagePathInOriginalDirectory = [fieldItem photoImagePathInOriginalDirectory:YES];
			NSString *photoImagePathInTempDirectory = [fieldItem photoImagePathInOriginalDirectory:NO];
			NSString *thumbnailImagePath = [fieldItem photoImageThumbnailPathInOriginal:YES];
			NSString *thumbnailImageInTemp = [fieldItem photoImageThumbnailPathInOriginal:NO];
			if (fieldItem.image) {
				[fileManager removeItemAtPath:photoImagePathInOriginalDirectory error:NULL];
				[fileManager moveItemAtPath:photoImagePathInTempDirectory toPath:photoImagePathInOriginalDirectory error:NULL];

				[fileManager removeItemAtPath:thumbnailImagePath error:NULL];
				[fileManager moveItemAtPath:thumbnailImageInTemp toPath:thumbnailImagePath error:NULL];
			} else {
				[fileManager removeItemAtPath:photoImagePathInOriginalDirectory error:NULL];
				[fileManager removeItemAtPath:photoImagePathInTempDirectory error:NULL];

				[fileManager removeItemAtPath:thumbnailImagePath error:NULL];
				[fileManager removeItemAtPath:thumbnailImageInTemp error:NULL];
			}
		} else if ([fieldItem.field.type isEqualToString:WalletFieldTypeVideo]) {
			NSString *videoFilePath = [fieldItem videoFilePathInOriginal:YES];
			NSString *videoFilePathInTemp = [fieldItem videoFilePathInOriginal:NO];
			NSString *thumbnailImagePath = [fieldItem videoThumbnailPathInOriginal:YES];
			NSString *thumbnailImageInTemp = [fieldItem videoThumbnailPathInOriginal:NO];
			if (fieldItem.video) {
				[fileManager removeItemAtPath:videoFilePath error:NULL];
				[fileManager moveItemAtPath:videoFilePathInTemp toPath:videoFilePath error:NULL];

				[fileManager removeItemAtPath:thumbnailImagePath error:NULL];
				[fileManager moveItemAtPath:thumbnailImageInTemp toPath:thumbnailImagePath error:NULL];
			} else {
				[fileManager removeItemAtPath:videoFilePath error:NULL];
				[fileManager removeItemAtPath:videoFilePathInTemp error:NULL];

				[fileManager removeItemAtPath:thumbnailImagePath error:NULL];
				[fileManager removeItemAtPath:thumbnailImageInTemp error:NULL];
			}
		}
	}
}

- (void)removeTempFiles {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	for (WalletFieldItem *fieldItem in _item.fieldItems) {
		if (fieldItem.image) {
			NSString *thumbnailImagePathInTemp = [fieldItem photoImageThumbnailPathInOriginal:NO];
			[fileManager removeItemAtPath:thumbnailImagePathInTemp error:NULL];
			continue;
		}
		if (fieldItem.video) {
			NSString *thumbnailImagePathInTemp = [fieldItem videoThumbnailPathInOriginal:NO];
			[fileManager removeItemAtPath:thumbnailImagePathInTemp error:NULL];
			NSString *videoFilePathInTemp = [fieldItem videoFilePathInOriginal:NO];
			[fileManager removeItemAtPath:videoFilePathInTemp error:NULL];
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
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
        _sectionItems = [[NSMutableArray alloc] initWithArray:[_item.category.fields.allObjects sortedArrayUsingDescriptors:@[sortDescriptor]]];

		[_sectionItems insertObject:self.titleItem atIndex:0];
		[_sectionItems insertObject:self.categoryItem atIndex:1];

		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"walletItem.uniqueID == %@ AND field == NULL", _item.uniqueID];
		NSArray *fieldItemsFieldEqualsNULL = [WalletFieldItem MR_findAllWithPredicate:predicate];
		for (WalletFieldItem *fieldItem in fieldItemsFieldEqualsNULL) {
			if (fieldItem.image || fieldItem.video) {
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
        _noteItem = [NSMutableDictionary dictionaryWithDictionary:@{@"title":@"Note", @"order":@""}];
    }
    
    return _noteItem;
}

- (NSMutableDictionary *)deleteItem
{
    if (!_deleteItem) {
        _deleteItem = [NSMutableDictionary dictionaryWithDictionary:@{@"title":@"Delete", @"order":@""}];
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
	[_item changeFavorite:_item.favorite == nil];
    button.selected = _item.favorite != nil;
}

- (WalletFieldItem *)fieldItemForIndexPath:(NSIndexPath *)indexPath create:(BOOL)create {
	WalletField *field = _sectionItems[indexPath.row];
	if (![field isKindOfClass:[WalletField class]]) {
		return nil;
	}
	NSSet *resultSet = [_item.fieldItems objectsPassingTest:^BOOL(WalletFieldItem *obj, BOOL *stop) {
		return [obj.field.uniqueID isEqualToString:field.uniqueID];
	}];
	if ([resultSet count]) {
		return [resultSet anyObject];
	}
	if (create) {
		WalletFieldItem *fieldItem = [WalletFieldItem MR_createEntity];
		fieldItem.uniqueID = [[NSUUID UUID] UUIDString];
		fieldItem.field = field;
		[_item addFieldItemsObject:fieldItem];
		return fieldItem;
	}
	return nil;
}

- (void)dateChanged:(UIDatePicker *)sender {
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
	if ([_item.category.uniqueID isEqualToString:A3WalletUUIDPhotoCategory]) {
		BOOL hasImage = NO;
		BOOL categoryDoesNotHaveImageField = YES;
		for (WalletFieldItem *fieldItem in _item.fieldItems) {
			if ([fieldItem.field.type isEqualToString:WalletFieldTypeImage]) {
				categoryDoesNotHaveImageField = NO;
				hasImage = fieldItem.image != nil;
				if (hasImage) break;
			}
		}
		if (!categoryDoesNotHaveImageField) {
			[self.navigationItem.rightBarButtonItem setEnabled:hasImage];
			return;
		}
	} else if ([_item.category.uniqueID isEqualToString:A3WalletUUIDVideoCategory]) {
		BOOL hasVideo = NO;
		BOOL categoryDoesNotHaveVideoField = YES;
		for (WalletFieldItem *fieldItem in _item.fieldItems) {
			if ([fieldItem.field.type isEqualToString:WalletFieldTypeVideo]) {
				categoryDoesNotHaveVideoField = NO;
				hasVideo = fieldItem.video != nil;
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
	if (self.firstResponder) {
		[self.firstResponder resignFirstResponder];
	}

	NSManagedObjectContext *context = [[MagicalRecordStack defaultStack] context];
	if ([context hasChanges]) {
		[context rollback];
	}
	[self removeTempFiles];

    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)doneButtonAction:(UIBarButtonItem *)button
{
    if (self.firstResponder) {
        [self.firstResponder resignFirstResponder];
    }

	for (WalletFieldItem *fieldItem in _item.fieldItems.allObjects) {
		if (!fieldItem.value && !fieldItem.video && !fieldItem.image && !fieldItem.date) {
			[fieldItem MR_deleteEntity];
		}
	}

	_item.modificationDate = [NSDate date];
	NSManagedObjectContext *context = [[MagicalRecordStack defaultStack] context];
	if ([context hasChanges]) {
		[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
        
        if (_delegate && [_delegate respondsToSelector:@selector(walletItemEdited:)]) {
            [_delegate walletItemEdited:_item];
        }
    }
	[self moveMediaFilesToNormalPath];

	if (_alwaysReturnToOriginalCategory || [_originalCategoryUniqueID isEqualToString:_item.category.uniqueID]) {
		[self dismissViewControllerAnimated:YES completion:NULL];
	} else {
		[self dismissViewControllerAnimated:YES completion:NULL];

		extern NSString *const A3WalletNotificationItemCategoryMoved;
		NSNotification *notification = [[NSNotification alloc] initWithName:A3WalletNotificationItemCategoryMoved
																	 object:nil
																   userInfo:@{@"categoryID":_item.category.uniqueID,
																              @"itemID":_item.uniqueID}];
		[[NSNotificationCenter defaultCenter] postNotification:notification];
	}
}

- (void)mediaButtonAction:(UIButton *)sender
{
    // 다시 사진을 선택하도록 한다. (해당 테이블 셀을 눌렀을때와 동일한 프로세스로 동작하면 됨)
    NSIndexPath *ip = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    [self tableView:self.tableView didSelectRowAtIndexPath:ip];
}

- (void)deleteMediaItem {
	if ([self.sectionItems[_currentIndexPath.row] isKindOfClass:[WalletFieldItem class]]) {
		WalletFieldItem *fieldItem = _sectionItems[_currentIndexPath.row];
		if (fieldItem.image) {
			[[NSFileManager defaultManager] removeItemAtPath:[fieldItem photoImageThumbnailPathInOriginal:NO] error:NULL];
		} else {
			[[NSFileManager defaultManager] removeItemAtPath:[fieldItem videoThumbnailPathInOriginal:NO] error:NULL];
		}
		[fieldItem MR_deleteEntity];

		[_sectionItems removeObjectAtIndex:_currentIndexPath.row];
		[self.tableView deleteRowsAtIndexPaths:@[_currentIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
	} else {
		WalletFieldItem *fieldItem = [self fieldItemForIndexPath:_currentIndexPath create:NO];
		if (fieldItem) {
			if ([fieldItem.field.type isEqualToString:WalletFieldTypeImage]) {
				[[NSFileManager defaultManager] removeItemAtPath:[fieldItem photoImageThumbnailPathInOriginal:NO ] error:NULL];
				[fieldItem.image MR_deleteEntity];
				fieldItem.image = nil;
			} else if ([fieldItem.field.type isEqualToString:WalletFieldTypeVideo]) {
				[[NSFileManager defaultManager] removeItemAtPath:[fieldItem videoFilePathInOriginal:NO ] error:NULL];
				[[NSFileManager defaultManager] removeItemAtPath:[fieldItem videoThumbnailPathInOriginal:NO ] error:NULL];
				[fieldItem.video MR_deleteEntity];
				fieldItem.video = nil;
			}
			[self.tableView reloadRowsAtIndexPaths:@[_currentIndexPath] withRowAnimation:UITableViewRowAnimationFade];
		}
	}
	[self updateDoneButtonEnabled];
}

- (void)askDeleteImage {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
															 delegate:self
													cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"common", nil)
											   destructiveButtonTitle:NSLocalizedStringFromTable(@"Delete Photo", @"common", nil)
													otherButtonTitles:nil];
	actionSheet.tag = 1;
	[actionSheet showInView:self.view];
}

- (void)askDeleteVideo {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
															 delegate:self
													cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"common", nil)
											   destructiveButtonTitle:NSLocalizedStringFromTable(@"Delete Video", @"common", nil)
													otherButtonTitles:nil];
	actionSheet.tag = 1;
	[actionSheet showInView:self.view];
}

- (void)askVideoPickupWithDelete:(BOOL)deleteEnable
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
		if (deleteEnable) {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                     delegate:self
                                                            cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"common", nil)
                                                       destructiveButtonTitle:NSLocalizedStringFromTable(@"Delete Video", @"common", nil)
                                                            otherButtonTitles:NSLocalizedStringFromTable(@"Take Video", @"common", nil),
                                          NSLocalizedStringFromTable(@"Choose Existing", @"common", nil),
                                          nil];
            actionSheet.tag = 2;
            [actionSheet showInView:self.view];
        }
        else {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                     delegate:self
                                                            cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"common", nil)
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:NSLocalizedStringFromTable(@"Take Video", @"common", nil),
                                          NSLocalizedStringFromTable(@"Choose Existing", @"common", nil),
                                          nil];
            actionSheet.tag = 2;
            [actionSheet showInView:self.view];
        }
	} else {
		if (deleteEnable) {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                     delegate:self
                                                            cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"common", nil)
                                                       destructiveButtonTitle:NSLocalizedStringFromTable(@"Delete Video", @"common", nil)
                                                            otherButtonTitles:
                                          NSLocalizedStringFromTable(@"Choose Existing", @"common", nil),
                                          nil];
            actionSheet.tag = 2;
            [actionSheet showInView:self.view];
        }
        else {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                     delegate:self
                                                            cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"common", nil)
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:
                                          NSLocalizedStringFromTable(@"Choose Existing", @"common", nil),
                                          nil];
            actionSheet.tag = 2;
            [actionSheet showInView:self.view];
        }
	}
}

- (void)configureFloatingTextField:(JVFloatLabeledTextField *)txtFd
{
    txtFd.textColor = [UIColor colorWithRed:159.0/255.0 green:159.0/255.0 blue:159.0/255.0 alpha:1.0];
    txtFd.floatingLabelTextColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0];
    txtFd.font = [UIFont systemFontOfSize:17.0];
    txtFd.floatingLabelFont = [UIFont systemFontOfSize:14];
    txtFd.floatingLabelYPadding = @(-6);
    txtFd.delegate = self;
}

- (BOOL)hasChanges {
	if (_isAddNewItem) {
		return ![self isItemDataEmpty];
	}
	return [[[MagicalRecordStack defaultStack] context] hasChanges];
}

- (BOOL)isItemDataEmpty
{
    if ([_item.name length] || [_item.note length]) {
        return NO;
    }

    for (WalletFieldItem *fieldItem in _item.fieldItems.allObjects) {
		if (fieldItem.date || fieldItem.image || fieldItem.video || [fieldItem.value length]) {
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
        
        [_sectionItems insertObject:self.dateInputItem atIndex:dateIndexPath.row + 1];
        [self.tableView reloadRowsAtIndexPaths:@[self.dateInputIndexPath] withRowAnimation:UITableViewRowAnimationFade];
		NSIndexPath *pickerIndexPath = [NSIndexPath indexPathForRow:dateIndexPath.row+1 inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[pickerIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];

		[self.tableView scrollToRowAtIndexPath:pickerIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
	}
}

- (void)dismissDatePicker
{
    if ([_sectionItems containsObject:self.dateInputItem]) {
        [self.tableView beginUpdates];
        
        NSUInteger idx = [_sectionItems indexOfObject:self.dateInputItem];
        [_sectionItems removeObject:self.dateInputItem];
        [self.tableView reloadRowsAtIndexPaths:@[self.dateInputIndexPath] withRowAnimation:UITableViewRowAnimationFade];
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
    _item.category = toCategory;

	_isMemoCategory = [_item.category.uniqueID isEqualToString:A3WalletUUIDMemoCategory];

    // 현재 변경중인 field item 정보를, 새로운 카테고리에 해당하는 field item으로 바꾼다.
	NSArray *fieldsOfTargetCategory = [toCategory fieldsArray];

    NSMutableArray *originalFieldItems = [[NSMutableArray alloc] initWithArray:_item.fieldItems.allObjects];
    NSMutableArray *addedItems = [NSMutableArray new];

	for (WalletField *fieldOfTargetCategory in fieldsOfTargetCategory) {
		// items에 동일한 이름의 값이 있는지 체크하고, 타입을 비교하여, 데이타를 옮길수 잇는 아이템들을 뽑아낸다.
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"field.name==%@", fieldOfTargetCategory.name];
		NSArray *filteredResults = [originalFieldItems filteredArrayUsingPredicate:predicate];

		if (!filteredResults.count) continue;

		WalletFieldItem *originalFieldItem = filteredResults[0];	// 같은 이름의 필드를 찾았다.

		if ([originalFieldItem.field.type isEqualToString:fieldOfTargetCategory.type]) {
			originalFieldItem.field = fieldOfTargetCategory;
			[addedItems addObject:originalFieldItem];
		}
		else if (![originalFieldItem.field.type isEqualToString:WalletFieldTypeDate] && ![originalFieldItem.field.type isEqualToString:WalletFieldTypeImage] && ![originalFieldItem.field.type isEqualToString:WalletFieldTypeVideo]) {
			originalFieldItem.field = fieldOfTargetCategory;
			[addedItems addObject:originalFieldItem];
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
		if ([remainItem.field.type isEqualToString:WalletFieldTypeDate] && remainItem.date) {
			[moveToNoteString appendFormat:@"%@ : %@\n", remainItem.field.name, [dateFormatter stringFromDate:remainItem.date]];
		} else
        if (remainItem.value.length > 0) {
            NSString *movingText = [NSString stringWithFormat:@"%@ : %@\n", remainItem.field.name, remainItem.value];
			[moveToNoteString appendString:movingText];
        }
		if (![remainItem.field.type isEqualToString:WalletFieldTypeImage] && ![remainItem.field.type isEqualToString:WalletFieldTypeVideo]) {
			[remainItem MR_deleteEntity];
		} else {
			remainItem.field = nil;
		}
    }
    if (moveToNoteString.length > 0) {
        self.item.note = [moveToNoteString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n\t "]];
    }
    
    // 정보 불러오기
    _sectionItems = nil;
	[self sectionItems];
    [self.tableView reloadData];
}

#pragma mark- UIImagePickerControllerDelegate

- (void) saveImage:(UIImage *)image withFilePath:(NSString *)imagePath withMeta:(NSDictionary *)metadata
{
    NSData *jpeg = UIImageJPEGRepresentation(image, 1.0);
    
    CGImageSourceRef  source ;
    source = CGImageSourceCreateWithData((__bridge CFDataRef)jpeg, NULL);
    
    CFStringRef UTI = CGImageSourceGetType(source); //this is the type of image (e.g., public.jpeg)
    
    //this will be the data CGImageDestinationRef will write into
    NSMutableData *dest_data = [NSMutableData data];
    
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)dest_data,UTI,1,NULL);
    
    if(!destination) {
        NSLog(@"***Could not create image destination ***");
    }
    
    //add the image contained in the image source to the destination, overidding the old metadata with our modified metadata
    CGImageDestinationAddImageFromSource(destination,source,0, (__bridge CFDictionaryRef) metadata);
    
    //tell the destination to write the image data and metadata into our data object.
    //It will return false if something goes wrong
    BOOL success = NO;
    success = CGImageDestinationFinalize(destination);
    
    if(!success) {
        NSLog(@"***Could not create data from image destination ***");
    }
    
    //now we have the data ready to go, so do whatever you want with it
    //here we just write it to disk at the same path we were passed
    [dest_data writeToFile:imagePath atomically:YES];
    
    //cleanup
    
    CFRelease(destination);
    CFRelease(source);
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)imageEditInfo {
	if (IS_IPAD && self.popOverController) {
		[self.popOverController dismissPopoverAnimated:YES];
		self.popOverController = nil;
	}
	else {
		[picker dismissViewControllerAnimated:YES completion:NULL];
	}

	NSString *mediaType = imageEditInfo[UIImagePickerControllerMediaType];
	if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
		//get the videoURL
		NSURL *movieURL = imageEditInfo[UIImagePickerControllerMediaURL];
		if (!_currentFieldItem.video) {
			_currentFieldItem.video = [WalletFieldItemVideo MR_createEntity];
		}
		_currentFieldItem.video.extension = movieURL.pathExtension;
		NSURL *destinationMovieURL = [NSURL fileURLWithPath:[_currentFieldItem videoFilePathInOriginal:NO ]];
		[[NSFileManager defaultManager] moveItemAtURL:movieURL toURL:destinationMovieURL error:NULL];
        
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

		UIImage *originalImage = [WalletData videoPreviewImageOfURL:destinationMovieURL];
		[_currentFieldItem makeVideoThumbnailWithImage:originalImage inOriginalDirectory:NO];
	}
	else {
		FNLOG(@"%@", imageEditInfo);
		UIImage *originalImage = [imageEditInfo objectForKey:UIImagePickerControllerEditedImage];
		if (!originalImage) {
			originalImage = [imageEditInfo objectForKey:UIImagePickerControllerOriginalImage];
		}

		if (!_currentFieldItem.image) {
			_currentFieldItem.image = [WalletFieldItemImage MR_createEntity];
		}
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

	self.imagePickerController = nil;
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
	NSString *errorDescription = nil;
	NSData *data = [NSPropertyListSerialization dataFromPropertyList:_imageMetadata format:NSPropertyListXMLFormat_v1_0 errorDescription:&errorDescription];
	_currentFieldItem.image.metadata = data;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[picker dismissViewControllerAnimated:YES completion:NULL];
	self.imagePickerController = nil;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
	[manager stopMonitoringSignificantLocationChanges];

	if ([locations count]) {
		self.myLocation = locations[0];
	}
}

#pragma mark - UIActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	
    if (buttonIndex == actionSheet.cancelButtonIndex) {
		return;
	}
    
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        
        if (actionSheet.tag ==1 || actionSheet.tag == 2) {
            // 삭제하기
            [self deleteMediaItem];
            
            return;
        }
        else if (actionSheet.tag == 3) {

			[self.item MR_deleteEntity];
			[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];

            [self dismissViewControllerAnimated:NO completion:NULL];
            
            if (_delegate && [_delegate respondsToSelector:@selector(WalletItemDeleted)]) {
                [_delegate WalletItemDeleted];
            }
            
            return;
        }
    }
    
	NSInteger myButtonIndex = buttonIndex;
	_imagePickerController = [[UIImagePickerController alloc] init];
	if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
		myButtonIndex++;
    if (actionSheet.destructiveButtonIndex>=0)
        myButtonIndex--;
	switch (myButtonIndex) {
		case 0:
			_imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
			_imagePickerController.allowsEditing = NO;

			_locationManager = [CLLocationManager new];
			_locationManager.delegate = self;
			[_locationManager startMonitoringSignificantLocationChanges];
			break;
		case 1:
			_imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
			_imagePickerController.allowsEditing = NO;
			break;
		case 2:
			_imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
			_imagePickerController.allowsEditing = YES;
			break;
	}
    
    // photo
    if (actionSheet.tag == 1) {
        _imagePickerController.mediaTypes = @[(NSString *) kUTTypeImage];
    }
    // video
    else if (actionSheet.tag == 2){
        _imagePickerController.mediaTypes = @[(NSString *) kUTTypeMovie];
		[A3UIDevice verifyAndAlertMicrophoneAvailability];
    }
    
    _imagePickerController.videoQuality = UIImagePickerControllerQualityTypeHigh;
	_imagePickerController.navigationBar.barStyle = UIBarStyleDefault;
	_imagePickerController.delegate = self;

    if (IS_IPAD) {
        if (_imagePickerController.sourceType == UIImagePickerControllerSourceTypeCamera) {
			_imagePickerController.showsCameraControls = YES;
			[self presentViewController:_imagePickerController animated:YES completion:NULL];
		}
        else {
            self.popOverController = [[UIPopoverController alloc] initWithContentViewController:_imagePickerController];
            CGRect rect = [self frameOfImageViewInCellForIndexPath:_currentIndexPath];
            [_popOverController presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }
    else {
		[self presentViewController:_imagePickerController animated:YES completion:NULL];
    }
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    if (actionSheet.tag == 1) {
        for (UIView *subview in actionSheet.subviews) {
            if ([subview isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)subview;
                if ([[button titleForState:UIControlStateNormal] isEqualToString:NSLocalizedStringFromTable(@"Delete Photo", @"common", nil)]) {
                    
                    [button setTitleColor:[UIColor colorWithRed:255.0/255.0 green:59.0/255.0 blue:48.0/255.0 alpha:1.0] forState:UIControlStateNormal];
                    
                }
            }
        }
    }
    else if (actionSheet.tag == 2) {
        for (UIView *subview in actionSheet.subviews) {
            if ([subview isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)subview;
                if ([[button titleForState:UIControlStateNormal] isEqualToString:NSLocalizedStringFromTable(@"Delete Video", @"common", nil)]) {
                    
                    [button setTitleColor:[UIColor colorWithRed:255.0/255.0 green:59.0/255.0 blue:48.0/255.0 alpha:1.0] forState:UIControlStateNormal];
                    
                }
            }
        }
    }
    else if (actionSheet.tag == 3) {
        for (UIView *subview in actionSheet.subviews) {
            if ([subview isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)subview;
                if ([[button titleForState:UIControlStateNormal] isEqualToString:NSLocalizedStringFromTable(@"Delete Item", @"common", nil)]) {
                    
                    [button setTitleColor:[UIColor colorWithRed:255.0/255.0 green:59.0/255.0 blue:48.0/255.0 alpha:1.0] forState:UIControlStateNormal];
                    
                }
            }
        }
    }
}

#pragma mark - CategorySelect delegate

- (void)walletCategorySelected:(WalletCategory *) category
{
    FNLOG(@"walletCategorySelected : %@", category.name);

	if (IS_IPAD) {
		[self dismissRightSideView];
	}

    if (_item.category != category) {
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
	} else if ([[self.sectionItems objectAtIndex:indexPath.row] isKindOfClass:[WalletField class]]) {

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
	self.firstResponder = textField;

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
	self.firstResponder = nil;

	[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];

	NSString *text = [textField.text stringByTrimmingSpaceCharacters];
	NSIndexPath *indexPath = [self.tableView indexPathForCellSubview:textField];
	FNLOG(@"%ld, %ld", (long)indexPath.section, (long)indexPath.row);
	// update
	if (_sectionItems[indexPath.row] == self.titleItem) {
		_item.name = [text length] ? text : nil;
	}
	else if ([_sectionItems[indexPath.row] isKindOfClass:[WalletField class]]) {
		WalletFieldItem *fieldItem = [self fieldItemForIndexPath:indexPath create:YES];

		fieldItem.value = [text length] ? text : nil;
	}
}

- (BOOL)isMediaCategory {
	return [_item.category.uniqueID isEqualToString:A3WalletUUIDPhotoCategory] || [_item.category.uniqueID isEqualToString:A3WalletUUIDVideoCategory];
}

- (BOOL)isNonTextInputItem:(id)item {
	if (item == self.noteItem) return NO;
	if (![item isKindOfClass:[WalletField class]]) return YES;

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
	self.firstResponder = textView;
}

- (void)textViewDidChange:(UITextView *)textView
{
	NSString *text = [textView.text stringByTrimmingSpaceCharacters];
	_item.note = [text length] ? text : nil;
	[self updateDoneButtonEnabled];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
	self.firstResponder = nil;
	NSString *text = [textView.text stringByTrimmingSpaceCharacters];
	_item.note = [text length] ? text : nil;

    [self updateDoneButtonEnabled];

	UITableViewCell *cell = [self.tableView cellForCellSubview:textView];
	[cell layoutIfNeeded];
}

#pragma mark - tableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	FNLOG();
    if (self.firstResponder) {
        [self.firstResponder resignFirstResponder];
    }

	_currentIndexPath = indexPath;

	if (indexPath.section == 0) {
	    if ([self.sectionItems objectAtIndex:indexPath.row] == self.categoryItem) {
            // category
            A3WalletCategorySelectViewController *viewController = [[A3WalletCategorySelectViewController alloc] initWithStyle:UITableViewStyleGrouped];
            viewController.selectedCategory = _item.category;
            viewController.delegate = self;

            if (IS_IPHONE) {
                [self.navigationController pushViewController:viewController animated:YES];
            } else {
				_rightSideViewController = [[A3NavigationController alloc] initWithRootViewController:viewController];
				[self presentRightSideView:_rightSideViewController.view];
				[self.navigationController addChildViewController:_rightSideViewController];
            }
        }
        else if ([[self.sectionItems objectAtIndex:indexPath.row] isKindOfClass:[WalletField class]]) {
            WalletField *field = [_sectionItems objectAtIndex:indexPath.row];
			_currentFieldItem = [self fieldItemForIndexPath:indexPath create:YES];

			if ([field.type isEqualToString:WalletFieldTypeDate]) {
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
				[self dismissDatePicker];

				UIActionSheet *actionSheet = [self actionSheetAskingImagePickupWithDelete:_currentFieldItem.image != nil delegate:self];
				actionSheet.tag = 1;
				[actionSheet showInView:self.view];
            }
            else if ([field.type isEqualToString:WalletFieldTypeVideo]) {
				[self dismissDatePicker];

				[self askVideoPickupWithDelete:_currentFieldItem.video != nil];
            }
            else {
                A3WalletItemFieldCell *inputCell = (A3WalletItemFieldCell *)[tableView cellForRowAtIndexPath:indexPath];
                [inputCell.valueTextField becomeFirstResponder];
            }
        } else if ([self.sectionItems[indexPath.row] isKindOfClass:[WalletFieldItem class]]) {
			WalletFieldItem *fieldItem = _sectionItems[indexPath.row];
			if (fieldItem.image) {
				[self askDeleteImage];
			} else if (fieldItem.video) {
				[self askDeleteVideo];
			}
		}
    }
    else {
        // delete category
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:@"Delete Item"
                                                        otherButtonTitles:nil];
        actionSheet.tag = 3;
        [actionSheet showInView:self.view];

        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
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

		cell = deleteCell;
	}

    return cell;
}

- (UITableViewCell *)getFieldTypeCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
	if ([_sectionItems[indexPath.row] isKindOfClass:[WalletFieldItem class]]) {
		UITableViewCell *cell;
		WalletFieldItem *fieldItem = _sectionItems[indexPath.row];
		if (fieldItem.image) {
			cell = [self getImageCell:tableView indexPath:indexPath fieldItem:fieldItem];
		} else if (fieldItem.video) {
			cell = [self getVideoCell:tableView indexPath:indexPath fieldItem:fieldItem];
		} else {
			FNLOG(@"Invalid Data has been found. WalletFieldItem field == NULL, image == NULL, video == NULL");
			UITableViewCell *defaultCell = [tableView dequeueReusableCellWithIdentifier:A3TableViewCellDefaultCellID forIndexPath:indexPath];
			cell = defaultCell;
		}
		return cell;
	}
	WalletField *field = [_sectionItems objectAtIndex:indexPath.row];
	if (![field isKindOfClass:[WalletField class]]) return nil;

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

	cell = inputCell;
	return cell;
}

- (UITableViewCell *)getVideoCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath fieldItem:(WalletFieldItem *)fieldItem {
	UITableViewCell *cell;
	if (fieldItem.video) {

		A3WalletItemPhotoFieldCell *photoCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemPhotoFieldCellID4 forIndexPath:indexPath];

		photoCell.selectionStyle = UITableViewCellSelectionStyleNone;
		[self configureFloatingTextField:photoCell.valueTextField];

		photoCell.valueTextField.placeholder = fieldItem.field.name;
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
		iconCell.titleLabel.text = fieldItem.field.name;
		iconCell.titleLabel.textColor = [UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:205.0/255.0 alpha:1.0];
		iconCell.iconImgView.image = [UIImage imageNamed:@"video"];

		cell = iconCell;
	}
	return cell;
}

- (UITableViewCell *)getImageCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath fieldItem:(WalletFieldItem *)fieldItem {
	UITableViewCell *cell;
	if (fieldItem.image) {
		A3WalletItemPhotoFieldCell *photoCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemPhotoFieldCellID4 forIndexPath:indexPath];

		photoCell.selectionStyle = UITableViewCellSelectionStyleNone;
		[self configureFloatingTextField:photoCell.valueTextField];

		photoCell.valueTextField.placeholder = fieldItem.field.name;
		photoCell.valueTextField.enabled = NO;

		photoCell.valueTextField.text = @" ";
		photoCell.photoButton.hidden = NO;

		NSString *thumbFilePath = [fieldItem photoImageThumbnailPathInOriginal:NO ];
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
		iconCell.titleLabel.text = fieldItem.field.name;
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
	inputCell.valueTextField.placeholder = fieldItem.field.name;

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
		inputCell.valueTextField.textColor = [[A3AppDelegate instance] themeColor];
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
	dateInputCell.datePicker.datePickerMode = UIDatePickerModeDate;
	[dateInputCell.datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
	_datePicker = dateInputCell.datePicker;
	return dateInputCell;
}

- (A3WalletNoteCell *)getNoteCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
	A3WalletNoteCell *noteCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemNoteCellID4 forIndexPath:indexPath];
	[noteCell setupTextView];
	noteCell.textView.text = _item.note;

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
	inputCell.valueTextField.placeholder = @"Category";
	inputCell.valueTextField.text = _item.category.name;
	return inputCell;
}

- (A3WalletItemTitleCell *)getTitleCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
	A3WalletItemTitleCell *titleCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemTitleCellID forIndexPath:indexPath];

	titleCell.selectionStyle = UITableViewCellSelectionStyleNone;

	titleCell.titleTextField.delegate = self;
	titleCell.titleTextField.placeholder = @"Title";
	titleCell.titleTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
	[titleCell.favoriteButton addTarget:self action:@selector(favoriteButtonAction:) forControlEvents:UIControlEventTouchUpInside];

	titleCell.titleTextField.text = _item.name;

	_titleTextField = titleCell.titleTextField;

	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	df.dateStyle = NSDateFormatterFullStyle;
    
	NSDate *date = _item.modificationDate ? _item.modificationDate : [NSDate date];
    if (IS_IPAD || [NSDate isFullStyleLocale]) {
        titleCell.timeLabel.text = [NSString stringWithFormat:@"Current %@", [self fullStyleDateStringFromDate:date withShortTime:YES]];
    }
    else {
        titleCell.timeLabel.text = [NSString stringWithFormat:@"Current %@", [self customFullStyleDateStringFromDate:date withShortTime:YES]];
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

@end
