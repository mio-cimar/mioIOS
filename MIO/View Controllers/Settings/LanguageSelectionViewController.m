//
//  LanguageSelectionViewController.m
//  MIO
//
//  Created by Ronny Libardo on 10/8/16.
//  Copyright © 2016 MIO CIMAR. All rights reserved.
//

#import "LanguageSelectionViewController.h"

#define currentLanguageBundle [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:[[NSLocale preferredLanguages] objectAtIndex:0] ofType:@"lproj"]];


@interface LanguageSelectionViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *lblLanguageDisclaimer;

@end

@implementation LanguageSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    NSNumber *language = [[NSUserDefaults standardUserDefaults] objectForKey:kMIOLanguageKey];
//    
//    switch ([language integerValue]) {
//        case MIOSettingsLanguageEnglish:
//            self.selectedLanguage   = MIOSettingsLanguageEnglish;
//            break;
//            
//        case MIOSettingsLanguageSpanish:
//            self.selectedLanguage   = MIOSettingsLanguageSpanish;
//            break;
//            
//        default:
//            break;
//    }
    
    self.navigationItem.title   = LocalizedString(@"settings-language-selection-title");
    self.lblLanguageDisclaimer.text = LocalizedString(@"settings-language-selection-language-disclaimer");
    
//    self.tableView.tableFooterView  = self.tableView.tableHeaderView;
//    self.tableView.tableHeaderView  = [UIView new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45.0f;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return 42.0f;
//}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    return @"PACÍFICO Y CARIBE";
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell                       = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MIOLanguageOptionCell"];
    
    switch (indexPath.row) {
        case MIOSettingsLanguageEnglish:
            cell.textLabel.text = LocalizedString(@"settings-english-language");
            break;
            
        case MIOSettingsLanguageSpanish:
            cell.textLabel.text = LocalizedString(@"settings-spanish-language");
            break;
            
        default:
            break;
    }
    
    [MIOAnalyticsManager trackEventWithCategory:@"Settings" action:[NSString stringWithFormat:@"Set language to %@", @(indexPath.row)]];
    
    cell.accessoryType  = self.selectedLanguage == indexPath.row ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

//- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
//    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
//    
//    header.textLabel.font               = [UIFont fontWithName:@"SFUIText-Regular" size:12];
//    header.textLabel.textAlignment      = NSTextAlignmentLeft;
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case MIOSettingsLanguageEnglish:
            self.selectedLanguage   = MIOSettingsLanguageEnglish;
            
            LocalizationSetLanguage(@"en");
            [self changeLanguage:@"en"];
            
            break;
            
        case MIOSettingsLanguageSpanish:
            self.selectedLanguage   = MIOSettingsLanguageSpanish;
            
            LocalizationSetLanguage(@"es");
            [self changeLanguage:@"es"];
            
            break;
            
        default:
            break;
    }

    self.navigationItem.title   = LocalizedString(@"settings-language-selection-title");
    self.lblLanguageDisclaimer.text = LocalizedString(@"settings-language-selection-language-disclaimer");
    
    [self.tableView reloadData];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kMIOLanguageModifiedKey];
    [[NSUserDefaults standardUserDefaults] setObject:@(self.selectedLanguage) forKey:kMIOLanguageKey];
    [NSNotificationCenter.defaultCenter postNotificationName:kMIOLanguageModifiedKey object:nil];

}

-(CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
    return 1.0;
}

-(UIView*)tableView:(UITableView*)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}


-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1.0;
}

-(UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}


- (void)changeLanguage:(NSString *)inLang
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObject:inLang] forKey:@"AppleLanguages"];
    [[NSUserDefaults standardUserDefaults] synchronize];
//     NSLog(@"test %@", NSLocalizedStringFromTableInBundle(@"NewKey", nil, currentLanguageBundle, @""));
}

@end
