//
//  A3AppDelegate.m
//  A3SetupDefaultData
//
//  Created by A3 on 12/5/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3SetupAppDelegate.h"
#import "A3YahooCurrency.h"
#import "NSFileManager+A3Addtion.h"
#import "CurrencyRateItem.h"
#import "Reachability.h"
#import "A3CacheStoreManager.h"

@implementation A3SetupAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
	NSError *error = nil;
	@try {
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSString *storePath = [[fileManager applicationSupportPath] stringByAppendingPathComponent:@"AppBoxCacheStore.sqlite"];

		if ([fileManager fileExistsAtPath:storePath]) {
			[fileManager removeItemAtPath:storePath error:&error];
		}
		[MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"AppBoxCacheStore.sqlite"];

		[self initCurrencyData];

		[[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
	}
	@catch (id exception) {
		NSLog(@"%@", [(id <NSObject>)exception description]);
	}

//	NSArray *fetchedObjects = [CurrencyItem MR_findAll];
//	NSLog(@"%@", fetchedObjects);
	
	return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
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
	
	NSUInteger idx = [symbols indexOfObject:symbol];
	if (NSNotFound == idx) {
		NSLog(@"Fail to get displayName from system: %@", symbol);
		return nil;
	}
	
	return [names objectAtIndex:idx];
}

#pragma mark Make Yahoo Currency Initial Data

- (void)initCurrencyData {
	NSArray *yahooArray = [self yahooCurrencyArray];
	if (nil == yahooArray) {
		return;
	}

	NSArray *localesArray = [NSLocale availableLocaleIdentifiers];
	NSMutableArray *validLocales = [[NSMutableArray alloc] initWithCapacity:[localesArray count]];
	for (id localeid in localesArray) {
		NSLocale *locale = [NSLocale localeWithLocaleIdentifier:localeid];
		if ([[locale objectForKey:NSLocaleCurrencyCode] length]) {
			[validLocales addObject:@{
									  NSLocaleCurrencyCode : [locale objectForKey:NSLocaleCurrencyCode],
									  NSLocaleIdentifier : localeid,
									  NSLocaleCurrencySymbol : [locale objectForKey:NSLocaleCurrencySymbol]
									  }];
		}
	}
	NSComparator comparator = ^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
		return [obj1[NSLocaleCurrencyCode] compare:obj2[NSLocaleCurrencyCode]];
	};
	[validLocales sortUsingComparator:comparator];

	NSDate *updated = nil;
	for (id obj in yahooArray) {
		A3YahooCurrency *yahooCurrency = [[A3YahooCurrency alloc] initWithObject:obj];
		CurrencyRateItem *entity = [CurrencyRateItem MR_createEntity];
		entity.currencyCode = yahooCurrency.currencyCode;
		entity.flagImageName = [self countryNameForCurrencyCode:entity.currencyCode];
		entity.rateToUSD = yahooCurrency.rateToUSD;
		entity.updated = yahooCurrency.updated;
		updated = [yahooCurrency.updated laterDate:updated];
		NSUInteger idx = [validLocales indexOfObject:@{NSLocaleCurrencyCode:yahooCurrency.currencyCode}
										 inSortedRange:NSMakeRange(0, [validLocales count])
											   options:NSBinarySearchingFirstEqual
									   usingComparator:comparator];
		if (idx != NSNotFound) {
			entity.currencySymbol = validLocales[idx][NSLocaleCurrencySymbol];
		}
	}

	NSArray *exceptionList = @[
			@{NSLocaleCurrencyCode : @"ALL", NSLocaleCurrencySymbol : @"Lek"},
			@{NSLocaleCurrencyCode : @"AZN", NSLocaleCurrencySymbol : @"\u043c\u0430\u043d."},
			@{NSLocaleCurrencyCode : @"BAM", NSLocaleCurrencySymbol : @"KM"},
			@{NSLocaleCurrencyCode : @"DKK", NSLocaleCurrencySymbol : @"kr"},
			@{NSLocaleCurrencyCode : @"HRK", NSLocaleCurrencySymbol : @"kn"},
			@{NSLocaleCurrencyCode : @"LKR", NSLocaleCurrencySymbol : @"Rs."},
			@{NSLocaleCurrencyCode : @"MAD", NSLocaleCurrencySymbol : @"\u062f.\u0645.\u200f"},
			@{NSLocaleCurrencyCode : @"RUB", NSLocaleCurrencySymbol : @"\u0440\u0443\u0431."},
			@{NSLocaleCurrencyCode : @"SEK", NSLocaleCurrencySymbol : @"kr"},
			@{NSLocaleCurrencyCode : @"TND", NSLocaleCurrencySymbol : @"\u062f.\u062a.\u200f"},
			@{NSLocaleCurrencyCode : @"TRY", NSLocaleCurrencySymbol : @"\u20ba"},
			@{NSLocaleCurrencyCode : @"MXV", NSLocaleCurrencySymbol : @""},
			@{NSLocaleCurrencyCode : @"ZMK", NSLocaleCurrencySymbol : @"ZK"},
			@{NSLocaleCurrencyCode : @"XDR", NSLocaleCurrencySymbol : @""},
			@{NSLocaleCurrencyCode : @"IEP", NSLocaleCurrencySymbol : @"£"},
			@{NSLocaleCurrencyCode : @"SHP", NSLocaleCurrencySymbol : @"£"},
			// TODO: Singular L(loti), plural M(Maloti) for LSL (Lesotho)
			@{NSLocaleCurrencyCode : @"LSL", NSLocaleCurrencySymbol : @"M"},
			@{NSLocaleCurrencyCode : @"ZWL", NSLocaleCurrencySymbol : @"$"},
			@{NSLocaleCurrencyCode : @"FKP", NSLocaleCurrencySymbol : @"£"},
			@{NSLocaleCurrencyCode : @"SVC", NSLocaleCurrencySymbol : @"₡"},
			@{NSLocaleCurrencyCode : @"CNH", NSLocaleCurrencySymbol : @"¥"},
			@{NSLocaleCurrencyCode : @"CLF", NSLocaleCurrencySymbol : @"UF"},
			@{NSLocaleCurrencyCode : @"MVR", NSLocaleCurrencySymbol : @"Rf"},
			@{NSLocaleCurrencyCode : @"XAG", NSLocaleCurrencySymbol : @"oz t"},
			@{NSLocaleCurrencyCode : @"XPD", NSLocaleCurrencySymbol : @"oz t"},
			@{NSLocaleCurrencyCode : @"XPT", NSLocaleCurrencySymbol : @"oz t"},
			@{NSLocaleCurrencyCode : @"XCP", NSLocaleCurrencySymbol : @"oz"},
			@{NSLocaleCurrencyCode : @"XAU", NSLocaleCurrencySymbol : @"oz t"},
			@{NSLocaleCurrencyCode : @"KPW", NSLocaleCurrencySymbol : @"₩"},
			@{NSLocaleCurrencyCode : @"XPF", NSLocaleCurrencySymbol : @"F"},
	];

	[exceptionList enumerateObjectsUsingBlock:^(NSDictionary *object, NSUInteger idx, BOOL *stop) {
		NSArray *fetched = [CurrencyRateItem MR_findByAttribute:@"currencyCode" withValue:object[NSLocaleCurrencyCode]];
		if ([fetched count]) {
			CurrencyRateItem *item = fetched[0];
			item.currencySymbol = object[NSLocaleCurrencySymbol];
		}
	}];

	NSArray *results = [CurrencyRateItem MR_findAll];
	for (CurrencyRateItem *entity in results) {
		NSLog(@"Code: %@, Country name %@, symbol = %@, name = %@", entity.currencyCode, entity.flagImageName, entity.currencySymbol, entity.name);
	}

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
			{@"ERN", @"Eritrea", @"YES"},
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
			{@"MXV", @"Mexico", @"YES"},
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
			{@"XAF", @"XAF", @"YES"},
			{@"XAG", @"XAG", @"NO"},
			{@"XAU", @"XAU", @"NO"},
			{@"XCP", @"XCP", @"NO"},
			{@"XCD", @"XCD", @"YES"},
			{@"XDR", @"XDR", @"YES"},
			{@"XEU", @"Europe", @"YES"},
			{@"XOF", @"XOF", @"YES"},
			{@"XPD", @"XPD", @"YES"},
			{@"XPF", @"XPF", @"YES"},
			{@"XPT", @"XPT", @"YES"},
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

	return countryName;
}

@end
