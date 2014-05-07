//
//  IFAThirdPartyCodeCreditsViewController.m
//  Gusty
//
//  Created by Marcelo Schroeder on 8/10/12.
//  Copyright (c) 2012 InfoAccent Pty Limited. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "IFACommon.h"

@interface IFAThirdPartyCodeCreditsViewController ()

@property (nonatomic, strong) NSArray *IFA_credits;

@end

@implementation IFAThirdPartyCodeCreditsViewController {
    
}

#pragma mark - Overrides

- (id)init{
    return [self initWithStyle:UITableViewStyleGrouped];
}

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.IFA_credits = [[IFAUtils infoPList] objectForKey:@"IFAThirdPartyCodeCredits"];
    }
    return self;
}

-(UITableViewCell *)createReusableCellWithIdentifier:(NSString *)a_reuseIdentifier atIndexPath:(NSIndexPath *)a_indexPath{
    UITableViewCell *l_cell = [super createReusableCellWithIdentifier:a_reuseIdentifier atIndexPath:a_indexPath];
    l_cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return l_cell;
}

#pragma mark - UITableViewDataDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSIndexPath *l_selectedIndexPath = self.tableView.indexPathForSelectedRow;
    NSDictionary *l_credit = self.IFA_credits[(NSUInteger) l_selectedIndexPath.row];
    NSURL *l_url = [NSURL URLWithString:l_credit[@"url"]];
    [self ifa_openUrl:l_url];
}

#pragma mark - UITableViewDataSource

-(void)viewDidLoad{
    [super viewDidLoad];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString * const k_cellId = @"cell";
    UITableViewCell *l_cell = [self dequeueAndCreateReusableCellWithIdentifier:k_cellId atIndexPath:indexPath];
    NSDictionary *l_credit = self.IFA_credits[(NSUInteger) indexPath.row];
    l_cell.textLabel.text = l_credit[@"name"];
    return l_cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.IFA_credits.count;
}

@end
