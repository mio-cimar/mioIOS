//
//  LocalForecastRegion.m
//  MIO
//
//  Created by Alonso Vega on 6/25/16.
//  Copyright © 2016 MIO CIMAR. All rights reserved.
//

#import "LocalForecastRegion.h"
#import "LocalForecast.h"
#import "MIOAPI.h"

NSString *const LocalForecastDataArrived                = @"LocalForecastDataArrived";
NSString *const LocalForecastDataRetrievalTimestampKey  = @"LocalForecastDataRetrievalTimestampKey";

@implementation LocalForecastRegion

@synthesize isPerformingFetch;

+ (NSString *)primaryKey {
    return @"identifier";
}
+ (NSArray *)ignoredProperties {
    return @[@"isPerformingFetch"];
}

+ (void)apiClient:(APIClient *)apiClient localForecastRegionsWithCallback:(void (^)(APIResponse *response))callback {
    [apiClient GET:@"/api/local_forecasts/"
        parameters:nil
           headers:nil
          progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        APIResponse *response   = [APIResponse new];
        response.success        = YES;
        response.statusCode     = APIResponseStatusCodeSuccess;
        response.mappedResponse = [responseObject objectForKey:@"results"];
        callback(response);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        APIResponse *response   = [APIResponse new];
        response.success        = NO;
        response.statusCode     = ((NSHTTPURLResponse *)task.response).statusCode ? ((NSHTTPURLResponse *)task.response).statusCode : error.code;
        
        callback(response);
    }];

//    [apiClient GET:@"/api/local_forecasts/" parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        APIResponse *response   = [APIResponse new];
//        response.success        = YES;
//        response.statusCode     = APIResponseStatusCodeSuccess;
//        response.mappedResponse = [responseObject objectForKey:@"results"];
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

+ (void)saveLocalForecastRegionsDictionaryRepresentationToStorage:(NSArray *)data {
    RLMRealm *realm = [RLMRealm defaultRealm];
    for (NSDictionary *item in data) {
        LocalForecastRegion *model = [[LocalForecastRegion alloc] init];
        model.identifier    = @([[item objectForKey:@"id"] integerValue]);
        model.name          = [item objectForKey:@"name"];
        model.comment       = [item objectForKey:@"comment"];
        model.englishName   = [item objectForKey:@"english_name"];
        model.mediumMapURL  = [item objectForKey:@"medium_map_url"];
        model.largeMapURL   = [item objectForKey:@"large_map_url"];
        model.mediumIcon    = [item objectForKey:@"medium_icon_url"];
        model.largeIcon     = [item objectForKey:@"large_icon_url"];
        model.wind          = [item objectForKey:@"wind_text"] != [NSNull null] ? [item objectForKey:@"wind_text"] : @"";
        model.swell         = [item objectForKey:@"wave_text"] != [NSNull null] ? [item objectForKey:@"wave_text"] : @"";
        model.temperature   = [item objectForKey:@"temp_text"] != [NSNull null] ? [item objectForKey:@"temp_text"] : @"";;
        model.saltiness     = [item objectForKey:@"salt_text"] != [NSNull null] ? [item objectForKey:@"salt_text"] : @"";;
        
        model.order         = @([[item objectForKey:@"taxonomy_id"] integerValue]);
        [realm beginWriteTransaction];
        [realm addOrUpdateObject:model];
        [realm commitWriteTransaction];
    }
}

- (void)apiClient:(APIClient *)apiClient localForecastWithCallback:(void (^)(APIResponse *response))callback {
    [apiClient GET:[NSString stringWithFormat:@"/api/local_forecasts/%@/weekly_view/", self.identifier]
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
    
//    [apiClient GET:[NSString stringWithFormat:@"/api/local_forecasts/%@/weekly_view/",
//                                   parameters:nil
//                                     progress:^(NSProgress * _Nonnull downloadProgress) {
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

+ (void)saveLocalForecastsDictionaryRepresentationToStorage:(NSArray *)data {

    RLMRealm *realm = [RLMRealm defaultRealm];
        for (NSDictionary *item in data) {
            LocalForecast *model = [[LocalForecast alloc] init];
            model.identifier        = @([[item objectForKey:@"id"] integerValue]);
            model.localForecast     = @([[item objectForKey:@"local_forecast"] integerValue]);
            model.wavePeriod        = [item objectForKey:@"wave_period"];
            model.waveHeight        = [item objectForKey:@"wave_height_sig"];
            model.waveHeightMax     = [item objectForKey:@"wave_height_max"];
            model.waveDirection     = [item objectForKey:@"wave_direction"];
            model.windBurst         = [item objectForKey:@"wind_burst"];
            model.windSpeed         = [item objectForKey:@"wind_speed"];
            model.windDirection     = [item objectForKey:@"wind_direction"];

            NSDateFormatter *formatter  = [[NSDateFormatter alloc] init] ;
            formatter.dateFormat        = @"yyyy-MM-dd'T'HH:mm:ssZ";
            //"2021-09-07T00:00:00-06:00"
            formatter.locale            = [NSLocale localeWithLocaleIdentifier:@"en_US"];
            formatter.timeZone          = [NSTimeZone timeZoneWithName:@"UTC"];

            model.date                  = [formatter dateFromString:item[@"date"]];
            [realm beginWriteTransaction];
            [realm addOrUpdateObject:model];
            [realm commitWriteTransaction];
        }
    [[NSNotificationCenter defaultCenter] postNotificationName:LocalForecastDataArrived object:nil userInfo:data.count ? @{ @"localForecast" : [[data firstObject] objectForKey:@"local_forecast" ] } : nil];
}

@end
