#import <libactivator/libactivator.h>
#include <lua5.3/lua.h>
#include <lua5.3/lualib.h>
#include <lua5.3/lauxlib.h>
#import "stats.h"

@interface SBApplication : NSObject
- (id)folderNames;
- (id)badgeNumberOrString;
@end

@interface SBIconListModel : NSObject
-(id)insertIcon:(id)arg1 atIndex:(unsigned long long)arg2 options:(unsigned long long)arg3 ;
-(id)insertIcon:(id)arg1 atIndex:(unsigned long long)arg2 ;
-(void)removeIconAtIndex:(unsigned long long)arg1 ;
-(unsigned long long)indexForIcon:(id)arg1 ;
@end

@interface SBIconListView : UIView
@property (nonatomic,retain) SBIconListModel * model;                                                                         //@synthesize model=_model - In the implementation block
- (id)icons;
- (void)removeIcon:(id)arg1;
- (id)iconViewForIcon:(id)arg1 ;
- (void)removeIconView:(id)arg1 ;
- (id)insertIcon:(id)arg1 atIndex:(NSUInteger)arg2 moveNow:(BOOL)arg3;
- (BOOL)isFull;
-(void)setIconsNeedLayout;
-(void)layoutIconsIfNeeded:(double)arg1 ;
-(void)layoutIconsNow;
@end

@interface SBFolder : NSObject
- (NSString *)displayName;
- (id)addIcon:(id)arg1;
- (id)indexPathForIcon:(id)arg1;
- (void)removeIconAtIndexPath:(id)arg1;
- (id)placeIcon:(id)arg1 atIndexPath:(NSIndexPath *)arg2;
-(id)insertIcon:(id)arg1 atIndexPath:(NSIndexPath *)arg2 options:(unsigned long long)arg3 ;
@end

@interface SBIconView : UIView
@end

struct SBIconImageInfo {
    CGSize size;
    CGFloat scale;
    CGFloat continuousCornerRadius;
};

@interface SBIcon : NSObject
-(long long)badgeValue;
- (SBFolder *)folder;
- (id)applicationBundleID;
- (id)nodeIdentifier;
- (id)displayNameForLocation:(int)arg1;
- (id)tags;
- (BOOL)isBookmarkIcon;
- (BOOL)isFolderIcon;
- (BOOL)isPlaceholder;
/*- (UIImage *)getIconImage:(int)arg1;
-(UIImage *)iconImageWithInfo:(SBIconImageInfo)arg1 ;*/
-(UIImage *)generateIconImageWithInfo:(struct SBIconImageInfo)arg1 ;
- (id)application;
- (BOOL)isApplicationIcon;
@end

@interface SBFolderView : UIView
//-(void)_updateIconListViews;
-(void)_removeIconListView:(SBIconListView *)arg1 ;
@end

@interface SBRootFolderView : SBFolderView
-(void)resetIconListViews;
@end

@interface SBFolderController : NSObject
@property (nonatomic,readonly) SBFolderView * folderView; 
@property(retain, nonatomic) SBFolder *folder;
@property(readonly, copy, nonatomic) NSArray *iconListViews;
-(void)layoutIconLists:(double)arg1 animationType:(long long)arg2 forceRelayout:(BOOL)arg3 ;
@end

@interface SBIconController : NSObject
+ (id)sharedInstance;
- (void)sortAppsBy:(NSString *)filePath;
- (SBFolderController *)_rootFolderController;
- (void)errorSortingApps;
- (SBFolderController *)_currentFolderController;
@end

@interface SBAlertItem : NSObject <UIAlertViewDelegate>
+ (void)activateAlertItem:(id)arg1;
- (id)alertSheet;
@end
@interface AppSortAlert : SBAlertItem
@end
@interface AppSortAlertError : SBAlertItem
@end
@interface UIImage (AppSort)
- (NSString *)averageColor;
@end

@interface SBApplicationController : NSObject
-(SBApplication *)applicationWithBundleIdentifier:(NSString *)arg1 ;
@end

typedef struct {
  int red, green, blue;
} RGBColor;

@implementation UIImage (AppSort)
 
- (NSString *)averageColor {
    CGSize size = {1, 1};
    UIGraphicsBeginImageContext(size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(ctx, kCGInterpolationMedium);
    [self drawInRect:(CGRect){.size = size} blendMode:kCGBlendModeCopy alpha:1];
    uint8_t *data = (uint8_t *)CGBitmapContextGetData(ctx);
    UIGraphicsEndImageContext();
    return [NSString stringWithFormat:@"%02X%02X%02X",data[0],data[1],data[2]];
}

@end

/*%subclass AppSortAlertError : SBAlertItem
- (id)alertSheet {
	return [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error trying to sort apps by the selected script. Please contact the script creator." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
}
%end

%subclass AppSortAlert : SBAlertItem
- (id)alertSheet {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sort Apps By..." message:@"test" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
	NSArray *scripts = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/Library/Application Support/AppSort/" error:nil];
	for (NSString *string in scripts) {
		if ([string rangeOfString:@".lua"].location != NSNotFound) {
			NSString *buttonTitle = [string stringByReplacingOccurrencesOfString:@".lua" withString:@""];
			[alertView addButtonWithTitle:buttonTitle];
		}
	}

	return alertView;
}
- (void)alertView:(id)arg1 clickedButtonAtIndex:(NSInteger)arg2 {
	if (arg2 != 0) {
		NSString *formattedPath = [NSString stringWithFormat:@"/Library/Application Support/AppSort/%@.lua",[arg1 buttonTitleAtIndex:arg2]];
		[[%c(SBIconController) sharedInstance] sortAppsBy:formattedPath];
	}
	%orig;
}
%end*/

@interface AppSortListener : NSObject <LAListener>
@end
@implementation AppSortListener
- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {
	//AppSortAlert *alert = [[%c(AppSortAlert) alloc] init];
	//UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sort Apps By..." message:@"test" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sort Apps By..." message:nil preferredStyle:UIAlertControllerStyleAlert];

	NSArray *scripts = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/Library/Application Support/AppSort/" error:nil];
	//long long index = 0;
	for (NSString *string in scripts) {
		if ([string rangeOfString:@".lua"].location != NSNotFound) {
			//index++;
			NSString *buttonTitle = [string stringByReplacingOccurrencesOfString:@".lua" withString:@""];
			//[alertView addButtonWithTitle:buttonTitle];
			[alertController addAction:[UIAlertAction actionWithTitle:buttonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
				//if (index != 0) {
					NSString *formattedPath = [NSString stringWithFormat:@"/Library/Application Support/AppSort/%@.lua",buttonTitle];
					[[%c(SBIconController) sharedInstance] sortAppsBy:formattedPath];
				//}
			}]];
		}
	}

	for (UIWindow *window in [UIApplication sharedApplication].windows) {
		if (window.isKeyWindow) {
			[alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
			[window.rootViewController presentViewController:alertController animated:YES completion:nil];
			break;
		}
	}
}
- (NSString *)activator:(LAActivator *)activator requiresLocalizedTitleForListenerName:(NSString *)listenerName {
	return @"App Sort";
}
- (NSString *)activator:(LAActivator *)activator requiresLocalizedDescriptionForListenerName:(NSString *)listenerName {
	return @"Sort your apps";
}
- (NSArray *)activator:(LAActivator *)activator requiresCompatibleEventModesForListenerWithName:(NSString *)listenerName {
	return @[@"springboard"];
}
- (NSData *)activator:(LAActivator *)activator requiresIconDataForListenerName:(NSString *)listenerName scale:(CGFloat *)scale {
	return [NSData dataWithContentsOfURL:[NSURL URLWithString:@"/Library/PreferenceBundles/appsort.bundle/icon.png"]];
}
@end

static int l_concat_args(lua_State *L, const char *func_name, const char *separator)
{
    int n = lua_gettop(L);
    int i;
    NSMutableString *result = [NSMutableString string];
    lua_getglobal(L, "tostring");
    for (i=1; i<=n; i++) {
        const char *s;
        lua_pushvalue(L, -1);
        lua_pushvalue(L, i);
        lua_call(L, 1, 1);
        s = lua_tolstring(L, -1, NULL);
        if (s == NULL) return -1;
        if (i>1) [result appendFormat:@"%s", separator];
        [result appendFormat:@"%s", s];
        lua_pop(L, 1);
    }
    lua_pop(L, 1);
    lua_pushstring(L, result.UTF8String);
    return 1;
}

static int l_print(lua_State *L) {
	l_concat_args(L, "print", "\t");
	NSLog(@"AppSortLog AppSort Script: %s", lua_tostring(L,-1));
	return 0;
}

/*%hook SBIconListModel
-(id)insertIcon:(id)arg1 atIndex:(unsigned long long)arg2 {
	NSLog(@"AppSortLog SBIconListModel--- insertIcon:%@ atIndexPath:%llu return:%@", arg1, arg2, %orig);
	//%orig;
	return %orig;
}
-(id)insertIcon:(id)arg1 atIndex:(unsigned long long)arg2 options:(unsigned long long)arg3 {
	NSLog(@"AppSortLog SBIconListModel--- insertIcon:%@ atIndexPath:%llu options:%llu return:%@", arg1, arg2, arg3, %orig);
	//%orig;
	return %orig;
}
%end

%hook SBFolder
-(id)insertIcon:(id)arg1 atIndexPath:(NSIndexPath *)arg2 options:(unsigned long long)arg3 {
	NSLog(@"AppSortLog SBFolder--- insertIcon:%@ atIndexPath:%@ options:%llu return:%@", arg1, arg2, arg3, %orig);
	//%orig;
	return %orig;
}
%end*/

%hook SBIconController
%new
- (void)sortAppsBy:(NSString *)filePath {
	NSLog(@"AppSortLog Preparing icons...");
	//Create an array with arrays to be converted into lua tables for external script processing, also create a dictionary so we can look up icons based on id's
	NSMapTable *iconDictionary = [[NSMapTable alloc] init];
	NSMutableArray *inputApps = [[NSMutableArray alloc] init];
	NSNumber *numberForFolderIdentification = @0;
  SBFolderController *controller = ([self _currentFolderController])?[self _currentFolderController]:[self _rootFolderController];
	for (SBIconListView *listview in controller.iconListViews) {
		for (SBIcon *icon in [listview icons]) {
			NSString *name = [icon displayNameForLocation:0];
			if (name == nil) name = @"unknown";
		//NSLog(@"AppSortLog app name: %@", name);
			NSString *identifier = [icon nodeIdentifier];
			if (![identifier isKindOfClass:[NSString class]] || identifier == nil) {
				identifier = [numberForFolderIdentification stringValue];
				numberForFolderIdentification = [NSNumber numberWithInt:[numberForFolderIdentification intValue]+1];
			}
			CGSize imageSize = CGSizeMake(60, 60);
			struct SBIconImageInfo imageInfo;
			imageInfo.size  = imageSize;
			imageInfo.scale = [UIScreen mainScreen].scale;
			imageInfo.continuousCornerRadius = 12;
			UIImage *iconImage = [icon generateIconImageWithInfo:imageInfo];
			NSString *color = [iconImage averageColor];
			if (color == nil)color = @"FFFFFF";
    	//NSLog(@"AppSortLog Average Color %@",[iconImage averageColor]);
    	//NSLog(@"AppSortLog primary Color %@",color);
			NSString *genre = @"Other";
			NSString *type = @"Application";
			NSString *usage = @"0";
			if ([icon isApplicationIcon]) {
				//SBApplication *app = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:[icon applicationBundleID]];
				genre = [[icon folder] displayName];
				usage = [[ASStatManager sharedInstance] screenTimeForIdentifier:identifier];
				if (usage == nil)usage = @"0";
				if(genre == nil)genre = @"Application";
			}
			else if ([icon isBookmarkIcon]) {
				genre = @"Webclip";
				type = @"Webclip";
			}
			else if ([icon isFolderIcon]) {
				genre = @"Folder";
				type = @"Folder";
			}
			//SBApplication *app = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:[icon applicationBundleID]];
			NSString *badge = [NSString stringWithFormat:@"%lld", [icon badgeValue]];
			if ([badge isKindOfClass:[NSNumber class]]) {
				badge = [(NSNumber *)badge stringValue];
			}
			else if (badge == nil)badge = @"0";
			else if ([badge isEqual:@""])badge = @"0";

			

			if (![icon isPlaceholder] && ![icon isKindOfClass:[%c(ANPlaceHolderIcon) class]]) {
				[iconDictionary setObject:icon forKey:identifier];
				[inputApps addObject:[NSArray arrayWithObjects:name,color,genre,identifier,type,badge,usage,nil]];
			}


		}
	}
	NSLog(@"AppSortLog Sorting icons... %@", filePath);
	//Initialize lua and get libraries ready
	lua_State *L = luaL_newstate();
	luaL_openlibs(L);
	lua_settop(L, 0);
	lua_pushcfunction(L, l_print);
    lua_setglobal(L, "print");

	//start lua file
	luaL_dofile(L, [filePath cStringUsingEncoding:NSUTF8StringEncoding]);

	//get the main function we use
    lua_getglobal(L, "sort");

    //start creating the argument we pass to the sort function
    lua_newtable(L);
    for (int i = 0; i < [inputApps count]; i++) {
    	//keys we use in the table for each icon
        const char *q[7] = {"name","color","genre","id","type","badge","usage"};
        //create the "icon"
        lua_newtable(L);
        //add objects to keys, fills in the "icon" table with appropriate values
        for (int o = 0; o < 7; o++) {
            lua_pushstring(L, [[NSString stringWithFormat:@"%@", [[inputApps objectAtIndex:i] objectAtIndex:o]] cStringUsingEncoding:NSUTF8StringEncoding]);
            lua_setfield(L, -2, q[o]);
        }
        //adds the "icon" table to the table of icons
        lua_rawseti(L, -2, i+1);
    }
    //call the sort function with the table we just created as an argument
    lua_pcall(L, 1, 1, 0);
   
    NSMutableArray *sortedIds = [[NSMutableArray alloc] init];
    for (int p = 0; p < [inputApps count]; p++) {
    	//push the number of the icon table we want to get and then get that table
    	if (lua_istable(L, -1)) {
			NSLog(@"AppSortLog YAY1");
    		lua_rawgeti(L, -1,p+1);
    	} else {
			NSLog(@"AppSortLog NAY1");
    		[self errorSortingApps];
    		goto clean;
    	}
    	//push the "id" string to get the identifier of the icon
    	lua_pushstring(L, "id");
    	if (lua_istable(L, -2)) {
			NSLog(@"AppSortLog YAY2");
    		lua_gettable(L, -2);
    	} else {
			NSLog(@"AppSortLog NAY2");
    		[self errorSortingApps];
    		goto clean;
    		//lua_gettable(L, -2);
    	}
    	//move the icon identifier from the lua stack to an nsarray
    	if (lua_isstring(L,-1)) {
			NSLog(@"AppSortLog YAY3");
     		[sortedIds addObject:[NSString stringWithFormat:@"%s",lua_tostring(L, -1)]];
     	}
     	else {
			NSLog(@"AppSortLog NAY3");
     		[self errorSortingApps];
     		goto clean;
     	}
     	//clear some values off the lua stack
     	lua_pop(L, 2);
    }
    //close lua session
    NSLog(@"AppSortLog making sure all icons are included in script and no duplicates...");
    NSMutableArray *added = [[NSMutableArray alloc] init];
    for (NSString *ii in sortedIds) {
      if (![added containsObject:ii]) {
		NSLog(@"AppSortLog YAY4");
        [added addObject:ii];
      } else {
		NSLog(@"AppSortLog NAY4");
        [self errorSortingApps];
        goto clean;
      }
    }
    NSEnumerator *enumerator = [iconDictionary keyEnumerator];
    NSString *key;
    while ((key = [enumerator nextObject])) {
      if (![sortedIds containsObject:key]) {
        [self errorSortingApps];
        goto clean;
      }
    }
    NSLog(@"AppSortLog removing icons...");
  	//remove all icons
  	for (SBIconListView *listview in [self _rootFolderController].iconListViews) {
  		for (SBIcon *icon in [listview icons]) {
			/*SBIconView *iconView = [listview iconViewForIcon:icon];
  			[listview removeIconView:iconView];*/
			[listview.model removeIconAtIndex:[listview.model indexForIcon:icon]];
  		}
  	}
  	//NSLog(@"AppSortLog %@",sortedIds);
  	NSLog(@"AppSortLog Adding back icons...");
  	//add back icons hopefully in correct order
	NSArray<SBIconListView *> *listViews = [self _rootFolderController].iconListViews;
  	int cL = 0;
  	int cI = 0;
  	for (NSString *iconId in sortedIds) {
  		//NSUInteger indexes[2] = {0,0};
  		//NSIndexPath *path = [[NSIndexPath indexPathWithIndexes:indexes length:2] retain];
		if (cI == 24) {
  		//if ([[listViews objectAtIndex:cL] isFull]) {
  			cL++;
  			cI = 0;
  		}
		/*if (cL == [listViews count])
		[[listViews objectAtIndex:(cL-1)].model insertIcon:[iconDictionary objectForKey:iconId] atIndex:cI options:0];
  		else*/
		[[listViews objectAtIndex:cL].model insertIcon:[iconDictionary objectForKey:iconId] atIndex:cI options:0];
		cI++;
		//if (iconId) {}
  		//[[self _rootFolderController].folder insertIcon:[iconDictionary objectForKey:iconId] atIndexPath:path options:0];
  		//[path release];
  	}
	//[[self _rootFolderController] resetIconListViews];
	for (int i=0; i<([listViews count]-1); i++) {
	//for (SBIconListView *listView in listViews) {
		[listViews[i] setIconsNeedLayout];
		[listViews[i] layoutIconsIfNeeded:0];
		SBRootFolderView *rootFolderView = (SBRootFolderView *)[self _rootFolderController].folderView;
		if ([listViews[i].icons count] == 0)
		[rootFolderView _removeIconListView:listViews[i]];
	}
  	//clean up
  	clean:
  	NSLog(@"AppSortLog Cleaning up...");
  	lua_close(L);
   	[sortedIds release];
    [iconDictionary release];
    [inputApps release];
}
%new
- (void)errorSortingApps {
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"There was an error trying to sort apps by the selected script. Please contact the script creator." preferredStyle:UIAlertControllerStyleAlert];
	
	for (UIWindow *window in [UIApplication sharedApplication].windows) {
		if (window.isKeyWindow) {
			[alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
			[window.rootViewController presentViewController:alertController animated:YES completion:nil];
			break;
		}
	}
}
%end

%ctor {
	[[LAActivator sharedInstance] registerListener:[[AppSortListener alloc] init] forName:@"com.broganminer.appsort"];
}