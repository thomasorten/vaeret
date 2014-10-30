//
//  ViewController.m
//  Vaeret
//
//  Created by Thomas Orten on 10/22/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import "ViewController.h"
#import "WeatherCollectionViewCell.h"

#define defaultSearchString @"Søk etter sted"

@interface ViewController () <UITextViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property(assign) NSInteger currentTaskId;
@property (weak, nonatomic) IBOutlet UIView *searchPlaceView;
@property (weak, nonatomic) IBOutlet UIView *findMeView;
@property (weak, nonatomic) IBOutlet UIView *underlineView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *copyrightLabel;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@property (weak, nonatomic) IBOutlet UIView *weatherGridView;

@property (weak, nonatomic) IBOutlet UICollectionView *weatherCollectionView;

@property (weak, nonatomic) IBOutlet UILabel *weatherGridOneLabel;
@property (weak, nonatomic) IBOutlet UILabel *weatherGridTwoLabel;
@property (weak, nonatomic) IBOutlet UILabel *weatherGridThreeLabel;
@property (weak, nonatomic) IBOutlet UILabel *weatherGridFourLabel;
@property (weak, nonatomic) IBOutlet UILabel *weatherGridFiveLabel;
@property (weak, nonatomic) IBOutlet UILabel *weatherGridSixLabel;

@property int initialScrollOffsetPosition;
@property int initialFindMeScrollOffsetPosition;
@property int initialSearchViewYPosition;
@property int initialSearchViewXPosition;
@property int initialFindMeViewYPosition;
@property int initialCancelButtonXPosition;
@property CGRect initialTextFieldFrame;

@end

@implementation ViewController

@synthesize currentTaskId;

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.weatherGridOneLabel setText:@"\uf002"];
    [self.weatherGridTwoLabel setText:@"\uf002"];
    [self.weatherGridThreeLabel setText:@"\uf002"];
    [self.weatherGridFourLabel setText:@"\uf002"];
    [self.weatherGridFiveLabel setText:@"\uf002"];
    [self.weatherGridSixLabel setText:@"\uf002"];

    [self generateData];

    [self.placeTextField setDelegate:self];

    [self.placeTextField setBackgroundColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.7]];

    [self registerForKeyboardNotifications];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];

    self.initialSearchViewYPosition = self.searchPlaceView.frame.origin.y;
    self.initialSearchViewXPosition = self.searchPlaceView.frame.origin.x;
    self.initialFindMeViewYPosition = self.findMeView.frame.origin.y;
    self.initialCancelButtonXPosition = self.cancelButton.frame.origin.x;
    self.initialTextFieldFrame = self.placeTextField.frame;

    [self performSelector:@selector(animateLogo) withObject:nil afterDelay:0.5];
}

-(void)animateLogo
{
    [self.titleLabel.constraints enumerateObjectsUsingBlock:^(NSLayoutConstraint *constraint, NSUInteger idx, BOOL *stop) {
        if ((constraint.firstItem == self.titleLabel) &&   (constraint.firstAttribute == NSLayoutAttributeCenterY)) {
            constraint.constant = 48.0;
        }
    }];

    [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded];
    }];


//    [UIView animateWithDuration:0.6 animations:^{
//        CGRect frame;
//        // move our subView to its new position
//        frame=self.titleLabel.frame;
//        frame.origin.y = 48;
//        self.titleLabel.frame=frame;
//    }];

    [self performSelector:@selector(fadeInSearch) withObject:nil afterDelay:0.5];
}

- (IBAction)onCancelButtonPressed:(id)sender
{
    [self animateTitles:YES];
}

- (IBAction)onLocateMeButtonPressed:(id)sender
{

}

-(void)fadeInSearch
{
    [UIView animateWithDuration:0.6 animations:^{
        self.searchPlaceView.alpha = 1.0;
        self.findMeView.alpha = 1.0;
        self.copyrightLabel.alpha = 0.8;
    }];
}

// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    CGRect fieldFrame = self.searchPlaceView.frame;
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    CGPoint origin = fieldFrame.origin;
    self.initialScrollOffsetPosition = origin.y;

    CGRect findMeFrame = self.findMeView.frame;
    self.initialFindMeScrollOffsetPosition = findMeFrame.origin.y;

    origin.y -= (self.searchPlaceView.frame.origin.y+50);
    if (!CGRectContainsPoint(aRect, origin) ) {
        [UIView animateWithDuration:0.2 animations:^{
            CGRect frame;
            // move our subView to its new position
            frame = self.searchPlaceView.frame;
            frame.origin.y = (fieldFrame.origin.y+240)-(aRect.size.height);

            self.searchPlaceView.frame=frame;

            CGRect frame2;
            // move our subView to its new position
            frame2 = self.findMeView.frame;
            frame2.origin.y = (findMeFrame.origin.y)+(aRect.size.height);

            self.findMeView.frame=frame2;

            // Place popover according to new position
            [self.placeTextField setPopoverSize:CGRectMake(self.searchPlaceView.frame.origin.x, (self.searchPlaceView.frame.origin.y+self.placeTextField.frame.size.height), self.underlineView.frame.size.width, 135)];
        }];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    [UIView animateWithDuration:0.2 animations:^{
        CGRect frame;
        // move our subView to its new position
        frame=self.searchPlaceView.frame;
        frame.origin.y = self.initialScrollOffsetPosition;
        self.searchPlaceView.frame=frame;

        CGRect frame2;
        // move our subView to its new position
        frame2=self.findMeView.frame;
        frame2.origin.y = self.initialFindMeScrollOffsetPosition;
        self.findMeView.frame=frame2;
    }];
}


- (void)dismissKeyboard
{
    [self.view endEditing:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([textField.text isEqual:defaultSearchString]) {
        textField.text = @"";
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField.text isEqual:@""]) {
        textField.text = defaultSearchString;
    }
}

- (void)callPlace
{
        data = [[NSMutableArray alloc] init];
        NSString *urlString = [NSString stringWithFormat:@"http://10.0.0.49:3000/weather/places?query={\"Stadnamn\":{\"$regex\":\"^%@\",\"$options\":\"i\"}}", self.placeTextField.text];
        NSString *encodedUrlString = [urlString stringByAddingPercentEscapesUsingEncoding:
                                  NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:encodedUrlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *responseData, NSError *connectionError) {
            if (responseData) {
                NSArray *contents = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&connectionError];
                [contents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    [data addObject:[NSDictionary dictionaryWithObjectsAndKeys: [obj objectForKey:@"N"],@"DisplayText", nil]];
                }];
            }
        }];
}

- (void)generateData
{
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Add code here to do background processing
        //
        //
        NSError* err = nil;
        data = [[NSMutableArray alloc] init];
        NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"places" ofType:@"json"];
        NSArray *contents = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:dataPath] options:kNilOptions error:&err];
        dispatch_async( dispatch_get_main_queue(), ^{
            // Add code here to update the UI/send notifications based on the
            // results of the background processing
            [contents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [data addObject:[NSDictionary dictionaryWithObjectsAndKeys: [obj objectForKey:@"N"], @"DisplayText", [obj objectForKey:@"T"], @"DisplaySubText", obj, @"CustomObject", nil]];
            }];
        });
    });
}

#pragma mark MPGTextField Delegate Methods

- (NSArray *)dataForPopoverInTextField:(MPGTextField *)textField
{
    if ([textField isEqual:self.placeTextField]) {
        return data;
    }
    else{
        return nil;
    }
}

- (BOOL)textFieldShouldSelect:(MPGTextField *)textField
{
    return YES;
}

- (void)textField:(MPGTextField *)textField didEndEditingWithSelection:(NSDictionary *)result
{
        if ([textField isEqual:self.placeTextField]) {
            customProgressView = [[CustomProgressView alloc] init];
            customProgressView.delegate = self;
            [self.view addSubview:customProgressView];

            [self performSelector:@selector(setProgress:) withObject:[NSNumber numberWithFloat:1.0] afterDelay:0.1];
        }
}

-(void)setProgress:(NSNumber*)value
{
    [customProgressView performSelectorOnMainThread:@selector(setProgress:) withObject:value waitUntilDone:NO];
}

- (void)didFinishAnimation:(CustomProgressView*)progressView
{
    [progressView removeFromSuperview];

    [self performSelector:@selector(animateTitles:) withObject:nil afterDelay:0.2];
}

-(void)animateTitles:(BOOL)reverse
{
    int searchViewYPosition = self.initialSearchViewYPosition;
    int searchViewXPosition = self.initialSearchViewXPosition;
    int findMeYPosition = self.initialFindMeViewYPosition;
    int cancelButtonXPosition = self.initialCancelButtonXPosition;

    if (!reverse) {
        searchViewYPosition = 50;
        findMeYPosition = [[UIScreen mainScreen] bounds].size.height+50;
    }

    [UIView animateWithDuration:0.3 animations:^{
        self.underlineView.alpha = reverse ? 1 : 0;
        self.titleLabel.alpha = reverse ? 1 : 0;
    }];

    [UIView animateWithDuration:0.6 animations:^{

        [self.placeTextField sizeToFit];
        [self.placeTextField setEnabled:reverse];

        CGRect frame;
        // move our subView to its new position
        frame = self.searchPlaceView.frame;
        frame.origin.y = searchViewYPosition;
        frame.origin.x = reverse ? searchViewXPosition : (([[UIScreen mainScreen] bounds].size.width-self.placeTextField.frame.size.width)/2)-17;
        self.searchPlaceView.frame=frame;

        CGRect frame2;
        // move our subView to its new position
        frame2 = self.findMeView.frame;
        frame2.origin.y = findMeYPosition;
        self.findMeView.frame=frame2;

        CGRect frame3;
        // move our subView to its new position
        frame3 = self.cancelButton.frame;
        frame3.origin.x = reverse ? cancelButtonXPosition : (([[UIScreen mainScreen] bounds].size.width+self.placeTextField.frame.size.width)/2);
        self.cancelButton.frame=frame3;

        self.cancelButton.alpha = reverse ? 0 : 1;
    }];

    if (reverse) {
        self.placeTextField.frame= self.initialTextFieldFrame;
        [self performSelector:@selector(resetTextField) withObject:nil afterDelay:0.6];
        [self performSelector:@selector(animateWeatherViews:) withObject:[NSNumber numberWithBool:YES] afterDelay:0];
    } else {
        [self performSelector:@selector(animateWeatherViews:) withObject:[NSNumber numberWithBool:NO] afterDelay:0.8];
    }
}

- (void)animateWeatherViews:(NSNumber *)reverse
{
    BOOL isReverse = [reverse boolValue];
    [UIView animateWithDuration:0.6 animations:^{
        self.weatherCollectionView.alpha = isReverse ? 0 : 1;
        self.weatherGridView.alpha = isReverse ? 0 : 1;
    }];
}

-(void)resetTextField
{
    self.placeTextField.text = defaultSearchString;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return 6;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WeatherCollectionViewCell *weatherCell =
    [self.weatherCollectionView dequeueReusableCellWithReuseIdentifier:@"WeatherCell"
                                              forIndexPath:indexPath];
    [weatherCell.weatherIcon812Label setText:@"\uf002"];
    
    return weatherCell;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    
}


@end
