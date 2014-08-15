//
//  HolidayData+Country.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/26/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "HolidayData.h"
#import "HolidayData+Country.h"
#import "A3UIDevice.h"
#import "A3AppDelegate.h"
#import "A3UserDefaultsKeys.h"
#import "A3UserDefaults.h"

NSString *const kHolidayCountryCode = @"kHolidayCountryCode";
NSString *const kHolidayCapitalCityName = @"kHolidayCapitalCityName";
NSString *const kHolidayTimeZone = @"kHolidayTimeZone";
NSString *const kA3TimeZoneName = @"kA3TimeZoneName";

@implementation HolidayData (Country)

+ (NSArray *)supportedCountries {
	return @[
			@{
					kHolidayCountryCode : @"ar",
//					kHolidayCapitalCityName:@"Buenos Aires",
//					kHolidayTimeZone:@"ART",
					kA3TimeZoneName : @"America/Argentina/Buenos_Aires",
			},    // UTC-3
			@{
					kHolidayCountryCode : @"au",
//					kHolidayCapitalCityName:@"Canberra",
//					kHolidayTimeZone:@"",
					kA3TimeZoneName : @"Australia/Sydney",
			},    // UTC+10
			@{
					kHolidayCountryCode : @"at",
//					kHolidayCapitalCityName:@"Vienna",
//					kHolidayTimeZone:@"CET",
					kA3TimeZoneName : @"Europe/Vienna",
			},    // UTC+1
			@{
					kHolidayCountryCode : @"be",
//					kHolidayCapitalCityName:@"Brussels",
//					kHolidayTimeZone:@"CET",
					kA3TimeZoneName : @"Europe/Brussels"
			},    // UTC+1, CEST (UTC+2)
			@{
					kHolidayCountryCode : @"bw",
//					kHolidayCapitalCityName:@"Gaborone",
//					kHolidayTimeZone:@"CAT",
					kA3TimeZoneName : @"Africa/Gaborone"
			},    // UTC+2
			@{
					kHolidayCountryCode : @"br",
//					kHolidayCapitalCityName:@"Brasilia",
//					kHolidayTimeZone:@"BRT",
					kA3TimeZoneName : @"America/Sao_Paulo"
			},    // UTC-3
			@{    // Cameroon
					kHolidayCountryCode : @"cm",
//					kHolidayCapitalCityName:@"Yaoundé",
//					kHolidayTimeZone:@"WAT",
					kA3TimeZoneName : @"Africa/Douala"
			},    // West Africa Time, UTC+1
			@{
					kHolidayCountryCode : @"ca",
//					kHolidayCapitalCityName:@"Ottawa",
//					kHolidayTimeZone:@"EST",
					kA3TimeZoneName : @"America/Toronto"
			},    // Eastern Standard Time, -5
			@{
					kHolidayCountryCode : @"cf",
//					kHolidayCapitalCityName:@"Bangui",
//					kHolidayTimeZone:@"WAT",
					kA3TimeZoneName : @"Africa/Bangui"
			},    // UTC+1
			@{
					kHolidayCountryCode : @"cl",
//					kHolidayCapitalCityName:@"Santiago",
//					kHolidayTimeZone:@"CLT",
					kA3TimeZoneName : @"America/Santiago"
			},    // Chile Standard Time, UTC-4
			@{
					kHolidayCountryCode : @"cn",
//					kHolidayCapitalCityName:@"Beijing",
//					kHolidayTimeZone:@"",
					kA3TimeZoneName : @"Asia/Shanghai"
			},    // UTC+8
			@{
					kHolidayCountryCode : @"co",
//					kHolidayCapitalCityName:@"Bogota",
//					kHolidayTimeZone:@"COT",
					kA3TimeZoneName : @"America/Bogota"
			},    // UTC-5
			@{
					kHolidayCountryCode : @"hr",
//					kHolidayCapitalCityName:@"Zagreb",
//					kHolidayTimeZone:@"CET",
					kA3TimeZoneName : @"Europe/Zagreb"
			},    // UTC+1
			@{
					kHolidayCountryCode : @"cz",
//					kHolidayCapitalCityName:@"Prague",
//					kHolidayTimeZone:@"CET",
					kA3TimeZoneName : @"Europe/Prague"
			},    // UTC+1
			@{
					kHolidayCountryCode : @"dk",
//					kHolidayCapitalCityName:@"Copenhagen",
//					kHolidayTimeZone:@"CET",
					kA3TimeZoneName : @"Europe/Copenhagen"
			},    // UTC+1
			@{
					kHolidayCountryCode : @"do",
//					kHolidayCapitalCityName:@"Santo domingo",
//					kHolidayTimeZone:@"AST",
					kA3TimeZoneName : @"America/Santo_Domingo"
			},    // UTC-4
			@{
					kHolidayCountryCode : @"ec",
//					kHolidayCapitalCityName:@"Quito",
//					kHolidayTimeZone:@"EST",
					kA3TimeZoneName : @"America/Guayaquil"
			},    // UTC-5
			@{
					kHolidayCountryCode : @"eg",
//					kHolidayCapitalCityName:@"Cairo",
//					kHolidayTimeZone:@"EET",
					kA3TimeZoneName : @"Africa/Cairo"
			},    // UTC+2
			@{
					kHolidayCountryCode : @"sv",
//					kHolidayCapitalCityName:@"San Salvador",
//					kHolidayTimeZone:@"CST",
					kA3TimeZoneName : @"America/El_Salvador"
			},    // UTC-6
			@{
					kHolidayCountryCode : @"gq",
//					kHolidayCapitalCityName:@"Malabo",
//					kHolidayTimeZone:@"WAT",
					kA3TimeZoneName : @"Africa/Malabo"
			},    // UTC+1
//			@"ee", @"fi", @"fr", @"de", @"gr", @"gt", @"gn", @"gw", @"hn", @"hk", // 30
			@{// Estonia
					kHolidayCountryCode : @"ee",
					kA3TimeZoneName : @"Europe/Tallinn"
			},    // UTC+1
			@{// Finland
					kHolidayCountryCode : @"fi",
					kA3TimeZoneName : @"Europe/Helsinki"
			},    // UTC+1
			@{
					kHolidayCountryCode : @"fr",
					kA3TimeZoneName : @"Europe/Paris"
			},    // UTC+1
			@{
					kHolidayCountryCode : @"de",
					kA3TimeZoneName : @"Europe/Berlin"
			},    // UTC+1
			@{
					kHolidayCountryCode : @"gr",
					kA3TimeZoneName : @"Europe/Athens"
			},    // UTC+1
			@{
					kHolidayCountryCode : @"gt",
					kA3TimeZoneName : @"America/Guatemala"
			},    // UTC+1
			@{
					kHolidayCountryCode : @"gn",
					kA3TimeZoneName : @"Africa/Conakry"
			},    // UTC+1
			@{
					kHolidayCountryCode : @"gw",
					kA3TimeZoneName : @"Africa/Bissau"
			},    // UTC+1
			@{
					kHolidayCountryCode : @"hn",
					kA3TimeZoneName : @"America/Tegucigalpa"
			},    // UTC+1
			@{
					kHolidayCountryCode : @"hk",
					kA3TimeZoneName : @"Asia/Hong_Kong"
			},    // UTC+1
			@{
					kHolidayCountryCode : @"hu",
//					kHolidayCapitalCityName:@"Budapest",
//					kHolidayTimeZone:@"CET",
					kA3TimeZoneName : @"Europe/Budapest"
			},    // UTC+1
			@{
					kHolidayCountryCode : @"id",
//					kHolidayCapitalCityName:@"Jakarta",
//					kHolidayTimeZone:@"WIT",
					kA3TimeZoneName : @"Asia/Jakarta"
			},    // UTC+7
			@{
					kHolidayCountryCode : @"ie",
//					kHolidayCapitalCityName : @"Dublin",
//					kHolidayTimeZone : @"WET",
					kA3TimeZoneName : @"Europe/Dublin",
			},    // UTC+0
			@{
					kHolidayCountryCode : @"it",
//					kHolidayCapitalCityName : @"Rome",
//					kHolidayTimeZone : @"CET",
					kA3TimeZoneName : @"Europe/Rome",
			},    // UTC+1
			@{	// Ivory Coast or Côte d'Ivoire
					kHolidayCountryCode : @"ci",
//					kHolidayCapitalCityName : @"Yamoussoukro",
//					kHolidayTimeZone : @"GMT",
					kA3TimeZoneName : @"Africa/Abidjan",
			},
			@{
					kHolidayCountryCode : @"jm",
//					kHolidayCapitalCityName : @"Kingston",
//					kHolidayTimeZone : @"EST",
					kA3TimeZoneName : @"America/Jamaica",
			},    // UTC-5
			@{
					kHolidayCountryCode : @"jp",
//					kHolidayCapitalCityName : @"Tokyo",
//					kHolidayTimeZone : @"JST",
					kA3TimeZoneName : @"Asia/Tokyo",
			},    // UTC+9
			@{
					kHolidayCountryCode : @"il",
//					kHolidayCapitalCityName : @"Jerusalem",
//					kHolidayTimeZone : @"EET",
					kA3TimeZoneName : @"Asia/Jerusalem",
			},    // UTC+2
			@{
					kHolidayCountryCode : @"jo",
//					kHolidayCapitalCityName : @"Amman",
//					kHolidayTimeZone : @"EAT",
					kA3TimeZoneName : @"Asia/Amman",
			},    // UTC+3
			@{
					kHolidayCountryCode : @"ke",
//					kHolidayCapitalCityName : @"Nairobi",
//					kHolidayTimeZone : @"EAT",
					kA3TimeZoneName : @"Africa/Nairobi",
			},    // UTC+3
			@{
					kHolidayCountryCode : @"lv",
//					kHolidayCapitalCityName : @"Riga",
//					kHolidayTimeZone : @"EET",
					kA3TimeZoneName : @"Europe/Riga",
			},    // UTC+2
			@{
					kHolidayCountryCode : @"li",
//					kHolidayCapitalCityName : @"Vaduz",
//					kHolidayTimeZone : @"CET",
					kA3TimeZoneName : @"Europe/Vaduz",
			},    // UTC+1
			@{
					kHolidayCountryCode : @"lt",
//					kHolidayCapitalCityName : @"Vilnius",
//					kHolidayTimeZone : @"EET",
					kA3TimeZoneName : @"Europe/Vilnius",
			},    // UTC+2
			@{
					kHolidayCountryCode : @"lu",
//					kHolidayCapitalCityName : @"Luxembourg",
//					kHolidayTimeZone : @"CET",
					kA3TimeZoneName : @"Europe/Luxembourg",
			},    // UTC+1
			@{kHolidayCountryCode : @"mo",
//					kHolidayCapitalCityName : @"Macau",
//					kHolidayTimeZone : @"",
					kA3TimeZoneName : @"Asia/Macau",
			},    // UTC+8
			@{
					kHolidayCountryCode : @"mg",
//					kHolidayCapitalCityName : @"Antananarivo",
//					kHolidayTimeZone : @"EAT",
					kA3TimeZoneName : @"Indian/Antananarivo",
			},    // UTC+3
			@{kHolidayCountryCode : @"ml",
//					kHolidayCapitalCityName : @"Bamako",
//					kHolidayTimeZone : @"GMT",
					kA3TimeZoneName : @"Africa/Bamako",
			},
			@{
					kHolidayCountryCode : @"mt",
//					kHolidayCapitalCityName : @"Valletta",
//					kHolidayTimeZone : @"CET",
					kA3TimeZoneName : @"Europe/Malta",
			},    // UTC+1
			@{
					kHolidayCountryCode : @"mu",
//					kHolidayCapitalCityName : @"Port Louis",
//					kHolidayTimeZone : @"",
					kA3TimeZoneName : @"Indian/Mauritius",
			},    // UTC+4
			@{
					kHolidayCountryCode : @"mx",
//					kHolidayCapitalCityName : @"Mexico City",
//					kHolidayTimeZone : @"CST",
					kA3TimeZoneName : @"America/Mexico_City",
			},    // UTC-6
			@{
					kHolidayCountryCode : @"md",
//					kHolidayCapitalCityName : @"Chisinau",
//					kHolidayTimeZone : @"EET",
					kA3TimeZoneName : @"Europe/Chisinau",
			},    // UTC+2
			@{
					kHolidayCountryCode : @"nl",
//					kHolidayCapitalCityName : @"Amsterdam",
//					kHolidayTimeZone : @"CET",
					kA3TimeZoneName : @"Europe/Amsterdam",
			},    // UTC+1
			@{
					kHolidayCountryCode : @"nz",
//					kHolidayCapitalCityName : @"Wellington",
//					kHolidayTimeZone : @"NZST",
					kA3TimeZoneName : @"Pacific/Auckland",
			},    // UTC+12
			@{
					kHolidayCountryCode : @"ni",
//					kHolidayCapitalCityName : @"Managua",
//					kHolidayTimeZone : @"CST",
					kA3TimeZoneName : @"America/Managua",
			},    // UTC-6
			@{
					kHolidayCountryCode : @"ne",
//					kHolidayCapitalCityName : @"Niamey",
//					kHolidayTimeZone : @"WAT",
					kA3TimeZoneName : @"Africa/Niamey",
			},    // UTC+1
			@{
					kHolidayCountryCode : @"no",
//					kHolidayCapitalCityName : @"Oslo",
//					kHolidayTimeZone : @"CET",
					kA3TimeZoneName : @"Europe/Oslo",
			},    // UTC+1
			@{
					kHolidayCountryCode : @"pa",
//					kHolidayCapitalCityName : @"Panama City",
//					kHolidayTimeZone : @"EST",
					kA3TimeZoneName : @"America/Panama",
			},    // UTC-5
			@{
					kHolidayCountryCode : @"py",
//					kHolidayCapitalCityName : @"Asuncion",
//					kHolidayTimeZone : @"AST",
					kA3TimeZoneName : @"America/Asuncion",
			},    // UTC-4
			@{
					kHolidayCountryCode : @"pe",
//					kHolidayCapitalCityName : @"Lima",
//					kHolidayTimeZone : @"PET",
					kA3TimeZoneName : @"America/Lima",
			},    // UTC-5
			@{
					kHolidayCountryCode : @"ph",
//					kHolidayCapitalCityName : @"Manila",
//					kHolidayTimeZone : @"",
					kA3TimeZoneName : @"Asia/Manila",
			},    // UTC+8
			@{
					kHolidayCountryCode : @"pl",
//					kHolidayCapitalCityName : @"Warsaw",
//					kHolidayTimeZone : @"CET",
					kA3TimeZoneName : @"Europe/Warsaw",
			},    // UTC+1
			@{
					kHolidayCountryCode : @"pt",
//					kHolidayCapitalCityName : @"Lisbon",
//					kHolidayTimeZone : @"WET",
					kA3TimeZoneName : @"Europe/Lisbon",
			},    // UTC+0
			@{
					kHolidayCountryCode : @"pr",
//					kHolidayCapitalCityName : @"San Juan",
//					kHolidayTimeZone : @"AST",
					kA3TimeZoneName : @"America/Puerto_Rico",
			},    // UTC-4
			@{
					kHolidayCountryCode : @"qa",
//					kHolidayCapitalCityName : @"Doha",
//					kHolidayTimeZone : @"EAT",
					kA3TimeZoneName : @"Asia/Qatar",
			},    // UTC+3
			@{
					kHolidayCountryCode : @"kr",
//					kHolidayCapitalCityName : @"Seoul",
//					kHolidayTimeZone : @"KST",
					kA3TimeZoneName : @"Asia/Seoul",
			},    // UTC+9
			@{
					kHolidayCountryCode : @"re",
//					kHolidayCapitalCityName : @"Saint-denis",
//					kHolidayTimeZone : @"",
					kA3TimeZoneName : @"Indian/Reunion",
			},    // UTC+4
			@{
					kHolidayCountryCode : @"ro",
//					kHolidayCapitalCityName : @"Bucharest",
//					kHolidayTimeZone : @"EET",
					kA3TimeZoneName : @"Europe/Bucharest",
			},    // UTC+2
			@{
					kHolidayCountryCode : @"ru",
//					kHolidayCapitalCityName : @"Moscow",
//					kHolidayTimeZone : @"MSK",
					kA3TimeZoneName : @"Europe/Moscow",
			},    // UTC+4
			@{
					kHolidayCountryCode : @"sa",
//					kHolidayCapitalCityName : @"Riyadh",
//					kHolidayTimeZone : @"EAT",
					kA3TimeZoneName : @"Asia/Riyadh",
			},    // UTC+3
			@{
					kHolidayCountryCode : @"sn",
//					kHolidayCapitalCityName : @"Dakar",
//					kHolidayTimeZone : @"UTC",
					kA3TimeZoneName : @"Africa/Dakar",
			},
			@{
					kHolidayCountryCode : @"sg",
//					kHolidayCapitalCityName : @"Singapore",
//					kHolidayTimeZone : @"SGT",
					kA3TimeZoneName : @"Asia/Singapore",
			},    // UTC+8
			@{
					kHolidayCountryCode : @"sk",
//					kHolidayCapitalCityName : @"Bratislava",
//					kHolidayTimeZone : @"CET",
					kA3TimeZoneName : @"Europe/Bratislava",
			},    // UTC+1
			@{
					kHolidayCountryCode : @"za",
//					kHolidayCapitalCityName : @"Cape Town",
//					kHolidayTimeZone : @"EET",
					kA3TimeZoneName : @"Africa/Johannesburg",
			},    // UTC+2
			@{
					kHolidayCountryCode : @"es",
//					kHolidayCapitalCityName : @"Madrid",
//					kHolidayTimeZone : @"CET",
					kA3TimeZoneName : @"Europe/Madrid",
			},    // UTC+1
			@{
					kHolidayCountryCode : @"se",
//					kHolidayCapitalCityName : @"Stockholm",
//					kHolidayTimeZone : @"CET",
					kA3TimeZoneName : @"Europe/Stockholm",
			},    // UTC+1
			@{
					kHolidayCountryCode : @"ch",
//					kHolidayCapitalCityName : @"Bern",
//					kHolidayTimeZone : @"CET",
					kA3TimeZoneName : @"Europe/Zurich",
			},    // UTC+1
			@{
					kHolidayCountryCode : @"tw",
//					kHolidayCapitalCityName : @"Taipei",
//					kHolidayTimeZone : @"",
					kA3TimeZoneName : @"Asia/Taipei",
			},    // UTC+8
			@{
					kHolidayCountryCode : @"tr",
//					kHolidayCapitalCityName : @"Ankara",
//					kHolidayTimeZone : @"EET",
					kA3TimeZoneName : @"Europe/Istanbul",
			},    // UTC+2
			@{
					kHolidayCountryCode : @"ae",
//					kHolidayCapitalCityName : @"Abu Dhabi",
//					kHolidayTimeZone : @"GST",
					kA3TimeZoneName : @"Asia/Dubai",
			},    // UTC+4
			@{
					kHolidayCountryCode : @"gb",
//					kHolidayCapitalCityName : @"London",
//					kHolidayTimeZone : @"GMT",
					kA3TimeZoneName : @"Europe/London",
			},
			@{
					kHolidayCountryCode : @"uy",
//					kHolidayCapitalCityName : @"Montevideo",
//					kHolidayTimeZone : @"",
					kA3TimeZoneName : @"America/Montevideo",
			},    // UTC-3
			@{
					kHolidayCountryCode : @"us",
//					kHolidayCapitalCityName : @"WashingtonDC",
//					kHolidayTimeZone : @"EST",
					kA3TimeZoneName : @"America/New_York",
			},    // UTC-5
			@{
					kHolidayCountryCode : @"vi",
//					kHolidayCapitalCityName : @"Charlotte Amalie",
//					kHolidayTimeZone : @"EAT",
					kA3TimeZoneName : @"America/St_Thomas",
			},    // UTC+3
			@{
					kHolidayCountryCode : @"ve",
//					kHolidayCapitalCityName : @"Caracas",
//					kHolidayTimeZone : @"AST",
					kA3TimeZoneName : @"America/Caracas",
			},    // UTC-4:30 (Not exactly AST)
			@{
					kHolidayCountryCode : @"my",
//					kHolidayCapitalCityName : @"Kuala Lumpur",
//					kHolidayTimeZone : @"",
					kA3TimeZoneName : @"Asia/Kuala_Lumpur",
			},    // UTC+8
			@{
					kHolidayCountryCode : @"cr",
//					kHolidayCapitalCityName : @"San Jose",
//					kHolidayTimeZone : @"CST",
					kA3TimeZoneName : @"America/Costa_Rica",
			},    // UTC-6
			@{
					kHolidayCountryCode : @"in",
//					kHolidayCapitalCityName : @"New Delhi",
//					kHolidayTimeZone : @"IST",
					kA3TimeZoneName : @"Asia/Kolkata",
			},    // UTC+5:30
			@{
					kHolidayCountryCode : @"ht",
//					kHolidayCapitalCityName : @"Port-au-Prince",
//					kHolidayTimeZone : @"EST",
					kA3TimeZoneName : @"America/Port-au-Prince",
			},    // Eastern Time Zone, UTC-5, Eastern Daylight Time (UTC-4)
			@{
					kHolidayCountryCode : @"kw",
//					kHolidayCapitalCityName : @"Kuwait City",
//					kHolidayTimeZone : @"EAT",
					kA3TimeZoneName : @"Asia/Kuwait",
			},    // UTC+3
			@{
					kHolidayCountryCode : @"ua",
//					kHolidayCapitalCityName : @"Kiev",
//					kHolidayTimeZone : @"EET",
					kA3TimeZoneName : @"Europe/Kiev",
			},    // UTC+2
			@{
					kHolidayCountryCode : @"mk",
//					kHolidayCapitalCityName : @"Skopje",
//					kHolidayTimeZone : @"CET",
					kA3TimeZoneName : @"Europe/Skopje",
			},    // Central European Time, UTC+1
			@{
					kHolidayCountryCode : @"et",
//					kHolidayCapitalCityName : @"Addis Ababa",
//					kHolidayTimeZone : @"EAT",
					kA3TimeZoneName : @"Africa/Addis_Ababa",
			},    // UTC+3, East Africa Time
			@{
					kHolidayCountryCode : @"bd",
//					kHolidayCapitalCityName : @"Dhaka",
//					kHolidayTimeZone : @"BST",
					kA3TimeZoneName : @"Asia/Dhaka",
			},    // UTC+6, Bangladesh Standard Time
			@{
					kHolidayCountryCode : @"bg",
//					kHolidayCapitalCityName : @"Sofia",
//					kHolidayTimeZone : @"EET",
					kA3TimeZoneName : @"Europe/Sofia",
			},    // Eastern European Time, UTC+2, EEST(SummerTime)UTC+3
			@{
					kHolidayCountryCode : @"bs",
//					kHolidayCapitalCityName : @"Nassau",
//					kHolidayTimeZone : @"EST",
					kA3TimeZoneName : @"America/Nassau",
			},    // UTC-5
			@{
					kHolidayCountryCode : @"pk",
//					kHolidayCapitalCityName : @"Islamabad",
//					kHolidayTimeZone : @"PKT",
					kA3TimeZoneName : @"Asia/Karachi",
			},    // Pakistan Standard Time, UTC+5
			@{
					kHolidayCountryCode : @"th",
//					kHolidayCapitalCityName : @"Bangkok",
//					kHolidayTimeZone : @"ICT",
					kA3TimeZoneName : @"Asia/Bangkok",
			},    // UTC+7, Indochina Time
			@{
					kHolidayCountryCode : @"mz",
//					kHolidayCapitalCityName : @"Maputo",
//					kHolidayTimeZone : @"CAT",
					kA3TimeZoneName : @"Africa/Maputo",
			},    // UTC+2, Central Africa Time

//			@"ar", @"au", @"at", @"be", @"bw", @"br", @"cm", @"ca", @"cf", @"cl", // 10
//			@"cn", @"co", @"hr", @"cz", @"dk", @"do", @"ec", @"eg", @"sv", @"gq", // 20
//			@"ee", @"fi", @"fr", @"de", @"gr", @"gt", @"gn", @"gw", @"hn", @"hk", // 30
//			@"hu", @"id", @"ie", @"it", @"ci", @"jm", @"jp", @"il", @"jo", @"ke", // 40
//			@"lv", @"li", @"lt", @"lu", @"mo", @"mg", @"ml", @"mt", @"mu", @"mx", // 50
//			@"md", @"nl", @"nz", @"ni", @"ne", @"no", @"pa", @"py", @"pe", @"ph", // 60
//			@"pl", @"pt", @"pr", @"qa", @"kr", @"re", @"ro", @"ru", @"sa", @"sn", // 70
//			@"sg", @"sk", @"za", @"es", @"se", @"ch", @"tw", @"tr", @"ae", @"gb", // 80
//			@"uy", @"us", @"vi", @"ve", @"my", @"cr", @"in", @"ht", @"kw", @"ua", // 90
//			@"mk", @"et", @"bd", @"bg", @"bs", @"pk", @"th", @"mz",
	];
}

- (NSMutableArray *)holidaysForCountry:(NSString *)countryCode year:(NSUInteger)year fullSet:(BOOL)fullSet {
	self.year = year;
	NSMutableArray *holidays = [self valueForKeyPath:[NSString stringWithFormat:@"%@_HolidaysInYear", [countryCode lowercaseString]]];
	if (!fullSet) {
		NSArray *excludedHoliday = [[A3UserDefaults standardUserDefaults] objectForKey:[[self class] keyForExcludedHolidaysForCountry:countryCode]];
		NSMutableArray *needToDelete = [NSMutableArray new];
		for (NSDictionary *item in holidays) {
			if ([excludedHoliday containsObject:item[kHolidayName]]) {
				[needToDelete addObject:item];
			}
		}
		[holidays removeObjectsInArray:needToDelete];
	}
	[holidays sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		return [obj1[kHolidayDate] compare:obj2[kHolidayDate]];
	}];
	return holidays;
}

+ (NSArray *)userSelectedCountries {
	NSArray *countries = [[A3UserDefaults standardUserDefaults] objectForKey:kHolidayCountriesForCurrentDevice];
	if (!countries) {

		countries = @[@"us", @"kr", @"jp", @"gb"];

		NSString *systemCountry = [[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode] lowercaseString];

		if (![countries containsObject:systemCountry]) {
			countries = [@[systemCountry] arrayByAddingObjectsFromArray:countries];
		} else {
			NSMutableArray *mutableCountries = [countries mutableCopy];
			[mutableCountries removeObject:systemCountry];
			[mutableCountries insertObject:systemCountry atIndex:0];
			countries = [[NSArray alloc] initWithArray:mutableCountries];
		}
		[[A3UserDefaults standardUserDefaults] setObject:countries forKey:kHolidayCountriesForCurrentDevice];
		[[A3UserDefaults standardUserDefaults] synchronize];
	}
	return countries;
}

+ (void)setUserSelectedCountries:(NSArray *)newData {
	[[A3UserDefaults standardUserDefaults] setObject:newData forKey:kHolidayCountriesForCurrentDevice];
	[[A3UserDefaults standardUserDefaults] synchronize];
}

+ (NSInteger)thisYear {
	NSCalendar *gregorian = [[A3AppDelegate instance] calendar];;
	NSDateComponents *components = [gregorian components:NSYearCalendarUnit fromDate:[NSDate date]];
	return [components year];
}

+ (id)keyForExcludedHolidaysForCountry:(NSString *)countryCode {
	return [NSString stringWithFormat:@"%@%@", kHolidayCountryExcludedHolidays, countryCode];
}

+ (NSArray *)candidateForLunarDates {
	return @[@"kr", @"cn", @"hk", @"tw", @"sg", @"mo"];
}

+ (NSMutableArray *)arrayOfShowingLunarDates {
	NSArray *array = [[A3UserDefaults standardUserDefaults] objectForKey:kHolidayCountriesShowLunarDates];
	if (!array) {
		array = [HolidayData candidateForLunarDates];
		[[A3UserDefaults standardUserDefaults] setObject:array forKey:kHolidayCountriesShowLunarDates];
		[[A3UserDefaults standardUserDefaults] synchronize];
	}
	return [array mutableCopy];
}

+ (BOOL)needToShowLunarDatesForCountryCode:(NSString *)countryCode {
	NSMutableArray *array = [HolidayData arrayOfShowingLunarDates];
	return [array containsObject:countryCode];
}

+ (BOOL)needToShowLunarDatesOptionMenuForCountryCode:(NSString *)countryCode {
	return [[HolidayData candidateForLunarDates] containsObject:countryCode];
}

+ (void)addCountryToShowLunarDatesSet:(NSString *)countryCode {
	NSMutableArray *array = [HolidayData arrayOfShowingLunarDates];
	if (![array containsObject:countryCode]) {
		[array addObject:countryCode];
		[[A3UserDefaults standardUserDefaults] setObject:array forKey:kHolidayCountriesShowLunarDates];
		[[A3UserDefaults standardUserDefaults] synchronize];
	}
}

+ (void)removeCountryFromShowLunarDatesSet:(NSString *)countryCode {
	NSMutableArray *array = [HolidayData arrayOfShowingLunarDates];
	if ([array containsObject:countryCode]) {
		[array removeObject:countryCode];
		[[A3UserDefaults standardUserDefaults] setObject:array forKey:kHolidayCountriesShowLunarDates];
		[[A3UserDefaults standardUserDefaults] synchronize];
	}
}

+ (NSTimeZone *)timeZoneForCountryCode:(NSString *)countryCode {
	NSArray *countries = [HolidayData supportedCountries];
	for (NSDictionary *obj in countries) {
		if ([obj[kHolidayCountryCode] isEqualToString:countryCode]) {
			return [NSTimeZone timeZoneWithName:obj[kA3TimeZoneName]];
		}
	}
	return nil;
}

- (NSUInteger)indexForUpcomingFirstHolidayInHolidays:(NSArray *)holidays {
	NSUInteger upcomingHolidayIndex = [holidays indexOfObjectPassingTest:^BOOL(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
		return [[NSDate date] compare:obj[kHolidayDate]] == NSOrderedAscending;
	}];
	return upcomingHolidayIndex;
}

- (NSDictionary *)firstUpcomingHolidaysForCountry:(NSString *)countryCode {
	NSInteger thisYear;
	NSCalendar *gregorian = [[A3AppDelegate instance] calendar];
	NSDateComponents *components = [gregorian components:NSYearCalendarUnit fromDate:[NSDate date]];
	thisYear = [components year];
	NSMutableArray *holidaysThisYear = [self holidaysForCountry:countryCode year:thisYear fullSet:NO ];

	NSUInteger indexForFirstUpcomingHoliday = [self indexForUpcomingFirstHolidayInHolidays:holidaysThisYear];
	if (indexForFirstUpcomingHoliday == NSNotFound) {
		holidaysThisYear = [self holidaysForCountry:countryCode year:thisYear + 1 fullSet:NO];
		indexForFirstUpcomingHoliday = [self indexForUpcomingFirstHolidayInHolidays:holidaysThisYear];
	}
	if (indexForFirstUpcomingHoliday != NSNotFound) {
		return holidaysThisYear[indexForFirstUpcomingHoliday];
	}
	return nil;
}

@end
