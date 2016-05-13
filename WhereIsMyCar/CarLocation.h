//
//  CarLocation.h
//  WhereIsMyCar
//
//  Created by Elena Maso Willen on 12/05/2016.
//  Copyright © 2016 Training. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface CarLocation : NSObject <NSCoding>

@property (assign, nonatomic) CGPoint carCoords;
@property (assign, nonatomic) float carCoordLat;
@property (assign, nonatomic) float carCoordLng;


- (instancetype) initWithCoord:(CGPoint)coords latitude:(float)latitude longitude:(float)longitude;





@end
