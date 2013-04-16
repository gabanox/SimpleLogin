//
//  LoginViewController.m
//  SimpleLogin
//
//  Created by Gabriel Ramirez on 4/7/13.
//  Copyright (c) 2013 badge.me. All rights reserved.
//

#import "LoginViewController.h"
#import "BackgroundLayer.h"
#import "UIStyler.h"
#import "Constants.h"
#import "AppDelegate.h"

#define CELL_HEIGHT 40
#define CELL_NUMBER_OF_ROWS 2
#define RESIZE_DISTANCE_FACTOR 50
#define OK_ALERT_BUTTON 0
#define EMPTY_LENGTH 0

#define EMPTY_STRING = @"";

typedef enum {
    USER_NAME,
    PASSWORD
} TEXTFIELDS;

typedef enum {
    USERNAME_TAG = 1,
    PASSWORD_TAG = 2
} TAGS;

@interface LoginViewController () {
    TEXTFIELDS EditedTextField;
    TAGS Tag;
    UIActivityIndicatorView *_spinner;
    IBOutlet UIButton *resetButton;
    int counter;
}

- (BOOL) validate: (UITextField *)aTextField field: (TEXTFIELDS) aField;

@property (nonatomic, retain) AppDelegate *appDelegate;
@property (nonatomic, retain) IBOutlet UITableView *loginTable;
@property (nonatomic, retain) UIButton *loginButton;
@property (nonatomic, retain) IBOutlet UIView *headerView;
@property (nonatomic, copy) NSString *tableHeader;
@property (nonatomic, retain) UITextField *username;
@property (nonatomic, retain) UITextField *password;
@property (nonatomic, retain) UITapGestureRecognizer *tapGesture;
@property (nonatomic, retain) UITapGestureRecognizer *tapGestureForSecurityCodeLayer;
@property (nonatomic, retain) UIActivityIndicatorView *spinner;
@property (nonatomic, retain) UIAlertView *statusMessage;

@end

@implementation LoginViewController

@synthesize appDelegate;
@synthesize loginTable = _loginTable;
@synthesize headerView = _headerView;
@synthesize tableHeader = _tableHeader;
@synthesize loginButton = _loginButton;
@synthesize username  = _username, password = _password;
@synthesize tapGesture  = _tapGesture;
@synthesize spinner;


#pragma mark Encapsulation

#pragma mark TableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELL_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    self.headerView = [[UIView alloc] init];
    self.headerView.bounds = self.loginTable.bounds;
    return self.headerView;
}

#pragma mark TableView Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return CELL_NUMBER_OF_ROWS;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *cellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if(cell == nil){
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if(indexPath.row == 0){
        self.username = [UIStyler styleTextFieldForLoginTableWithTableCell:cell textIndicator:@"Usuario"];
        [self.username setTag:USERNAME_TAG];
        [self.username setSpellCheckingType:UITextSpellCheckingTypeNo];
        
        self.username.textColor = [UIColor lightGrayColor];
        self.username.delegate = self;
        
        [cell.contentView addSubview:self.username];
        
    }else if(indexPath.row == 1){
        
        self.password = [UIStyler styleTextFieldForLoginTableWithTableCell:cell textIndicator:@"Contraseña"];
        [self.password setTag:PASSWORD_TAG];
        
        self.password.textColor = [UIColor lightGrayColor];
        self.password.delegate = self;
        
        [cell.contentView addSubview:self.password];
    }
    
    [cell setSelectionStyle:UITableViewCellEditingStyleNone];
    
    return cell;
}

- (void) hideKeyboardAction:(id) sender
{
    [self performSelectorOnMainThread:@selector(tapAnyWhereAction:) withObject:self.username waitUntilDone:YES];
    [self performSelector:@selector(loginButtonAction:)];
}

- (void) loginButtonAction:(id)sender
{    
    [self.loginButton addSubview:self.spinner];
    [self.spinner setCenter:CGPointMake(self.loginButton.bounds.size.width - 30, self.loginButton.bounds.size.height / 2)];
    
    BOOL valid = NO;
    NSString *msg = nil;
    
    if([self validate:self.username field:USER_NAME]){
        valid = NO;
        [self shakeView:self.loginTable];
        msg = @"El usuario no puede estar vacío";
        [self.username becomeFirstResponder];
        EditedTextField = USER_NAME;
        
    }else if([self validate:self.password field:PASSWORD]) {
        valid = NO;
        [self shakeView:self.loginTable];
        msg  = @"El password no puede estar vacío";
        [self.username resignFirstResponder];
        [self.password becomeFirstResponder];
        EditedTextField = PASSWORD;
        
    }else {
        valid = YES;
    }
    
    if(valid){ //OKAY
        
        [self.spinner startAnimating];
        
    }else {
        
    }
    
    
}

#pragma mark ViewController lifecicle

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
    
    self.loginButton = [[UIButton alloc] initWithFrame:CGRectMake(33, 250, 256, 37)];
    
    [self.loginButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    UIColor *color = [UIColor colorWithRed:20.0f/255.0f green:87.0f/255.0f blue:121.0f/255.0f alpha:1.0];
    
    [self.loginButton.titleLabel setFont:[UIFont fontWithName:@"ArialMT" size:17]];
    [self.loginButton setBackgroundColor:color];
    
    [self.loginButton.layer setBorderWidth:1.0f];
    [self.loginButton.layer setBorderColor:color.CGColor];
    [self.loginButton.layer setCornerRadius:4.0f];
    [self.loginButton.layer setBorderWidth:1.0f];
    
    self.spinner = [[UIActivityIndicatorView alloc]
                     initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    
    [self.view addSubview:self.loginButton];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAnyWhereAction:)];
    
    self.tapGesture.delegate = self;
    
    [self.loginButton setTitle:@"Ingresar" forState:UIControlStateNormal];
    [self.loginButton removeTarget:self action:nil forControlEvents:UIControlEventAllEvents];
    [self.loginButton addTarget:self action:@selector(loginButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.username.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.username.autocorrectionType = UITextAutocorrectionTypeNo;
    
    [self.password setSecureTextEntry:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.username = nil;
}

-(void) viewWillAppear:(BOOL)animated
{
    CAGradientLayer *bgLayer = [BackgroundLayer blueGradient];
    bgLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:bgLayer atIndex:0];
    
    [self resetState];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark UI Events

- (void) keyboardWillShow: (NSNotification *)keyboardNotification
{
    [self.view addGestureRecognizer:self.tapGesture];
    
    CGRect tableFrame = self.loginTable.frame;
    CGRect loginButtonFrame = self.loginButton.frame;
    
    tableFrame.origin.y -= RESIZE_DISTANCE_FACTOR;
    loginButtonFrame.origin.y -= RESIZE_DISTANCE_FACTOR;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationDelay:0.0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    self.loginTable.frame = tableFrame;
    self.loginButton.frame = loginButtonFrame;
    
    [UIView commitAnimations];
}

- (void) keyboardWillHide: (NSNotification *)keyboardNotification
{
    [self.view removeGestureRecognizer:self.tapGesture];
    
    CGRect tableFrame = self.loginTable.frame;
    CGRect loginButtonFrame = self.loginButton.frame;
    
    tableFrame.origin.y += RESIZE_DISTANCE_FACTOR;
    loginButtonFrame.origin.y += RESIZE_DISTANCE_FACTOR;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationDelay:0.0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    self.loginTable.frame = tableFrame;
    self.loginButton.frame = loginButtonFrame;
    
    [UIView commitAnimations];
    
}

- (void) tapAnyWhereAction: (UIGestureRecognizer *) gesture
{
    [self.username resignFirstResponder];
    [self.password resignFirstResponder];
    [self.loginButton setTitle:@"Ingresar" forState:UIControlStateNormal];
    [self.spinner stopAnimating];
}


#pragma mark TextField Delegate

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog(@"textFieldDidBeginEditing %@", textField.text);
    
    if([textField.text length] > 0){
        if(![textField.text isEqualToString:@"Usuario"]){
            textField.text = self.username.text;
        }
        if(![self.password.text isEqualToString:@"Contraseña"]){
            textField.text = self.password.text;
        }
    }
    [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSLog(@"textFieldDidEndEditing %@", textField.text);
    if([textField.text isEqualToString:@""]){
        
        textField.textColor = [UIColor lightGrayColor];
        
        if(textField.tag == USERNAME_TAG){
            self.username.text = @"Usuario";
        }else if(textField.tag == PASSWORD_TAG){
            self.password.text = @"Contraseña";
        }
        
    }else {
        
        if(textField.tag == USERNAME_TAG){
            self.username.text = textField.text;
        }
        if(textField.tag == PASSWORD_TAG){
            self.password.text = textField.text;
        }
        textField.textColor = [UIColor blackColor];
        
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL) textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

#pragma mark Gesture Recognizer Delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isMemberOfClass:[UIButton class]]) {
        return NO;
    }
    return YES;
}

#pragma mark Alert View Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == OK_ALERT_BUTTON){
        
        switch (EditedTextField) {
            case USER_NAME:
                [self.username becomeFirstResponder];
                break;
                
            case PASSWORD:
                [self.password becomeFirstResponder];
                break;
                
            default:
                break;
        }
        [self.spinner stopAnimating];
    }
}

#pragma mark Validators

- (BOOL) validate: (UITextField *)aTextField field: (TEXTFIELDS) aField
{
    BOOL valid;
    switch (aField) {
        case USER_NAME:
            valid = aTextField.text.length > 0 && ![aTextField.text isEqualToString:@"Usuario"] ? YES : NO;
            
            break;
            
        case PASSWORD:
            valid = aTextField.text.length > 0 && ![aTextField.text isEqualToString:@"Contraseña"] ? YES : NO;
            
            break;
            
        default:
            break;
    }
    return !valid;
}

- (void) resetState
{
    [self.username setText:@""];
    [self.password setText:@""];
    [self.loginButton setTitle:@"Ingresar" forState:UIControlStateNormal];
    [self.loginButton becomeFirstResponder];
    if(self.spinner != nil && [self.spinner isAnimating]){
        [self.spinner stopAnimating];
    }
    
    self.username.text = @"Usuario";
    self.username.textColor = [UIColor grayColor];
    
    self.password.text = @"Contraseña";
    self.password.textColor = [UIColor grayColor];
}

- (void)shakeView:(UIView *)viewToShake
{
    CGFloat t = 4.0;
    CGAffineTransform translateRight  = CGAffineTransformTranslate(CGAffineTransformIdentity, t, 0.0);
    CGAffineTransform translateLeft = CGAffineTransformTranslate(CGAffineTransformIdentity, -t, 0.0);
    
    viewToShake.transform = translateLeft;
    
    [UIView animateWithDuration:0.07 delay:0.0 options:UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat animations:^{
        [UIView setAnimationRepeatCount:2.0];
        viewToShake.transform = translateRight;
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                viewToShake.transform = CGAffineTransformIdentity;
            } completion:NULL];
        }
    }];
}

@end
