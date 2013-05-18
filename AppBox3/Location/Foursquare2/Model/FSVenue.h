//
//  VenueAnnotation.h
//  Foursquare2-iOS
//
//  Created by Constantine Fry on 1/21/13.
//
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface FSLocation : NSObject{
    CLLocationCoordinate2D _coordinate;
}

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSNumber*distance;
@property (nonatomic, strong) NSString*address;
@property (nonatomic, strong) NSString*city;
@property (nonatomic, strong) NSString*country;
@property (nonatomic, strong) NSString*state;
@property (nonatomic, strong) NSString*postalCode;

@end


@interface FSVenue : NSObject<MKAnnotation>

@property (nonatomic,assign) CLLocationCoordinate2D coordinate;
@property (nonatomic,strong)NSString*name;
@property (nonatomic,strong)NSString*venueId;
@property (nonatomic,strong)FSLocation*location;
@property (nonatomic,strong)NSString *contact;

@end
