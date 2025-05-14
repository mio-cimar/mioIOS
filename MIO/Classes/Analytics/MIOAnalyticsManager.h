//
//  MIOAnalyticsManager.h
//  MIO
//
//  Created by Ronny Libardo Bustos Jiménez on 24/9/17.
//  Copyright © 2017 MIO CIMAR. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MIOAnalyticsManager : NSObject

+ (void)trackScreen:(NSString *)details screenClass: (NSString *)screenClass;
+ (void)trackEventWithCategory:(NSString *)category action:(NSString *)action;

@end
