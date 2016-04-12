//
//  A3QRCodeViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/7/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import "A3QRCodeViewController.h"
#import "A3AppDelegate.h"
#import "QRCodeHistory.h"
#import "A3QRCodeHistoryViewController.h"
#import "A3NavigationController.h"
#import "UIViewController+A3Addition.h"
#import "AFHTTPRequestOperation.h"
#import "A3QRCodeDetailViewController.h"
#import "RSCornersView.h"
#import "A3QRCodeDataHandler.h"

NSString *const A3QRCodeSettingsPlayAlertSound = @"A3QRCodeSettingsPlayAlertSound";
NSString *const A3QRCodeSettingsPlayVibrate = @"A3QRCodeSettingsPlayVibrate";
NSString *const A3QRCodeImageSoundOn = @"star01_on";
NSString *const A3QRCodeImageSoundOff = @"star01";
NSString *const A3QRCodeImageVibrateOn = @"star01_on";
NSString *const A3QRCodeImageVibrateOff = @"star01";
NSString *const A3QRCodeImageTorchOn = @"m_flash_on";
NSString *const A3QRCodeImageTorchOff = @"m_flash_off";

@interface A3QRCodeViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, weak) IBOutlet UIToolbar *topToolbar;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *torchOnOffButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *vibrateOnOffButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *soundOnOffButton;
@property (nonatomic, strong) A3QRCodeDataHandler *dataHandler;

@end

@implementation A3QRCodeViewController {
	BOOL _googleSearchInProgress;
}

- (void)viewDidLoad {
    [super viewDidLoad];

	[self.navigationController setNavigationBarHidden:YES];
	self.isCornersVisible = NO;
	self.stopOnFirst = YES;

	[self setupBarcodeHandler];
	[self setupTapGestureHandler];

	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults registerDefaults:@{A3QRCodeSettingsPlayVibrate : @YES,
									 A3QRCodeSettingsPlayAlertSound : @YES}];
	
	[self.soundOnOffButton setImage:[UIImage imageNamed:[userDefaults boolForKey:A3QRCodeSettingsPlayAlertSound] ? A3QRCodeImageSoundOn : A3QRCodeImageSoundOff]];
	[self.vibrateOnOffButton setImage:[UIImage imageNamed:[userDefaults boolForKey:A3QRCodeSettingsPlayVibrate] ? A3QRCodeImageVibrateOn : A3QRCodeImageVibrateOff]];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[self.navigationController setNavigationBarHidden:YES];
	
	[self startRunning];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

}

- (IBAction)appsButtonAction:(id)sender {
	if (IS_IPHONE) {
		if ([[A3AppDelegate instance] isMainMenuStyleList]) {
			[[A3AppDelegate instance].drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
		} else {
			UINavigationController *navigationController = [A3AppDelegate instance].currentMainNavigationController;
			[navigationController popViewControllerAnimated:YES];
			[navigationController setToolbarHidden:YES];
		}
	} else {
		[[[A3AppDelegate instance] rootViewController_iPad] toggleLeftMenuViewOnOff];
	}
}

- (IBAction)torchOnOff:(id)sender {
	[self toggleTorch];
	[self.torchOnOffButton setImage:[UIImage imageNamed:self.torchState ? A3QRCodeImageTorchOn : A3QRCodeImageTorchOff]];
}

- (IBAction)vibrateOnOff:(id)sender {
	BOOL vibrateOn = [[NSUserDefaults standardUserDefaults] boolForKey:A3QRCodeSettingsPlayVibrate];
	vibrateOn = !vibrateOn;
	[[NSUserDefaults standardUserDefaults] setBool:vibrateOn forKey:A3QRCodeSettingsPlayVibrate];
	[self.vibrateOnOffButton setImage:[UIImage imageNamed:vibrateOn ? A3QRCodeImageVibrateOn : A3QRCodeImageVibrateOff]];
}

- (IBAction)scanFromImage:(id)sender {
	UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
	imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	imagePickerController.delegate = self;
	[self presentViewController:imagePickerController animated:YES completion:nil];
}

- (IBAction)historyButtonAction:(id)sender {
	A3QRCodeHistoryViewController *historyViewController = [A3QRCodeHistoryViewController new];
	A3NavigationController *navigationController = [[A3NavigationController alloc] initWithRootViewController:historyViewController];
	[self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

- (IBAction)soundOnOff:(id)sender {
	BOOL soundOn = [[NSUserDefaults standardUserDefaults] boolForKey:A3QRCodeSettingsPlayAlertSound];
	soundOn = !soundOn;
	[[NSUserDefaults standardUserDefaults] setBool:soundOn forKey:A3QRCodeSettingsPlayAlertSound];
	[self.soundOnOffButton setImage:[UIImage imageNamed:soundOn ? A3QRCodeImageSoundOn: A3QRCodeImageSoundOff]];
}

- (void)setupBarcodeHandler {
	__typeof(self) __weak weakSelf = self;
	self.barcodesHandler = ^(NSArray *barcodeObjects) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[barcodeObjects enumerateObjectsUsingBlock:^(AVMetadataMachineReadableCodeObject * _Nonnull barcode, NSUInteger idx, BOOL * _Nonnull stop) {
				NSManagedObjectContext *moc = [NSManagedObjectContext MR_rootSavingContext];
				
				QRCodeHistory *history = [QRCodeHistory MR_findFirstByAttribute:@"scanData" withValue:barcode.stringValue inContext:moc];
				if (history) {
					history.created = [NSDate date];
				} else {
					history = [QRCodeHistory MR_createEntityInContext:moc];
					history.uniqueID = [[NSUUID UUID] UUIDString];
					history.created = [NSDate date];
					history.type = barcode.type;
					history.scanData = barcode.stringValue;
					
					NSArray *qrcodeTypes = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode, AVMetadataObjectTypeDataMatrixCode];
					if ([qrcodeTypes indexOfObject:barcode.type] != NSNotFound) {
						history.dimension = @"2";
					} else {
						history.dimension = @"1";
					}
				}
				
				[moc MR_saveToPersistentStoreAndWait];

				if ([history.dimension isEqualToString:@"1"]) {
					if (!history.searchData) {
						[weakSelf searchBarcode:barcode.stringValue];
					} else {
						[weakSelf presentDetailViewControllerWithData:history];
					}
				} else {
					[weakSelf.dataHandler performActionWithData:barcode.stringValue inViewController:weakSelf];
				}
			}];
		});
	};
}

- (void)setupTapGestureHandler {
	self.tapGestureHandler = ^(CGPoint tapPoint) {

	};
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	UIImage *originalImage = [info valueForKey:UIImagePickerControllerOriginalImage];
	
	CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy:CIDetectorAccuracyHigh }];
	CIImage *image = [[CIImage alloc] initWithImage:originalImage];
	NSArray *features = [detector featuresInImage:image];
	CIQRCodeFeature *feature = [features firstObject];
	void(^alertBlock)() = nil;
	if (feature) {
		NSManagedObjectContext *moc = [NSManagedObjectContext MR_rootSavingContext];

		QRCodeHistory *existingItem = [QRCodeHistory MR_findFirstByAttribute:@"scanData" withValue:feature.messageString inContext:moc];
		if (existingItem) {
			existingItem.created = [NSDate date];
		} else {
			QRCodeHistory *newItem = [QRCodeHistory MR_createEntityInContext:moc];
			newItem.uniqueID = [[NSUUID UUID] UUIDString];
			newItem.created = [NSDate date];
			newItem.type = feature.type;
			newItem.scanData = feature.messageString;
			newItem.dimension = @"2";
		}

		[moc MR_saveToPersistentStoreAndWait];

		[self.dataHandler performActionWithData:feature.messageString inViewController:self];

	} else {
		alertBlock = ^() {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Info"
																message:@"Code not found."
															   delegate:nil
													  cancelButtonTitle:@"OK"
													  otherButtonTitles:nil];
			[alertView show];
		};
	}
	[picker dismissViewControllerAnimated:YES completion:alertBlock];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)searchBarcode:(NSString *)barcode {
	FNLOG();
	if (_googleSearchInProgress) {
		return;
	}
	_googleSearchInProgress = YES;
	
	NSURL *url = [NSURL URLWithString:[[NSString stringWithFormat:@"https://ajax.googleapis.com/ajax/services/search/web?v=1.0&q=%@", barcode] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];

	NSURLRequest *request = [NSURLRequest requestWithURL:url];

	AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
	operation.responseSerializer = [AFJSONResponseSerializer serializer];
	[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id JSON) {
		if ([JSON[@"responseStatus"] integerValue] == 200) {
			NSManagedObjectContext *moc = [NSManagedObjectContext MR_rootSavingContext];
			QRCodeHistory *history = [QRCodeHistory MR_findFirstByAttribute:@"scanData" withValue:barcode inContext:moc];
			history.searchData = [NSKeyedArchiver archivedDataWithRootObject:JSON];
			[moc MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
				[self presentDetailViewControllerWithData:history];
			}];
		}
		_googleSearchInProgress = NO;
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		_googleSearchInProgress = NO;
	}];

	[operation start];
}

- (void)presentDetailViewControllerWithData:(QRCodeHistory *)data {
	A3QRCodeDetailViewController *viewController = [A3QRCodeDetailViewController new];
	viewController.historyData = data;
	[self.navigationController pushViewController:viewController animated:YES];
}

- (A3QRCodeDataHandler *)dataHandler {
	if (!_dataHandler) {
		_dataHandler = [A3QRCodeDataHandler new];
	}
	return _dataHandler;
}

@end
