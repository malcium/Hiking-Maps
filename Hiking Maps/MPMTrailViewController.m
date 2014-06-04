//
//  MPMViewController.m
//  HikingMaps
//
//  Created by Morgan McCoy on 3/10/14.
//  Copyright (c) 2014 Westminster College. All rights reserved.
//

#import "MPMTrailViewController.h"
#import "Trail.h"
#import "MPMTopoViewController.h"
#import "MPMNearestViewController.h"

@interface MPMTrailViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, strong) UISearchDisplayController *searchController;

@property (nonatomic, strong) NSArray *searchResults;

@end

@implementation MPMTrailViewController

- (id)init
{
    self = [super init];
    
    if(!self) return nil;
    
    self.forest = [[NSString alloc] init];
    
    self.trails = [[NSArray alloc] init];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.toolbarHidden = YES;
	
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 44)];
    [self.searchBar setTranslucent:YES];
    self.searchBar.tintColor = [UIColor colorWithRed:0.937 green:0.871 blue:0.804 alpha:1.0];
    self.searchBar.backgroundColor = [UIColor colorWithRed:0.937 green:0.871 blue:0.804 alpha:1.0];
    
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
   
    [self.view addSubview:self.tableView];
    
    self.tableView.dataSource = self;
    
    self.tableView.delegate = self;
    self.searchBar.delegate = self;
    self.searchController.delegate = self;
    self.searchController.searchResultsDataSource = self;
    self.searchController.searchResultsDelegate = self;
    
    [self.tableView setTableHeaderView:self.searchBar];
    
    self.title = self.forest;
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.tableView.frame = self.view.bounds;
    self.tableView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate
                                    predicateWithFormat:@"name contains[cd] %@",
                                    searchText];
    
    self.searchResults = [self.trails filteredArrayUsingPredicate:resultPredicate];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == self.searchController.searchResultsTableView)
    {
        return [self.searchResults count];
    }
    else
    {
        return [self.trails count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TrailIdentifier"];
    
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TrailIdentifier"];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if(tableView == self.searchController.searchResultsTableView)
    {
        cell.textLabel.text = [self.searchResults[indexPath.row] name];
    }
    else
    {
        cell.textLabel.text = [self.trails[indexPath.row] name];
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.contentView.superview.backgroundColor = [UIColor colorWithRed:0.937 green:0.871 blue:0.804 alpha:1.0];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.searchController isActive])
    {
        indexPath = [self.searchController.searchResultsTableView indexPathForSelectedRow];
        Trail *t = self.searchResults[indexPath.row];
        if ([t.name isEqualToString:@"Nearest Trails..."]){
            [self goToNearestTrails];
        }
        else{
            MPMTopoViewController *viewController = [[MPMTopoViewController alloc] init];
            viewController.trail = t;
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }
    else
    {
        Trail *t = self.trails[indexPath.row];
        if ([t.name isEqualToString:@"Nearest Trails..."]){
            [self goToNearestTrails];
        }
        else{
            MPMTopoViewController *viewController = [[MPMTopoViewController alloc] init];
            viewController.trail = t;
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }
}

- (void) goToNearestTrails
{
    MPMNearestViewController *viewController = [[MPMNearestViewController alloc] init];
    viewController.trails = self.trails;
    viewController.forest = self.forest;
    [self.navigationController pushViewController:viewController animated:YES];
}
@end
