#import "AppDelegate.h"
#import "LanguageSelectionViewController.h"
#import "Warning.h"
#import <Parse/Parse.h>
//#import <Fabric/Fabric.h>
//#import <Crashlytics/Crashlytics.h>

@import Firebase;
@import UserNotifications;

NSString *const kAnalyticsTrackingId = @"UA-84259082-4";

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSString *language          = [[[NSLocale preferredLanguages] objectAtIndex:0] componentsSeparatedByString:@"-"][0];
    NSNumber *selectedLanguage  = [[NSUserDefaults standardUserDefaults] objectForKey:kMIOLanguageKey];
    
    if (!selectedLanguage) {
        NSLog(@"Setting Language First Time");
        
        if ([language isEqualToString:@"en"]) {
            [[NSUserDefaults standardUserDefaults] setObject:@(MIOSettingsLanguageEnglish) forKey:kMIOLanguageKey];
            
            LocalizationSetLanguage(@"en");
        }
        else {
            [[NSUserDefaults standardUserDefaults] setObject:@(MIOSettingsLanguageSpanish) forKey:kMIOLanguageKey];
            
            LocalizationSetLanguage(@"es");
        }
    }
    else {
        switch ([selectedLanguage integerValue]) {
            case MIOSettingsLanguageEnglish:
                LocalizationSetLanguage(@"en");
                break;
                
            case MIOSettingsLanguageSpanish:
                LocalizationSetLanguage(@"es");
                break;
                
            default:
                break;
        }
    }

    [FIRApp configure];
    FIRFirestore *defaultFirestore = [FIRFirestore firestore];
    defaultFirestore.settings.persistenceEnabled = YES;

    NSLog(@"%@", defaultFirestore);
    
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    config.schemaVersion = 1;
    config.migrationBlock = ^(RLMMigration *migration, uint64_t oldSchemaVersion) {
        if (oldSchemaVersion < 1) {
            // Nothing to do!
        }
    };
    [RLMRealmConfiguration setDefaultConfiguration:config];

    UNAuthorizationOptions authOptions =
    UNAuthorizationOptionAlert
    | UNAuthorizationOptionSound
    | UNAuthorizationOptionBadge;
    [[UNUserNotificationCenter currentNotificationCenter]
     requestAuthorizationWithOptions:authOptions
     completionHandler:^(BOOL granted, NSError * _Nullable error) {
     }
     ];
    
    // For iOS 10 display notification (sent via APNS)
    [[UNUserNotificationCenter currentNotificationCenter] setDelegate:self];
    // For iOS 10 data message (sent via FCM)
    //[FIRMessaging messaging].delegate = self;
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tokenRefreshWithNotification:) name:kFIRInstanceIDTokenRefreshNotification object:nil];
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleDefault;
    sleep(2);
    return YES;
}

- (void)tokenRefreshWithNotification:(NSNotification *)notification {
#if DEV
    [[FIRMessaging messaging] subscribeToTopic:@"notifications-ios-dev"];
#else
    [[FIRMessaging messaging] subscribeToTopic:@"notifications-ios"];
#endif
}

// To receive notifications for iOS 9 and below.
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    // If you are receiving a notification message while your app is in the background,
    // this callback will not be fired till the user taps on the notification launching the application.
    // TODO: Handle data of notification
    
    // Print message ID.
    NSLog(@"Message ID: %@", userInfo[@"gcm.message_id"]);
    
    // Print full message.
    NSLog(@"%@", userInfo);
    
    [self handleNotification:userInfo];
}

// Receive displayed notifications for iOS 10 devices.
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    // Print message ID.
    NSDictionary *userInfo = notification.request.content.userInfo;
    NSLog(@"Message ID: %@", userInfo[@"gcm.message_id"]);
    
    // Print full message.
    NSLog(@"%@", userInfo);
}

-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler{

    [self handleNotification:response.notification.request.content.userInfo];

    NSLog(@"Userinfo %@",response.notification.request.content.userInfo);

}

#endif

- (void)handleNotification:(NSDictionary *)userInfo {
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        id message = userInfo[@"aps"][@"alert"];
        
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:message && message != [NSNull null] ? message[@"title"] : @""
                                              message:message && message != [NSNull null] ? message[@"body"] : @""
                                              preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction
                                       actionWithTitle:LocalizedString(@"ignore")
                                       style:UIAlertActionStyleCancel
                                       handler:^(UIAlertAction *action)
                                       {
                                       }];
        
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle: LocalizedString(@"show")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationArrivedNotification object:nil userInfo:@{ @"warningIdentifier" : userInfo[@"notificationId"] }];
                                   }];
        
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];
        
        [self.window.rootViewController presentViewController:alertController animated:YES completion:^{
        }];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationArrivedNotification object:nil userInfo:@{ @"warningIdentifier" : userInfo[@"notificationId"] }];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//    [self refreshFirebaseIfNeeded];
}

//- (void) refreshFirebaseIfNeeded {
//    NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
//    NSString *previousVersion = [[NSUserDefaults standardUserDefaults] stringForKey:@"bundleVersion"];
//    if (![currentVersion isEqualToString:previousVersion]) {
//        [[NSUserDefaults standardUserDefaults] setValue:currentVersion forKey:@"bundleVersion"];
//        [[FIRInstanceID instanceID] deleteIDWithHandler:^(NSError * _Nullable error) {}];
//    }
//}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark Configuración Inicial
- (void)inizializarAjustesBasicosDeAplicacion{
    
    //Fondo de la barra superior de estado
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationArrivedNotification object:nil];
    }
}
@end
