//
//  TDLMasterListViewController.m
//  ToDoList
//
//  Created by Anthony Oliveri on 1/14/14.
//  Copyright (c) 2014 Anthony Oliveri. All rights reserved.
//

#import "TDLMasterListViewController.h"

#define LISTS_SECTION 0
#define ADD_LIST_SECTION 1

@interface TDLMasterListViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property TDLAppDelegate *appDelegate;
@property NSManagedObject *selectedList;

@end


@implementation TDLMasterListViewController


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == LISTS_SECTION)
        return 25.0f;
    else
        return 10.0f;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;

    self.appDelegate = [[UIApplication sharedApplication] delegate];
    self.toDoLists = [self loadObjects:@"ToDoList"];
}


// Fetch all the lists or items stored in Documents/CoreData.sqlite
-(NSArray *)loadObjects:(NSString *)toDoEntity
{
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:toDoEntity inManagedObjectContext: self.appDelegate.managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSError *error;
    NSArray *unorderedObjects =  [self.appDelegate.managedObjectContext executeFetchRequest:request error:&error];
    NSArray *descriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"tablePosition" ascending:YES]];
    return [unorderedObjects sortedArrayUsingDescriptors:descriptors];
}


// Reload items to get the newly entered item
// Unwinds from modal segue of TDLAddToDoItemViewController
- (IBAction)unwindToMaster:(UIStoryboardSegue *)segue
{
    TDLAddObjectViewController *source = [segue sourceViewController];
    NSString *newListName = source.textField.text;
    if([newListName length] > 0)
    {
        [self storeNewList:newListName];
        self.toDoLists = [self loadObjects:@"ToDoList"];
        [self.tableView reloadData];
    }
}


// Save the new item as a managed object in the Documents/CoreData.sqlite directory
- (void)storeNewList:(NSString *)newListName
{
    NSNumber *last = [NSNumber numberWithUnsignedInteger:[self.toDoLists count]];
    NSManagedObject *newList = [NSEntityDescription insertNewObjectForEntityForName:@"ToDoList" inManagedObjectContext:self.appDelegate.managedObjectContext];
    
    [newList setValue:newListName forKey:@"name"];
    [newList setValue:last forKey:@"tablePosition"];
    [newList setValue:false forKey:@"completed"];
    [newList setValue:Nil forKey:@"itemsInList"];
    
    [self.appDelegate saveContext];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Section 0 contains all the lists
    // Section 1 is the Add List cell
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == LISTS_SECTION)
    {
        return [self.toDoLists count];
    }
    // ADD_LIST_SECTION
    else
    {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == LISTS_SECTION)
    {
        static NSString *CellIdentifier = @"ListPrototypeCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        NSManagedObject *toDoList = [self.toDoLists objectAtIndex:[self findListIndex:indexPath]];
        cell.textLabel.text = [toDoList valueForKey:@"name"];
        
        // Completed items get a strikethrough and are grayed out
        bool completed = [[toDoList valueForKey:@"completed"] boolValue];
        if(completed)
        {
            NSMutableAttributedString *grayStrikeThrough = [[NSMutableAttributedString alloc] initWithString:cell.textLabel.text];
            [grayStrikeThrough addAttribute:NSStrikethroughStyleAttributeName
                                      value:[NSNumber numberWithInt:NSUnderlineStyleSingle]
                                      range:(NSRange){0,[grayStrikeThrough length]}];
            
            [grayStrikeThrough addAttribute:NSForegroundColorAttributeName
                                      value:[UIColor lightGrayColor]
                                      range:(NSRange){0,[grayStrikeThrough length]}];
            
            cell.textLabel.attributedText = grayStrikeThrough;
        }

        return cell;
    }
    // ADD_LIST_SECTION
    else
    {
        static NSString *CellIdentifier = @"AddListPrototypeCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        return cell;
    }
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == LISTS_SECTION)
    {
        return YES;
    }
    // ADD_LIST_SECTION
    else
    {
        return NO;
    }
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        int listIndex = [self findListIndex:indexPath];
        
        // Decrement the list position of all lists that will move up the master list
        for(int j = listIndex + 1; j < [self.toDoLists count]; j++)
        {
            NSNumber *newPosition = [NSNumber numberWithInteger:(j - 1)];
            [self.toDoLists[j] setValue:newPosition forKey:@"tablePosition"];
        }
        
        // Delete the object
        [self.appDelegate.managedObjectContext deleteObject:self.toDoLists[listIndex]];
        [self.appDelegate saveContext];
        self.toDoLists = [self loadObjects:@"ToDoList"];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView reloadData];
    }
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}



- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    int movedListIndex = [self findListIndex:fromIndexPath];
    NSNumber *newPosition;
    if(fromIndexPath < toIndexPath)
    {
        // Update the list position of all list model objects
        for(long j = fromIndexPath.row + 1; j <= toIndexPath.row; j++)
        {
            newPosition = [NSNumber numberWithInteger:(j - 1)];
            [self.toDoLists[j] setValue:newPosition forKey:@"tablePosition"];
        }
    }
    else if(fromIndexPath > toIndexPath)
    {
        // Update the list position of all list model objects
        for(long j = toIndexPath.row; j < fromIndexPath.row; j++)
        {
            newPosition = [NSNumber numberWithInteger:(j + 1)];
            [self.toDoLists[j] setValue:newPosition forKey:@"tablePosition"];
        }
    }
    newPosition = [NSNumber numberWithInteger:toIndexPath.row];
    [self.toDoLists[movedListIndex] setValue:newPosition forKey:@"tablePosition"];
    
    [self.appDelegate saveContext];
    self.toDoLists = [self loadObjects:@"ToDoList"];
    [tableView reloadData];
}



#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"addList"])
    {
        TDLAddObjectViewController *addObjectVC = (TDLAddObjectViewController *)[segue destinationViewController];
        addObjectVC.backViewController = self;
    }
    else if ([[segue identifier] isEqualToString:@"goToList"])
    {
        TDLToDoListViewController *toDoListVC = (TDLToDoListViewController *)[segue destinationViewController];
        toDoListVC.toDoList = self.selectedList;
    }
}



#pragma mark - Table view delegate


// Manual segue to the selected list
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.section != LISTS_SECTION) return;
    
    int listIndex = [self findListIndex:indexPath];
    self.selectedList = self.toDoLists[listIndex];
    [self performSegueWithIdentifier:@"goToList" sender:Nil];
}


// Find the item in the store
- (int) findListIndex:(NSIndexPath *)indexPath
{
    int i = 0;
    for(NSManagedObject *listObject in self.toDoLists)
    {
        if([[listObject valueForKey:@"tablePosition"] integerValue] == indexPath.row)    break;
        i++;
    }
    return i;
}


@end
