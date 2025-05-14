//
//  SettingsTableViewController.m
//  MIO
//
//  Created by Ronny Libardo on 10/7/16.
//  Copyright © 2016 MIO CIMAR. All rights reserved.
//

#import "SettingsTableViewController.h"

#import "LanguageSelectionViewController.h"
#import "SpeedSelectionViewController.h"
#import "HeightSelectionViewController.h"

@import Firebase;

typedef NS_ENUM(NSInteger, MIOSettingsSections) {
    MIOSettingsSectionNotifications,
    MIOSettingsSectionMeasureUnits,
    MIOSettingsSectionOther
};

@interface SettingsTableViewController ()

@property (nonatomic) MIOSettingsLanguages selectedLanguage;
@property (nonatomic) MIOSettingsHeightMeasureUnits selectedHeightMeasureUnit;
@property (nonatomic) MIOSettingsSpeedMeasureUnits selectedSpeedMeasureUnit;
@property (weak, nonatomic) IBOutlet UILabel *selectedLanguageLabel;
@property (weak, nonatomic) IBOutlet UILabel *selectedSpeedMeasureUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *selectedHeightMeasureUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *lblHeight;
@property (weak, nonatomic) IBOutlet UILabel *lblSpeed;
@property (weak, nonatomic) IBOutlet UILabel *lblLanguage;
@property (weak, nonatomic) IBOutlet UILabel *lblRateApp;

@end

@implementation SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView setNeedsLayout];
    [self.tableView layoutIfNeeded];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSNumber    *notificationsEnabled   = [[NSUserDefaults standardUserDefaults] objectForKey:kMIONotificationsEnabledKey];
    
    if (!notificationsEnabled) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:[[UIApplication sharedApplication] isRegisteredForRemoteNotifications]] forKey:kMIONotificationsEnabledKey];
        
        notificationsEnabled    = [NSNumber numberWithBool:[[UIApplication sharedApplication] isRegisteredForRemoteNotifications]];
    }
    
    [MIOAnalyticsManager trackScreen:@"Settings" screenClass:[self.classForCoder description]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.selectedLanguage           = [[[NSUserDefaults standardUserDefaults] objectForKey:kMIOLanguageKey] integerValue];
    self.selectedSpeedMeasureUnit   = [[[NSUserDefaults standardUserDefaults] objectForKey:kMIOSpeedMeasureUnitKey] integerValue];
    self.selectedHeightMeasureUnit  = [[[NSUserDefaults standardUserDefaults] objectForKey:kMIOHeightMeasureUnitKey] integerValue];
    
    self.selectedLanguageLabel.text             = self.selectedLanguage == MIOSettingsLanguageSpanish ? LocalizedString(@"settings-spanish-language") : LocalizedString(@"settings-english-language");
    self.selectedHeightMeasureUnitLabel.text    = self.selectedHeightMeasureUnit == MIOSettingsHeightMeasureUnitFeet ? LocalizedString(@"settings-measure-unit-feet") : LocalizedString(@"measure-unit-meter");
    self.selectedSpeedMeasureUnitLabel.text     = self.selectedSpeedMeasureUnit == MIOSettingsSpeedMeasureUnitKilometers ? LocalizedString(@"measure-unit-kilometer") : LocalizedString(@"measure-unit-knot");
    
    self.lblHeight.text             = LocalizedString(@"settings-height");
    self.lblSpeed.text              = LocalizedString(@"settings-speed");
    self.lblLanguage.text           = LocalizedString(@"settings-language");
    self.lblRateApp.text            = LocalizedString(@"settings-rate-app");
    
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    
    header.textLabel.font               = [UIFont fontWithName:@"SFUIText-Regular" size:12];
    header.textLabel.textAlignment      = NSTextAlignmentLeft;
}

-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case MIOSettingsSectionNotifications:
            return 42.0f;
            break;
            
        case MIOSettingsSectionOther:
            return 31.0f;
            break;
            
        case MIOSettingsSectionMeasureUnits:
            return 40.0f;
            break;
            
        default:
            break;
    }
    
    return 0.0f;
}


-(CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
    return 1.0;
}

-(UIView*)tableView:(UITableView*)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowSpeedMeasureUnitSelection"]) {
        ((SpeedSelectionViewController *)segue.destinationViewController).selectedSpeedMeasureUnit  = self.selectedSpeedMeasureUnit;
    }
    else if ([segue.identifier isEqualToString:@"ShowHeightMeasureUnitSelection"]) {
        ((HeightSelectionViewController *)segue.destinationViewController).selectedHeightMeasureUnit  = self.selectedHeightMeasureUnit;
    }
    else if ([segue.identifier isEqualToString:@"ShowLanguageSelection"]) {
        ((LanguageSelectionViewController *)segue.destinationViewController).selectedLanguage  = self.selectedLanguage;
        
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 1 && indexPath.section == 1) {
        NSURL *appURL = [NSURL URLWithString:@"https://itunes.apple.com/cr/app/mio-cimar/id1008031032?l=en&mt=8"];
        
        if ([[UIApplication sharedApplication] canOpenURL:appURL]) {
            [[UIApplication sharedApplication] openURL:appURL];
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return section == 1 ? LocalizedString(@"settings-measure-units") : nil;
}

- (void)allowNotificationsSwitchChangedState:(id)sender {
    BOOL state = [sender isOn];
    
    if ([[UIApplication sharedApplication] isRegisteredForRemoteNotifications]) {
#if DEV
        NSString *topicName = @"notifications-ios-dev";
#else
        NSString *topicName = @"notifications-ios";
#endif
        if (state) {
            [[FIRMessaging messaging] subscribeToTopic:topicName];
        }
        else {
            [[FIRMessaging messaging] unsubscribeFromTopic:topicName];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:[sender isOn]] forKey:kMIONotificationsEnabledKey];
}

- (IBAction)goUCR:(UIButton *)sender {
    NSURL *UCRURL = [NSURL URLWithString:@"https://www.ucr.ac.cr"];
    
    [MIOAnalyticsManager trackEventWithCategory:@"Settings link" action:[UCRURL absoluteString]];
    
    if ([[UIApplication sharedApplication] canOpenURL:UCRURL]) {
        [[UIApplication sharedApplication] openURL:UCRURL];
    }
}

- (IBAction)goImactus:(UIButton *)sender {
    NSURL *imactusURL = [NSURL URLWithString:@"http://www.imactus.com"];
    
    [MIOAnalyticsManager trackEventWithCategory:@"Settings link" action:[imactusURL absoluteString]];
    
    if ([[UIApplication sharedApplication] canOpenURL:imactusURL]) {
        [[UIApplication sharedApplication] openURL:imactusURL];
    }
}


@end
