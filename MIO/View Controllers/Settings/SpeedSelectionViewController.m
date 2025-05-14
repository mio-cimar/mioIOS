//
//  SpeedSelectionViewController.m
//  MIO
//
//  Created by Ronny Libardo on 10/9/16.
//  Copyright © 2016 MIO CIMAR. All rights reserved.
//

#import "SpeedSelectionViewController.h"

@interface SpeedSelectionViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SpeedSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //    NSNumber *language = [[NSUserDefaults standardUserDefaults] objectForKey:kMIOLanguageKey];
    //
    //    switch ([language integerValue]) {
    //        case MIOSettingsLanguageEnglish:
    //            self.selectedSpeedMeasureUnit   = MIOSettingsLanguageEnglish;
    //            break;
    //
    //        case MIOSettingsLanguageSpanish:
    //            self.selectedSpeedMeasureUnit   = MIOSettingsLanguageSpanish;
    //            break;
    //
    //        default:
    //            break;
    //    }
    
    self.navigationItem.title   = LocalizedString(@"settings-speed-selection-title");
    
    self.tableView.tableFooterView  = [UIView new];
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
    UITableViewCell *cell                       = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MIOSpeedMeasureUnitCell"];
    
    switch (indexPath.row) {
        case MIOSettingsSpeedMeasureUnitKilometers:
            cell.textLabel.text = LocalizedString(@"measure-unit-kilometer");
            break;
            
        case MIOSettingsSpeedMeasureUnitKnots:
            cell.textLabel.text = LocalizedString(@"measure-unit-knot");
            break;
            
        default:
            break;
    }
    
    cell.accessoryType  = self.selectedSpeedMeasureUnit == indexPath.row ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
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
        case MIOSettingsSpeedMeasureUnitKilometers: {
            
            self.selectedSpeedMeasureUnit   = MIOSettingsSpeedMeasureUnitKilometers;
            break;
        }
            
        case MIOSettingsSpeedMeasureUnitKnots: {
            self.selectedSpeedMeasureUnit   = MIOSettingsSpeedMeasureUnitKnots;
            break;
        }
            
        default:
            break;
    }
    
    [MIOAnalyticsManager trackEventWithCategory:@"Settings" action:[NSString stringWithFormat:@"Set speed unit to %@", @(indexPath.row)]];
    
    [self.tableView reloadData];
    
    [[NSUserDefaults standardUserDefaults] setObject:@(self.selectedSpeedMeasureUnit) forKey:kMIOSpeedMeasureUnitKey];
    
    
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

@end
