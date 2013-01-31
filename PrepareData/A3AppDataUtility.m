//
//  A3AppDataUtility.m
//  AppBoxPro2
//
//  Created by Byeong Kwon Kwak on 4/12/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3AppDataUtility.h"
#import "MenuGroup.h"
#import "MenuItem.h"
#import "MenuFavorite.h"
#import "CurrencyItem.h"
#import "CurrencyFavorite.h"
#import "CurrencyItem+name.h"

@implementation A3AppDataUtility {
@private
	NSManagedObjectContext *_managedObjectContext;
}

@synthesize managedObjectContext = _managedObjectContext;


- (id)init {
	self = [super init];
	if (self) {

	}

	return self;
}

- (void)initializeMenu {
	// ID, name, order, isFavorite, icon name
	NSString *groupsAndMenus[][21][5] = {
			{
				{@"FAVORITES",			@"Favorites", 			@"0100",	@"",		@""},					// Row #00, Group
				{@"BATTERY_LIFE", 		@"Battery Life", 		@"0100",	@"010",		@"app_pCal_32"},		// Row #01, Members
				{@"FLASHLIGHT", 		@"Flashlight", 			@"0200",	@"020",		@"app_pCal_32"},		// Row #02
				{@"LEVEL", 				@"Level", 				@"0300",	@"030",		@"app_pCal_32"},		// Row #03
				{@"MIRROR", 			@"Mirror",				@"0400",	@"040",		@"app_pCal_32"},		// Row #04
				{@"RULER", 				@"Ruler", 				@"0500",	@"050",		@"app_ruler_32"},		// Row #05
				{@"SYSTEM_INFO", 		@"System Info", 		@"0600",	@"060",		@"app_pCal_32"},		// Row #06
				{@"", 					@"", 					@"",		@"",		@""},					// Row #07
				{@"", 					@"", 					@"",		@"",		@""},					// Row #08
				{@"", 					@"", 					@"",		@"",		@""},					// Row #09
				{@"", 					@"", 					@"",		@"",		@""},					// Row #10
				{@"", 					@"", 					@"",		@"",		@""},					// Row #11
				{@"", 					@"", 					@"",		@"",		@""},					// Row #12
				{@"", 					@"", 					@"",		@"",		@""},					// Row #13
				{@"", 					@"", 					@"",		@"",		@""},					// Row #14
				{@"", 					@"", 					@"",		@"",		@""},					// Row #15
				{@"", 					@"", 					@"",		@"",		@""},					// Row #16
				{@"", 					@"", 					@"",		@"",		@""},					// Row #17
				{@"", 					@"", 					@"",		@"",		@""},					// Row #18
				{@"", 					@"", 					@"",		@"",		@""},					// Row #19
				{@"", 					@"", 					@"",		@"",		@""},					// Row #20
			},
			{
				{@"PRODUCTIVITY", 		@"Productivity", 		@"0200",	@"",		@"app_pCal_32"},		// Row #00, Group
				{@"EVENT_DIARY", 		@"Event Diary",			@"0100",	@"",		@"app_event_32"},		// Row #01, Members
				{@"PERIODIC_CALENDAR", 	@"Periodic Calendar",	@"0200",	@"",		@"app_pCal_32"},		// Row #02
				{@"WALLET", 			@"Wallet", 				@"0300",	@"",		@"app_wallet_32"},		// Row #03
				{@"CALENDAR", 			@"Calendar", 			@"0400",	@"",		@"app_pCal_32"},		// Row #04
				{@"TIMESHEET", 			@"Timesheet", 			@"0500",	@"",		@"app_pCal_32"},		// Row #05
				{@"MOMENT_DIARY", 		@"Moment Diary",		@"0600",	@"",		@"app_diary_32"},		// Row #06
				{@"PHOTO_DIARY", 		@"Photo Diary",			@"0700",	@"",		@"app_photo_32"},		// Row #07
				{@"MONEY_DIARY", 		@"Money Diary",			@"0800",	@"",		@"app_diary_32"},		// Row #08
				{@"AUTOMOBILE_DIARY", 	@"Automobile Diary",	@"0900",	@"",		@"app_diary_32"},		// Row #09
				{@"SCORE_CARD", 		@"Score Card",			@"1000",	@"",		@"app_pCal_32"},		// Row #10
				{@"FILE_STORAGE", 		@"File Storage",		@"1100",	@"",		@"app_pCal_32"},		// Row #11
				{@"MEDIA_STORAGE", 		@"Media Storage",		@"1200",	@"",		@"app_pCal_32"},		// Row #12
				{@"", 					@"", 					@"",		@"",		@""},					// Row #13
				{@"", 					@"", 					@"",		@"",		@""},					// Row #14
				{@"", 					@"", 					@"",		@"",		@""},					// Row #15
				{@"", 					@"", 					@"",		@"",		@""},					// Row #16
				{@"", 					@"", 					@"",		@"",		@""},					// Row #17
				{@"", 					@"", 					@"",		@"",		@""},					// Row #18
				{@"", 					@"", 					@"",		@"",		@""},					// Row #19
				{@"", 					@"", 					@"",		@"",		@""},					// Row #20
			},
			{
				{@"UTILITY", 			@"Utility",				@"0300",	@"",		@"app_pCal_32"},		// Row #00, Group
				{@"BATTERY_LIFE", 		@"Battery Life",		@"0100",	@"070",		@"app_pCal_32"},		// Row #01, Members
				{@"FLASHLIGHT", 		@"Flashlight",			@"0200",	@"080",		@"app_pCal_32"},		// Row #02
				{@"LEVEL", 				@"Level",				@"0300",	@"090",		@"app_pCal_32"},		// Row #03
				{@"MIRROR", 			@"Mirror",				@"0400",	@"100",		@"app_pCal_32"},		// Row #04
				{@"Random Generator", 	@"Random Generator",	@"0500",	@"",		@"app_pCal_32"},		// Row #05
				{@"RULER", 				@"Ruler",				@"0600",	@"110",		@"app_ruler_32"},		// Row #06
				{@"SYSTEM_INFO", 		@"System Info",			@"0700",	@"120",		@"app_systeminfo_32"},	// Row #07
				{@"LOTTERY", 			@"Lottery",				@"0800",	@"",		@"app_pCal_32"},		// Row #08
				{@"PASSWORD GENERATOR", @"Password Generator",	@"0900",	@"",		@"app_pCal_32"},		// Row #09
				{@"PROTRACTOR", 		@"Protractor",			@"1000",	@"",		@"app_pCal_32"},		// Row #10
				{@"COMPASS", 			@"Compass",				@"1100",	@"",		@"app_pCal_32"},		// Row #11
				{@"ELECTRONIC_SIGN", 	@"Electronic Sign",		@"1200",	@"",		@"app_pCal_32"},		// Row #12
				{@"MAGNIFYING_GLASS", 	@"Magnifying Glass",	@"1300",	@"",		@"app_pCal_32"},		// Row #13
				{@"DEFECTIVE TEST", 	@"Defective Test",		@"1400",	@"",		@"app_pCal_32"},		// Row #14
				{@"TALLY_COUNTER", 		@"Tally Counter",		@"1500",	@"",		@"app_pCal_32"},		// Row #15
				{@"PARKING_LOT", 		@"Parking Lot",			@"1600",	@"",		@"app_pCal_32"},		// Row #16
				{@"BMI_CALCULATOR", 	@"BMI Calculator",		@"1700",	@"",		@"app_pCal_32"},		// Row #17
				{@"ALTIMETER", 			@"Altimeter",			@"1800",	@"",		@"app_pCal_32"},		// Row #18
				{@"PEDOMETER", 			@"Pedometer",			@"1900",	@"",		@"app_pCal_32"},		// Row #19
				{@"", 					@"", 					@"",		@"",		@""},					// Row #20
			},
			{
				{@"CONVERTER", 			@"Converter", 			@"0400",	@"",		@"app_pCal_32"},		// Row #00, Group
				{@"CURRENCY", 			@"Currency",			@"0100",	@"",		@"app_currency_32"},	// Row #01, Members
				{@"UNIT", 				@"Unit",				@"0200",	@"",		@"app_unit_32"},		// Row #02
				{@"TRANSLATOR", 		@"Translator",			@"0300",	@"",		@"app_translator_32"},	// Row #03
				{@"TIMEZONE", 			@"Timezone Converter",	@"0400",	@"",		@"app_pCal_32"},		// Row #04
				{@"CLOTHING_SIZE", 		@"Clothing Size",		@"0500",	@"",		@"app_pCal_32"},		// Row #05
				{@"", 					@"", 					@"",		@"",		@""},					// Row #06
				{@"", 					@"", 					@"",		@"",		@""},					// Row #07
				{@"", 					@"", 					@"",		@"",		@""},					// Row #08
				{@"", 					@"", 					@"",		@"",		@""},					// Row #09
				{@"", 					@"", 					@"",		@"",		@""},					// Row #10
				{@"", 					@"", 					@"",		@"",		@""},					// Row #11
				{@"", 					@"", 					@"",		@"",		@""},					// Row #12
				{@"", 					@"", 					@"",		@"",		@""},					// Row #13
				{@"", 					@"", 					@"",		@"",		@""},					// Row #14
				{@"", 					@"", 					@"",		@"",		@""},					// Row #15
				{@"", 					@"", 					@"",		@"",		@""},					// Row #16
				{@"", 					@"", 					@"",		@"",		@""},					// Row #17
				{@"", 					@"", 					@"",		@"",		@""},					// Row #18
				{@"", 					@"", 					@"",		@"",		@""},					// Row #19
				{@"", 					@"", 					@"",		@"",		@""},					// Row #20
			},
			{
				{@"CALCULATOR", 		@"Calculator",			@"0500",	@"",		@"app_pCal_32"},		// Row #00, Group
				{@"DATE_CALC", 			@"Date Calc", 			@"0100",	@"",		@"app_pCal_32"},		// Row #01, Members
				{@"LOAN_CALC", 			@"Loan Calc",			@"0200",	@"",		@"app_loan_32"},		// Row #02
				{@"PRICE_COMPARE", 		@"Price Compare",		@"0300",	@"",		@"app_pCal_32"},		// Row #03
				{@"SALE_PRICE", 		@"Sale Price",			@"0400",	@"",		@"app_pCal_32"},		// Row #04
				{@"TIP_CALC", 			@"Tip Calc",			@"0500",	@"",		@"app_pCal_32"},		// Row #05
				{@"NORMAL_CALCULATOR", 	@"Normal Calculator",	@"0600",	@"",		@"app_pCal_32"},		// Row #06
				{@"FRACTION_CALC", 		@"Fraction Calc",		@"0700",	@"",		@"app_pCal_32"},		// Row #07
				{@"SUNRISE_SUNSET", 	@"Sunrise/Sunset",		@"0800",	@"",		@"app_pCal_32"},		// Row #08
				{@"SALARY_CALC", 		@"Salary Calc",			@"0900",	@"",		@"app_pCal_32"},		// Row #09
				{@"PERCENT_CALC", 		@"Percent Calc",		@"1000",	@"",		@"app_pCal_32"},		// Row #10
				{@"", 					@"", 					@"",		@"",		@""},					// Row #11
				{@"", 					@"", 					@"",		@"",		@""},					// Row #12
				{@"", 					@"", 					@"",		@"",		@""},					// Row #13
				{@"", 					@"", 					@"",		@"",		@""},					// Row #14
				{@"", 					@"", 					@"",		@"",		@""},					// Row #15
				{@"", 					@"", 					@"",		@"",		@""},					// Row #16
				{@"", 					@"", 					@"",		@"",		@""},					// Row #17
				{@"", 					@"", 					@"",		@"",		@""},					// Row #18
				{@"", 					@"", 					@"",		@"",		@""},					// Row #19
				{@"", 					@"", 					@"",		@"",		@""},					// Row #20
			},
			{
				{@"REFERENCE", 			@"Reference",			@"0600",	@"",		@"app_pCal_32"},		// Row #00, Group
				{@"HOLIDAYS", 			@"Holidays",			@"0100",	@"",		@"app_pCal_32"},		// Row #01, Members
				{@"CLOCK", 				@"Clock",				@"0200",	@"",		@"app_clock_32"},		// Row #02
				{@"WEATHER", 			@"Weather",				@"0300",	@"",		@"app_pCal_32"},		// Row #O3
				{@"AREA_CODE_LIST", 	@"Area Code List",		@"0400",	@"",		@"app_pCal_32"},		// Row #04
				{@"GAS_PRICE", 			@"Gas Price",			@"0500",	@"",		@"app_pCal_32"},		// Row #05
				{@"GOLF", 				@"Golf",				@"0600",	@"",		@"app_pCal_32"},		// Row #06
				{@"STOCKS", 			@"Stocks",				@"0700",	@"",		@"app_pCal_32"},		// Row #07
				{@"RELIGION_HOLIDAY", 	@"Religion Holiday",	@"0800",	@"",		@"app_pCal_32"},		// Row #08
				{@"THIS_DAY_IN_HISTORY",@"This day in History",	@"0900",	@"",		@"app_pCal_32"},		// Row #09
				{@"PHASES", 			@"Phases",				@"1000",	@"",		@"app_pCal_32"},		// Row #10
				{@"PRICE_SCANNER", 		@"Price Scanner",		@"1100",	@"",		@"app_pCal_32"},		// Row #11
				{@"", 					@"", 					@"",		@"",		@""},					// Row #12
				{@"", 					@"", 					@"",		@"",		@""},					// Row #13
				{@"", 					@"", 					@"",		@"",		@""},					// Row #14
				{@"", 					@"", 					@"",		@"",		@""},					// Row #15
				{@"", 					@"", 					@"",		@"",		@""},					// Row #16
				{@"", 					@"", 					@"",		@"",		@""},					// Row #17
				{@"", 					@"", 					@"",		@"",		@""},					// Row #18
				{@"", 					@"", 					@"",		@"",		@""},					// Row #19
				{@"", 					@"", 					@"",		@"",		@""},					// Row #20
			},
			{
				{@"WEBAPPS", 			@"WebApps",				@"0700",	@"",		@"app_pCal_32"},		// Row #00, Group
				{@"GMAIL", 				@"Gmail",				@"0100",	@"",		@"app_pCal_32"},		// Row #01, Members
				{@"GOOGLE_CALENDAR", 	@"Google Calendar",		@"0200",	@"",		@"app_pCal_32"},		// Row #02
				{@"GOOGLE_DOCS", 		@"Google Docs",			@"0300",	@"",		@"app_pCal_32"},		// Row #03
				{@"GOOGLE_PLUS", 		@"Google+",				@"0400",	@"",		@"app_pCal_32"},		// Row #04
				{@"GOOGLE_NEWS", 		@"News",				@"0500",	@"",		@"app_pCal_32"},		// Row #05
				{@"GOOGLE_READER", 		@"Google Reader",		@"0600",	@"",		@"app_pCal_32"},		// Row #06
				{@"GOOGLE_PHOTOS", 		@"Google Photos",		@"0700",	@"",		@"app_pCal_32"},		// Row #07
				{@"GOOGLE_TRANSLATE", 	@"Google Translate",	@"0800",	@"",		@"app_pCal_32"},		// Row #08
				{@"GOOGLE_TASKS", 		@"Tasks",				@"0900",	@"",		@"app_pCal_32"},		// Row #09
				{@"GOOGLE_BOOKS", 		@"Google Books",		@"1000",	@"",		@"app_pCal_32"},		// Row #10
				{@"GOOGLE_IGOOGLE", 	@"Google iGoogle",		@"1100",	@"",		@"app_pCal_32"},		// Row #11
				{@"YAHOO", 				@"Yahoo",				@"1200",	@"",		@"app_pCal_32"},		// Row #12
				{@"WEB_GAMES", 			@"WebGames",			@"1300",	@"",		@"app_pCal_32"},		// Row #13
				{@"", 					@"", 					@"",		@"",		@""},					// Row #14
				{@"", 					@"", 					@"",		@"",		@""},					// Row #15
				{@"", 					@"", 					@"",		@"",		@""},					// Row #16
				{@"", 					@"", 					@"",		@"",		@""},					// Row #17
				{@"", 					@"", 					@"",		@"",		@""},					// Row #18
				{@"", 					@"", 					@"",		@"",		@""},					// Row #19
				{@"", 					@"", 					@"",		@"",		@""},					// Row #20
			},
			{
				{@"GAMES", 				@"Games",				@"0800",	@"",		@""},					// Row #00, Group
				{@"", 					@"", 					@"",		@"",		@""},					// Row #01
				{@"", 					@"", 					@"",		@"",		@""},					// Row #02
				{@"", 					@"", 					@"",		@"",		@""},					// Row #03
				{@"", 					@"", 					@"",		@"",		@""},					// Row #04
				{@"", 					@"", 					@"",		@"",		@""},					// Row #05
				{@"", 					@"", 					@"",		@"",		@""},					// Row #06
				{@"", 					@"", 					@"",		@"",		@""},					// Row #07
				{@"", 					@"", 					@"",		@"",		@""},					// Row #08
				{@"", 					@"", 					@"",		@"",		@""},					// Row #09
				{@"", 					@"", 					@"",		@"",		@""},					// Row #10
				{@"", 					@"", 					@"",		@"",		@""},					// Row #11
				{@"", 					@"", 					@"",		@"",		@""},					// Row #12
				{@"", 					@"", 					@"",		@"",		@""},					// Row #13
				{@"", 					@"", 					@"",		@"",		@""},					// Row #14
				{@"", 					@"", 					@"",		@"",		@""},					// Row #15
				{@"", 					@"", 					@"",		@"",		@""},					// Row #16
				{@"", 					@"", 					@"",		@"",		@""},					// Row #17
				{@"", 					@"", 					@"",		@"",		@""},					// Row #18
				{@"", 					@"", 					@"",		@"",		@""},					// Row #19
				{@"", 					@"", 					@"",		@"",		@""},					// Row #20
			},
	};

	for (NSInteger i = 0; i < 8; i++) {
		MenuGroup *newMenuGroup;
		newMenuGroup = [NSEntityDescription insertNewObjectForEntityForName:@"MenuGroup" inManagedObjectContext:self.managedObjectContext];
		newMenuGroup.menuGroupID = groupsAndMenus[i][0][0];
		newMenuGroup.name = NSLocalizedString(groupsAndMenus[i][0][1], nil);
		newMenuGroup.order = groupsAndMenus[i][0][2];
		NSLog(@"Group: %@", newMenuGroup.name);

		NSMutableArray *newMenuItems = [[NSMutableArray alloc] initWithCapacity:21];
		for (NSInteger j = 1; j < 21; j++) {
			if ([groupsAndMenus[i][j][0] length] == 0)
				break;
			MenuItem *newMenuItem;
			newMenuItem = [NSEntityDescription insertNewObjectForEntityForName:@"MenuItem" inManagedObjectContext:self.managedObjectContext];
			newMenuItem.appID = groupsAndMenus[i][j][0];
			newMenuItem.name = groupsAndMenus[i][j][1];
			newMenuItem.iconName = groupsAndMenus[i][j][4];
			NSLog(@"id = %@, name = %@, iconName = %@", newMenuItem.appID, newMenuItem.name, newMenuItem.iconName);
			[newMenuItems addObject:newMenuItem];

			if ([groupsAndMenus[i][j][3] length]) {
				MenuFavorite *favorite = [NSEntityDescription insertNewObjectForEntityForName:@"MenuFavorite" inManagedObjectContext:self.managedObjectContext];
				favorite.order = groupsAndMenus[i][j][3];
				favorite.menuItem = newMenuItem;
			}
		}
		if ([newMenuItems count]) {
			[newMenuGroup setMenuItems:[NSSet setWithArray:newMenuItems]];
		}
	}
}

- (NSArray *)yahooCurrencyArray {
	NSURL *yahooURL = [NSURL URLWithString:@"http://finance.yahoo.com/webservice/v1/symbols/allcurrencies/quote?format=json"];
	NSURLRequest *request = [NSURLRequest requestWithURL:yahooURL];
	NSURLResponse *response;
	NSData *yahooData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:NULL];
	if (!yahooData) {
		NSLog(@"Fail to download Yahoo currency data!");
		return nil;
	}
	NSError *error;
	NSDictionary *foundationData = [NSJSONSerialization JSONObjectWithData:yahooData options:NSJSONReadingMutableContainers error:&error];

	NSDictionary *list = [foundationData objectForKey:@"list"];
	return [list objectForKey:@"resources"];
}

- (NSString *)nameForCurrencySymbol:(NSString *)symbol {
	NSArray *symbols = @[@"XCP", @"ZMW", @"CNH", @"XDR", @"CLF"];
	NSArray *names = @[@"Copper Highgrade", @"Zambian kwacha", @"Offshore Renminbi", @"Special Drawing Rights", @"Unidad de Fomento"];

	NSUInteger index = [symbols indexOfObject:symbol];
	if (NSNotFound == index) {
		NSLog(@"Fail to get displayName from system: %@", symbol);
		return nil;
	}

	return [names objectAtIndex:index];
}

#pragma mark Make Yahoo Currency Initial Data

- (void)addFavoritesForCurrencyItem:(CurrencyItem *)currencyItem {
	NSArray *favorites = @[@"USD", @"EUR", @"GBP", @"CAD", @"JPY", @"HKD", @"CNY", @"CHF", @"KRW"];

	NSUInteger index = [favorites indexOfObject:currencyItem.symbol];
	if (index != NSNotFound) {
		CurrencyFavorite *currencyFavorite = [NSEntityDescription insertNewObjectForEntityForName:@"CurrencyFavorite" inManagedObjectContext:self.managedObjectContext];
		currencyFavorite.order = [NSString stringWithFormat:@"0%d0", (int)index];
		currencyFavorite.currencyItem = currencyItem;
	}
}

- (void)initCurrencyData {
	NSArray *yahooCurrencyArray = [self yahooCurrencyArray];
	if (nil == yahooCurrencyArray) {
		return;
	}

	for (NSDictionary *yahooItem in yahooCurrencyArray) {
		CurrencyItem *currencyItem = [NSEntityDescription insertNewObjectForEntityForName:@"CurrencyItem" inManagedObjectContext:self.managedObjectContext];
		currencyItem.symbol = [[[[yahooItem objectForKey:@"resource"] objectForKey:@"fields"] objectForKey:@"symbol"] substringToIndex:3];
		NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
		[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
		[numberFormatter setCurrencyCode:currencyItem.symbol];
		NSLog(@"%@ = %@, %@", currencyItem.symbol, [numberFormatter stringFromNumber:@0], [currencyItem localizedName]);

		currencyItem.flagImageName = [self countryNameForCurrencyCode:currencyItem.symbol];

		[self addFavoritesForCurrencyItem:currencyItem];
	}

	// Add USD
	CurrencyItem *usdCurrencyItem = [NSEntityDescription insertNewObjectForEntityForName:@"CurrencyItem" inManagedObjectContext:self.managedObjectContext];
	usdCurrencyItem.symbol = @"USD";
	usdCurrencyItem.flagImageName = [self countryNameForCurrencyCode:usdCurrencyItem.symbol];
	[self addFavoritesForCurrencyItem:usdCurrencyItem];
}

- (void)makeCurrencyDataFile {
	NSArray *yahooCurrencyArray = [self yahooCurrencyArray];
	if (nil == yahooCurrencyArray) {
		return;
	}

	NSMutableArray *currencyArray = [[NSMutableArray alloc] initWithCapacity:[yahooCurrencyArray count]];

//	NSError *error;
//	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"CLF" options:0 error:&error];

	NSLocale *currentLocale = [NSLocale currentLocale];

	for (NSDictionary *item in yahooCurrencyArray) {
		NSMutableArray *itemArray = [[NSMutableArray alloc] initWithCapacity:5];
		// Add Symbol
		NSString *symbol = [[[[item objectForKey:@"resource"] objectForKey:@"fields"] objectForKey:@"symbol"] substringToIndex:3];

//		NSRange range = [regex rangeOfFirstMatchInString:symbol options:0 range:NSMakeRange(0, [symbol length])];
//		if (!NSEqualRanges(range, NSMakeRange(NSNotFound, 0))) {
//			continue;
//		}

		[itemArray addObject:symbol];
		NSString *name = [currentLocale displayNameForKey:NSLocaleCurrencyCode value:symbol];
		if (![name length]) {
			name = [self nameForCurrencySymbol:symbol];
		}
		[itemArray addObject:name != nil?name:@""];
		[itemArray addObject:[[[item objectForKey:@"resource"] objectForKey:@"fields"] objectForKey:@"price"]];

        NSMutableString *updateDateString = [NSMutableString stringWithString:[[[item objectForKey:@"resource"] objectForKey:@"fields"] objectForKey:@"ts"] ];
        NSDate *updatedDate = [NSDate dateWithTimeIntervalSince1970:[updateDateString integerValue]];
		[itemArray addObject:updatedDate];
		NSString *countryName = [self countryNameForCurrencyCode:symbol];
		[itemArray addObject:countryName];

		[currencyArray addObject:itemArray];
	}

	[currencyArray addObject:[NSMutableArray arrayWithObjects:@"USD", @"USD", @"1.0", [[currencyArray lastObject] objectAtIndex:3], @"United_States", nil]];

	[currencyArray sortUsingComparator:^NSComparisonResult(NSArray *object1, NSArray *object2){
		return [[object1 objectAtIndex:0] compare:[object2 objectAtIndex:0]];;
	}];

	NSLog(@"%lu items", [currencyArray count]);

	NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *filePath = [docDir stringByAppendingPathComponent:@"allCurrencyCodesData.db"];
	[currencyArray writeToFile:filePath atomically:YES];

	NSLog(@"File saved in %@", filePath);
}

- (NSString *)countryNameForCurrencyCode:(NSString *)code {
	// ISO Currency Codes
	NSString *codeVSnation[][3] = {
			{@"ADF", @"Andorra", @"YES"},
			{@"ADP", @"Andorra", @"YES"},
			{@"AED", @"United_Arab_Emirates", @"YES"},
			{@"AFN", @"Afghanistan", @"YES"},
			{@"ALL", @"Albania", @"YES"},
			{@"AMD", @"Armenia", @"YES"},
			{@"ANG", @"Netherlands_Antilles", @"YES"},
			{@"AOA", @"Angola", @"YES"},
			{@"AON", @"Angola", @"YES"},
			{@"ARS", @"Argentina", @"YES"},
			{@"ATS", @"Austria", @"YES"},
			{@"AUD", @"Australia", @"YES"},
			{@"AWG", @"Aruba", @"YES"},
			{@"AZM", @"Azerbaijan", @"YES"},
			{@"AZN", @"Azerbaijan", @"YES"},
			{@"BAM", @"Bosnia_and_Herzegovina", @"YES"},
			{@"BBD", @"Barbados", @"YES"},
			{@"BDT", @"Bangladesh", @"YES"},
			{@"BEF", @"Belgium", @"YES"},
			{@"BGN", @"Bulgaria", @"YES"},
			{@"BHD", @"Bahrain", @"YES"},
			{@"BIF", @"Burundi", @"YES"},
			{@"BMD", @"Bermuda", @"YES"},
			{@"BND", @"Brunei", @"YES"},
			{@"BOB", @"Bolivia", @"YES"},
			{@"BRL", @"Brazil", @"YES"},
			{@"BSD", @"Bahamas", @"YES"},
			{@"BTN", @"Bhutan", @"YES"},
			{@"BWP", @"Botswana", @"YES"},
			{@"BYR", @"Belarus", @"YES"},
			{@"BZD", @"Belize", @"YES"},
			{@"CAD", @"Canada", @"YES"},
			{@"CDF", @"Congo", @"YES"},
			{@"CHF", @"Switzerland", @"YES"},
			{@"CLP", @"Chile", @"YES"},
			{@"CLF", @"Chile", @"YES"},
			{@"CNY", @"China", @"YES"},
			{@"CNH", @"China", @"YES"},
			{@"COP", @"Colombia", @"YES"},
			{@"CRC", @"Costa_Rica", @"YES"},
			{@"CUC", @"Cuba", @"YES"},
			{@"CUP", @"Cuba", @"YES"},
			{@"CVE", @"Cape_Verde", @"YES"},
			{@"CYP", @"Cyprus", @"YES"},
			{@"CZK", @"Czech_Republic", @"YES"},
			{@"DEM", @"Germany", @"YES"},
			{@"DJF", @"Djibouti", @"YES"},
			{@"DKK", @"Denmark", @"YES"},
			{@"DOP", @"Dominican_Republic", @"YES"},
			{@"DZD", @"Algeria", @"YES"},
			{@"ECS", @"Ecuador", @"YES"},
			{@"EEK", @"Estonia", @"YES"},
			{@"EGP", @"Egypt", @"YES"},
			{@"ESP", @"Spain", @"YES"},
			{@"ETB", @"Ethiopia", @"YES"},
			{@"EUR", @"Europe", @"YES"},
			{@"FIM", @"Finland", @"YES"},
			{@"FJD", @"Fiji", @"YES"},
			{@"FKP", @"Falkland_Islands", @"YES"},
			{@"FRF", @"France", @"YES"},
			{@"GBP", @"United_Kingdom", @"YES"},
			{@"GEL", @"Georgia", @"YES"},
			{@"GHC", @"Ghana", @"YES"},
			{@"GHS", @"Ghana", @"YES"},
			{@"GIP", @"Gibraltar", @"YES"},
			{@"GMD", @"Gambia", @"YES"},
			{@"GNF", @"Guinea", @"YES"},
			{@"GRD", @"Greece", @"YES"},
			{@"GTQ", @"Guatemala", @"YES"},
			{@"GYD", @"Guyana", @"YES"},
			{@"HKD", @"Hong_Kong", @"YES"},
			{@"HNL", @"Honduras", @"YES"},
			{@"HRK", @"Croatia", @"YES"},
			{@"HTG", @"Haiti", @"YES"},
			{@"HUF", @"Hungary", @"YES"},
			{@"IDR", @"Indonesia", @"YES"},
			{@"IEP", @"Ireland", @"YES"},
			{@"ILS", @"Israel", @"YES"},
			{@"INR", @"India", @"YES"},
			{@"IQD", @"Iraq", @"YES"},
			{@"IRR", @"Iran", @"YES"},
			{@"ISK", @"Iceland", @"YES"},
			{@"ITL", @"Italy", @"YES"},
			{@"JMD", @"Jamaica", @"YES"},
			{@"JOD", @"Jordan", @"YES"},
			{@"JPY", @"Japan", @"YES"},
			{@"KES", @"Kenya", @"YES"},
			{@"KGS", @"Kyrgyzstan", @"YES"},
			{@"KHR", @"Cambodia", @"YES"},
			{@"KMF", @"Comoros", @"YES"},
			{@"KPW", @"North_Korea", @"YES"},
			{@"KRW", @"South_Korea", @"YES"},
			{@"KWD", @"Kuwait", @"YES"},
			{@"KYD", @"Cayman_Islands", @"YES"},
			{@"KZT", @"Kazakhstan", @"YES"},
			{@"LAK", @"Laos", @"YES"},
			{@"LBP", @"Lebanon", @"YES"},
			{@"LKR", @"Sri_Lanka", @"YES"},
			{@"LRD", @"Liberia", @"YES"},
			{@"LSL", @"Lesotho", @"YES"},
			{@"LTL", @"Lithuania", @"YES"},
			{@"LUF", @"Luxembourg", @"YES"},
			{@"LVL", @"Latvia", @"YES"},
			{@"LYD", @"Libya", @"YES"},
			{@"MAD", @"Morocco", @"YES"},
			{@"MDL", @"Moldova", @"YES"},
			{@"MGA", @"Madagascar", @"YES"},
			{@"MGF", @"Madagascar", @"YES"},
			{@"MKD", @"Macedonia", @"YES"},
			{@"MMK", @"Myanmar", @"YES"},
			{@"MNT", @"Mongolia", @"YES"},
			{@"MOP", @"Macau", @"YES"},
			{@"MRO", @"Mauritania", @"YES"},
			{@"MTL", @"Malta", @"YES"},
			{@"MUR", @"Mauritius", @"YES"},
			{@"MVR", @"Maldives", @"YES"},
			{@"MWK", @"Malawi", @"YES"},
			{@"MXN", @"Mexico", @"YES"},
			{@"MYR", @"Malaysia", @"YES"},
			{@"MZM", @"Mozambique", @"YES"},
			{@"MZN", @"Mozambique", @"YES"},
			{@"NAD", @"Namibia", @"YES"},
			{@"NGN", @"Nigeria", @"YES"},
			{@"NIO", @"Nicaragua", @"YES"},
			{@"NLG", @"Netherlands", @"YES"},
			{@"NOK", @"Norway", @"YES"},
			{@"NPR", @"Nepal", @"YES"},
			{@"NZD", @"New_Zealand", @"YES"},
			{@"OMR", @"Oman", @"YES"},
			{@"PAB", @"Panama", @"YES"},
			{@"PEN", @"Peru", @"YES"},
			{@"PGK", @"Papua_New_Guinea", @"YES"},
			{@"PHP", @"Philippines", @"YES"},
			{@"PKR", @"Pakistan", @"YES"},
			{@"PLN", @"Poland", @"YES"},
			{@"PTE", @"Portugal", @"YES"},
			{@"PYG", @"Paraguay", @"YES"},
			{@"QAR", @"Qatar", @"YES"},
			{@"ROL", @"Romania", @"YES"},
			{@"RON", @"Romania", @"YES"},
			{@"RSD", @"Serbia", @"YES"},
			{@"RUB", @"Russia", @"YES"},
			{@"RWF", @"Rwanda", @"YES"},
			{@"SAR", @"Saudi_Arabia", @"YES"},
			{@"SBD", @"Solomon_Islands", @"YES"},
			{@"SCR", @"Seychelles", @"YES"},
			{@"SDD", @"Sudan", @"YES"},
			{@"SDG", @"Sudan", @"YES"},
			{@"SDP", @"Sudan", @"YES"},
			{@"SEK", @"Sweden", @"YES"},
			{@"SGD", @"Singapore", @"YES"},
			{@"SHP", @"Saint_Helena", @"YES"},
			{@"SIT", @"Slovenia", @"YES"},
			{@"SKK", @"Slovakia", @"YES"},
			{@"SLL", @"Sierra_Leone", @"YES"},
			{@"SOS", @"Somalia", @"YES"},
			{@"SRD", @"Suriname", @"YES"},
			{@"SRG", @"Suriname", @"YES"},
			{@"STD", @"Sao_Tome_and_Principe", @"YES"},
			{@"SVC", @"El_Salvador", @"YES"},
			{@"SYP", @"Syria", @"YES"},
			{@"SZL", @"Swaziland", @"YES"},
			{@"THB", @"Thailand", @"YES"},
			{@"TJS", @"Tajikistan", @"YES"},
			{@"TMM", @"Turkmenistan", @"YES"},
			{@"TMT", @"Turkmenistan", @"YES"},
			{@"TND", @"Tunisia", @"YES"},
			{@"TOP", @"Tonga", @"YES"},
			{@"TRL", @"Turkey", @"YES"},
			{@"TRY", @"Turkey", @"YES"},
			{@"TTD", @"Trinidad_and_Tobago", @"YES"},
			{@"TWD", @"Republic_of_China", @"YES"},
			{@"TZS", @"Tanzania", @"YES"},
			{@"UAH", @"Ukraine", @"YES"},
			{@"UGX", @"Uganda", @"YES"},
			{@"USD", @"United_States", @"YES"},
			{@"UYU", @"Uruguay", @"YES"},
			{@"UZS", @"Uzbekistan", @"YES"},
			{@"VEB", @"Venezuela", @"YES"},
			{@"VEF", @"Venezuela", @"YES"},
			{@"VND", @"Vietnam", @"YES"},
			{@"VUV", @"Vanuatu", @"YES"},
			{@"WST", @"Samoa", @"YES"},
			{@"XAF", @"CFA", @"YES"},
			{@"XAG", @"Ag", @"NO"},
			{@"XAU", @"Au", @"NO"},
			{@"XCP", @"Ag", @"NO"},
			{@"XCD", @"One_east_caribbean_dollar", @"YES"},
			{@"XEU", @"Europe", @"YES"},
			{@"XOF", @"Guinea-Bissau", @"YES"},
			{@"XPD", @"Pd", @"YES"},
			{@"XPF", @"French_Polynesia", @"YES"},
			{@"XPT", @"Pt", @"YES"},
			{@"YER", @"Yemen", @"YES"},
			{@"ZAR", @"South_Africa", @"YES"},
			{@"ZMK", @"Zambia", @"YES"},
			{@"ZMW", @"Zambia", @"YES"},
			{@"ZWD", @"Zimbabwe", @"YES"},
			{@"ZWL", @"Zimbabwe", @"YES"},
	};
	NSString *countryName = @"";

	for (int i = 0; sizeof(codeVSnation) / sizeof(codeVSnation[0]) > i; i++) {
		if ([code isEqualToString:codeVSnation[i][0]]) {
			countryName = codeVSnation[i][1];
			break;
		}
	}

	countryName = [countryName stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" \t"]];
	if ([countryName length] == 0) {
		NSLog(@"Unknown country %@", code);
	}
	return countryName;
}

@end
