//
//  EIMAppDelegate.h
//  Emoji IM
//
//  Created by Genji on 2015/01/27.
//  Copyright (c) 2015 Genji App. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface EIMAppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, weak) IBOutlet NSMenu *menu;

@property (nonatomic, readonly, getter=isCapsLockModeEnabled) BOOL capsLockModeEnabled;
@property (nonatomic, readonly) NSInteger skinTone;
@property (nonatomic, readonly) NSArray *excludedApps;
@property (nonatomic) BOOL ignoresEisuKey;
@property (nonatomic, readonly) unsigned short keyCode;
@property (nonatomic, readonly) NSWindowController *preferencesWindowController;
@property (nonatomic, readonly) NSArray *favorites;
@property (nonatomic, readonly) BOOL showsCompositeString;

@property (nonatomic, readonly) NSDate *expiredDate;
@property (nonatomic, readonly, getter=isExpired) BOOL expired;

- (void)addExcludedApps:(NSArray *)appURLs;
- (void)removeExcludedAppsAtIndexes:(NSIndexSet *)indexes;

- (void)addFavorite:(NSDictionary *)favoriteDictionary;
- (void)removeFavoritesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceFavoriteAtIndex:(NSUInteger)index withFavorite:(NSDictionary *)favoriteDictionary;

@end

