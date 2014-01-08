//
//  ToDoList_AddToDoItemViewController.m
//  ToDoList
//
//  Created by Anthony Oliveri on 12/23/13.
//  Copyright (c) 2013 Anthony Oliveri. All rights reserved.
//

#import "TDLAddToDoItemViewController.h"

@interface TDLAddToDoItemViewController ()

@property (weak, nonatomic) IBOutlet UITextField *textField;
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
	// Do any additional setup after loading the view.
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if(sender != self.doneButton) return;
    
    [self storeNewItem];
    
    if(self.textField.text.length > 0)
    {
        self.toDoItem = [[TDLToDoItem alloc] init];
        self.toDoItem.itemName = self.textField.text;
        self.toDoItem.completed = NO;
    }
}


// Save the new item as a managed object in the Documents/CoreData.sqlite directory
- (void)storeNewItem
{
    TDLAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSManagedObject *newItem = [NSEntityDescription insertNewObjectForEntityForName:@"ToDoItem" inManagedObjectContext:context];
    
    [newItem setValue: _textField.text forKey:@"itemName"];
    [newItem setValue:NO forKey:@"completed"];
    [newItem setValue:[NSDate date] forKey:@"creationDate"];
    
    NSError *error;
    [context save:&error];
}
    
    
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
