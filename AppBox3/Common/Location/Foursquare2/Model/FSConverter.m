//
//  FSConverter.m
//  Foursquare2-iOS
//
//  Created by Constantine Fry on 2/7/13.
//
//

#import "FSConverter.h"
#import "FSVenue.h"
#import "NSString+conversion.h"

@implementation FSConverter

-(NSArray*)convertToObjects:(NSArray*)venues{
    NSMutableArray *objects = [NSMutableArray arrayWithCapacity:[venues count]];
    for (NSDictionary *v  in venues) {
		FNLOG(@"%@", v);
        FSVenue *ann = [[FSVenue alloc]init];
        ann.name = v[@"name"];
        ann.venueId = v[@"id"];
		ann.location.city = v[@"location"][@"city"];
		ann.location.country = v[@"location"][@"country"];
		ann.location.state = v[@"location"][@"state"];
		ann.location.postalCode = v[@"location"][@"postalCode"];
        ann.contact = v[@"contact"][@"formattedPhone"];
		FNLOG(@"%@", ann.contact);

        ann.location.address = v[@"location"][@"address"];
        ann.location.distance = v[@"location"][@"distance"];
        
        [ann.location setCoordinate:CLLocationCoordinate2DMake([v[@"location"][@"lat"] doubleValue],
                                                      [v[@"location"][@"lng"] doubleValue])];

		ann.location.address1 = ann.location.address;
		ann.location.address2 = [NSString combineString:[NSString combineString:ann.location.city withString:ann.location.state] withString:ann.location.postalCode];
		ann.location.address3 = ann.location.country;

        [objects addObject:ann];
    }
    return objects;
}

@end
