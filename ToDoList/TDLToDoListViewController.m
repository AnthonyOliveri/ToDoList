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
    [self loadManagedObjects];
    
    for(NSManagedObject *itemObject in self.toDoItemObjects)
    {
        TDLToDoItem *item = [[TDLToDoItem alloc] init];
        item.itemName = [itemObject valueForKey:@"itemName"];
        item.completed = [[itemObject valueForKey:@"completed"] boolValue];
        item.creationDate = [itemObject valueForKey:@"creationDate"];
        [self.toDoItems addObject:item];
    }
}

- (void)loadManagedObjects
{
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"ToDoItem" inManagedObjectContext: self.appDelegate.managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSError *error;
    self.toDoItemObjects = [self.appDelegate.managedObjectContext executeFetchRequest:request error:&error];
}


// Extract the name of the newly created item and display it
- (IBAction)unwindToList:(UIStoryboardSegue *)segue
{
    [self loadManagedObjects];
    
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
    if ([self.tableView isEditing])
    {
        [self.tableView setEditing:NO animated:YES];
        [self.editButton setTitle:@"Edit"];
    }
    else
    {
        [self.tableView setEditing:YES animated:YES];
        [self.editButton setTitle:@"Done"];
    }
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Search for the stored item that matches the selected item
        //// Consider replacing for loop with a context predicate
        int i = 0;
        for(NSManagedObject *itemObject in self.toDoItemObjects)
        {
            TDLToDoItem *item = self.toDoItems[indexPath.row];
            NSString *currentItemName = item.itemName;
            NSString *managedObjectName = [itemObject valueForKey:@"itemName"];
            if([currentItemName isEqualToString: managedObjectName])    break;
            i++;
        }
        
        [self.appDelegate.managedObjectContext deleteObject:self.toDoItemObjects[i]];
        NSError *error = nil;
        if(![self.appDelegate.managedObjectContext save:&error])
        {
            NSLog(@"Cannot delete item: %@, %@", error, [error localizedDescription]);
            return;
        };

        [self.toDoItems removeObjectAtIndex:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}



// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    
}




// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
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
    
    // Search for the stored item that matches the selected item
    //// Consider replacing for loop with a context predicate
    int i = 0;
    for(NSManagedObject *itemObject in self.toDoItemObjects)
    {
        TDLToDoItem *item = self.toDoItems[indexPath.row];
        NSString *currentItemName = item.itemName;
        NSString *managedObjectName = [itemObject valueForKey:@"itemName"];
        if([currentItemName isEqualToString: managedObjectName])    break;
        i++;
    }
    
    NSNumber *completed = [NSNumber numberWithBool:tappedItem.completed];
    [self.toDoItemObjects[i] setValue:completed forKey:@"completed"];
    NSError *error;
    if(![self.appDelegate.managedObjectContext save:&error])
    {
        NSLog(@"Cannot update item completion: %@, %@", error, [error localizedDescription]);
        return;
    }
    
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}


@end
