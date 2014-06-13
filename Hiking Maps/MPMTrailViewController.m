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

// properties used for tableview manipulation, only needs to be accessible
// here in the implementation
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, strong) UISearchDisplayController *searchController;

@property (nonatomic, strong) NSArray *searchResults;

@property (nonatomic, strong) NSArray *sections;

@end

@implementation MPMTrailViewController

// custom init used to allocate the forest and trails array used to populate the tableview
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
    [self.searchBar setTranslucent:NO];
    self.searchBar.barTintColor = [UIColor colorWithRed:0.729 green:0.722 blue:0.424 alpha:1.0];
    
    self.searchBar.backgroundColor = [UIColor colorWithRed:0.729 green:0.722 blue:0.424 alpha:1.0];
    self.searchBar.tintColor = [UIColor colorWithRed:0.729 green:0.722 blue:0.424 alpha:1.0];
    
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    
    [self.view addSubview:self.tableView];
    
    // register the reuse identifer for producing the headers in the tableview
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"Header"];
    
    // sets the background color and text color for the section index on the right-hand side of the screen
    self.tableView.sectionIndexBackgroundColor = [UIColor colorWithRed:0.729 green:0.722 blue:0.424 alpha:1.0];
    self.tableView.sectionIndexColor = [UIColor grayColor];
    
    // set the delegates and datasources to self (this)
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.searchBar.delegate = self;
    self.searchController.delegate = self;
    self.searchController.searchResultsDataSource = self;
    self.searchController.searchResultsDelegate = self;
    
    // set the searchbar as the table header view
    [self.tableView setTableHeaderView:self.searchBar];
    
    // sets the main title of the screen
    self.title = self.forest;
    
    // uses this method call to populate self.sections array used for organizing the tableview according to section
    // indexes
    [self setObjects:self.trails];
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
        return [self.sections[section] count];
    }
}

// Populates the tableview cells based upon which tableview is active, the search results table view or the main
// table view that is broken into alphabetic sections
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
        cell.textLabel.text = [self.sections[indexPath.section][indexPath.row] name];
    }
    
    return cell;
}

// method to define the number of sections in the tableview (UITableViewDataSource)
// returns only one section if the search results tableview is active
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self.searchDisplayController isActive])
        return 1;
    return [self.sections count];
}

// adds styling to the cell so that the accessory view will be shaded by the background color as well
- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.contentView.superview.backgroundColor = [UIColor colorWithRed:0.937 green:0.871 blue:0.804 alpha:1.0];
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.bounds.size.width, cell.bounds.size.height)];
    v.backgroundColor = [UIColor colorWithRed:0.624 green:0.506 blue:0.439 alpha:1.0];
    cell.selectedBackgroundView = v;
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
        Trail *t = self.sections[indexPath.section][indexPath.row];
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

// method to set the trail objects into self.sections 2D array, organized alphabetically
// for use with the section index portion of the tableview, to jump to a specific alphabetic section
- (void)setObjects:(NSArray *)objects {
    SEL selector = @selector(name);
    NSInteger sectionTitlesCount = [[[UILocalizedIndexedCollation currentCollation] sectionTitles] count];
    
    NSMutableArray *mutableSections = [[NSMutableArray alloc] initWithCapacity:sectionTitlesCount];
    for (NSUInteger i = 0; i < sectionTitlesCount; i++)
    {
        [mutableSections addObject:[NSMutableArray array]];
    }
    
    for (id object in objects)
    {
        NSInteger sectionNumber = [[UILocalizedIndexedCollation currentCollation] sectionForObject:object collationStringSelector:selector];
        [[mutableSections objectAtIndex:sectionNumber] addObject:object];
    }
    
    for (NSUInteger i = 0; i < sectionTitlesCount; i++)
    {
        NSArray *objectsForSection = [mutableSections objectAtIndex:i];
        [mutableSections replaceObjectAtIndex:i withObject:[[UILocalizedIndexedCollation currentCollation] sortedArrayFromArray:objectsForSection collationStringSelector:selector]];
    }
    // create a dummy trail that only has a name to fill the first tableview cell, add it to the first index
    // of the first array (the 'A' section).
    Trail *nearest = [[Trail alloc] init];
    nearest.name = @"Nearest Trails...";
    mutableSections[0] = [@[nearest] arrayByAddingObjectsFromArray:mutableSections[0]];
    
    // set the sections property used to populate the tableview
    self.sections = mutableSections;
    
    // and reload the tableview property
    [self.tableView reloadData];
}

// returns an array of strings to set the titles of the section headers
// returns the alphabet based on the localization settings of the device
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if ([self.searchDisplayController isActive])
        return nil;
    return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
}

// returns the section index used to jump to a particular section when it's tapped in the section indexes (A --> Z)
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

// method to customize the header cells in the tableview as far as the background color, size, font, etc..
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"Header"];
    
    UILabel *titleLabel = (UILabel *)[headerView.contentView viewWithTag:1];
    if (titleLabel == nil) {
        UIColor *backgroundColor = [UIColor colorWithRed:0.729 green:0.722 blue:0.424 alpha:1.0];
        headerView.contentView.backgroundColor = backgroundColor;
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, self.tableView.bounds.size.width, 15.0)];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.tintColor = backgroundColor;
        titleLabel.shadowOffset = CGSizeMake(0.0, 0.5);
        titleLabel.tag = 1;
        titleLabel.font = [UIFont systemFontOfSize:12.0];
        [headerView.contentView addSubview:titleLabel];
    }
    
    NSString *sectionTitle = [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section];
    if (sectionTitle == nil) {
        sectionTitle = @"Missing Title";
    }
    
    titleLabel.text = sectionTitle;
    
    return headerView;
}

// method to se the height of the header cells in the tableview.  Reduces it to zero if the
// search bar is active, or if there are no trails in that particular alphabetic section.
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([self.searchDisplayController isActive] || [self.sections[section] count] == 0)
        return 0.0;
    return 15.0;
}

@end
