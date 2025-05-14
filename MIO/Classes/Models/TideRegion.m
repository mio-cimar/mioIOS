//
//  TideRegion+CoreDataClass.m
//  MIO
//
//  Created by Ronny Libardo on 9/29/16.
//  Copyright © 2016 MIO CIMAR. All rights reserved.
//

#import "TideRegion.h"
#import "TideEntry.h"
#import "TideEntrySearchResult.h"
#import "MIOAPI.h"
#import <DateTools/DateTools.h>

NSString *const TideEntryDataArrived                    = @"TideEntryDataArrived";
NSString *const TideRegionsDataRetrievalTimestampKey    = @"TideRegionsDataRetrievalTimestampKey";

@implementation TideRegion

@synthesize isPerformingFetch;

+ (NSString *)primaryKey {
    return @"identifier";
}

+ (NSArray *)ignoredProperties {
    return @[@"isPerformingFetch"];
}

+ (void)apiClient:(APIClient *)apiClient tideRegionsWithCallback:(void (^)(APIResponse *response))callback {
    
    [apiClient GET:@"/api/tide_regions/"
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
    
//    [apiClient GET:@"/api/tide_regions/" parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
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

- (void)apiClient:(APIClient *)apiClient tideEntriesFromDate:(NSDate *)from toDate:(NSDate *)to withCallback:(void (^)(APIResponse *response))callback {
    
    NSDictionary *parameters = @{ @"start"  : [from formattedDateWithFormat:@"yyyy-MM-dd" timeZone:[NSTimeZone timeZoneWithName:@"UTC"]],
                                  @"end"    : [to formattedDateWithFormat:@"yyyy-MM-dd" timeZone:[NSTimeZone timeZoneWithName:@"UTC"]]
                                  };
    
    [apiClient GET:[NSString stringWithFormat:@"/api/tide_regions/%@/search_date/", self.identifier]
        parameters:parameters
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

//    [apiClient GET:[NSString stringWithFormat:@"/api/tide_regions/%@/search_date/", self.identifier]
//        parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
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

+ (void)saveTideRegionsDictionaryRepresentationToStorage:(NSArray *)data {
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        for (NSDictionary *item in data) {
            TideRegion *model = [[TideRegion alloc]init];
            model.identifier    = @([[item objectForKey:@"id"] integerValue]);
            model.name          = [item objectForKey:@"name"];
            model.englishName   = [item objectForKey:@"english_name"];
            model.mediumIcon    = [item objectForKey:@"medium_icon_url"];
            model.largeIcon     = [item objectForKey:@"large_icon_url"];
            
            model.order         = @([[item objectForKey:@"order"] integerValue]);
            [realm addOrUpdateObject:model];
        }
    }];
}

+ (void)saveTideEntriesDictionaryRepresentationToStorage:(NSArray *)data {
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        for (NSDictionary *item in data) {
            TideEntry *model   = [[TideEntry alloc] init];
            model.identifier    = @([[item objectForKey:@"id"] integerValue]);
            model.isHighTide    = [NSNumber numberWithBool:[[item objectForKey:@"is_high_tide"] boolValue]];
            model.tideHeight    = @([[item objectForKey:@"tide_height"] doubleValue]);
            model.moon          = @([[item objectForKey:@"moon"] integerValue]);
            model.tideRegion    = @([[item objectForKey:@"tide_region"] integerValue]);

            NSDateFormatter *formatter  = [[NSDateFormatter alloc] init] ;
            formatter.dateFormat        = @"yyyy-MM-dd'T'HH:mm:ssZ";
            formatter.locale            = [NSLocale localeWithLocaleIdentifier:@"en_US"];
            formatter.timeZone          = [NSTimeZone timeZoneWithName:@"UTC"];

            model.date                  = [formatter dateFromString:[item objectForKey:@"date"]];
            [realm addOrUpdateObject:model];
        }
    }];
    if(data.firstObject) {
        [[NSNotificationCenter defaultCenter] postNotificationName:TideEntryDataArrived object:nil userInfo:@{ @"tideRegion" : [[data firstObject] objectForKey:@"tide_region"] }];
    }
}

+ (void)saveTideEntriesSearchResultsDictionaryRepresentationToStorage:(NSArray *)data {
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        for (NSDictionary *item in data) {
            TideEntrySearchResult *model = [[TideEntrySearchResult alloc] init];
            model.identifier    = @([[item objectForKey:@"id"] integerValue]);
            model.isHighTide    = [NSNumber numberWithBool:[[item objectForKey:@"is_high_tide"] boolValue]];
            model.tideHeight    = @([[item objectForKey:@"tide_height"] doubleValue]);
            model.moon          = @([[item objectForKey:@"moon"] integerValue]);
            model.tideRegion    = @([[item objectForKey:@"tide_region"] integerValue]);

            NSDateFormatter *formatter  = [[NSDateFormatter alloc] init] ;
            formatter.dateFormat        = @"yyyy-MM-dd'T'HH:mm:ssZ";
            formatter.locale            = [NSLocale localeWithLocaleIdentifier:@"en_US"];
            formatter.timeZone          = [NSTimeZone timeZoneWithName:@"UTC"];

            model.date                  = [formatter dateFromString:[item objectForKey:@"date"]];
            [realm addOrUpdateObject:model];
        }
    }];
}

@end
