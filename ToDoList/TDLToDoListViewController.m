//
//  TDLToDoListViewController.m
//  ToDoList
//
//  Created by Anthony Oliveri on 12/23/13.
//  Copyright (c) 2013 Anthony Oliveri. All rights reserved.
//

#import "TDLToDoListViewController.h"

#define ITEMS_SECTION 0
#define ADD_ITEM_SECTION 1

@interface TDLToDoListViewController ()

@property TDLAppDelegate *appDelegate;
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


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == ITEMS_SECTION)
        return 25.0f;
    else
        return 10.0f;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.appDelegate = [[UIApplication sharedApplication] delegate];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self loadInitialData];
}


// Fetch all the lists and items stored in Documents/CoreData.sqlite
- (void)loadInitialData
{
    [self loadItemData];
    self.listTitle.text = [self.toDoList valueForKey:@"listTitle"];
}


- (void)loadItemData
{
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"ToDoItem" inManagedObjectContext: self.appDelegate.managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"listContainer = %@", self.toDoList];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *unorderedItems =  [self.appDelegate.managedObjectContext executeFetchRequest:request error:&error];
    NSArray *descriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"itemPosition" ascending:YES]];
    self.toDoItems = [unorderedItems sortedArrayUsingDescriptors:descriptors];
}


// Reload items to get the newly entered item
// Unwinds from modal segue of TDLAddToDoItemViewController
- (IBAction)unwindToList:(UIStoryboardSegue *)segue
{
    TDLAddObjectViewController *source = [segue sourceViewController];
    NSString *newItemName = source.textField.text;
    if([newItemName length] > 0)
    {
        [self storeNewItem:newItemName];
        [self loadItemData];
        [self.tableView reloadData];
    }
}


// Save the new item as a managed object in the Documents/CoreData.sqlite directory
- (void)storeNewItem:(NSString *)newItemName
{
    NSNumber *last = [NSNumber numberWithUnsignedInteger:[self.toDoItems count]];
    NSManagedObject *newItem = [NSEntityDescription insertNewObjectForEntityForName:@"ToDoItem" inManagedObjectContext:self.appDelegate.managedObjectContext];
    
    [newItem setValue:newItemName forKey:@"itemName"];
    [newItem setValue:[NSNumber numberWithBool:false] forKey:@"completed"];
    [newItem setValue:[NSDate date] forKey:@"creationDate"];
    [newItem setValue:last forKey:@"itemPosition"];
    [newItem setValue:self.toDoList forKey:@"listContainer"];
    
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
    // Section 0 is the list of to-do items
    // Section 1 is the Add Item cell
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == ITEMS_SECTION)
    {
        return [self.toDoItems count];
    }
    // ADD_ITEM_SECTION
    else
    {
        return 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == ITEMS_SECTION)
    {
        static NSString *CellIdentifier = @"ItemPrototypeCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        NSManagedObject *toDoItem = [self.toDoItems objectAtIndex:[self findItemIndex:indexPath]];
        cell.textLabel.text = [toDoItem valueForKey:@"itemName"];
        
        // Completed items get a strikethrough and are grayed out
        bool completed = [[toDoItem valueForKey:@"completed"] boolValue];
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
    // ADD_ITEM_SECTION
    else
    {
        static NSString *CellIdentifier = @"AddItemPrototypeCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        return cell;
    }
}


- (IBAction)enterEditMode:(id)sender
{
    // Get out of editing mode
    if ([self.tableView isEditing])
    {
        [self.tableView setEditing:NO animated:YES];
        [self.navigationItem.rightBarButtonItem setTitle:@"Edit"];
    }
    // Enter editing mode
    else
    {
        [self.tableView setEditing:YES animated:YES];
        [self.navigationItem.rightBarButtonItem setTitle:@"Done"];
    }
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == ITEMS_SECTION)
    {
        return YES;
    }
    // ADD_ITEM_SECTION
    else
    {
        return NO;
    }
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        int itemIndex = [self findItemIndex:indexPath];
        
        // Decrement the list position of all items that will move up the list
        for(int j = itemIndex + 1; j < [self.toDoItems count]; j++)
        {
            NSNumber *newPosition = [NSNumber numberWithInteger:(j - 1)];
            [self.toDoItems[j] setValue:newPosition forKey:@"itemPosition"];
        }
        
        // Delete the object
        [self.appDelegate.managedObjectContext deleteObject:self.toDoItems[itemIndex]];
        [self.appDelegate saveContext];
        [self loadItemData];
        
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
    int movedItemIndex = [self findItemIndex:fromIndexPath];
    NSNumber *newPosition;
    if(fromIndexPath < toIndexPath)
    {
        // Update the list position of all item model objects
        for(long j = fromIndexPath.row + 1; j <= toIndexPath.row; j++)
        {
            newPosition = [NSNumber numberWithInteger:(j - 1)];
            [self.toDoItems[j] setValue:newPosition forKey:@"itemPosition"];
        }
    }
    else if(fromIndexPath > toIndexPath)
    {
        // Update the list position of all item model objects
        for(long j = toIndexPath.row; j < fromIndexPath.row; j++)
        {
            newPosition = [NSNumber numberWithInteger:(j + 1)];
            [self.toDoItems[j] setValue:newPosition forKey:@"itemPosition"];
        }
    }
    newPosition = [NSNumber numberWithInteger:toIndexPath.row];
    [self.toDoItems[movedItemIndex] setValue:newPosition forKey:@"itemPosition"];
    
    [self.appDelegate saveContext];
    [self loadItemData];
    [tableView reloadData];
}


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"addItem"])
    {
        TDLAddObjectViewController *addObjectVC = (TDLAddObjectViewController *)[segue destinationViewController];
        addObjectVC.backViewController = self;
    }
}


#pragma mark - Table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.section != ITEMS_SECTION) return;
    
    int itemIndex = [self findItemIndex:indexPath];
    bool completed = [[self.toDoItems[itemIndex] valueForKey:@"completed"] boolValue];
    NSNumber *isCompleted = [NSNumber numberWithBool:!completed];
    
    [self.toDoItems[itemIndex] setValue:isCompleted forKey:@"completed"];
    [self.appDelegate saveContext];
    
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}


- (IBAction)textFieldReturn:(id)sender
{
    // Save the title
    [self.toDoList setValue:self.listTitle.text forKey:@"ListTitle"];
    [self.appDelegate saveContext];
    
    // Dismiss the keyboard
    [sender resignFirstResponder];
}


// Find the item in the store
- (int) findItemIndex:(NSIndexPath *)indexPath
{
    int i = 0;
    for(NSManagedObject *itemObject in self.toDoItems)
    {
        if([[itemObject valueForKey:@"itemPosition"] integerValue] == indexPath.row)    break;
        i++;
    }
    return i;
}


@end
