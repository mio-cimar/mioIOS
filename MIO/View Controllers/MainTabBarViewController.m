//
//  MainTabBarViewController.m
//  MIO
//
//  Created by Fabricio Rodriguez on 3/12/19.
//  Copyright © 2019 MIO CIMAR. All rights reserved.
//

#import "MainTabBarViewController.h"
#import "Warning.h"
#import "MIOWarningsViewController.h"

@implementation MainTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTitles];
    self.selectedIndex = 1;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(languageChanged:) name:kMIOLanguageModifiedKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(warningNotificationArrived:) name:kNotificationArrivedNotification object:nil];
}

- (void)languageChanged:(NSNotification *)notification {
    [self setupTitles];
}

- (void) setupTitles {
    if(self.tabBar.items) {
        for (int index = 0; index < self.tabBar.items.count; index++) {
            UITabBarItem *item = self.tabBar.items[index];
            switch (index) {
                case 0:
                    [item setTitle:LocalizedString(@"warnings-list-title")];
                    break;
                case 1:
                    [item setTitle:LocalizedString(@"forecasts-title")];
                    break;
                case 2:
                    [item setTitle:LocalizedString(@"tide-regions-title")];
                    break;
                case 3:
                    [item setTitle:LocalizedString(@"more-title")];
                    break;
                default:
                    break;
            }
        }
    }
}

- (void)warningNotificationArrived:(NSNotification *)notification {
    NSString *warningIdentifier = [notification.userInfo objectForKey:@"warningIdentifier"];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *identifier = [formatter numberFromString:warningIdentifier];
    self.notificationToPresent = identifier;
    if(self.selectedIndex == 0) {
        UINavigationController *warningsNav = (UINavigationController *) self.selectedViewController;
        MIOWarningsViewController *warnings = [warningsNav.viewControllers firstObject];
        [warnings checkForNotificationArrived];
    } else {
        self.selectedIndex = 0;
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
