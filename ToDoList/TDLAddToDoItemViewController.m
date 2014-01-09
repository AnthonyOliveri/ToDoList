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
    [self.textField becomeFirstResponder];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if(sender != self.doneButton) return;
    
    if(self.textField.text.length > 0)
    {
        [self storeNewItem];
        
        self.toDoItem = [[TDLToDoItem alloc] init];
        self.toDoItem.itemName = self.textField.text;
        self.toDoItem.completed = NO;
    }
}


// Save the new item as a managed object in the Documents/CoreData.sqlite directory
- (void)storeNewItem
{
    self.appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObject *newItem = [NSEntityDescription insertNewObjectForEntityForName:@"ToDoItem" inManagedObjectContext:self.appDelegate.managedObjectContext];
    
    [newItem setValue: self.textField.text forKey:@"itemName"];
    [newItem setValue:[NSNumber numberWithBool:NO] forKey:@"completed"];
    [newItem setValue:[NSDate date] forKey:@"creationDate"];
    
    NSError *error;
    if(![self.appDelegate.managedObjectContext save:&error])
    {
        NSLog(@"Cannot store item: %@, %@", error, [error localizedDescription]);
        return;
    }
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
