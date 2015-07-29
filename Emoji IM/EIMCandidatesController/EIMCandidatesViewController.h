//
//  EIMCandidatesViewController.h
//  Emoji IM
//
//  Created by Genji on 2015/04/26.
//  Copyright (c) 2015 Genji App. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol EIMCandidatesViewDelegate <NSObject>

- (void)candidatesViewSelectionChanged:(NSString *)candidateString;
- (void)candidatesViewSelected:(NSString *)candidateString;

@end


@interface EIMCandidatesViewController : NSViewController

@property (nonatomic, weak) IBOutlet NSTableView *tableView;
@property (nonatomic, weak) IBOutlet NSTextField *numberOfCandidatesLabel;

@property (nonatomic, weak) id <EIMCandidatesViewDelegate> delegate;
@property (nonatomic, readonly, getter=isViewVisible) BOOL viewVisible;
@property (nonatomic, strong) NSArray *candidates;
@property (nonatomic, strong) NSArray *currentKeywords;
@property (nonatomic, readonly) NSSize footerViewSize;

@end
