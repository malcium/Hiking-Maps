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
    
    // initialize the table view and search bar and search bar controller and set the delegates and nav bar title
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 44)];
    [self.searchBar setTranslucent:YES];
    self.searchBar.barTintColor = [UIColor colorWithRed:0.937 green:0.871 blue:0.804 alpha:1.0];
    
    self.searchBar.backgroundColor = [UIColor colorWithRed:0.937 green:0.871 blue:0.804 alpha:1.0];
    self.searchBar.tintColor = [UIColor colorWithRed:0.729 green:0.722 blue:0.424 alpha:1.0];
    
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

// re-sizes upon device reorientation
-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.tableView.frame = self.view.bounds;
    self.tableView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
}

// Create a predicate to use for the search bar, checks if the name attribute of a trail contains the search text
// and sets the array to be searched (self.trails)
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate
                                    predicateWithFormat:@"name contains[cd] %@",
                                    searchText];
    
    self.searchResults = [self.trails filteredArrayUsingPredicate:resultPredicate];
}

// reloads the table according to the search string entered
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

// Changes the number of rows in the table depending on whether the search results tableview is showing or not
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

// Populates the tableview cells based upon which tableview is active, the search results table view or the main
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

// adds styling to the cell so that the accessory view will be shaded by the background color as well
- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.contentView.superview.backgroundColor = [UIColor colorWithRed:0.937 green:0.871 blue:0.804 alpha:1.0];
}

// Action upon selecting row for index path depending upon which tableview is active, the search tableview
// or the main
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

// If the nearest trails option is selected (top cell in tableview), then go to a different view controller
// to calculate and display the nearest trails
- (void) goToNearestTrails
{
    MPMNearestViewController *viewController = [[MPMNearestViewController alloc] init];
    viewController.trails = self.trails;
    viewController.forest = self.forest;
    [self.navigationController pushViewController:viewController animated:YES];
}
@end
