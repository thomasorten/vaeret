//
//  ViewController.m
//  Vaeret
//
//  Created by Thomas Orten on 10/22/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import "ViewController.h"
#import "WeatherCollectionViewCell.h"
#import "Masonry.h"

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

@property CGRect initialTextFieldFrame;

@property (nonatomic, strong) MASConstraint *logoCenterYConstraint;
@property (nonatomic, strong) MASConstraint *searchCenterYConstraint;
@property (nonatomic, strong) MASConstraint *searchCenterXConstraint;
@property (nonatomic, strong) MASConstraint *findMeCenterYConstraint;
@property (nonatomic, strong) MASConstraint *cancelButtonXConstraint;

@property float screenHeight;
@property float screenWidth;

@end

@implementation ViewController

@synthesize currentTaskId;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.screenWidth = [[UIScreen mainScreen] bounds].size.width;
    self.screenHeight = [[UIScreen mainScreen] bounds].size.height;

    [self.weatherGridOneLabel setText:@"\uf002"];
    [self.weatherGridTwoLabel setText:@"\uf002"];
    [self.weatherGridThreeLabel setText:@"\uf002"];
    [self.weatherGridFourLabel setText:@"\uf002"];
    [self.weatherGridFiveLabel setText:@"\uf002"];
    [self.weatherGridSixLabel setText:@"\uf002"];


    // Constraints
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        self.logoCenterYConstraint = make.centerY.equalTo(self.view);
    }];
    [self.searchPlaceView mas_makeConstraints:^(MASConstraintMaker *make) {
        self.searchCenterXConstraint = make.centerX.equalTo(self.view);
        self.searchCenterYConstraint = make.centerY.equalTo(self.view);
    }];
    [self.findMeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        self.findMeCenterYConstraint = make.top.equalTo(self.searchPlaceView.mas_bottom);
    }];
    [self.copyrightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-30);
    }];
    [self.weatherGridView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view).centerOffset(CGPointMake(0, self.weatherGridView.frame.size.height));
    }];
    [self.weatherCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view).centerOffset(CGPointMake(0, -70));
    }];
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(58);
        self.cancelButtonXConstraint = make.centerX.equalTo(self.view).centerOffset(CGPointMake((self.placeTextField.frame.size.width/2)+10, 0));
    }];

    [self generateData];

    [self.placeTextField setDelegate:self];

    [self.placeTextField setBackgroundColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.7]];

    [self registerForKeyboardNotifications];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];

    [self performSelector:@selector(animateLogo) withObject:nil afterDelay:0.5];
}

-(void)animateLogo
{
    self.logoCenterYConstraint.centerOffset(CGPointMake(0, -self.screenHeight*0.35));
    [UIView animateWithDuration:0.6 animations:^{
        [self.view layoutIfNeeded];
    }];

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
    self.searchCenterYConstraint.centerOffset(CGPointMake(0, -self.screenHeight*0.15));
    [UIView animateWithDuration:0.2 animations:^{
        [self.view layoutIfNeeded];
    }];
    [self.placeTextField setPopoverSize:CGRectMake(self.searchPlaceView.frame.origin.x, (self.searchPlaceView.frame.origin.y+self.placeTextField.frame.size.height), self.underlineView.frame.size.width, 135)];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    self.searchCenterYConstraint.centerOffset = (CGPointMake(0, 0));
    [UIView animateWithDuration:0.2 animations:^{
        [self.view layoutIfNeeded];
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
    [UIView animateWithDuration:0.3 animations:^{
        self.underlineView.alpha = reverse ? 1 : 0;
        self.titleLabel.alpha = reverse ? 1 : 0;
        self.findMeView.alpha = reverse ? 1 : 0;
    }];

    [UIView animateWithDuration:0.6 animations:^{

        int initialWidth = self.placeTextField.frame.size.width;

        [self.placeTextField sizeToFit];
        [self.placeTextField setEnabled:reverse];

        int newWidth = self.placeTextField.frame.size.width;

        if (reverse) {
            self.searchCenterYConstraint.centerOffset(CGPointMake(0, 0));
            self.searchCenterXConstraint.centerOffset(CGPointMake(0, 0));
        } else {
            self.searchCenterYConstraint.centerOffset(CGPointMake(0, -self.screenHeight*0.38));
            self.searchCenterXConstraint.centerOffset(CGPointMake(((initialWidth-newWidth)/2)-17, 0));
        }

        self.cancelButtonXConstraint.centerOffset(CGPointMake((self.placeTextField.frame.size.width/2)+10, 0));

        self.cancelButton.alpha = reverse ? 0 : 1;

        [UIView animateWithDuration:0.2 animations:^{
            [self.view layoutIfNeeded];
        }];

    }];

    if (reverse) {
        [self performSelector:@selector(resetTextField) withObject:nil afterDelay:0.3];
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
