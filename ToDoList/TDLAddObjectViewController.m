//
//  ToDoList_AddToDoItemViewController.m
//  ToDoList
//
//  Created by Anthony Oliveri on 12/23/13.
//  Copyright (c) 2013 Anthony Oliveri. All rights reserved.
//

#import "TDLAddObjectViewController.h"

@interface TDLAddObjectViewController ()

@property TDLAppDelegate *appDelegate;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) UIViewController *backViewController;

- (IBAction)cancelAdd:(id)sender;
- (IBAction)submitNewObject:(id)sender;

@end


@implementation TDLAddObjectViewController


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
    
    // This view could have been pushed from a To-Do List or the Master List
    self.backViewController = [self getBackViewController];
    if ([self.backViewController.title isEqualToString:@"To Do List"])
    {
        self.textField.placeholder = @"New Item";
        self.title = @"Add Item";
    }
    else if ([self.backViewController.title isEqualToString:@"Master List"])
    {
        self.textField.placeholder = @"New List";
        self.title = @"Add List";
    }
}


- (UIViewController *)getBackViewController
{
    NSUInteger numberOfViewControllers = self.navigationController.viewControllers.count;
    
    if (numberOfViewControllers < 2)
        return nil;
    else
        return [self.navigationController.viewControllers objectAtIndex:numberOfViewControllers - 2];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if(sender != self.doneButton) return;
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


- (IBAction)cancelAdd:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)submitNewObject:(id)sender
{
    // Pass the name of the new item back to the To Do List VC
    if ([self.backViewController.title isEqualToString:@"To Do List"])
    {
        [self performSegueWithIdentifier:@"toList" sender:sender];
    }
    // Pass the name of the new list back to the Master VC
    else if ([self.backViewController.title isEqualToString:@"Master List"])
    {
        [self performSegueWithIdentifier:@"toMaster" sender:sender];
    }
}


@end
