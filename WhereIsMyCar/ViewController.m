//
//  ViewController.m
//  WhereIsMyCar
//
//  Created by Elena Maso Willen on 12/05/2016.
//  Copyright © 2016 Training. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "CarLocation.h"

@interface ViewController () <MKMapViewDelegate>

@property (strong, nonatomic) CLLocationManager *locMgr;
@property (assign, nonatomic) CGPoint userLocationCoord;
@property (strong, nonatomic) NSMutableArray *carLocationsArray;
@property (strong, nonatomic) CarLocation *userCarLocation;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

- (IBAction)setAPin:(id)sender;

- (IBAction)findCar:(id)sender;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    [self loadCarLocation];

}


- (void)viewDidAppear:(BOOL)animated {
    self.locMgr = [[CLLocationManager alloc] init];
    [self.locMgr requestWhenInUseAuthorization];
    self.mapView.delegate = self;
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
    [self.mapView setDelegate:self];
    
    CLLocationCoordinate2D locCoord = userLocation.coordinate;
    float x = locCoord.latitude;
    float y = locCoord.longitude;
    
    self.userLocationCoord = CGPointMake(x, y);
    
    NSLog(@"Lat: %f Lng: %f", locCoord.latitude, locCoord.longitude);
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 800, 800);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    
}


- (IBAction)setAPin:(id)sender {
    
    
    CLLocationCoordinate2D locCoord = CLLocationCoordinate2DMake(self.userLocationCoord.x, self.userLocationCoord.y);

    
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = locCoord;
    point.title = @"My car is here!";
    
    [self.mapView addAnnotation:point];
    
    self.userCarLocation = [[CarLocation alloc] initWithCoord:self.userLocationCoord latitude:self.userLocationCoord.x longitude:self.userLocationCoord.y];
    
    
    [self saveCarLocation];
    
}

- (IBAction)findCar:(id)sender {
    
    if (self.userCarLocation != nil) {
        float x = self.userCarLocation.carCoordLat;
        float y = self.userCarLocation.carCoordLng;
        
        CLLocationCoordinate2D locCoord = CLLocationCoordinate2DMake(x, y);

        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(locCoord, 800, 800);
        [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
        
        CLLocationCoordinate2D lineCoordinates[2] =
        {{self.userLocationCoord.x, self.userLocationCoord.y},
        {x, y}};
        
        MKPolyline *line = [MKPolyline polylineWithCoordinates:lineCoordinates count:2];
        [self.mapView addOverlay:line];
        [self.mapView setVisibleMapRect:line.boundingMapRect];
        

//        //Try to add direction but it's not that...
//        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:locCoord addressDictionary:nil];
//        
//        MKMapItem *destination = [[MKMapItem alloc] initWithPlacemark:placemark];
//        
//        MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
//        [request setSource:[MKMapItem mapItemForCurrentLocation]];
//        [request setDestination:destination];
//        [request setTransportType:MKDirectionsTransportTypeWalking];
//        [request setRequestsAlternateRoutes:YES];
//        MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
//        [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse * _Nullable response, NSError * _Nullable error) {
//            if (!error) {
//                for (MKRoute *route in [response routes]) {
//                    [self.mapView addOverlay:[route polyline] level:MKOverlayLevelAboveRoads];
//                }
//            }
//        }];
        
        
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Car not found!" message:@"Are you sure you came by car? If you took the tube, please check CittyMapper" preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}



#pragma  mark - Loading and saving

- (NSURL *)applicationDocumentDirectory {
    
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)saveCarLocation {
    
    NSString *path = [[self applicationDocumentDirectory].path stringByAppendingPathComponent:@"carLocation"];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.userCarLocation];
    [data writeToFile:path atomically:YES];
}

- (void)loadCarLocation {
    NSString *path = [[self applicationDocumentDirectory].path stringByAppendingPathComponent:@"carLocation"];
    
    NSData *locationData = [NSData dataWithContentsOfFile:path];
    self.userCarLocation = [NSKeyedUnarchiver unarchiveObjectWithData:locationData];
    
    
    
    CLLocationCoordinate2D locCoord = CLLocationCoordinate2DMake(self.userCarLocation.carCoordLat, self.userCarLocation.carCoordLng);
    
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = locCoord;
    point.title = @"My car is here!";
    
    [self.mapView addAnnotation:point];

}


- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolyline *route = overlay;
        MKPolylineRenderer *routeRenderer = [[MKPolylineRenderer alloc] initWithPolyline:route];
        routeRenderer.strokeColor = [[UIColor redColor] colorWithAlphaComponent:0.6];
        NSArray *pattern = @[@2, @5];
        [routeRenderer setLineDashPattern:pattern];
        [routeRenderer setLineWidth:3];
        return routeRenderer;
    } else {
        MKCircle *circle = overlay;
        MKCircleRenderer *routeRenderer = [[MKCircleRenderer alloc] initWithCircle:circle];
        
        routeRenderer.strokeColor = [[UIColor redColor] colorWithAlphaComponent:0.6];
        routeRenderer.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:0.6];
        [routeRenderer setLineWidth:2];
        return routeRenderer;
    }
    return nil;
}


@end












