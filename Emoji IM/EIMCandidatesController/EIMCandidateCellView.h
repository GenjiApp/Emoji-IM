//
//  EIMCandidateCellView.h
//  Emoji IM
//
//  Created by Genji on 2015/04/26.
//  Copyright (c) 2015 Genji App. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface EIMCandidateCellView : NSTableCellView

@property (nonatomic, weak) IBOutlet NSTextField *emojiLabel;
@property (nonatomic, weak) IBOutlet NSTextField *titleLabel;

@end
