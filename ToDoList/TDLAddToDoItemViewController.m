//
//  ToDoList_AddToDoItemViewController.m
//  ToDoList
//
//  Created by Anthony Oliveri on 12/23/13.
//  Copyright (c) 2013 Anthony Oliveri. All rights reserved.
//

#import "TDLAddToDoItemViewController.h"

@interface TDLAddToDoItemViewController ()

@property TDLAppDelegate *appDelegate;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@end


@implementation TDLAddToDoItemViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.appDelegate = [[UIApplication sharedApplication] delegate];
    [self.textField becomeFirstResponder];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if(sender != self.doneButton) return;
    
    if(self.textField.text.length > 0)
    {
        [self storeNewItem];
    }
}


// Save the new item as a managed object in the Documents/CoreData.sqlite directory
// Create a toDoItem which will be sent to TDLToDoListViewController
- (void)storeNewItem
{
    TDLToDoListViewController *toDoListVC = [self.navigationController.viewControllers objectAtIndex:0];
    NSNumber *last = [NSNumber numberWithUnsignedInteger:[toDoListVC.toDoItemObjects count]];
 
    NSManagedObject *newItem = [NSEntityDescription insertNewObjectForEntityForName:@"ToDoItem" inManagedObjectContext:self.appDelegate.managedObjectContext];
    
    [newItem setValue:self.textField.text forKey:@"itemName"];
    [newItem setValue:[NSNumber numberWithBool:NO] forKey:@"completed"];
    [newItem setValue:[NSDate date] forKey:@"creationDate"];
    [newItem setValue:last forKey:@"listPosition"];
    
    [self.appDelegate saveContext];
    
    self.toDoItem = [[TDLToDoItem alloc] init];
    self.toDoItem.itemName = self.textField.text;
    self.toDoItem.completed = NO;
    self.toDoItem.listPosition = last;
}


// Make done button on keyboard dismiss the keyboard
-(IBAction)textFieldReturn:(id)sender
{
    [sender resignFirstResponder];
}
    
    
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
