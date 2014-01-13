//
//  ViewController.m
//  FacebookProfilePicture
//
//  Created by Bert Wijnants on 13/01/14.
//  Copyright (c) 2014 Smile. All rights reserved.
//

#import "ViewController.h"

#import <FacebookSDK/FacebookSDK.h>

@implementation ViewController

@synthesize profilePictureView;
@synthesize profilePictureOuterView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    FBLoginView *loginView = [[FBLoginView alloc] init];
    loginView.defaultAudience = FBSessionDefaultAudienceOnlyMe;
    loginView.publishPermissions = @[@"publish_actions"];
    loginView.readPermissions = @[@"user_photos"];
    loginView.frame = CGRectOffset(loginView.frame, (self.view.center.x - (loginView.frame.size.width / 2)), 50);
    loginView.delegate = self;
    [self.view addSubview:loginView];
    
    profilePictureView = [[FBProfilePictureView alloc] init];
    profilePictureView.frame = CGRectMake(self.view.bounds.size.width/2 - 100, 130, 200, 200);
    [self.view addSubview:profilePictureView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self action:@selector(changePicture) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Change picture" forState:UIControlStateNormal];
    button.frame = CGRectMake(self.view.bounds.size.width/2 - 200, 360, 400, 40);
    [self.view addSubview:button];
    
    NSLog(@"init");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    self.profilePictureView.profileID = user.id;
    NSLog(@"logged in as %@", user.id);
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    self.profilePictureView.profileID = nil;
}

- (void)changePicture
{
    NSLog(@"change picture");
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;
    
    self.imagePickerController = imagePickerController;
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *picture = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    
    
    [self createAlbum];
    //FBRequest *photoUploadRequest = [FBRequest requestForUploadPhoto: picture];
    //photoUploadRequest[@"album"] = "snul";
    
}

- (void)createAlbum
{
    NSMutableDictionary<FBOpenGraphObject> *album = [FBGraphObject openGraphObjectForPost];
    album[@"name"] = @"me, my selfies and i";
    album[@"description"] = @"";
    
    // check if exists
    
    FBRequest *readRequest = [FBRequest requestForGraphPath:@"me/albums" graphObject:album];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            NSLog(@"result: %@", result);
            NSString *_objectID = [result objectForKey:@"id"];
            NSString *alertTitle = @"Object successfully created";
            NSString *alertText = [NSString stringWithFormat:@"An object with id %@ has been created", _objectID];
            [[[UIAlertView alloc] initWithTitle:alertTitle
                                        message:alertText
                                       delegate:self
                              cancelButtonTitle:@"OK!"
                              otherButtonTitles:nil] show];
        } else {
            // An error occurred, we need to handle the error
            // See: https://developers.facebook.com/docs/ios/errors
            NSLog(@"%@", error);
        }
    }];
    
    
    FBRequest *request = [FBRequest requestForPostWithGraphPath:@"me/albums" graphObject:album];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            NSLog(@"result: %@", result);
            NSString *_objectID = [result objectForKey:@"id"];
            NSString *alertTitle = @"Object successfully created";
            NSString *alertText = [NSString stringWithFormat:@"An object with id %@ has been created", _objectID];
            [[[UIAlertView alloc] initWithTitle:alertTitle
                                        message:alertText
                                       delegate:self
                              cancelButtonTitle:@"OK!"
                              otherButtonTitles:nil] show];
        } else {
            // An error occurred, we need to handle the error
            // See: https://developers.facebook.com/docs/ios/errors
            NSLog(@"%@", error);
        }
    }];
}

@end
