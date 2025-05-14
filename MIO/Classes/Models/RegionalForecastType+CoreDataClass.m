//
//  RegionalForecastType+CoreDataClass.m
//  MIO
//
//  Created by Ronny Libardo on 10/5/16.
//  Copyright © 2016 MIO CIMAR. All rights reserved.
//

#import "RegionalForecastType+CoreDataClass.h"

#import "RegionalForecastTypeSlide+CoreDataClass.h"

#import "MIOAPI.h"

#import <MagicalRecord/MagicalRecord.h>

NSString *const RegionalForecastDataArrived                 = @"RegionalForecastDataArrived";
NSString *const RegionalForecastsDataRetrievalTimestampKey  = @"RegionalForecastsDataRetrievalTimestamp";

@implementation RegionalForecastType

+ (NSString *)primaryKey {
    return @"identifier";
}

+ (void)apiClient:(APIClient *)apiClient regionalForecastTypesWithCallback:(void (^)(APIResponse *response))callback {
    [apiClient GET:@"/api/regional_forecasts/" parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
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
}

+ (void)saveRegionalForecastTypesDictionaryRepresentationToStorage:(NSArray *)regionalForecastTypes {
    NSInteger regionalForecastTypeOrder = 0;
    RLMRealm *realm = [RLMRealm defaultRealm];
    for (NSDictionary *regionalForecastType in regionalForecastTypes) {
        RegionalForecastType *regionalForecastTypeModel = [[RegionalForecastType alloc] init];
        regionalForecastTypeModel.identifier    = @([[regionalForecastType objectForKey:@"id"] integerValue]);
        regionalForecastTypeModel.name          = [regionalForecastType objectForKey:@"name"];
        regionalForecastTypeModel.text          = [regionalForecastType objectForKey:@"text"];
        regionalForecastTypeModel.englishName   = [regionalForecastType objectForKey:@"english_name"];
        regionalForecastTypeModel.animation     = [regionalForecastType objectForKey:@"animation_url"];
        regionalForecastTypeModel.dateString    = [regionalForecastType objectForKey:@"date"];
        regionalForecastTypeModel.mediumIcon    = [regionalForecastType objectForKey:@"medium_icon_url"];
        regionalForecastTypeModel.largeIcon     = [regionalForecastType objectForKey:@"large_icon_url"];
        regionalForecastTypeModel.scaleBar      = [regionalForecastType objectForKey:@"scale_bar_url"];
        
        NSDateFormatter *formatter  = [[NSDateFormatter alloc] init] ;
        formatter.dateFormat        = @"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z";
        formatter.locale            = [NSLocale localeWithLocaleIdentifier:@"en_US"];
        formatter.timeZone          = [NSTimeZone timeZoneWithName:@"UTC"];
        
        regionalForecastTypeModel.date          = [formatter dateFromString:regionalForecastType[@"date"]];
        
        regionalForecastTypeModel.order         = @([[regionalForecastType objectForKey:@"taxonomy_id"] integerValue]);
        
        
        NSDictionary *slides = [regionalForecastType objectForKey:@"slides"];
        
        NSInteger regionalForecastTypeSlideOrder = 0;
        
        for (NSDictionary *slide in slides) {
            RegionalForecastTypeSlide *regionalForecastTypeSlideModel = [[RegionalForecastTypeSlide alloc] init];
            regionalForecastTypeSlideModel.identifier = [NSNumber numberWithInteger:[[slide objectForKey:@"id"] integerValue]];
            regionalForecastTypeSlideModel.image    = slide[@"url"];
            regionalForecastTypeSlideModel.date     = [formatter dateFromString:slide[@"date"]];
            regionalForecastTypeSlideModel.order    = @(regionalForecastTypeSlideOrder);
            [regionalForecastTypeModel.slides addObject:regionalForecastTypeSlideModel];
            regionalForecastTypeSlideOrder++;
        }
        [realm beginWriteTransaction];
        [realm addOrUpdateObject:regionalForecastTypeModel];
        [realm commitWriteTransaction];
        regionalForecastTypeOrder++;
    }
}

@end
