//
//  EIMAppDelegate.m
//  Emoji IM
//
//  Created by Genji on 2015/01/27.
//  Copyright (c) 2015 Genji App. All rights reserved.
//

#import "EIMAppDelegate.h"
#import "EIMPreferencesKeys.h"
#import "EIMResourceFileNames.h"

@interface EIMAppDelegate ()

@property (nonatomic, strong) id eventHandler;
@property (nonatomic, readwrite, getter=isCapsLockModeEnabled) BOOL capsLockModeEnabled;
@property (nonatomic, readwrite) NSInteger skinTone;
@property (nonatomic, strong) NSMutableArray *excludedAppsInternal;
@property (nonatomic, readwrite) unsigned short keyCode;
@property (nonatomic, strong) NSMutableArray *favoritesInternal;
@property (nonatomic, readwrite) BOOL showsCompositeString;

@end


@implementation EIMAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
#ifdef DEBUG
  NSLog(@"%@", NSStringFromSelector(_cmd));
#endif

  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  [userDefaults registerDefaults:@{EIMPreferencesCapsLockModeEnabledKey: @(NO),
                                   EIMPreferencesExcludedAppsKey: @[],
                                   EIMPreferencesSkinToneKey: @(-1),
                                   EIMPreferencesIgnoreEisuKeyKey: @(NO),
                                   EIMPreferencesFavoritesKey: @[],
                                   EIMPreferencesShowsCompositeStringKey: @(NO)}];

  self.capsLockModeEnabled = [userDefaults boolForKey:EIMPreferencesCapsLockModeEnabledKey];
  self.skinTone = [userDefaults integerForKey:EIMPreferencesSkinToneKey];
  self.excludedAppsInternal = [[userDefaults arrayForKey:EIMPreferencesExcludedAppsKey] mutableCopy];
  self.ignoresEisuKey = [userDefaults boolForKey:EIMPreferencesIgnoreEisuKeyKey];
  self.favoritesInternal = [[userDefaults arrayForKey:EIMPreferencesFavoritesKey] mutableCopy];
  self.showsCompositeString = [userDefaults boolForKey:EIMPreferencesShowsCompositeStringKey];

  // Caps Lock Mode、Skin Tone は Cocoa Bindings で値が変更されるので、キィ値監視をする。
  [userDefaults addObserver:self forKeyPath:EIMPreferencesCapsLockModeEnabledKey options:NSKeyValueObservingOptionNew context:NULL];
  [userDefaults addObserver:self forKeyPath:EIMPreferencesSkinToneKey options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
  [self disableEventMonitor];

  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  [userDefaults removeObserver:self forKeyPath:EIMPreferencesCapsLockModeEnabledKey];
  [userDefaults removeObserver:self forKeyPath:EIMPreferencesSkinToneKey];
}


#pragma mark -
#pragma mark Private Methods
- (void)enableEventMonitor
{
  [self disableEventMonitor];
  self.eventHandler = [NSEvent addGlobalMonitorForEventsMatchingMask:NSKeyDownMask handler:^(NSEvent *event) {
    self.keyCode = event.keyCode;
  }];
}

- (void)disableEventMonitor
{
  if(self.eventHandler) {
    [NSEvent removeMonitor:self.eventHandler];
    self.eventHandler = nil;
  }
}


#pragma mark -
#pragma mark Accessor Method
- (NSArray *)excludedApps
{
  return self.excludedAppsInternal;
}

- (void)setIgnoresEisuKey:(BOOL)ignoresEisuKey
{
  if(ignoresEisuKey && !AXIsProcessTrusted()) {
    ignoresEisuKey = NO;
  }

  _ignoresEisuKey = ignoresEisuKey;
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  if(ignoresEisuKey) {
    [self enableEventMonitor];
    [userDefaults setBool:_ignoresEisuKey forKey:EIMPreferencesIgnoreEisuKeyKey];
  }
  else {
    [self disableEventMonitor];
    [userDefaults removeObjectForKey:EIMPreferencesIgnoreEisuKeyKey];
  }
}

- (NSArray *)favorites
{
  return self.favoritesInternal;
}

- (NSWindowController *)preferencesWindowController
{
  static NSWindowController *preferencesWindowController = nil;
  if(!preferencesWindowController) {
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSStoryboard *storyboard = [NSStoryboard storyboardWithName:EIMPreferencesWindowStoryboardFileName bundle:mainBundle];
    preferencesWindowController = [storyboard instantiateInitialController];
  }

  return preferencesWindowController;
}


#pragma mark -
#pragma mark Public Methods
- (void)addExcludedApps:(NSArray *)appURLs
{
  for(NSURL *appURL in appURLs) {
    NSBundle *appBundle = [NSBundle bundleWithURL:appURL];
    if([self.excludedApps indexOfObject:appBundle.bundleIdentifier] == NSNotFound) {
      [self.excludedAppsInternal addObject:appBundle.bundleIdentifier];
    }
  }

  [[NSUserDefaults standardUserDefaults] setObject:self.excludedAppsInternal forKey:EIMPreferencesExcludedAppsKey];
}

- (void)removeExcludedAppsAtIndexes:(NSIndexSet *)indexes
{
  [self.excludedAppsInternal removeObjectsAtIndexes:indexes];

  [[NSUserDefaults standardUserDefaults] setObject:self.excludedAppsInternal forKey:EIMPreferencesExcludedAppsKey];
}

- (void)addFavorite:(NSDictionary *)favoriteDictionary
{
  [self.favoritesInternal addObject:favoriteDictionary];

  [[NSUserDefaults standardUserDefaults] setObject:self.favoritesInternal forKey:EIMPreferencesFavoritesKey];
}

- (void)removeFavoritesAtIndexes:(NSIndexSet *)indexes
{
  [self.favoritesInternal removeObjectsAtIndexes:indexes];

  [[NSUserDefaults standardUserDefaults] setObject:self.favoritesInternal forKey:EIMPreferencesFavoritesKey];
}

- (void)replaceFavoriteAtIndex:(NSUInteger)index withFavorite:(NSDictionary *)favoriteDictionary
{
  [self.favoritesInternal replaceObjectAtIndex:index withObject:favoriteDictionary];

  [[NSUserDefaults standardUserDefaults] setObject:self.favoritesInternal forKey:EIMPreferencesFavoritesKey];
}


#pragma mark -
#pragma mark NSKeyValueObserving Method
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
  if([keyPath isEqualToString:EIMPreferencesCapsLockModeEnabledKey]) {
    self.capsLockModeEnabled = [change[NSKeyValueChangeNewKey] boolValue];
  }
  else if([keyPath isEqualToString:EIMPreferencesSkinToneKey]) {
    self.skinTone = [change[NSKeyValueChangeNewKey] integerValue];
  }
}

@end
