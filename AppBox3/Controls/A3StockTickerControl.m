//
//  A3StockTickerControl.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 11/22/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3StockTickerControl.h"
#import "AFJSONRequestOperation.h"
#import "common.h"

@interface A3StockTickerControl ()
	@property (nonatomic, strong) NSArray *stockExchangeArray;
@end

@implementation A3StockTickerControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#define YQL_URL_STRING_FOR_STOCK	@"http://query.yahooapis.com/v1/public/yql?q=%@%@"

- (void)startStockTickerAnimation {
	NSMutableString *symbols = [NSMutableString string];
	[symbols appendString:@"%5EIXIC,"];
	[symbols appendString:@"%5EGSPC,"];
	[symbols appendString:@"AAPL,"];
	[symbols appendString:@"GOOG,"];
	[symbols appendString:@"YHOO,"];
	[symbols appendString:@"MSFT,"];
	[symbols appendString:@"%5EFTSE,"];
	[symbols appendString:@"%5EGDAXI,"];
	[symbols appendString:@"%5EHSI,"];
	[symbols appendString:@"%5EN225"];
	NSString *yql = [NSString stringWithFormat:@"select * from csv where url='http://download.finance.yahoo.com/d/quotes.csv?s=%@&f=nsl1d1t1c1p2&e=.csv' and columns='Name,Symbol,Price,Date,Time,Change,PercentChange'", symbols];
	NSMutableString *paramString = [[NSMutableString alloc] initWithString:[yql stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	[paramString replaceOccurrencesOfString:@"/" withString:@"%2F" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [paramString length])];
	[paramString replaceOccurrencesOfString:@":" withString:@"%3A" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [paramString length])];
	[paramString replaceOccurrencesOfString:@"=" withString:@"%3D" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [paramString length])];
	[paramString replaceOccurrencesOfString:@"," withString:@"%2C" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [paramString length])];
	[paramString replaceOccurrencesOfString:@"?" withString:@"%3F" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [paramString length])];
	[paramString replaceOccurrencesOfString:@"&" withString:@"%26" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [paramString length])];

	NSMutableString *option = [[NSMutableString alloc] initWithString:@"&format=json&env=store://datatables.org/alltableswithkeys"];
	[option replaceOccurrencesOfString:@"/" withString:@"%2F" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [option length])];
	[option replaceOccurrencesOfString:@":" withString:@"%3A" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [option length])];

	NSString *urlString = [NSString stringWithFormat:YQL_URL_STRING_FOR_STOCK, paramString, option];
	FNLOG(@"%@", urlString);
	NSURL *url = [NSURL URLWithString:urlString];

	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
		FNLOG(@"%@", JSON);
		NSDictionary *query = [JSON objectForKey:@"query"];
		if (query) {
			NSDictionary *results = [ query objectForKey:@"results"];
			if (results && [results isKindOfClass:[NSDictionary class]]) {
				for (NSString *key in [results allKeys]) {
					if ([key isEqualToString:@"row"]) {
						_stockExchangeArray = [results objectForKey:@"row"];
						if (_stockExchangeArray) {
							[self startStockTicker];
						}
					}
				}
			}
		}
	} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
		FNLOG(@"fail to download stock: %@", response.debugDescription);
	}];

	[operation start];
}

- (void)startStockTicker {
	NSMutableArray *tickerItemsArray = [[NSMutableArray alloc] initWithCapacity:[self.stockExchangeArray count]*2];
	UIFont *tickerFont = [UIFont boldSystemFontOfSize:13.0];

	for (NSDictionary *stockInfo in self.stockExchangeArray) {
		NSString *titleString = [NSString stringWithFormat:@"%@  %@", [stockInfo objectForKey:@"Name"], [stockInfo objectForKey:@"Price"]];
		CGSize size = [titleString sizeWithFont:tickerFont];
		UILabel *stockTitle = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, size.width + 20.0f, 24.0f)];
		stockTitle.backgroundColor = [UIColor clearColor];
		stockTitle.text = titleString;
		stockTitle.font = tickerFont;
		stockTitle.textColor = [UIColor whiteColor];
		stockTitle.textAlignment = UITextAlignmentCenter;
		[tickerItemsArray addObject:stockTitle];

		BOOL increase = [[stockInfo objectForKey:@"Change"] floatValue] >= 0.0f;
		NSString *change = [NSString stringWithFormat:@"%@ %@ %@",
													  [stockInfo objectForKey:@"Change"],
													  increase ? @"▲":@"▼",
													  [stockInfo objectForKey:@"PercentChange"]];
		size = [change sizeWithFont:tickerFont];
		UILabel *stockValueChange = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, size.width + 10.0f, 24.0f)];
		stockValueChange.backgroundColor = [UIColor clearColor];
		stockValueChange.text = change;
		stockValueChange.textColor = increase ? [UIColor greenColor] : [UIColor redColor];
		stockValueChange.textAlignment = UITextAlignmentCenter;
		stockValueChange.font = tickerFont;
		[tickerItemsArray addObject:stockValueChange];
	}

	self.marqueeItems = tickerItemsArray;
	[self startAnimation];
}

@end
