//
//  RegionalForecastType+CoreDataClass.m
//  MIO
//
//  Created by Ronny Libardo on 10/5/16.
//  Copyright © 2016 MIO CIMAR. All rights reserved.
//

#import "RegionalForecastType.h"
#import "RegionalForecastTypeSlide.h"
#import "MIOAPI.h"
#import <DateTools/DateTools.h>

NSString *const RegionalForecastDataArrived                 = @"RegionalForecastDataArrived";
NSString *const RegionalForecastsDataRetrievalTimestampKey  = @"RegionalForecastsDataRetrievalTimestamp";

@implementation RegionalForecastType

+ (NSString *)primaryKey {
    return @"identifier";
}

+ (void)apiClient:(APIClient *)apiClient regionalForecastTypesWithCallback:(void (^)(APIResponse *response))callback {
    
    [apiClient GET:@"/api/regional_forecasts/"
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
    
//    [apiClient GET:@"/api/regional_forecasts/" parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
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

+ (void)apiClient:(APIClient *)apiClient regionalForecastSlidesFor:(RegionalForecastType *)forecast with: (void (^)(APIResponse * _Nonnull))callback {
    NSDate *currentDate = [[NSCalendar currentCalendar] startOfDayForDate:[NSDate date]];
    NSDate *endDate = [[[NSCalendar currentCalendar] startOfDayForDate:[NSDate date]] dateByAddingWeeks:1];
    NSDateFormatter *formatter  = [[NSDateFormatter alloc] init] ;
    formatter.dateFormat        = @"yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z";
    formatter.locale            = [NSLocale localeWithLocaleIdentifier:@"en_US"];
    formatter.timeZone          = [NSTimeZone timeZoneWithName:@"UTC"];
    NSString *formattedStartDate= [formatter stringFromDate:currentDate];
    NSString *formattedEndDate  = [formatter stringFromDate:endDate];

    NSString *url = [@"/api/regional_forecasts/"stringByAppendingString: [NSString stringWithFormat:@"%ld/forecast_slides/?start=%@&end=%@/",
                                                                          (long)forecast.identifier.integerValue, formattedStartDate, formattedEndDate]];
    [apiClient GET:url
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
    
//    [apiClient GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
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

+ (void)saveRegionalForecastTypesDictionaryRepresentationToStorage:(NSArray *)regionalForecastTypes {
    NSInteger regionalForecastTypeOrder = 0;
    RLMRealm *realm = [RLMRealm defaultRealm];
    for (NSDictionary *regionalForecastType in regionalForecastTypes) {
        RegionalForecastType *regionalForecastTypeModel = [[RegionalForecastType alloc] init];
        regionalForecastTypeModel.identifier    = @([[regionalForecastType objectForKey:@"id"] integerValue]);
        regionalForecastTypeModel.name          = [regionalForecastType objectForKey:@"name"];
        regionalForecastTypeModel.text          = [regionalForecastType objectForKey:@"text"];
        regionalForecastTypeModel.spanishText   = [regionalForecastType objectForKey:@"spanish_text"];
        regionalForecastTypeModel.englishText   = [regionalForecastType objectForKey:@"english_text"];
        regionalForecastTypeModel.englishName   = [regionalForecastType objectForKey:@"english_name"];
        regionalForecastTypeModel.animation     = [regionalForecastType objectForKey:@"animation_url"];
        regionalForecastTypeModel.dateString    = [regionalForecastType objectForKey:@"date"];
        regionalForecastTypeModel.mediumIcon    = [regionalForecastType objectForKey:@"medium_icon_url"];
        regionalForecastTypeModel.largeIcon     = [regionalForecastType objectForKey:@"large_icon_url"];
        regionalForecastTypeModel.scaleBar      = [regionalForecastType objectForKey:@"scale_bar_url"];
        
        NSDateFormatter *formatter  = [[NSDateFormatter alloc] init] ;
        formatter.dateFormat        = @"yyyy-MM-dd'T'HH:mm:ssZ";
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

+ (void)saveRegionalForecastSlidesDictionaryRepresentationToStorage:(NSArray *)regionalForecastSlides
                                                               with: (void (^) (NSArray *slides))completion {
    NSMutableArray *slides = [[NSMutableArray alloc] init];
    NSDateFormatter *formatter  = [[NSDateFormatter alloc] init];
    formatter.dateFormat        = @"yyyy-MM-dd'T'HH:mm:ssZ";
    formatter.locale            = [NSLocale localeWithLocaleIdentifier:@"en_US"];
    formatter.timeZone          = [NSTimeZone timeZoneWithName:@"UTC"];
    NSInteger regionalForecastTypeSlideOrder = 0;
    for (NSDictionary *slide in regionalForecastSlides) {
        RegionalForecastTypeSlide *regionalForecastTypeSlideModel = [[RegionalForecastTypeSlide alloc] init];
        regionalForecastTypeSlideModel.identifier = [NSNumber numberWithInteger:[[slide objectForKey:@"id"] integerValue]];
        regionalForecastTypeSlideModel.image    = slide[@"url"];
        regionalForecastTypeSlideModel.date     = [formatter dateFromString:slide[@"date"]];
        regionalForecastTypeSlideModel.order    = @(regionalForecastTypeSlideOrder);
        [slides addObject:regionalForecastTypeSlideModel];
        regionalForecastTypeSlideOrder++;
    }
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm addOrUpdateObjects:slides];
    [realm commitWriteTransaction];
    completion(slides);
}

@end
