//
//  SettingsViewController.m
//  MIO
//
//  Created by Ronny Libardo on 12/26/16.
//  Copyright © 2016 MIO CIMAR. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *warningMessageLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewTopSpaceTopLayoutGuide;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewTopSpaceDisclaimer;
@property (weak, nonatomic) IBOutlet UIView *disclaimerView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.backBarButtonItem   = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.title = LocalizedString(@"settings-title");
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = YES;
        self.titleLabel.text = nil;
    } else {
        self.titleLabel.text = LocalizedString(@"settings-title");
        self.navigationItem.titleView = [[UIView alloc] init];
    }
//    CALayer *layer = [[CALayer alloc] init];
//    layer.frame = CGRectMake(0, 0, self.view.frame.size.width, 0.5);
//    layer.backgroundColor = [[UIColor colorWithRed:224/255.0 green:224/255.0 blue:224/255.0 alpha:1.0] CGColor];
//    [self.view.layer addSublayer:layer];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = LocalizedString(@"settings-title");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    self.warningMessageLabel.text = LocalizedString(@"settings-notifications-disabled-disclaimer");
    
    [self processPushNotificationsValidation];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)pushNotificationsEnabled {
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(currentUserNotificationSettings)]) {
        UIUserNotificationType types = [[[UIApplication sharedApplication] currentUserNotificationSettings] types];
        return (types & (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound));
    }
    else {
        UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        return (types & (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound));
    }
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    [self processPushNotificationsValidation];
}

- (void)processPushNotificationsValidation {
    if (![self pushNotificationsEnabled]) {
        self.disclaimerView.hidden                          = NO;
        self.containerViewTopSpaceDisclaimer.priority       = 999;
        self.containerViewTopSpaceTopLayoutGuide.priority   = 749;
    }
    else {
        self.disclaimerView.hidden                          = YES;
        self.containerViewTopSpaceDisclaimer.priority       = 749;
        self.containerViewTopSpaceTopLayoutGuide.priority   = 999;
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
