//
//  EIMCandidatesPanelController.h
//  Emoji IM
//
//  Created by Genji on 2015/04/27.
//  Copyright (c) 2015 Genji App. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class EIMCandidatesViewController;

@interface EIMCandidatesPanelController : NSWindowController

@property (nonatomic, readonly) EIMCandidatesViewController *candidatesViewController;

@end
