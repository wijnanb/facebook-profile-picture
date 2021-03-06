//
//  ViewController.h
//  FacebookProfilePicture
//
//  Created by Bert Wijnants on 13/01/14.
//  Copyright (c) 2014 Smile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface ViewController : UIViewController <FBLoginViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (retain, nonatomic) IBOutlet FBProfilePictureView *profilePictureView;
@property (retain, nonatomic) IBOutlet UIView *profilePictureOuterView;

@property (nonatomic) UIImagePickerController *imagePickerController;

@property (retain, nonatomic) id userId;


- (void)changePicture;
- (void)uploadToAlbumId:(id)albumId withPicture:(UIImage*) picture;
- (void)setProfilePictureWithId:(id)photoId;

@end

