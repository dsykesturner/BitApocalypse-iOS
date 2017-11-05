//
//  AdViewController.m
//  daniel_sykes-turner
//
//  Created by Daniel Sykes-Turner on 12/05/2014.
//  Copyright (c) 2014 UniverseApps. All rights reserved.
//

#import "AdViewController.h"

#import "InMobi.h"
#import "IMBanner.h"
#import "IMBannerDelegate.h"
#import "IMInterstitial.h"
#import "IMInterstitialDelegate.h"
#import "IMError.h"
//#import "IMNetworkExtras.h"
//#import "IMInMobiNetworkExtras.h"
#import "InMobiAnalytics.h"

@interface AdViewController () <IMInterstitialDelegate>

@property (strong, nonatomic) IMInterstitial *adInterstitial;

@end


@implementation AdViewController

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
    
    self.adInterstitial = [[IMInterstitial alloc] initWithAppId:@"186bd80703bf4a56b0507e0c1e649ab7"];
    
    self.adInterstitial.adMode = IMAdModeAppGallery;
    self.adInterstitial.delegate = self;
    [self.adInterstitial loadInterstitial];
}

-(IBAction)showAd:(id)sender
{
    if (self.adInterstitial.state == kIMInterstitialStateReady)
    {
        [self.adInterstitial presentInterstitialAnimated:YES];
    }
}


#pragma mark - IMInterstitalDelegate
-(void)interstitialDidReceiveAd:(IMInterstitial *)ad
{
    NSLog(@"ad received");
    NSLog(@"ad state: %u", self.adInterstitial.state);
}
-(void)interstitial:(IMInterstitial *)ad didFailToReceiveAdWithError:(IMError *)error
{
    NSLog(@"ad receive failed");
    NSLog(@"ad state: %u", self.adInterstitial.state);
}

-(void)interstitialDidDismissScreen:(IMInterstitial *)ad
{
    NSLog(@"ad dismissed");
    
    // load a new ad
    [self.adInterstitial loadInterstitial];
}
-(void)interstitialWillDismissScreen:(IMInterstitial *)ad
{
    NSLog(@"will dismiss");
}
-(void)interstitialWillPresentScreen:(IMInterstitial *)ad
{
    NSLog(@"ad presented");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
