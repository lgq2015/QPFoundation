//
//  QPCrashMonitor.m
//  QPFoundation
//
//  Created by keqiongpan@163.com on 16/4/1.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPCrashMonitor.h>
#include <execinfo.h>


/**
 *  系统定义的未截获异常处理器。
 */
static NSUncaughtExceptionHandler *QPSystemUncaughtExceptionHandler = NULL;


/**
 *  系统定义的程序崩溃异常处理器。
 */
struct sigaction QPSystemSignalHandler[NSIG] = {0};


#pragma mark - 崩溃信号异常。

@interface QPSignalException : NSException {
    NSArray *_callStackReturnAddresses;
    NSArray *_callStackSymbols;
}

@end

@implementation QPSignalException

+ (instancetype)exceptionWithName:(NSString *)name
                           reason:(NSString *)reason
                         userInfo:(NSDictionary *)userInfo
         callStackReturnAddresses:(NSArray *)callStackReturnAddresses
                 callStackSymbols:(NSArray *)callStackSymbols
{
    QPSignalException *exception;
    exception = (QPSignalException *)[self exceptionWithName:name
                                                      reason:reason
                                                    userInfo:userInfo];
    exception->_callStackReturnAddresses = callStackReturnAddresses;
    exception->_callStackSymbols = callStackSymbols;
    return exception;
}

- (NSArray *)callStackReturnAddresses
{
    return self->_callStackReturnAddresses;
}

- (NSArray *)callStackSymbols
{
    return self->_callStackSymbols;
}

@end


#pragma mark - 异常截获处理。

/**
 *  程序崩溃异常处理器。
 */
void QPCrashHandler(NSException *exception)
{
    QPCrashMonitor *monitor = [QPCrashMonitor sharedInstance];
    if ([monitor isRunning] &&
        [monitor respondsToSelector:@selector(handle:)]) {
        [monitor handle:exception];
    }
}


/**
 *  自定义的未截获异常处理器。
 */
void QPCustomUncaughtExceptionHandler(NSException *exception)
{
    // 回调自定义的程序崩溃异常处理器。

    QPCrashHandler(exception);

    // 回调系统定义的/注册之前定义的未截获异常处理器。

    if (QPSystemUncaughtExceptionHandler) {
        QPSystemUncaughtExceptionHandler(exception);
    }

    // 仍然运行两秒钟，确保记录日志等操作完成后，中断程序运行。

    NSDate *deathTime = [NSDate dateWithTimeIntervalSinceNow:2.0];
    while ([deathTime compare:[NSDate date]] < 0) {
        [[NSRunLoop currentRunLoop] runUntilDate:deathTime];
    }

    exit(EXIT_FAILURE);
}


/**
 *  自定义的程序崩溃信号处理器。
 */
void QPCustomSignalHandler(int signal, siginfo_t *info, void *uap)
{
    // 获取程序崩溃的调用堆栈。

    NSMutableArray *callStackReturnAddresses = [[NSThread callStackReturnAddresses] mutableCopy];
    NSMutableArray *callStackSymbols = [[NSThread callStackSymbols] mutableCopy];

    if (uap
        && [callStackReturnAddresses count] > 2
        && [callStackReturnAddresses count] == [callStackSymbols count]) {

        void *ip = NULL;

#if __DARWIN_UNIX03
#if defined(__arm__) || defined(__arm64__)
        ip = (void *)((ucontext_t *)uap)->uc_mcontext->__ss.__pc;
#elif defined(__i386__)
        ip = (void *)((ucontext_t *)uap)->uc_mcontext->__ss.__eip;
#elif defined(__x86_64__)
        ip = (void *)((ucontext_t *)uap)->uc_mcontext->__ss.__rip;
#endif
#else
#if defined(__arm__) || defined(__arm64__)
        ip = (void *)((ucontext_t *)uap)->uc_mcontext->ss.pc;
#elif defined(__i386__)
        ip = (void *)((ucontext_t *)uap)->uc_mcontext->ss.eip;
#elif defined(__x86_64__)
        ip = (void *)((ucontext_t *)uap)->uc_mcontext->ss.rip;
#endif
#endif

        char **symbols = backtrace_symbols(&ip, 1);
        NSNumber *faultAddress = @((NSUInteger)ip);
        NSString *faultSymbol = [NSString stringWithFormat:@"%s",
                                 symbols ? symbols[0] : NULL];
        free(symbols);

        NSRange indexRange = [faultSymbol rangeOfString:@"0"];
        if (indexRange.location != NSNotFound) {
            faultSymbol = [faultSymbol stringByReplacingCharactersInRange:indexRange
                                                               withString:@"*"];
        }

        [callStackReturnAddresses insertObject:faultAddress atIndex:2];
        [callStackSymbols insertObject:faultSymbol atIndex:2];
    }

    // 根据接收到的系统发出的程序崩溃信号，生成一个模拟的异常对象，并与一般的未
    // 截获异常一样，回调自定义的程序崩溃异常处理器，实现统一的崩溃处理入口。

    NSDictionary *signalDictionary = @{[@(SIGHUP ) stringValue]:@"SIGHUP",
                                       [@(SIGINT ) stringValue]:@"SIGINT",
                                       [@(SIGQUIT) stringValue]:@"SIGQUIT",
                                       [@(SIGILL ) stringValue]:@"SIGILL",
                                       [@(SIGTRAP) stringValue]:@"SIGTRAP",
                                       [@(SIGABRT) stringValue]:@"SIGABRT",
                                       [@(SIGEMT ) stringValue]:@"SIGEMT",
                                       [@(SIGFPE ) stringValue]:@"SIGFPE",
                                       [@(SIGKILL) stringValue]:@"SIGKILL",
                                       [@(SIGBUS ) stringValue]:@"SIGBUS",
                                       [@(SIGSEGV) stringValue]:@"SIGSEGV",
                                       [@(SIGSYS ) stringValue]:@"SIGSYS",
                                       [@(SIGPIPE) stringValue]:@"SIGPIPE",
                                       [@(SIGALRM) stringValue]:@"SIGALRM",
                                       [@(SIGTERM) stringValue]:@"SIGTERM"};

    NSString *exceptionName = [NSString stringWithFormat:@"Signal-%d(%@)",
                               signal, [signalDictionary objectForKey:
                                        [@(signal) stringValue]]];
    NSString *signalName = [NSString stringWithFormat:@"%s", strsignal(signal)];
    NSException *exception = [QPSignalException exceptionWithName:exceptionName
                                                           reason:signalName
                                                         userInfo:nil
                                         callStackReturnAddresses:callStackReturnAddresses
                                                 callStackSymbols:callStackSymbols];
    QPCrashHandler(exception);

    // 回调系统定义的/注册之前定义的程序崩溃信号处理。

    const int min_signal = 1;
    const int max_signal = sizeof(QPSystemSignalHandler) / sizeof(QPSystemSignalHandler[0]) - 1;

    if (signal < min_signal || signal > max_signal) {
        return;
    }

    struct sigaction *system_signal_handler = &QPSystemSignalHandler[signal];

    if (system_signal_handler->sa_sigaction) {
        if (system_signal_handler->sa_flags & SA_SIGINFO) {
            system_signal_handler->sa_sigaction(signal, info, uap);
        }
        else {
            system_signal_handler->sa_handler(signal);
        }
    }

    // 仍然运行两秒钟，确保记录日志等操作完成后，中断程序运行。

    NSDate *deathTime = [NSDate dateWithTimeIntervalSinceNow:2.0];
    while ([deathTime compare:[NSDate date]] < 0) {
        [[NSRunLoop currentRunLoop] runUntilDate:deathTime];
    }

    exit(EXIT_FAILURE);
}


/**
 *  判断程序崩溃异常/信号处理器当前是否在运行中。
 */
BOOL QPIsCrashHandlersRunning()
{
    return (QPSystemUncaughtExceptionHandler
            || NSGetUncaughtExceptionHandler()
            == &QPCustomUncaughtExceptionHandler);
}


/**
 *  注册程序崩溃信号处理器。
 */
void QPRegisterSignalHandler(int signal,
                            void(*handler)(int, siginfo_t *, void *))
{
    const int min_signal = 1;
    const int max_signal = sizeof(QPSystemSignalHandler) / sizeof(QPSystemSignalHandler[0]) - 1;

    if (signal < min_signal || signal > max_signal) {
        fprintf(stderr,
                "[QPFoundation] QPCrashMonitor can't be register signal [%d], "
                "because that is out of handleable signal bounds [%d~%d].",
                signal, min_signal, max_signal);
        exit(EXIT_FAILURE);
    }

    if (!handler) {
        fprintf(stderr,
                "[QPFoundation] QPCrashMonitor can't be register signal [%d] "
                "with a null handler.",
                signal);
        exit(EXIT_FAILURE);
    }

    // 如果之前注册程序崩溃处理器，则不再处理。

    struct sigaction *system_signal_handler = &QPSystemSignalHandler[signal];

    if (system_signal_handler->sa_sigaction) {
        fprintf(stderr,
                "[QPFoundation] QPCrashMonitor can't be register signal [%d], "
                "because that is already registered.",
                signal);
        exit(EXIT_FAILURE);
    }

    memset(system_signal_handler, 0, sizeof(*system_signal_handler));

    // 将系统的信号处理器记录下来，并替换为传入的新的信号处理器。

    struct sigaction custom_signal_handler = {0};

    custom_signal_handler.sa_sigaction = handler;
    sigemptyset(&custom_signal_handler.sa_mask);
    custom_signal_handler.sa_flags = SA_SIGINFO;

    sigaction(signal, &custom_signal_handler, system_signal_handler);
}


/**
 *  注销程序崩溃信号处理器。
 */
void QPUnregisterSignalHandler(int signal)
{
    const int min_signal = 1;
    const int max_signal = sizeof(QPSystemSignalHandler) / sizeof(QPSystemSignalHandler[0]) - 1;

    if ((signal < min_signal) || (signal > max_signal)) {
        return;
    }

    struct sigaction *system_signal_handler = &QPSystemSignalHandler[signal];
    sigaction(signal, system_signal_handler, NULL);
    memset(system_signal_handler, 0, sizeof(*system_signal_handler));
}


/**
 *  注册程序崩溃异常/信号处理器。
 */
void QPRegisterCrashHandlers()
{
    if (QPIsCrashHandlersRunning()) {
        return;
    }

    // 安装未截获异常处理器。

    QPSystemUncaughtExceptionHandler = NSGetUncaughtExceptionHandler();
    NSSetUncaughtExceptionHandler(&QPCustomUncaughtExceptionHandler);

    // 安装程序崩溃信号处理器。

    QPRegisterSignalHandler(SIGHUP  , &QPCustomSignalHandler);
    QPRegisterSignalHandler(SIGINT  , &QPCustomSignalHandler);
    QPRegisterSignalHandler(SIGQUIT , &QPCustomSignalHandler);
    QPRegisterSignalHandler(SIGILL  , &QPCustomSignalHandler);
//  QPRegisterSignalHandler(SIGTRAP , &QPCustomSignalHandler);
//  QPRegisterSignalHandler(SIGABRT , &QPCustomSignalHandler);
//  QPRegisterSignalHandler(SIGEMT  , &QPCustomSignalHandler);
    QPRegisterSignalHandler(SIGFPE  , &QPCustomSignalHandler);
//  QPRegisterSignalHandler(SIGKILL , &QPCustomSignalHandler);
    QPRegisterSignalHandler(SIGBUS  , &QPCustomSignalHandler);
    QPRegisterSignalHandler(SIGSEGV , &QPCustomSignalHandler);
    QPRegisterSignalHandler(SIGSYS  , &QPCustomSignalHandler);
    QPRegisterSignalHandler(SIGPIPE , &QPCustomSignalHandler);
//  QPRegisterSignalHandler(SIGALRM , &QPCustomSignalHandler);
//  QPRegisterSignalHandler(SIGTERM , &QPCustomSignalHandler);
}


/**
 *  注销程序崩溃异常/信号处理器。
 */
void QPUnregisterCrashHandlers()
{
    if (!QPIsCrashHandlersRunning()) {
        return;
    }

    // 恢复未截获异常处理器。

    NSSetUncaughtExceptionHandler(QPSystemUncaughtExceptionHandler);

    // 恢复程序崩溃信号处理器。

    QPUnregisterSignalHandler(SIGHUP);
    QPUnregisterSignalHandler(SIGINT);
    QPUnregisterSignalHandler(SIGQUIT);
    QPUnregisterSignalHandler(SIGILL);
//  QPUnregisterSignalHandler(SIGTRAP);
//  QPUnregisterSignalHandler(SIGABRT);
//  QPUnregisterSignalHandler(SIGEMT);
    QPUnregisterSignalHandler(SIGFPE);
//  QPUnregisterSignalHandler(SIGKILL);
    QPUnregisterSignalHandler(SIGBUS);
    QPUnregisterSignalHandler(SIGSEGV);
    QPUnregisterSignalHandler(SIGSYS);
    QPUnregisterSignalHandler(SIGPIPE);
//  QPUnregisterSignalHandler(SIGALRM);
//  QPUnregisterSignalHandler(SIGTERM);
}


@implementation QPCrashMonitor

#pragma mark - 公共方法。

+ (instancetype)sharedInstance
{
    static QPCrashMonitor *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

#pragma mark - 运行管理相关。

- (void)start
{
    QPRegisterCrashHandlers();
}

- (void)stop
{
    QPUnregisterCrashHandlers();
}

#pragma mark - 运行状态相关。

- (BOOL)isRunning
{
    return QPIsCrashHandlersRunning();
}

@end
