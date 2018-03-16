//
//  iTetThemesViewController.m
//  iTetrinet
//
//  Created by Alex Heinz on 7/4/09.
//  Copyright (c) 2009-2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetThemesViewController.h"
#import "iTetThemesArrayController.h"
#import "iTetTheme.h"

#import "iTetUserDefaults.h"
#import "NSUserDefaults+AdditionalTypes.h"

#import "iTetCommonLocalizations.h"

#define iTetThemesPreferencesViewName	NSLocalizedStringFromTable(@"preferences.themes", @"PreferencePanes", @"Title of the 'themes' preferences pane")

@implementation iTetThemesViewController

- (id)init
{
	if (![super initWithNibName:@"ThemesPrefsView" bundle:nil])
		return nil;
	
	[self setTitle:iTetThemesPreferencesViewName];
	
	// Make note of the currently selected index in user defaults
	initialThemeSelection = [[NSUserDefaults standardUserDefaults] unarchivedObjectForKey:iTetThemesSelectionPrefKey];
	if ([initialThemeSelection count] == 1)
		[initialThemeSelection retain];
	else
		initialThemeSelection = [[NSIndexSet alloc] initWithIndex:0];
	
	return self;
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	// Re-select the saved selection indexes
	[themesTableView selectRowIndexes:initialThemeSelection
				 byExtendingSelection:NO];
	
	// Scroll the tableview to show the selection
	[themesTableView scrollRowToVisible:[initialThemeSelection firstIndex]];
}

- (void)dealloc
{
	[initialThemeSelection release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Interface Actions

- (IBAction)addTheme:(id)sender
{
	// Open an "open file" sheet
	NSOpenPanel* openSheet = [NSOpenPanel openPanel];
	
	// Configure the panel
	[openSheet setCanChooseFiles:YES];
	[openSheet setCanChooseDirectories:NO];
	[openSheet setResolvesAliases:YES];
	[openSheet setAllowsMultipleSelection:NO];
	[openSheet setAllowsOtherFileTypes:NO];
	
	// Run the panel
	[openSheet beginSheetForDirectory:nil
								 file:nil
								types:[NSArray arrayWithObject:@"cfg"]
					   modalForWindow:[[self view] window]
						modalDelegate:self
					   didEndSelector:@selector(openSheetDidEnd:returnCode:contextInfo:)
						  contextInfo:NULL];
}

#define iTetThemeLoadFailedAlertTitle					NSLocalizedStringFromTable(@"preferences.themes.loading.unable.title", @"PreferencePanes", @"Title of alert displayed when a theme fails to load")
#define iTetThemeLoadFailedAlertInformativeText			NSLocalizedStringFromTable(@"preferences.themes.loading.unable.message", @"PreferencePanes", @"Informative text on alert displayed when a theme fails to load")
#define iTetDuplicateThemeAlertTitle					NSLocalizedStringFromTable(@"preferences.themes.duplicate.title", @"PreferencePanes", @"Title of alert displayed when a user attempts to add a theme to the themes list that is a duplicate of an existing theme")
#define iTetDuplicateDefaultThemeAlertInformativeText	NSLocalizedStringFromTable(@"preferences.themes.duplicate.message", @"PreferencePanes", @"Informative text on alert displayed when the user attempts to add a theme to the themes list that is a duplicate of one of the default iTetrinet themes")
#define iTetDuplicateOtherThemeAlertInformativeText		NSLocalizedStringFromTable(@"preferences.themes.exist", @"PreferencePanes", @"Informative text on alert displayed when the user attempts to add a theme to the themes list that is a duplicate of another theme they have added (rather than one of the default themes)")

- (void)openSheetDidEnd:(NSOpenPanel*)openSheet
			 returnCode:(NSInteger)returnCode
			contextInfo:(void*)contextInfo
{
	if (returnCode != NSOKButton)
		return;
	
	// Get the selected theme file path
	NSString* themeFile = [[openSheet filenames] objectAtIndex:0];
	
	// Attempt to create the theme from the selected file
	iTetTheme* newTheme = [iTetTheme themeFromThemeFile:themeFile];
	if ((id)newTheme == [NSNull null])
	{
		// Create an alert
		NSAlert* alert = [[NSAlert alloc] init];
		
		// Configure with the error message
		[alert setMessageText:iTetThemeLoadFailedAlertTitle];
		[alert setInformativeText:[NSString stringWithFormat:iTetThemeLoadFailedAlertInformativeText, themeFile]];
		[alert addButtonWithTitle:iTetOKButtonTitle];
		
		// Dismiss the old sheet
		[openSheet orderOut:self];
		
		// Run the alert
		[alert beginSheetModalForWindow:[[self view] window]
						  modalDelegate:self
						 didEndSelector:@selector(themeErrorAlertEnded:returnCode:contextInfo:)
							contextInfo:NULL];
		return;
	}
	
	// Check if the theme is a duplicate of the default theme
	if ([[iTetTheme defaultThemes] containsObject:newTheme])
	{
		// Create an alert
		NSAlert* alert = [[NSAlert alloc] init];
		
		// Configure with the error message
		[alert setMessageText:iTetDuplicateThemeAlertTitle];
		[alert setInformativeText:[NSString stringWithFormat:iTetDuplicateDefaultThemeAlertInformativeText, [newTheme themeName]]];
		[alert addButtonWithTitle:iTetOKButtonTitle];
		
		// Dismiss the old sheet
		[openSheet orderOut:self];
		
		// Run the alert
		[alert beginSheetModalForWindow:[[self view] window]
						  modalDelegate:self
						 didEndSelector:@selector(themeErrorAlertEnded:returnCode:contextInfo:)
							contextInfo:NULL];
		return;
	}
	
	// Check for other duplicate themes
	NSArray* themeList = [themesArrayController content];
	if ([themeList containsObject:newTheme])
	{
		// Create an alert
		NSAlert* alert = [[NSAlert alloc] init];
		
		// Configure with the error message
		[alert setMessageText:iTetDuplicateThemeAlertTitle];
		[alert setInformativeText:[NSString stringWithFormat:iTetDuplicateOtherThemeAlertInformativeText, [newTheme themeName]]];
		[alert addButtonWithTitle:iTetReplaceButtonTitle];
		[alert addButtonWithTitle:iTetCancelButtonTitle];
		
		// Dismiss the old sheet
		[openSheet orderOut:self];
		
		// Run the alert
		[alert beginSheetModalForWindow:[[self view] window]
						  modalDelegate:self
						 didEndSelector:@selector(duplicateThemeAlertEnded:returnCode:theme:)
							contextInfo:[newTheme retain]];
		return;
	}
	
	// Add theme to list
	[themesArrayController addObject:newTheme];
	
	// Select and show the new theme
	NSUInteger index = [[themesArrayController arrangedObjects] indexOfObject:newTheme];
	[themesTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:index]
				 byExtendingSelection:NO];
	[themesTableView scrollRowToVisible:index];
}

#pragma mark -
#pragma mark Error Sheet Callbacks

- (void)themeErrorAlertEnded:(NSAlert*)alert
				  returnCode:(NSInteger)returnCode
				 contextInfo:(void*)contextInfo
{
	// Does nothing
}

- (void)duplicateThemeAlertEnded:(NSAlert*)alert
					  returnCode:(NSInteger)returnCode
						   theme:(iTetTheme*)newTheme
{
	// Balance the retain used to hold onto the theme
	[newTheme autorelease];
	
	// If the user pressed "cancel", do nothing
	if (returnCode == NSAlertSecondButtonReturn)
		return;
	
	// If the user chose to replace the existing theme, do so
	// Note: themes are compared by name, so, odd as this looks, it works
	[themesArrayController replaceTheme:newTheme
							  withTheme:newTheme];
	
	// Select and show the new theme
	NSUInteger index = [[themesArrayController arrangedObjects] indexOfObject:newTheme];
	[themesTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:index]
				 byExtendingSelection:NO];
	[themesTableView scrollRowToVisible:index];
}

@end
