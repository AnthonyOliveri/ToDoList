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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.appDelegate = [[UIApplication sharedApplication] delegate];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self loadListData];
}


-(void)loadListData
{
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"ToDoList" inManagedObjectContext: self.appDelegate.managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSError *error;
    ////
    self.toDoLists =  [self.appDelegate.managedObjectContext executeFetchRequest:request error:&error];
    
    // If this is the first time the app is launched, set list title to default
    if([self.toDoLists count] == 0)
    {
        NSManagedObject *newList = [NSEntityDescription insertNewObjectForEntityForName:@"ToDoList" inManagedObjectContext:self.appDelegate.managedObjectContext];
        [newList setValue:@"My To-Do List" forKey:@"listTitle"];
        [newList setValue:[NSNumber numberWithInt:0] forKey:@"listPosition"];
        [newList setValue:Nil forKey:@"itemsInList"];
    }
    [self.appDelegate saveContext];
    
    NSArray *unorderedLists =  [self.appDelegate.managedObjectContext executeFetchRequest:request error:&error];
    NSArray *descriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"listPosition" ascending:YES]];
    self.toDoLists = [unorderedLists sortedArrayUsingDescriptors:descriptors];
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
        [self loadListData];
        [self.tableView reloadData];
    }
}


// Save the new item as a managed object in the Documents/CoreData.sqlite directory
- (void)storeNewList:(NSString *)newListName
{
    NSNumber *last = [NSNumber numberWithUnsignedInteger:[self.toDoLists count]];
    NSManagedObject *newList = [NSEntityDescription insertNewObjectForEntityForName:@"ToDoList" inManagedObjectContext:self.appDelegate.managedObjectContext];
    
    [newList setValue:newListName forKey:@"listTitle"];
    [newList setValue:last forKey:@"listPosition"];
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
        cell.textLabel.text = [toDoList valueForKey:@"listTitle"];
        return cell;
    }
    // ADD_LIST_SECTION
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


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/


// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
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
        if([[listObject valueForKey:@"listPosition"] integerValue] == indexPath.row)    break;
        i++;
    }
    return i;
}



@end
