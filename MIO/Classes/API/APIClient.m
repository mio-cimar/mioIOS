//
//  APIClient.m
//  Mi Dash
//
//  Created by Ronny Libardo on 3/30/16.
//  Copyright © 2016 MIO. All rights reserved.
//

#import "APIClient.h"

static NSString * const MiDashAPIAddress            = @"http://dev-midash.lumenup.net";
static NSString * const ToyotaAPIAddress            = @"http://api.toyotacr.com/";              // Producción
static NSString * const ToyotaAPIAddressDev         = @"http://dev-api-purdy.lumenup.net/";     // Desarrollo
static NSString * const AppointmentsAPIAddressDev   = @"http://dev.toyotacitas.lotecito.com/";  // Desarrollo

@implementation APIClient

- (NSString *)constructServerEndpointWithPath:(NSString *)path {
    NSString *serverEndpoint = [NSString stringWithFormat:@"%@%@", self.baseURL, path];
    
    return serverEndpoint;
}

+ (NSString *)MiDashAPIAddress {
    return MiDashAPIAddress;
}

+ (NSString *)ToyotaAPIAddress {
    return ToyotaAPIAddress;
}

+ (NSString *)AppointmentsAPIAddress {
    return AppointmentsAPIAddressDev;
}

@end
