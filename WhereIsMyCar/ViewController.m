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



@end












