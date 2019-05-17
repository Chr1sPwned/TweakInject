#line 1 "TweakInject.xm"
#import <dlfcn.h>
#import <objc/runtime.h>
#import <stdlib.h>
#import <stdio.h>
#import <unistd.h>
#import <pthread.h>
#import <sys/stat.h>
#import <sys/types.h>
#import <sys/mman.h>


#import "substitute.h"

#define TWEAKINJECTDEBUG 1

#define DEBUGLOG(fmt, args...)\
do {\
fprintf(stderr, fmt "\n", ##args); \
} while(0)
#define LIBJAILBREAK_DYLIB      (const char *)("/usr/lib/libjailbreak.dylib")
#ifndef TWEAKINJECTDEBUG
#define printf(str, ...)
#define NSLog(str, ...)
#endif

#define dylibDir @"/var/containers/Bundle/tweaksupport/Library/MobileSubstrate/DynamicLibraries"

NSArray *sbinjectGenerateDylibList() {
    NSString *processName = [[NSProcessInfo processInfo] processName];
    
    if ([processName isEqualToString:@"launchctl"]) {
        return nil;
    }
    
    NSError *e = nil;
    NSArray *dylibDirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dylibDir error:&e];
    if (e) {
        return nil;
    }
    
    
    
    NSArray *plists = [dylibDirContents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF ENDSWITH %@", @"plist"]];
    
    NSMutableArray *dylibsToInject = [NSMutableArray array];
    
    for (NSString *plist in plists) {
        
        NSString *plistPath = [dylibDir stringByAppendingPathComponent:plist];
        NSDictionary *filter = [NSDictionary dictionaryWithContentsOfFile:plistPath];
        
        BOOL isInjected = NO;
        
        NSArray *supportedVersions = filter[@"CoreFoundationVersion"];
        if (supportedVersions) {
            if (supportedVersions.count != 1 && supportedVersions.count != 2) {
                continue; 
            }
            if (supportedVersions.count == 1 && [supportedVersions[0] doubleValue] > kCFCoreFoundationVersionNumber) {
                continue; 
            }
            if (supportedVersions.count == 2 && ([supportedVersions[0] doubleValue] > kCFCoreFoundationVersionNumber || [supportedVersions[1] doubleValue] <= kCFCoreFoundationVersionNumber)) {
                continue; 
            }
        }
        
        for (NSString *entry in filter[@"Filter"][@"Bundles"]) {
            
            if (!CFBundleGetBundleWithIdentifier((CFStringRef)entry)) {
                
                continue;
            }
            [dylibsToInject addObject:[[plistPath stringByDeletingPathExtension] stringByAppendingString:@".dylib"]];
            isInjected = YES;
            break;
        }
        if (!isInjected) {
            
            for (NSString *process in filter[@"Filter"][@"Executables"]) {
                if ([process isEqualToString:processName]) {
                    [dylibsToInject addObject:[[plistPath stringByDeletingPathExtension] stringByAppendingString:@".dylib"]];
                    isInjected = YES;
                    break;
                }
            }
        }
        if (!isInjected) {
            
            for (NSString *clazz in filter[@"Filter"][@"Classes"]) {
                
                if (!NSClassFromString(clazz)) {
                    
                    continue;
                }
                
                [dylibsToInject addObject:[[plistPath stringByDeletingPathExtension] stringByAppendingString:@".dylib"]];
                isInjected = YES;
                break;
            }
        }
    }
    [dylibsToInject sortUsingSelector:@selector(caseInsensitiveCompare:)];
    return dylibsToInject;
}

void SpringBoardSigHandler(int signo, siginfo_t *info, void *uap){
    NSLog(@"Received signal %d", signo);

    FILE *f = fopen("/var/mobile/.sbinjectSafeMode", "w");
    fprintf(f, "Hello World\n");
    fclose(f);

    raise(signo);
}

int file_exist(char *filename) {
    struct stat buffer;
    int r = stat(filename, &buffer);
    return (r == 0);
}

@interface SpringBoard : UIApplication
- (BOOL)launchApplicationWithIdentifier:(NSString *)identifier suspended:(BOOL)suspended;
@end


#include <substrate.h>
#if defined(__clang__)
#if __has_feature(objc_arc)
#define _LOGOS_SELF_TYPE_NORMAL __unsafe_unretained
#define _LOGOS_SELF_TYPE_INIT __attribute__((ns_consumed))
#define _LOGOS_SELF_CONST const
#define _LOGOS_RETURN_RETAINED __attribute__((ns_returns_retained))
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif

@class SBLockScreenViewController; @class SBDashBoardViewController; 


#line 126 "TweakInject.xm"
static void (*_logos_orig$SafeMode$SBLockScreenViewController$finishUIUnlockFromSource$)(_LOGOS_SELF_TYPE_NORMAL SBLockScreenViewController* _LOGOS_SELF_CONST, SEL, int); static void _logos_method$SafeMode$SBLockScreenViewController$finishUIUnlockFromSource$(_LOGOS_SELF_TYPE_NORMAL SBLockScreenViewController* _LOGOS_SELF_CONST, SEL, int); static void _logos_method$SafeMode$SBLockScreenViewController$alertView$cickedButtonAtIndex$(_LOGOS_SELF_TYPE_NORMAL SBLockScreenViewController* _LOGOS_SELF_CONST, SEL, UIAlertView *, NSInteger); static void (*_logos_orig$SafeMode$SBDashBoardViewController$finishUIUnlockFromSource$)(_LOGOS_SELF_TYPE_NORMAL SBDashBoardViewController* _LOGOS_SELF_CONST, SEL, int); static void _logos_method$SafeMode$SBDashBoardViewController$finishUIUnlockFromSource$(_LOGOS_SELF_TYPE_NORMAL SBDashBoardViewController* _LOGOS_SELF_CONST, SEL, int); static void _logos_method$SafeMode$SBDashBoardViewController$alertView$clickedButtonAtIndex$(_LOGOS_SELF_TYPE_NORMAL SBDashBoardViewController* _LOGOS_SELF_CONST, SEL, UIAlertView *, NSInteger); 

static void _logos_method$SafeMode$SBLockScreenViewController$finishUIUnlockFromSource$(_LOGOS_SELF_TYPE_NORMAL SBLockScreenViewController* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, int source) {
    _logos_orig$SafeMode$SBLockScreenViewController$finishUIUnlockFromSource$(self, _cmd, source);
    

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Safe Mode" message:@"Oops! SpringBoard just crashed. Neither Substitute nor Tweak Injector caused this. Do you want to respring?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Respring", nil];
    [alert show];
    [alert release];
}

static void _logos_method$SafeMode$SBLockScreenViewController$alertView$cickedButtonAtIndex$(_LOGOS_SELF_TYPE_NORMAL SBLockScreenViewController* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, UIAlertView * alertView, NSInteger buttonIndex) {
    if (buttonIndex == 1) {
        exit(0);
    }
}



static void _logos_method$SafeMode$SBDashBoardViewController$finishUIUnlockFromSource$(_LOGOS_SELF_TYPE_NORMAL SBDashBoardViewController* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, int source) {
    _logos_orig$SafeMode$SBDashBoardViewController$finishUIUnlockFromSource$(self, _cmd, source);
    

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Safe Mode" message:@"Oops! SpringBoard just crashed. Neither Substitute nor Tweak Injector caused this. Do you want to respring?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Respring", nil];
    [alert show];
    [alert release];
}

static void _logos_method$SafeMode$SBDashBoardViewController$alertView$clickedButtonAtIndex$(_LOGOS_SELF_TYPE_NORMAL SBDashBoardViewController* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, UIAlertView * alertView, NSInteger buttonIndex) {
    if (buttonIndex == 1) {
        exit(0);
    }
}



typedef void *(*dlopen_t)(const char *filename, int flag);
dlopen_t old_dlopen;

int *patched_dlopen_common(const char *filename, int flag, dlopen_t old_dl) {
    if (strstr(filename, "/var/containers/Bundle") && strstr(filename, ".dylib")) {
        
         int tries = 5;
         while (tries-- > 0) {
            old_dl(filename, flag);
            return 0;
        }
     }

    old_dl(filename, flag);
    return 0;
}

int *patched_dlopen(const char *filename, int flag)
{
    
    return patched_dlopen_common(filename, flag, old_dlopen);
}



int entitle(pid_t pid) {
    if (access(LIBJAILBREAK_DYLIB, F_OK) != 0) {
        printf("[!] %s was not found!\n", LIBJAILBREAK_DYLIB);
        return -1;
    }

    void *handle = dlopen(LIBJAILBREAK_DYLIB, RTLD_LAZY);
    if (handle == NULL) {
        printf("[!] Failed to open libjailbreak.dylib: %s\n", dlerror());
        return -1;
    }

    typedef int (*entitle_t)(pid_t pid, uint32_t flags);
    entitle_t entitle_ptr = (entitle_t)dlsym(handle, "jb_oneshot_entitle_now");
    entitle_ptr(pid, FLAG_PLATFORMIZE);
    printf("[!] Platformized.\n");

    return 0;
}

void hook_dlopen() {
    entitle(getpid());

    void *handle = dlopen("/usr/lib/libsubstitute.dylib", RTLD_NOW);
    if (!handle) {
        DEBUGLOG("%s", dlerror());
        return;
    }
    int (*substitute_hook_functions)(const struct substitute_function_hook *hooks, size_t nhooks, struct substitute_function_hook_record **recordp, int options) = dlsym(handle, "substitute_hook_functions");
  
    if (!substitute_hook_functions) {
        DEBUGLOG("%s", dlerror());
        return;
    }


    struct substitute_function_hook dl_hook;
    dl_hook.function = (void *)"dlopen";
    dl_hook.replacement = (void *)patched_dlopen;
    dl_hook.old_ptr = &old_dlopen;
    dl_hook.options = 0;
    substitute_hook_functions(&dl_hook, 1, NULL, SUBSTITUTE_NO_THREAD_SAFETY);
}

BOOL safeMode = false;

__attribute__ ((constructor))
static void ctor(void) {
    @autoreleasepool {
        
        
        
                             
                             
        hook_dlopen();
        
        if (NSBundle.mainBundle.bundleIdentifier == nil || ![NSBundle.mainBundle.bundleIdentifier isEqualToString:@"org.coolstar.SafeMode"]){
            safeMode = false;
            NSString *processName = [[NSProcessInfo processInfo] processName];
            if ([processName isEqualToString:@"backboardd"] || [NSBundle.mainBundle.bundleIdentifier isEqualToString:@"com.apple.springboard"]) {
                struct sigaction action;
                memset(&action, 0, sizeof(action));
                action.sa_sigaction = &SpringBoardSigHandler;
                action.sa_flags = SA_SIGINFO | SA_RESETHAND;
                sigemptyset(&action.sa_mask);

                sigaction(SIGQUIT, &action, NULL);
                sigaction(SIGILL, &action, NULL);
                sigaction(SIGTRAP, &action, NULL);
                sigaction(SIGABRT, &action, NULL);
                sigaction(SIGEMT, &action, NULL);
                sigaction(SIGFPE, &action, NULL);
                sigaction(SIGBUS, &action, NULL);
                sigaction(SIGSEGV, &action, NULL);
                sigaction(SIGSYS, &action, NULL);

                if (file_exist("/var/mobile/.sbinjectSafeMode")){
                    safeMode = true;
                    if ([NSBundle.mainBundle.bundleIdentifier isEqualToString:@"com.apple.springboard"]){
                        unlink("/var/mobile/.sbinjectSafeMode");
                        NSLog(@"Entering Safe Mode!");
                        {Class _logos_class$SafeMode$SBLockScreenViewController = objc_getClass("SBLockScreenViewController"); MSHookMessageEx(_logos_class$SafeMode$SBLockScreenViewController, @selector(finishUIUnlockFromSource:), (IMP)&_logos_method$SafeMode$SBLockScreenViewController$finishUIUnlockFromSource$, (IMP*)&_logos_orig$SafeMode$SBLockScreenViewController$finishUIUnlockFromSource$);{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; memcpy(_typeEncoding + i, @encode(UIAlertView *), strlen(@encode(UIAlertView *))); i += strlen(@encode(UIAlertView *)); memcpy(_typeEncoding + i, @encode(NSInteger), strlen(@encode(NSInteger))); i += strlen(@encode(NSInteger)); _typeEncoding[i] = '\0'; class_addMethod(_logos_class$SafeMode$SBLockScreenViewController, @selector(alertView:cickedButtonAtIndex:), (IMP)&_logos_method$SafeMode$SBLockScreenViewController$alertView$cickedButtonAtIndex$, _typeEncoding); }Class _logos_class$SafeMode$SBDashBoardViewController = objc_getClass("SBDashBoardViewController"); MSHookMessageEx(_logos_class$SafeMode$SBDashBoardViewController, @selector(finishUIUnlockFromSource:), (IMP)&_logos_method$SafeMode$SBDashBoardViewController$finishUIUnlockFromSource$, (IMP*)&_logos_orig$SafeMode$SBDashBoardViewController$finishUIUnlockFromSource$);{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; memcpy(_typeEncoding + i, @encode(UIAlertView *), strlen(@encode(UIAlertView *))); i += strlen(@encode(UIAlertView *)); memcpy(_typeEncoding + i, @encode(NSInteger), strlen(@encode(NSInteger))); i += strlen(@encode(NSInteger)); _typeEncoding[i] = '\0'; class_addMethod(_logos_class$SafeMode$SBDashBoardViewController, @selector(alertView:clickedButtonAtIndex:), (IMP)&_logos_method$SafeMode$SBDashBoardViewController$alertView$clickedButtonAtIndex$, _typeEncoding); }}
                    }
                }
            }

            if (!safeMode) {
                for (NSString *dylib in sbinjectGenerateDylibList()) {
                    NSLog(@"Injecting %@ into %@", dylib, NSBundle.mainBundle.bundleIdentifier);
                    void *dl = dlopen([dylib UTF8String], RTLD_LAZY | RTLD_GLOBAL);

                    if (dl == NULL) {
                        NSLog(@"Injection failed: '%s'", dlerror());
                    }
                }
            }
        }
    }
}
