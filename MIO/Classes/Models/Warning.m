//
//  Warning.m
//  MIO
//
//  Created by Ronny Libardo on 9/14/16.
//  Copyright © 2016 MIO CIMAR. All rights reserved.
//

#import "Warning.h"
#import "MIOAPI.h"
#import <DateTools/DateTools.h>

NSString *const kNotificationArrivedNotification        = @"NotificationArrivedNotification";
NSString *const WarningsDataRetrievalTimestampKey       = @"WarningsDataRetrievalTimestampKey";

@implementation Warning

+ (NSString *)primaryKey {
    return @"identifier";
}

+ (void)apiClient:(APIClient *)apiClient warningsWithCallback:(void (^)(APIResponse *response))callback {
    
    [apiClient GET:@"/api/warnings/"
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

//    [apiClient GET:@"/api/warnings/" parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
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

+ (void)saveWarningsDictionaryRepresentationToStorage:(NSArray *)data {
    NSInteger dataOrder = 0;

    RLMRealm *realm = [RLMRealm defaultRealm];
    for (NSDictionary *item in data) {
        Warning *model = [[Warning alloc] init];
        model.identifier    = @([[item objectForKey:@"id"] integerValue]);
        model.title         = [item objectForKey:@"title"];
        model.subtitle      = [item objectForKey:@"subtitle"];
        model.text          = [item objectForKey:@"text"];
        model.level         = @([[item objectForKey:@"level"] integerValue]);
        NSDateFormatter *formatter  = [[NSDateFormatter alloc] init] ;
        //2021-09-08T01:02:03.231687-06:00
        formatter.dateFormat        = @"yyyy-MM-dd'T'HH:mm:ssZ";
        formatter.locale            = [NSLocale localeWithLocaleIdentifier:@"en_US"];
        formatter.timeZone          = [NSTimeZone timeZoneWithName:@"UTC"];
        NSDate *date = [formatter dateFromString:item[@"date"]];
        if (date) {
            model.date                  = date;
        } else {
            formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZ";
            model.date                  = [formatter dateFromString:item[@"date"]];
        }
        model.order                 = @(dataOrder);
        dataOrder++;
        [realm beginWriteTransaction];
        [realm addOrUpdateObject:model];
        [realm commitWriteTransaction];
    }
}

@end
