//
//  LocalForecast.m
//  MIO
//
//  Created by Alonso Vega on 6/25/16.
//  Copyright © 2016 MIO CIMAR. All rights reserved.
//

#import "LocalForecast.h"
#import "MIOAPI.h"
#import <DateTools/DateTools.h>

NSString * const DirectionN      = @"N";
NSString * const DirectionNNE    = @"NNE";
NSString * const DirectionNE     = @"NE";
NSString * const DirectionENE    = @"ENE";
NSString * const DirectionE      = @"E";
NSString * const DirectionESE    = @"ESE";
NSString * const DirectionSE     = @"SE";
NSString * const DirectionSSE    = @"SSE";
NSString * const DirectionS      = @"S";
NSString * const DirectionSSW    = @"SSW";
NSString * const DirectionSW     = @"SW";
NSString * const DirectionWSW    = @"WSW";
NSString * const DirectionW      = @"W";
NSString * const DirectionWNW    = @"WNW";
NSString * const DirectionNW     = @"NW";
NSString * const DirectionNNW    = @"NNW";

@implementation LocalForecast

@synthesize currentlyDisplayedPage;

+ (NSString *)primaryKey {
    return @"identifier";
}

+ (NSArray *)ignoredProperties {
    return @[@"currentlyDisplayedPage"];
}

+ (void)apiClient:(APIClient *)apiClient localForecastForRegion:(NSNumber *)regionIdentifier withCallback:(void (^)(APIResponse *response))callback {
    
    [apiClient GET:[NSString stringWithFormat:@"/api/local_forecasts/%@/weekly_view/", regionIdentifier]
        parameters:nil
           headers:nil
          progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        APIResponse *response   = [APIResponse new];
        response.success        = YES;
        response.statusCode     = APIResponseStatusCodeSuccess;
        response.mappedResponse = responseObject;
        
        callback(response);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        APIResponse *response   = [APIResponse new];
        response.success        = NO;
        response.statusCode     = ((NSHTTPURLResponse *)task.response).statusCode ? ((NSHTTPURLResponse *)task.response).statusCode : error.code;
        
        callback(response);
    }];

//    [apiClient GET:[NSString stringWithFormat:@"/api/local_forecasts/%@/weekly_view/", regionIdentifier] parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        APIResponse *response   = [APIResponse new];
//        response.success        = YES;
//        response.statusCode     = APIResponseStatusCodeSuccess;
//        response.mappedResponse = responseObject;
//        
//        callback(response);
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        APIResponse *response   = [APIResponse new];
//        response.success        = NO;
//        response.statusCode     = ((NSHTTPURLResponse *)task.response).statusCode ? ((NSHTTPURLResponse *)task.response).statusCode : error.code;
//        
//        callback(response);
//    }];
}

- (LocalForecastSwellAndWind)swellAndWind {
    CGFloat roundedWaveHeight   = round([self.waveHeight floatValue] * 10.0) / 10.0;
    CGFloat roundedWindSpeed    = round([self.windSpeed floatValue] * 10.0) / 10.0;
    
    if (roundedWindSpeed >= 40.0f && roundedWaveHeight > 2.5f) {
        return LocalForecastSwellAndWindRed2;
    }
    else if (roundedWindSpeed > 40.0f && roundedWindSpeed <= 50.0f && roundedWaveHeight >= 1.5f && roundedWaveHeight < 2.5f) {
        return LocalForecastSwellAndWindRed1;
    }
    else if (roundedWindSpeed > 30.0f && roundedWindSpeed <= 40.0f && roundedWaveHeight >= 2.0f && roundedWaveHeight < 4.5f) {
        return LocalForecastSwellAndWindYellow2; //NUEVO UMBRAL
    }
    else if (roundedWindSpeed > 30.0f && roundedWindSpeed <= 40.0f && roundedWaveHeight >= 1.0f && roundedWaveHeight < 2.0f) {
        return LocalForecastSwellAndWindYellow1;
    }
    else if (roundedWindSpeed > 20.0f && roundedWindSpeed <= 30.0f && roundedWaveHeight > 2.0f && roundedWaveHeight < 3.5f) {
        return LocalForecastSwellAndWindGreen2;
    }
    else if (roundedWindSpeed > 20.0f && roundedWindSpeed <= 30.0f && roundedWaveHeight >= 1.0f && roundedWaveHeight <= 2.0f) {
        return LocalForecastSwellAndWindGreen1;
    }
    else if (roundedWindSpeed >= 0.0f && roundedWindSpeed <= 20.0f && roundedWaveHeight >= 1.0f && roundedWaveHeight <= 3.5f) {
        return LocalForecastSwellAndWindLightBlue2;
    }
    else if (roundedWindSpeed >= 0.0f && roundedWindSpeed <= 20.0f && roundedWaveHeight < 1.0f) {
        return LocalForecastSwellAndWindLightBlue1;
    }
    
    return LocalForecastSwellAndWindNone;
}

- (LocalForecastBathingAndPorts)bathingAndPortsForRegion:(NSString *)region {
    if ([region isEqualToString:@"Caribe"]) {
        LocalForecastBathingAndPorts caribbeanBathingAndPorts = [self bathingAndPortsForCaribbean];
        
        return caribbeanBathingAndPorts;
    }
    else {
        LocalForecastBathingAndPorts pacificBathingAndPorts = [self bathingAndPortsForPacific];
        
        if (pacificBathingAndPorts == LocalForecastBathingAndPortsNone) {
            pacificBathingAndPorts = [self bathingAndPortsForCaribbean];
        }
        
        return pacificBathingAndPorts;
    }
    
    return LocalForecastBathingAndPortsNone;
}

- (LocalForecastBathingAndPorts)bathingAndPortsForCaribbean {
    CGFloat roundedWaveHeight   = round([self.waveHeight floatValue] * 10.0) / 10.0;
    
    if (roundedWaveHeight >= 3.0f) {
        return LocalForecastBathingAndPortsCaribbeanRed2;
    }
    else if (roundedWaveHeight > 2.7f && roundedWaveHeight < 3.0f) {
        return LocalForecastBathingAndPortsCaribbeanRed1;
    }
    else if (roundedWaveHeight >= 1.8f && roundedWaveHeight <= 2.7f) {
        return LocalForecastBathingAndPortsCaribbeanYellow;
    }
    else if (roundedWaveHeight >= 1.0f && roundedWaveHeight < 1.8f) {
        return LocalForecastBathingAndPortsCaribbeanGreen;
    }
    else if (roundedWaveHeight < 1.0f) {
        return LocalForecastBathingAndPortsCaribbeanLightBlue;
    }
    
    return LocalForecastBathingAndPortsNone;
}

- (LocalForecastBathingAndPorts)bathingAndPortsForPacific {
    CGFloat roundedWaveHeight   = round([self.waveHeight floatValue] * 10.0) / 10.0;
    CGFloat roundedWavePeriod   = round([self.wavePeriod floatValue] * 10.0) / 10.0;
    
    if (roundedWaveHeight > 2.3f && roundedWavePeriod >= 15) {
        return LocalForecastBathingAndPortsPacificRed;
    }
    else if (roundedWaveHeight > 1.8f && roundedWaveHeight <= 2.3f && roundedWavePeriod >= 15) {
        return LocalForecastBathingAndPortsPacificYellow;
    }
    else if (roundedWaveHeight >= 2.1f && roundedWavePeriod < 15) {//NUEVO UMBRAL AMARILLO
        return LocalForecastBathingAndPortsPacificYellow1;
    }
    else if (roundedWaveHeight >= 1.0f && roundedWaveHeight <= 1.8f && roundedWavePeriod >= 15) {
        return LocalForecastBathingAndPortsPacificGreen;
    }
    else if (roundedWaveHeight >= 0.75f && roundedWaveHeight < 2.1f && roundedWavePeriod < 15.0f) {
        return LocalForecastBathingAndPortsPacificLightBlue2;
    }
    else if (roundedWaveHeight < 1.0f && roundedWavePeriod < 20.0f) {
        return LocalForecastBathingAndPortsPacificLightBlue1;
    }
    
    return LocalForecastBathingAndPortsNone;
}

- (NSString *)waveDirectionText {
    double degrees = [self.waveDirection doubleValue];
    
    if (degrees < 0) {
        degrees = 360 + degrees;
        
    }
    else if (degrees > 360) {
        degrees = 360 - degrees;
    }
    
    if (degrees < 6.0 || degrees >= 354) {
        return DirectionS;
    } else if (degrees < 32) {
        return DirectionSSW;
    } else if (degrees < 58) {
        return DirectionSW;
    } else if (degrees < 84) {
        return DirectionWSW;
    } else if (degrees < 96) {
        return DirectionW;
    } else if (degrees < 122) {
        return DirectionWNW;
    } else if (degrees < 148) {
        return DirectionNW;
    } else if (degrees < 174) {
        return DirectionNNW;
    } else if (degrees < 186) {
        return DirectionN;
    } else if (degrees < 212) {
        return DirectionNNE;
    } else if (degrees < 238) {
        return DirectionNE;
    } else if (degrees < 264) {
        return DirectionENE;
    } else if (degrees < 276) {
        return DirectionE;
    } else if (degrees < 302) {
        return DirectionESE;
    } else if (degrees < 328) {
        return DirectionSE;
    } else if (degrees < 354) {
        return DirectionSSE;
    } else {
        return @"";
    }
}

- (NSString *)windDirectionText {
    double degrees = [self.windDirection doubleValue];
    
    if (degrees < 0) {
        degrees = 360 + degrees;
        
    }
    else if (degrees > 360) {
        degrees = 360 - degrees;
    }
    
    if (degrees < 11.25 || degrees >= 348.75) {
        return DirectionS;
    } else if (degrees < 33.75) {
        return DirectionSSW;
    } else if (degrees < 56.25) {
        return DirectionSW;
    } else if (degrees < 78.75) {
        return DirectionWSW;
    } else if (degrees < 101.25) {
        return DirectionW;
    } else if (degrees < 123.75) {
        return DirectionWNW;
    } else if (degrees < 146.25) {
        return DirectionNW;
    } else if (degrees < 168.75) {
        return DirectionNNW;
    } else if (degrees < 191.25) {
        return DirectionN;
    } else if (degrees < 213.75) {
        return DirectionNNE;
    } else if (degrees < 236.25) {
        return DirectionNE;
    } else if (degrees < 258.75) {
        return DirectionENE;
    } else if (degrees < 281.25) {
        return DirectionE;
    } else if (degrees < 303.75) {
        return DirectionESE;
    } else if (degrees < 326.25) {
        return DirectionSE;
    } else if (degrees < 348.75) {
        return DirectionSSE;
    } else {
        return @"";
    }
}

@end
