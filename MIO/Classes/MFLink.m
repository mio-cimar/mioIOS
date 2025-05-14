//
//  NSObject+MFLink.m
//  MIO
//
//  Created by Fabricio Rodriguez on 3/10/19.
//  Copyright © 2019 MIO CIMAR. All rights reserved.
//

#import "MFLink.h"
@implementation MFLink
//@import Firebase;

- (id)initWith:(FIRDocumentSnapshot *)snapshot {
    self = [super init];
    if (self) {
        self.key = snapshot.documentID;
        NSDictionary *data = snapshot.data;
        MIOSettingsLanguages selectedLanguage = [[[NSUserDefaults standardUserDefaults] objectForKey:kMIOLanguageKey] integerValue];
        if(selectedLanguage == MIOSettingsLanguageSpanish) {
            self.title = data[@"titleES"];
        } else {
            self.title = data[@"titleEN"];
        }
        self.isActive = data[@"isActive"];
        self.url = data[@"url"];
        self.order = data[@"order"];
    }
    return self;
}
@end
