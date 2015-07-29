//
//  EIMCandidatesController.h
//  Emoji IM
//
//  Created by Genji on 2015/05/21.
//  Copyright (c) 2015 Genji App. All rights reserved.
//

#import <InputMethodKit/InputMethodKit.h>
#import <Cocoa/Cocoa.h>
#import "EIMCandidatesPanelController.h"
#import "EIMCandidatesViewController.h"

@interface EIMCandidatesController : NSObject

+ (void)setupWithServer:(IMKServer *)server;
+ (void)updateCandidatesWithString:(NSString *)string forClient:(id <IMKTextInput>)inputClient fromInputController:(id <EIMCandidatesViewDelegate>)inputController;
+ (void)closeCandidatesPanel;
+ (void)selectPreviousCandidate;
+ (void)selectNextCandidate;
+ (BOOL)isPanelVisible;

@end
