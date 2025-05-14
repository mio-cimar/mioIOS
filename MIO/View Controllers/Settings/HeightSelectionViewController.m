//
//  HeightSelectionViewController.m
//  MIO
//
//  Created by Ronny Libardo on 10/9/16.
//  Copyright © 2016 MIO CIMAR. All rights reserved.
//

#import "HeightSelectionViewController.h"

@interface HeightSelectionViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation HeightSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    NSNumber *height = [[NSUserDefaults standardUserDefaults] objectForKey:kMIOHeightMeasureUnitKey];
//    
//    switch ([height integerValue]) {
//        case MIOSettingsHeightMeasureUnitFeet:
//            self.selectedHeightMeasureUnit   = MIOSettingsHeightMeasureUnitFeet;
//            break;
//            
//        case MIOSettingsHeightMeasureUnitMeters:
//            self.selectedHeightMeasureUnit   = MIOSettingsHeightMeasureUnitMeters;
//            break;
//            
//        default:
//            break;
//    }
    
    self.navigationItem.title   = LocalizedString(@"settings-height-selection-title");
    
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
    UITableViewCell *cell                       = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MIOHeightMeasureUnitOptionCell"];
    
    switch (indexPath.row) {
        case MIOSettingsHeightMeasureUnitFeet: {
            
            cell.textLabel.text = LocalizedString(@"settings-measure-unit-feet");
            break;
        }
            
        case MIOSettingsHeightMeasureUnitMeters: {
            
            cell.textLabel.text = LocalizedString(@"measure-unit-meter");
            break;
        }
            
        default:
            break;
    }
    
    [MIOAnalyticsManager trackEventWithCategory:@"Settings" action:[NSString stringWithFormat:@"Set distance unit to %@", @(indexPath.row)]];
    
    cell.accessoryType  = self.selectedHeightMeasureUnit == indexPath.row ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
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
        case MIOSettingsHeightMeasureUnitFeet:
            self.selectedHeightMeasureUnit   = MIOSettingsHeightMeasureUnitFeet;
            break;
            
        case MIOSettingsHeightMeasureUnitMeters:
            self.selectedHeightMeasureUnit   = MIOSettingsHeightMeasureUnitMeters;
            break;
            
        default:
            break;
    }
    
    [self.tableView reloadData];
    
    [[NSUserDefaults standardUserDefaults] setObject:@(self.selectedHeightMeasureUnit) forKey:kMIOHeightMeasureUnitKey];
    
    
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
