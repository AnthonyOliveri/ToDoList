//
//  TDLToDoListViewController.m
//  ToDoList
//
//  Created by Anthony Oliveri on 12/23/13.
//  Copyright (c) 2013 Anthony Oliveri. All rights reserved.
//

#import "TDLToDoListViewController.h"

@interface TDLToDoListViewController ()

@property TDLAppDelegate *appDelegate;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (weak, nonatomic) IBOutlet UITextField *listTitle;


@end


@implementation TDLToDoListViewController

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
    self.toDoItems = [[NSMutableArray alloc] init];
    self.appDelegate = [[UIApplication sharedApplication] delegate];
    [self loadInitialData];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
}


// Fetch all the items stored in Documents/CoreData.sqlite and load them into the toDoItems array
- (void)loadInitialData
{
    [self loadListData];
    
    self.toDoItemObjects = [self loadItemData];
    
    for(NSManagedObject *itemObject in self.toDoItemObjects)
    {
        TDLToDoItem *item = [[TDLToDoItem alloc] init];
        item.itemName = [itemObject valueForKey:@"itemName"];
        item.completed = [[itemObject valueForKey:@"completed"] boolValue];
        item.creationDate = [itemObject valueForKey:@"creationDate"];
        item.listPosition = [itemObject valueForKey:@"listPosition"];
        [self.toDoItems addObject:item];
    }
    NSArray *descriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"listPosition" ascending:YES]];
    [self.toDoItems sortUsingDescriptors:descriptors];
}


- (NSArray *)loadItemData
{
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"ToDoItem" inManagedObjectContext: self.appDelegate.managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSError *error;
    NSArray *unorderedItems =  [self.appDelegate.managedObjectContext executeFetchRequest:request error:&error];
    NSArray *descriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"listPosition" ascending:YES]];
    return [unorderedItems sortedArrayUsingDescriptors:descriptors];
}


-(void)loadListData
{
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"ToDoList" inManagedObjectContext: self.appDelegate.managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSError *error;
    self.toDoLists =  [self.appDelegate.managedObjectContext executeFetchRequest:request error:&error];
    
    // If this is the first time the app is launched, set list title to default
    if([self.toDoLists count] == 0)
    {
        NSManagedObject *newList = [NSEntityDescription insertNewObjectForEntityForName:@"ToDoList" inManagedObjectContext:self.appDelegate.managedObjectContext];
        [newList setValue:@"My To-Do List" forKey:@"title"];
    }
    [self.appDelegate saveContext];
    
    self.toDoLists =  [self.appDelegate.managedObjectContext executeFetchRequest:request error:&error];
    self.listTitle.text = [self.toDoLists[0] valueForKey:@"title"];
}


// Extract the name of the newly created item and display it
- (IBAction)unwindToList:(UIStoryboardSegue *)segue
{
    self.toDoItemObjects = [self loadItemData];
    
    TDLAddToDoItemViewController *source = [segue sourceViewController];
    TDLToDoItem *item = source.toDoItem;
    if(item != nil)
    {
        [self.toDoItems addObject:item];
        [self.tableView reloadData];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.toDoItems count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ListPrototypeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    TDLToDoItem *toDoItem = [self.toDoItems objectAtIndex:indexPath.row];
    cell.textLabel.text = toDoItem.itemName;
    
    if(toDoItem.completed)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}


- (IBAction)enterEditMode:(id)sender
{
    // Get out of editing mode
    if ([self.tableView isEditing])
    {
        [self.tableView setEditing:NO animated:YES];
        [self.editButton setTitle:@"Edit"];
    }
    // Enter editing mode
    else
    {
        [self.tableView setEditing:YES animated:YES];
        [self.editButton setTitle:@"Done"];
    }
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        int itemIndex = [self findItemIndex:indexPath];
        
        // Decrement the list position of all items that will move up the list
        for(int j = itemIndex + 1; j < [self.toDoItemObjects count]; j++)
        {
            NSNumber *newPosition = [NSNumber numberWithInteger:(j - 1)];
            [self.toDoItemObjects[j] setValue:newPosition forKey:@"listPosition"];
        }
        
        // Delete the object
        [self.appDelegate.managedObjectContext deleteObject:self.toDoItemObjects[itemIndex]];
        [self.appDelegate saveContext];
        self.toDoItemObjects = [self loadItemData];
        
        [self.toDoItems removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView reloadData];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    id object = [self.toDoItems objectAtIndex:fromIndexPath.row];
    [self.toDoItems removeObjectAtIndex:fromIndexPath.row];
    
    NSNumber *newPosition;
    if(fromIndexPath < toIndexPath)
    {
        [self.toDoItems insertObject:object atIndex:toIndexPath.row];
        
        // Update the list position of all item model objects
        for(long j = fromIndexPath.row + 1; j <= toIndexPath.row; j++)
        {
            newPosition = [NSNumber numberWithInteger:(j - 1)];
            [self.toDoItemObjects[j] setValue:newPosition forKey:@"listPosition"];
        }
    }
    else if(fromIndexPath > toIndexPath)
    {
        [self.toDoItems insertObject:object atIndex:toIndexPath.row];
        
        // Update the list position of all item model objects
        for(long j = toIndexPath.row; j < fromIndexPath.row; j++)
        {
            newPosition = [NSNumber numberWithInteger:(j + 1)];
            [self.toDoItemObjects[j] setValue:newPosition forKey:@"listPosition"];
        }
    }
    newPosition = [NSNumber numberWithInteger:toIndexPath.row];
    int itemIndex = [self findItemIndex:fromIndexPath];
    [self.toDoItemObjects[itemIndex] setValue:newPosition forKey:@"listPosition"];
    
    [self.appDelegate saveContext];
    self.toDoItemObjects = [self loadItemData];
    [tableView reloadData];
}


/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */


#pragma mark - Table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    TDLToDoItem *tappedItem = [self.toDoItems objectAtIndex:indexPath.row];
    tappedItem.completed = !tappedItem.completed;
    NSNumber *completed = [NSNumber numberWithBool:tappedItem.completed];
    
    int itemIndex = [self findItemIndex:indexPath];
    [self.toDoItemObjects[itemIndex] setValue:completed forKey:@"completed"];
    [self.appDelegate saveContext];
    
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}


- (IBAction)textFieldReturn:(id)sender
{
    // Save the title
    [self.toDoLists[0] setValue:self.listTitle.text forKey:@"title"];
    [self.appDelegate saveContext];
    
    // Dismiss the keyboard
    [sender resignFirstResponder];
}


// Find the item in the store
- (int) findItemIndex:(NSIndexPath *)indexPath
{
    int i = 0;
    for(NSManagedObject *itemObject in self.toDoItemObjects)
    {
        if([[itemObject valueForKey:@"listPosition"] integerValue] == indexPath.row)    break;
        i++;
    }
    return i;
}


@end
