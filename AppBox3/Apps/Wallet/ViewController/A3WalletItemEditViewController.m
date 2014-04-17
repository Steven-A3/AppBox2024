//
//  A3WalletItemEditViewController.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 2..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3WalletItemEditViewController.h"
#import "A3WalletCategorySelectViewController.h"
#import "A3WalletItemTitleView.h"
#import "A3WalletItemFieldCell.h"
#import "A3WalletItemPhotoFieldCell.h"
#import "A3WalletItemFieldCateCell.h"
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
#import "A3AppDelegate.h"
#import "UIViewController+A3AppCategory.h"
#import "UIViewController+A3Addition.h"
#import "UIImage+Extension2.h"
#import "UITableView+utility.h"

#import <CoreLocation/CoreLocation.h>
#import <ImageIO/ImageIO.h>

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
@property (nonatomic, strong) NSMutableDictionary *noteItem;
@property (nonatomic, strong) NSMutableDictionary *deleteItem;
@property (nonatomic, strong) NSMutableDictionary *dateInputItem;
@property (nonatomic, strong) UIPopoverController *popOverController;
@property (nonatomic, strong) A3WalletItemTitleView *headerView;
@property (nonatomic, strong) NSMutableDictionary *categoryItem;
@property (nonatomic, strong) NSIndexPath *currentIndexPath;

@property (nonatomic, strong) NSString *nameBackupText;
@property (nonatomic, strong) NSString *noteBackupText;

@property (nonatomic, strong) WalletCategory *originalCategory;

@property (nonatomic, strong) WalletFieldItem *currentFieldItem;
@property (nonatomic, strong) NSIndexPath *dateInputIndexPath;
@property (nonatomic, strong) NSDate *preDate;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;

@end

@implementation A3WalletItemEditViewController

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
		_item.category = _walletCategory;
	} else {
		self.navigationItem.title = @"Edit Item";

		_walletCategory = _item.category;
	}

	self.originalCategory = _item.category;

	[self makeBackButtonEmptyArrow];
    [self rightBarButtonDoneButton];
	self.navigationItem.rightBarButtonItem.enabled = NO;

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonAction:)];
    
	self.tableView.tableHeaderView = self.headerView;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, (IS_IPAD)?28:15, 0, 0);
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.tableView.rowHeight = 74.0;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorColor = [self tableViewSeparatorColor];

    [self registerContentSizeCategoryDidChangeNotification];
}

- (void)contentSizeDidChange:(NSNotification *) notification
{
	_headerView = nil;
	self.tableView.tableHeaderView = [self headerView];
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

	[self updateTopInfo];
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
        
        [_sectionItems insertObject:self.categoryItem atIndex:0];
        [_sectionItems addObject:self.noteItem];
    }
    
    return _sectionItems;
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

- (A3WalletItemTitleView *)headerView
{
    if (!_headerView) {
        NSString *nibName = IS_IPAD ? @"A3WalletItemTitleView_iPad":@"A3WalletItemTitleView";
        _headerView = [[[NSBundle mainBundle] loadNibNamed:nibName owner:Nil options:nil] lastObject];
        _headerView.isEditMode = YES;
        _headerView.titleTextField.delegate = self;
        _headerView.titleTextField.placeholder = @"Title";
        _headerView.titleTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
		[_headerView.favorButton addTarget:self action:@selector(favoriteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _headerView;
}

- (void)favoriteButtonAction:(UIButton *)button
{
	[_item changeFavorite:_item.favorite == nil];
    _headerView.favorButton.selected = _item.favorite != nil;
}

- (void)updateTopInfo
{
    _headerView.titleTextField.text = _item.name;
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateStyle = NSDateFormatterFullStyle;
    NSDate *current = [NSDate date];
    _headerView.timeLabel.text = [NSString stringWithFormat:@"Current %@",  [df stringFromDate:current]];
}

- (WalletFieldItem *)fieldItemForIndexPath:(NSIndexPath *)indexPath create:(BOOL)create {
	WalletField *field = _sectionItems[indexPath.row];
	NSSet *resultSet = [_item.fieldItems objectsPassingTest:^BOOL(WalletFieldItem *obj, BOOL *stop) {
		return [obj.field.uniqueID isEqualToString:field.uniqueID];
	}];
	if ([resultSet count]) {
		return [resultSet anyObject];
	}
	if (create) {
		WalletFieldItem *fieldItem = [WalletFieldItem MR_createEntity];
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
    
    self.navigationItem.rightBarButtonItem.enabled = [self hasChanges];
}

- (void)updateDoneButtonEnabled {
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

    [self dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)doneButtonAction:(UIBarButtonItem *)button
{
    if (self.firstResponder) {
        [self.firstResponder resignFirstResponder];
    }

	for (WalletFieldItem *fieldItem in _item.fieldItems.allObjects) {
		if (!fieldItem.value && ![fieldItem.hasVideo boolValue] && !fieldItem.image && fieldItem.date) {
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
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)mediaButtonAction:(UIButton *)sender
{
    // 다시 사진을 선택하도록 한다. (해당 테이블 셀을 눌렀을때와 동일한 프로세스로 동작하면 됨)
    NSIndexPath *ip = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    [self tableView:self.tableView didSelectRowAtIndexPath:ip];
}

- (void)deleteMediaItem
{
	WalletFieldItem *fieldItem = [self fieldItemForIndexPath:_currentIndexPath create:NO];
	if (fieldItem) {
		if ([fieldItem.field.type isEqualToString:WalletFieldTypeImage]) {
			fieldItem.image = nil;
			[[NSFileManager defaultManager] removeItemAtPath:fieldItem.imageThumbnailPath error:NULL];
		} else if ([fieldItem.field.type isEqualToString:WalletFieldTypeVideo]) {
			fieldItem.hasVideo = @NO;
			[[NSFileManager defaultManager] removeItemAtPath:fieldItem.videoFilePath error:NULL];
			[[NSFileManager defaultManager] removeItemAtPath:fieldItem.videoThumbnailPath error:NULL];
		}
		[self.tableView reloadRowsAtIndexPaths:@[_currentIndexPath] withRowAnimation:UITableViewRowAnimationFade];
	}
	[self updateDoneButtonEnabled];
}

- (void)askImagePickupWithDelete:(BOOL)deleteEnable
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        if (deleteEnable) {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                     delegate:self
                                                            cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"common", nil)
                                                       destructiveButtonTitle:NSLocalizedStringFromTable(@"Delete Photo", @"common", nil)
                                                            otherButtonTitles:NSLocalizedStringFromTable(@"Take Photo", @"common", nil),
                                          NSLocalizedStringFromTable(@"Choose Existing", @"common", nil),
                                          NSLocalizedStringFromTable(@"Choose and Resize", @"common", nil), nil];
            actionSheet.tag = 1;
            [actionSheet showInView:self.view];
        }
        else {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                     delegate:self
                                                            cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"common", nil)
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:NSLocalizedStringFromTable(@"Take Photo", @"common", nil),
                                          NSLocalizedStringFromTable(@"Choose Existing", @"common", nil),
                                          NSLocalizedStringFromTable(@"Choose and Resize", @"common", nil), nil];
            actionSheet.tag = 1;
            [actionSheet showInView:self.view];
        }
        
	} else {
        
        if (deleteEnable) {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                     delegate:self
                                                            cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"common", nil)
                                                       destructiveButtonTitle:NSLocalizedStringFromTable(@"Delete Photo", @"common", nil)
                                                            otherButtonTitles:
                                          NSLocalizedStringFromTable(@"Choose Existing", @"common", nil),
                                          NSLocalizedStringFromTable(@"Choose and Resize", @"common", nil), nil];
            actionSheet.tag = 1;
            [actionSheet showInView:self.view];
        }
        else {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                     delegate:self
                                                            cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"common", nil)
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:
                                          NSLocalizedStringFromTable(@"Choose Existing", @"common", nil),
                                          NSLocalizedStringFromTable(@"Choose and Resize", @"common", nil), nil];
            actionSheet.tag = 1;
            [actionSheet showInView:self.view];
        }
	}
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
		if (fieldItem.date || fieldItem.image || [fieldItem.hasVideo boolValue] || [fieldItem.value length]) {
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
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:dateIndexPath.row+1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
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

- (void)changeCategory:(WalletCategory *)toCategorry
{
    // 카테고리 변경
    // 같은 이름 필드는 값 입력
    // 나머지는 노트에 추가
    
    // 일반 필드는 item에 입력하고, walletFieldItem은 _editTempItems 에 저장한다.
    
    /*
     @property (nonatomic, retain) NSDate * modificationDate;
     @property (nonatomic, retain) NSString * name;
     @property (nonatomic, retain) NSString * note;
     @property (nonatomic, retain) NSString * order;
     @property (nonatomic, retain) WalletCategory *category;
     @property (nonatomic, retain) NSSet *fieldItems;
     */
    
    
    
    // name, order 변경안됨
    // category를 바꾼걸로
    _item.category = toCategorry;
    
    // 현재 변경중인 field item 정보를, 새로운 카테고리에 해당하는 field item으로 바꾼다.
    
    
    NSArray *cateFields = [toCategorry fieldsArray];
    NSMutableDictionary *cateNewEditTempItems = [NSMutableDictionary new];
    
    NSMutableArray *orgItems = [[NSMutableArray alloc] initWithArray:self.item.fieldItems.allObjects];
    NSMutableArray *addedItems = [NSMutableArray new];
    
    for (int i=0; i < cateFields.count; i++) {
        WalletField *cateField = cateFields[i];
        
        // items에 동일한 이름의 값이 있는지 체크하고, 타입을 비교하여, 데이타를 옮길수 잇는 아이템들을 뽑아낸다.
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"field.name==%@", cateField.name];
        NSArray *tmp = [orgItems filteredArrayUsingPredicate:predicate];
        if (tmp.count>0) {
            WalletFieldItem *tempFieldItem = tmp[0];
            if ([cateField.type isEqualToString:WalletFieldTypeDate]) {
                if ([tempFieldItem.field.type isEqualToString:WalletFieldTypeDate]) {
                    
                    // editTempItem에 새로운 값을 만들어서 저장한다.
                    WalletFieldItem *editFieldItem = [WalletFieldItem MR_createEntity];
                    editFieldItem.field = cateField;
                    editFieldItem.walletItem = self.item;
                    editFieldItem.date = tempFieldItem.date;
                    [cateNewEditTempItems setObject:editFieldItem forKey:cateField.uniqueID];
					[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
                    
                    [addedItems addObject:tempFieldItem];
                }
            }
            else if ([cateField.type isEqualToString:WalletFieldTypeImage]) {
                if ([tempFieldItem.field.type isEqualToString:WalletFieldTypeImage]) {
                    
                    // editTempItem에 새로운 값을 만들어서 저장한다.
                    WalletFieldItem *editFieldItem = [WalletFieldItem MR_createEntity];
                    editFieldItem.field = cateField;
                    editFieldItem.walletItem = self.item;
                    [cateNewEditTempItems setObject:editFieldItem forKey:cateField.uniqueID];
					[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
                    
                    [addedItems addObject:tempFieldItem];
                }
            }
            else if ([cateField.type isEqualToString:WalletFieldTypeVideo]) {
                if ([tempFieldItem.field.type isEqualToString:WalletFieldTypeVideo]) {
                    
                    // editTempItem에 새로운 값을 만들어서 저장한다.
                    WalletFieldItem *editFieldItem = [WalletFieldItem MR_createEntity];
                    editFieldItem.field = cateField;
                    editFieldItem.walletItem = self.item;
                    [cateNewEditTempItems setObject:editFieldItem forKey:cateField.uniqueID];
					[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
                    
                    [addedItems addObject:tempFieldItem];
                }
            }
            else {
                if (![tempFieldItem.field.type isEqualToString:WalletFieldTypeDate] && ![tempFieldItem.field.type isEqualToString:WalletFieldTypeImage] && ![tempFieldItem.field.type isEqualToString:WalletFieldTypeVideo]) {
                    
                    // editTempItem에 새로운 값을 만들어서 저장한다.
                    WalletFieldItem *editFieldItem = [WalletFieldItem MR_createEntity];
                    editFieldItem.field = cateField;
                    editFieldItem.walletItem = self.item;
                    editFieldItem.value = tempFieldItem.value;
                    [cateNewEditTempItems setObject:editFieldItem forKey:cateField.uniqueID];
					[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
                    
                    [addedItems addObject:tempFieldItem];
                }
            }
        }
        else {
            // 기존에 item이 없으면 새로이 fieldItem을 만들고 초기화하여 editTempItems에 저장한다
            WalletFieldItem *madeFieldItem = [WalletFieldItem MR_createEntity];
            madeFieldItem.field = cateField;
            madeFieldItem.walletItem = self.item;
            [cateNewEditTempItems setObject:madeFieldItem forKey:cateField.uniqueID];
			[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
        }
    }
    
    // 데이타가 있는 item들중에 옮겨지지 않은 데이타는 note에 텍스트로 기록한다.
    [orgItems removeObjectsInArray:addedItems];
    
    NSMutableString *mString = [NSMutableString new];
    for (int i = 0; i<orgItems.count; i++) {
        WalletFieldItem *remainItem = orgItems[i];
        if (remainItem.value.length > 0) {
            NSString *tmpText = [NSString stringWithFormat:@"%@ : %@\n", remainItem.field.name, remainItem.value];
            [mString appendString:tmpText];
        }
    }
    if (mString.length > 0) {
        self.item.note = mString;
    }
    
    // 정보 불러오기
    _sectionItems = nil;
    [self.tableView reloadData];
}

#pragma mark- UIImagePickerControllerDelegate

- (NSString *)uniqueMediaFilePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSCalendar *gregorian = [ [NSCalendar alloc ] initWithCalendarIdentifier:NSGregorianCalendar ];
    NSDateComponents *dc = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate: [NSDate date] ];
    
    NSString *newImagefilepath, *newImagefilename;
    srand((unsigned int) time(NULL));
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    do {
        NSString *uniquieIdentifier = [NSString stringWithFormat:@"%04ld-%02ld-%02ld%02ld%02ld%02ld-%ld", (long)[dc year], (long)[dc month], (long)[dc day], (long)[dc hour], (long)[dc minute], (long)[dc second], (long)rand() ];
        NSString *filename = kWalletImageFilePrefix;
        newImagefilename = [filename stringByAppendingString:uniquieIdentifier];
        newImagefilepath = [libraryDirectory stringByAppendingPathComponent:newImagefilename];
    } while ([fileManager fileExistsAtPath:newImagefilepath]);
    
    return newImagefilepath;
}

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

-(void) saveImage:(UIImage *)image withFilePath:(NSString *)imagePath
{
    NSError *error;
    [UIImageJPEGRepresentation(image, 1.0) writeToFile:imagePath options:NSAtomicWrite error:&error];
    if (error) {
        FNLOG(@"%@", [error description]);
    }
}

- (void)copyVideoFrom:(NSString *)sourcePath to:(NSString *)targetPath
{
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm copyItemAtPath:sourcePath toPath:targetPath error:NULL];
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
		[self copyVideoFrom:movieURL.path to:_currentFieldItem.videoFilePath];

		FNLOG(@"%@", movieURL.path);

		UIImage *originalImage = [WalletData videoPreviewImageOfURL:movieURL];
		CGSize boundsSize = CGSizeMake(160, 160);
		UIImage *thumbImage = [originalImage imageByScalingProportionallyToMinimumSize:boundsSize];
		[self saveImage:thumbImage withFilePath:_currentFieldItem.videoThumbnailPath];

		_currentFieldItem.hasVideo = @YES;
	}
	else {
		UIImage *originalImage = [imageEditInfo objectForKey:UIImagePickerControllerEditedImage];;
		if (!originalImage)
			originalImage = [imageEditInfo objectForKey:UIImagePickerControllerOriginalImage];

		if (!originalImage)
			return;

		CGSize boundsSize = CGSizeMake(160, 160);
		UIImage *thumbImage = [originalImage imageByScalingProportionallyToMinimumSize:boundsSize];
		NSString *thumbFilePath = _currentFieldItem.imageThumbnailPath;
		[self saveImage:thumbImage withFilePath:thumbFilePath];

		_currentFieldItem.image = originalImage;
	}

	[self.tableView reloadRowsAtIndexPaths:@[_currentIndexPath] withRowAnimation:UITableViewRowAnimationFade];
	[self updateDoneButtonEnabled];

	self.imagePickerController = nil;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[picker dismissViewControllerAnimated:YES completion:NULL];
	self.imagePickerController = nil;
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
    
    if (_item.category != category) {
        FNLOG(@"Change category");
        
        [self changeCategory:category];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // 다음 텍스트 필드로 이동.
    [textField resignFirstResponder];
    
    NSUInteger startIdx;
    if (textField == self.headerView.titleTextField) {
        startIdx = 0;
    }
    else {
        startIdx = (NSUInteger) (_currentIndexPath.row + 1);
    }
    
    if ([_sectionItems objectAtIndex:startIdx] == self.noteItem) {
        NSIndexPath *ip = [NSIndexPath indexPathForRow:startIdx inSection:0];
        A3WalletNoteCell *noteCell = (A3WalletNoteCell *)[self.tableView cellForRowAtIndexPath:ip];
        [noteCell.textView becomeFirstResponder];
    }
    else {
        for (NSUInteger idx = startIdx; idx < _sectionItems.count; idx++) {
            if ([_sectionItems[idx] isKindOfClass:[WalletField class]]) {
                WalletField *field = _sectionItems[idx];
                
                if (![field.type isEqualToString:WalletFieldTypeDate]
					&& ![field.type isEqualToString:WalletFieldTypeImage]
					&& ![field.type isEqualToString:WalletFieldTypeVideo])
                {
                    NSIndexPath *ip = [NSIndexPath indexPathForRow:idx inSection:0];
                    A3WalletItemFieldCell *inputCell = (A3WalletItemFieldCell* )[self.tableView cellForRowAtIndexPath:ip];
                    [inputCell.valueTextField becomeFirstResponder];
                    break;
                }
            }
        }
    }
    
    return YES;
}

- (void)textFieldDidChange:(NSNotification *)notification {
	UITextField *textField = notification.object;
    self.navigationItem.rightBarButtonItem.enabled = [self hasChanges] || [textField.text length];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.firstResponder = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];

    // update
    if (textField == _headerView.titleTextField) {
		_item.name = textField.text;
    }
    else {
        if ([_sectionItems[_currentIndexPath.row] isKindOfClass:[WalletField class]]) {
            WalletFieldItem *fieldItem = [self fieldItemForIndexPath:_currentIndexPath create:YES];

            // 변경사항이 없으면, 무시한다.
            if ([fieldItem.value isEqualToString:textField.text]) {
                return;
            }
			fieldItem.value = textField.text;
        }
    }
    
    self.navigationItem.rightBarButtonItem.enabled = [self hasChanges];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.firstResponder = textField;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self dismissDatePicker];

	_currentIndexPath = [self.tableView indexPathForCellSubview:textField];
	FNLOG(@"current text field indexpath : %@", [_currentIndexPath description]);

	if ([self.sectionItems objectAtIndex:_currentIndexPath.row] == self.noteItem) {
		// note
		textField.keyboardType = UIKeyboardTypeDefault;
	}
	else if ([[self.sectionItems objectAtIndex:_currentIndexPath.row] isKindOfClass:[WalletFieldItem class]]) {

		WalletField *field = _sectionItems[_currentIndexPath.row];
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

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [self dismissDatePicker];
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    _item.note = textView.text;
    
    [self.tableView beginUpdates];
    
    CGRect frame = textView.frame;
    frame.size.height = textView.contentSize.height+25;
    textView.frame = frame;

    [self.tableView endUpdates];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.noteBackupText = textView.text;
    
    self.navigationItem.rightBarButtonItem.enabled = [self hasChanges];
}

#pragma mark - tableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	_currentIndexPath = indexPath;

    if (self.firstResponder) {
        [self.firstResponder resignFirstResponder];
    }
    
    if (indexPath.section == 0) {
        if ([self.sectionItems objectAtIndex:indexPath.row] == self.categoryItem) {
            // category
            A3WalletCategorySelectViewController *viewController = [[A3WalletCategorySelectViewController alloc] initWithStyle:UITableViewStyleGrouped];
            viewController.selectedCategory = _item.category;
            viewController.delegate = self;
            
            if (IS_IPHONE) {
                [self.navigationController pushViewController:viewController animated:YES];
            } else {
                A3RootViewController_iPad *rootViewController = [[A3AppDelegate instance] rootViewController];
                [rootViewController presentRightSideViewController:viewController];
            }
            
            
        }
        else if ([[self.sectionItems objectAtIndex:indexPath.row] isKindOfClass:[WalletField class]]) {
            
            WalletField *field = [_sectionItems objectAtIndex:indexPath.row];
			_currentFieldItem = [self fieldItemForIndexPath:indexPath create:YES];
            
            if ([field.type isEqualToString:WalletFieldTypeDate]) {
                self.preDate = _currentFieldItem.date;
                
                if ([_sectionItems containsObject:self.dateInputItem]) {
                    if ([indexPath compare:self.dateInputIndexPath] == NSOrderedSame) {
                        // 현재 셀에 연결된 입력 picker
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

                [self askImagePickupWithDelete:_currentFieldItem.image != nil];
            }
            else if ([field.type isEqualToString:WalletFieldTypeVideo]) {
				[self dismissDatePicker];

				[self askVideoPickupWithDelete:[_currentFieldItem.hasVideo boolValue]];
            }
            else {
                A3WalletItemFieldCell *inputCell = (A3WalletItemFieldCell *)[tableView cellForRowAtIndexPath:indexPath];
                [inputCell.valueTextField becomeFirstResponder];
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
            
            NSDictionary *textAttributes = @{
                                             NSFontAttributeName : [UIFont systemFontOfSize:17]
                                             };
            
            NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:_item.note ? _item.note : @"" attributes:textAttributes];
            UITextView *txtView = [[UITextView alloc] init];
            [txtView setAttributedText:attributedString];
            float margin = IS_IPAD ? 49:31;
            CGSize txtViewSize = [txtView sizeThatFits:CGSizeMake(self.view.frame.size.width-margin, 1000)];
            float cellHeight = txtViewSize.height + 20;
            
            if (cellHeight < 180) {
                return 180;
            }
            else {
                return cellHeight;
            }
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
        return IS_RETINA ? 36.5 : 37;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=nil;
	if (indexPath.section == 0) {
		NSArray *items = @[self.categoryItem, self.noteItem, self.dateInputItem];
		NSUInteger itemIndex = [items indexOfObject:self.sectionItems[indexPath.row]];
		switch (itemIndex) {
			case 0:
				cell = [self getCategoryCell:tableView indexPath:indexPath];
				break;
			case 1:
				cell = [self getNoteCell:tableView indexPath:indexPath];
				break;
			case 2:
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
			cell= [self getImageCell:tableView indexPath:indexPath fieldItem:fieldItem];
			break;
		case 2:
			cell= [self getVideoCell:tableView indexPath:indexPath fieldItem:fieldItem];
			break;
		default:
			cell= [self getNormalCell:tableView indexPath:indexPath field:field fieldItem:fieldItem];
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

	cell = inputCell;
	return cell;
}

- (UITableViewCell *)getVideoCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath fieldItem:(WalletFieldItem *)fieldItem {
	UITableViewCell *cell;
	if ([fieldItem.hasVideo boolValue]) {

		A3WalletItemPhotoFieldCell *photoCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemPhotoFieldCellID4 forIndexPath:indexPath];

		photoCell.selectionStyle = UITableViewCellSelectionStyleNone;
		[self configureFloatingTextField:photoCell.valueTxtFd];

		photoCell.valueTxtFd.placeholder = fieldItem.field.name;
		photoCell.valueTxtFd.enabled = NO;

		photoCell.valueTxtFd.text = @" ";
		photoCell.photoButton.hidden = NO;

		NSString *thumbFilePath = [fieldItem videoThumbnailPath];
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
		[self configureFloatingTextField:photoCell.valueTxtFd];

		photoCell.valueTxtFd.placeholder = fieldItem.field.name;
		photoCell.valueTxtFd.enabled = NO;

		photoCell.valueTxtFd.text = @" ";
		photoCell.photoButton.hidden = NO;

		NSString *thumbFilePath = [fieldItem imageThumbnailPath];
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

	inputCell.valueTextField.enabled = NO;
	inputCell.valueTextField.placeholder = fieldItem.field.name;

	if ([fieldItem.date isKindOfClass:[NSDate class]]) {
		NSDateFormatter *df = [[NSDateFormatter alloc] init];
		[df setDateFormat:@"MMM dd, YYYY hh:mm a"];
		inputCell.valueTextField.text = [df stringFromDate:fieldItem.date];
	}
	else {
		inputCell.valueTextField.text = @"";
	}

	if ([indexPath compare:self.dateInputIndexPath] == NSOrderedSame) {
		inputCell.valueTextField.textColor = [UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0];
	} else {
		inputCell.valueTextField.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
	}
	return inputCell;
}

- (A3WalletDateInputCell *)getDateInputCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
// date input cell
	A3WalletDateInputCell *dateInputCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemDateInputCellID4 forIndexPath:indexPath];
	dateInputCell.selectionStyle = UITableViewCellSelectionStyleNone;
	dateInputCell.datePicker.date = self.preDate;
	dateInputCell.datePicker.datePickerMode = UIDatePickerModeDate;
	[dateInputCell.datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
	return dateInputCell;
}

- (A3WalletNoteCell *)getNoteCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
	A3WalletNoteCell *noteCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemNoteCellID4 forIndexPath:indexPath];

	noteCell.selectionStyle = UITableViewCellSelectionStyleNone;
	noteCell.textView.delegate = self;
	noteCell.textView.bounces = NO;
	noteCell.textView.placeholder = @"Notes";
	noteCell.textView.placeholderColor = [UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:205.0/255.0 alpha:1.0];
	noteCell.textView.font = [UIFont systemFontOfSize:17];

	if (self.noteBackupText) {
		noteCell.textView.text = _noteBackupText;
	} else {
		noteCell.textView.text = _item.note;
	}
	return noteCell;
}

- (A3WalletItemFieldCateCell *)getCategoryCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
	A3WalletItemFieldCateCell *inputCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemFieldCateCellID4 forIndexPath:indexPath];

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

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    NSUInteger numberSection = [tableView numberOfSections];
    
    float lastFooterHeight = 38.0;
    
    if (section == (numberSection-1)) {
        return lastFooterHeight;
    }
    else {
        return IS_RETINA ? 34.0 : 34.0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    }
    else {
        return 1.0;
    }
}

@end

