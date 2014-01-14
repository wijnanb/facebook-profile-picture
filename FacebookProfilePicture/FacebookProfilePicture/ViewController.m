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
    self.userId = user.id;
    
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
    
    
    [self uploadWithPicture:picture];
}

- (void)uploadWithPicture:(UIImage*) picture
{
    NSMutableDictionary<FBOpenGraphObject> *album = [FBGraphObject openGraphObjectForPost];
    album[@"name"] = @"me, my selfies and i";
    album[@"description"] = @"";
    
    // check if album with name exists
    FBRequest *readRequest = [FBRequest requestForGraphPath:@"me/albums"];
    [readRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            NSLog(@"result: %@", result);
           
            for (NSDictionary *albumData in [result objectForKey:@"data"])
            {
                id albumId = [albumData objectForKey:@"id"];
                NSString *albumName = [albumData objectForKey:@"name"];
                
                if ([albumName isEqualToString:[album objectForKey:@"name"]]) {
                    [self uploadToAlbumId:albumId withPicture:picture];
                    return;
                }
            }
            
            // create new album
            FBRequest *request = [FBRequest requestForPostWithGraphPath:@"me/albums" graphObject:album];
            [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if (!error) {
                    NSLog(@"Album successfully created. result: %@", result);
                    
                    id albumId = [result objectForKey:@"id"];
                    [self uploadToAlbumId:albumId withPicture:picture];
                } else {
                    // An error occurred, we need to handle the error
                    // See: https://developers.facebook.com/docs/ios/errors
                    NSLog(@"%@", error);
                }
            }];
            
        } else {
            // An error occurred, we need to handle the error
            // See: https://developers.facebook.com/docs/ios/errors
            NSLog(@"%@", error);
        }
    }];
}

- (void)uploadToAlbumId:(id)albumId withPicture:(UIImage*) picture
{
    NSLog(@"upload to albumId %@", albumId);
    
    FBRequest *request = [FBRequest requestForUploadPhoto: picture];
    [request setGraphPath: [NSString stringWithFormat:@"%@/photos", albumId]];
   
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            NSLog(@"Image successfully uploaded. result: %@", result);
            
            id photoId = [result objectForKey:@"id"];
            [self performSelector:@selector(setProfilePictureWithId:) withObject:photoId afterDelay:1.0];
        } else {
            // An error occurred, we need to handle the error
            // See: https://developers.facebook.com/docs/ios/errors
            NSLog(@"%@", error);
        }
    }];
}

- (void)setProfilePictureWithId:(id)photoId
{
    //NSString *makeProfileUrl = [NSString stringWithFormat:@"https://www.facebook.com/photo.php?fbid=%@&makeprofile=1", photoId];
    
    NSString *makeProfileUrlMobile = [NSString stringWithFormat:@"https://m.facebook.com/photo.php?fbid=%@&id=%@&prof&ls=your_photo_permalink&__user=%@", photoId, self.userId, self.userId];
    
    NSLog(@"Set profile image to %@", photoId);
    NSLog(@"Open url: %@", makeProfileUrlMobile);
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: makeProfileUrlMobile]];
}

@end
