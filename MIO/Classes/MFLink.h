//
//  NSObject+MFLink.h
//  MIO
//
//  Created by Fabricio Rodriguez on 3/10/19.
//  Copyright © 2019 MIO CIMAR. All rights reserved.
//

#import <Foundation/Foundation.h>
@import Firebase;

@interface MFLink : NSObject
@property(nonatomic) NSString *key;
@property(nonatomic) NSNumber *isActive;
@property(nonatomic) NSString *title;
@property(nonatomic) NSString *url;
@property(nonatomic) NSNumber *order;

-(id) initWith:(FIRDocumentSnapshot *) snapshot;

@end
