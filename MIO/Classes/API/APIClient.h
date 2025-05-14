//
//  APIClient.h
//  Mi Dash
//
//  Created by Ronny Libardo on 3/30/16.
//  Copyright © 2016 Jorge Leonardo Monge García. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

@interface APIClient : AFHTTPSessionManager

- (NSString *)constructServerEndpointWithPath:(NSString *)path;

+ (NSString *)MiDashAPIAddress;
+ (NSString *)ToyotaAPIAddress;
+ (NSString *)AppointmentsAPIAddress;

@end
