//
//  MIOPersistenceManager.h
//  MIO
//
//  Created by Alonso Vega on 6/25/16.
//  Copyright © 2016 MIO CIMAR. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MIOPersistenceManager : NSObject

+ (NSArray *)getAllObjectsOfClass:className sortedByAttribute:sortAttributeName;

@end
