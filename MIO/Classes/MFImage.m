//
//  NSObject+MFImage.m
//  MIO
//
//  Created by Fabricio Rodriguez on 3/10/19.
//  Copyright © 2019 MIO CIMAR. All rights reserved.
//

#import "MFImage.h"

@implementation MFImage
- (id)initWith:(FIRDocumentSnapshot *)snapshot {
    self = [super init];
    if (self) {
        self.key = snapshot.documentID;
        NSDictionary *data = snapshot.data;
        MIOSettingsLanguages selectedLanguage = [[[NSUserDefaults standardUserDefaults] objectForKey:kMIOLanguageKey] integerValue];
        if(selectedLanguage == MIOSettingsLanguageSpanish) {
            self.alternativeText = data[@"altTextES"];
        } else {
            self.alternativeText = data[@"altTextEN"];
        }
        self.name = data[@"name"];
        self.url = data[@"url"];
    }
    return self;
}
@end
