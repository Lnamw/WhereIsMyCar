//
//  CarLocation.m
//  WhereIsMyCar
//
//  Created by Elena Maso Willen on 12/05/2016.
//  Copyright © 2016 Training. All rights reserved.
//

#import "CarLocation.h"

@implementation CarLocation


- (instancetype) initWithCoord:(CGPoint)coords latitude:(float)latitude longitude:(float)longitude {
    
    if (self = [super init]) {
        self.carCoords = coords;
        self.carCoordLat = latitude;
        self.carCoordLng = longitude;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    if (self = [super init]) {
        self.carCoords = [aDecoder decodeCGPointForKey:@"carLocationCoords"];
        self.carCoordLat = [aDecoder decodeFloatForKey:@"carLocationLat"];
        self.carCoordLng = [aDecoder decodeFloatForKey:@"carLocationLng"];
    }

    return self;
}


- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeCGPoint:self.carCoords forKey:@"carLocationCoords"];
    [aCoder encodeFloat:self.carCoordLat forKey:@"carLocationLat"];
    [aCoder encodeFloat:self.carCoordLng forKey:@"carLocationLng"];
        
}

@end
