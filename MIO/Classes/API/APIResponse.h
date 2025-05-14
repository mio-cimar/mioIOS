//
//  APIResponse.h
//  Mi Dash
//
//  Created by Ronny Bustos Jiménez on 18/4/16.
//  Copyright © 2016 Jorge Leonardo Monge García. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, APIResponseStatusCode) {
    APIResponseStatusCodeSuccess                = 200,
    APIResponseStatusCodeBadRequest             = 400,
    APIResponseStatusCodeUnauthorized           = 401,
    APIResponseStatusCodeNotFound               = 404,
    APIResponseStatusCodeInternalServerError    = 500,
    APIResponseStatusCodeCannotFindHost         = -1003,
    APIResponseStatusCodeCannotConnectToHost    = -1004,
    APIResponseStatusCodeConnectionLost         = -1005,
    APIResponseStatusCodeDNSLookupFailed        = -1006,
    APIResponseStatusCodeNotConnectedToInternet = -1009
};

@interface APIResponse : NSObject

@property   (nonatomic)         BOOL                    success;
@property   (nonatomic)         BOOL                    cachePresent;
@property   (nonatomic)         APIResponseStatusCode   statusCode;
@property   (strong, nonatomic) id                      mappedResponse;

@end
