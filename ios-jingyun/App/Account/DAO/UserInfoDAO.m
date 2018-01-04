//
//  UserInfoDAO.m
//  ios-jingyun-test
//
//  Created by conwin on 2017/12/12.
//  Copyright © 2017年 conwin. All rights reserved.
//

#import "UserInfoDAO.h"
#import "sqlite3.h"
#import "UserInfoModel.h"

#define DBFILE_NAME @"UserInfoList.sqlite3"

//声明UserInfoDAO扩展
@interface UserInfoDAO () {
    sqlite3 *db;
}

//UserInfoDAO扩展中DateFormatter属性是私有的
@property(nonatomic, strong) NSDateFormatter *dateFormatter;

// UserInfoDAO扩展中沙箱目录中属性列表文件路径是私有的
@property(nonatomic, strong) NSString *plistFilePath;

@end

@implementation UserInfoDAO

static UserInfoDAO *sharedSingleton = nil;

+ (UserInfoDAO *)sharedInstance {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedSingleton = [[self alloc] init];
        //初始化沙箱目录中属性列表文件路径
        sharedSingleton.plistFilePath = [sharedSingleton applicationDocumentsDirectoryFile];
        //初始化DateFormatter
        sharedSingleton.dateFormatter = [[NSDateFormatter alloc] init];
        [sharedSingleton.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        //初始化属性列表文件
        [sharedSingleton createEditableCopyOfDatabaseIfNeeded];
        
    });
    return sharedSingleton;
}

//初始化文件
- (void)createEditableCopyOfDatabaseIfNeeded {
    const char *cpath = [self.plistFilePath UTF8String];
    
    if (sqlite3_open(cpath, &db) != SQLITE_OK) {
        NSLog(@"数据库打开失败。");
    } else {
        NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS UserInfoModel (id TEXT PRIMARY KEY, userName TEXT, password TEXT, serverName TEXT, serverAddress TEXT, port TEXT, isBindSIM INTEGER, isDomainLogin INTEGER);"];
        const char *cSql = [sql UTF8String];
        if (sqlite3_exec(db, cSql, NULL, NULL, NULL) != SQLITE_OK) {
            NSLog(@"建表失败。");
        }
    }
    sqlite3_close(db);
}

- (NSString *)applicationDocumentsDirectoryFile {
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, TRUE) lastObject];
    NSString *path = [documentDirectory stringByAppendingPathComponent:DBFILE_NAME];
    NSLog(@"path = %@", path);
    return path;
}


//插入Note方法
- (int)create:(UserInfoModel *)model {
    const char *cpath = [self.plistFilePath UTF8String];
    
    if (sqlite3_open(cpath, &db) != SQLITE_OK) {
        NSLog(@"数据库打开失败。");
    } else {
        //id TEXT PRIMARY KEY, serverName TEXT, userName TEXT, password TEXT, serverAddress TEXT, port TEXT, isBindSIM INTEGER, isDomainLogin INTEGER
        NSString *sql = @"INSERT OR REPLACE INTO UserInfoModel (id, userName, password, serverName, serverAddress, port, isBindSIM, isDomainLogin) VALUES (?,?,?,?,?,?,?,?)";
        const char *cSql = [sql UTF8String];
        
        //语句对象
        sqlite3_stmt *statement;
        //预处理过程
        if (sqlite3_prepare_v2(db, cSql, -1, &statement, NULL) == SQLITE_OK) {
  
            //获取系统当前的时间戳
            NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
            NSTimeInterval a=[dat timeIntervalSince1970];
            NSString *timeString = [NSString stringWithFormat:@"%d", (int)a]; //转为字符型

            const char *infoId = [timeString UTF8String];
            
            const char *userName = [model.userName UTF8String];
            const char *serverName = [model.serverName UTF8String];
            const char *password = [model.password UTF8String];
            const char *serverAddress = [model.serverAddress UTF8String];
            const char *port = [model.port UTF8String];
            const char *bindSim = model.isBindSIM? "1" : "0";
            const char *domainLogin = model.isDomainLogin? "1" : "0";
            
            //绑定参数开始
            sqlite3_bind_text(statement, 1, infoId, -1, NULL);
            sqlite3_bind_text(statement, 2, userName, -1, NULL);
            sqlite3_bind_text(statement, 3, password, -1, NULL);
            sqlite3_bind_text(statement, 4, serverName, -1, NULL);
            sqlite3_bind_text(statement, 5, serverAddress, -1, NULL);
            sqlite3_bind_text(statement, 6, port, -1, NULL);
            sqlite3_bind_text(statement, 7, bindSim, -1, NULL);
            sqlite3_bind_text(statement, 8, domainLogin, -1, NULL);
            
            //执行插入数据
            if (sqlite3_step(statement) != SQLITE_DONE) {
                NSLog(@"插入数据失败。");
            }
        }
        sqlite3_finalize(statement);
    }
    sqlite3_close(db);
    return 0;
}

//删除UserInfoModel方法
- (int)remove:(UserInfoModel *)model {
    const char *cpath = [self.plistFilePath UTF8String];
    
    if (sqlite3_open(cpath, &db) != SQLITE_OK) {
        NSLog(@"数据库打开失败。");
    } else {
        NSString *sql = @"DELETE from UserInfoModel where id =?";
        const char *cSql = [sql UTF8String];
        
        //语句对象
        sqlite3_stmt *statement;
        //预处理过程
        if (sqlite3_prepare_v2(db, cSql, -1, &statement, NULL) == SQLITE_OK) {
            const char *idstr = [model.id UTF8String];
            
            //绑定参数开始
            sqlite3_bind_text(statement, 1, idstr, -1, NULL);
            //执行删除数据
            if (sqlite3_step(statement) != SQLITE_DONE) {
                NSLog(@"删除数据失败。");
            }
        }
        sqlite3_finalize(statement);
    }
    sqlite3_close(db);
    return 0;
}

//修改UserInfoModel方法
- (int)modify:(UserInfoModel *)model {
//    const char *cpath = [self.plistFilePath UTF8String];
//
//    if (sqlite3_open(cpath, &db) != SQLITE_OK) {
//        NSLog(@"数据库打开失败。");
//    } else {
//
//        NSString *sql = @"UPDATE UserInfoModel set content=? where cdate =?";
//        const char *cSql = [sql UTF8String];
//
//        //语句对象
//        sqlite3_stmt *statement;
//        //预处理过程
//        if (sqlite3_prepare_v2(db, cSql, -1, &statement, NULL) == SQLITE_OK) {
//
//            NSString *strDate = [self.dateFormatter stringFromDate:model.date];
//            const char *cDate = [strDate UTF8String];
//
//            const char *cContent = [model.content UTF8String];
//
//            //绑定参数开始
//            sqlite3_bind_text(statement, 1, cContent, -1, NULL);
//            sqlite3_bind_text(statement, 2, cDate, -1, NULL);
//            //执行
//            if (sqlite3_step(statement) != SQLITE_DONE) {
//                NSLog(@"修改数据失败。");
//            }
//        }
//
//        sqlite3_finalize(statement);
//
//    }
//    sqlite3_close(db);
    return 0;
}

//查询所有数据方法
- (NSMutableArray *)findAll {
    const char *cpath = [self.plistFilePath UTF8String];
    
    NSMutableArray *listData = [[NSMutableArray alloc] init];
    
    if (sqlite3_open(cpath, &db) != SQLITE_OK) {
        NSLog(@"数据库打开失败。");
    } else {
        
        NSString *sql = @"SELECT * FROM UserInfoModel";
        const char *cSql = [sql UTF8String];
        
        //语句对象
        sqlite3_stmt *statement;
        //预处理过程
        if (sqlite3_prepare_v2(db, cSql, -1, &statement, NULL) == SQLITE_OK) {
            
            //执行查询
            while (sqlite3_step(statement) == SQLITE_ROW) {
                
                char *idStr = (char *) sqlite3_column_text(statement, 0);
                NSString *id = [[NSString alloc] initWithUTF8String:idStr];
                
                char *userNameStr = (char *) sqlite3_column_text(statement, 1);
                NSString *userName = [[NSString alloc] initWithUTF8String:userNameStr];
                
                char *passwordStr = (char *) sqlite3_column_text(statement, 2);
                NSString *password = [[NSString alloc] initWithUTF8String:passwordStr];
                
                char *serverNameStr = (char *) sqlite3_column_text(statement, 3);
                NSString *serverName = [[NSString alloc] initWithUTF8String:serverNameStr];
                
                char *serverAddressStr = (char *) sqlite3_column_text(statement, 4);
                NSString *serverAddress = [[NSString alloc] initWithUTF8String:serverAddressStr];
                
                char *portStr = (char *) sqlite3_column_text(statement, 5);
                NSString *port = [[NSString alloc] initWithUTF8String:portStr];
                
                char *isBindSIMStr = (char *) sqlite3_column_text(statement, 6);
                NSString *isBindSIM = [[NSString alloc] initWithUTF8String:isBindSIMStr];
                BOOL bindSIM = [isBindSIM isEqualToString:@"1"];
                
                char *isDomainLoginStr = (char *) sqlite3_column_text(statement, 7);
                NSString *isDomainLogin = [[NSString alloc] initWithUTF8String:isDomainLoginStr];
                BOOL domainLogin = [isDomainLogin isEqualToString:@"1"];
                
                //id TEXT PRIMARY KEY, userName TEXT, password TEXT, serverName TEXT, serverAddress TEXT, port TEXT, isBindSIM INTEGER, isDomainLogin INTEGER
                
                UserInfoModel *info = [UserInfoModel new];
                info.id = id;
                info.userName = userName;
                info.password = password;
                info.serverName = serverName;
                info.serverAddress = serverAddress;
                info.port = port;
                info.isBindSIM = bindSIM;
                info.isDomainLogin = domainLogin;
 
                [listData addObject:info];
            }
            
            sqlite3_finalize(statement);
            sqlite3_close(db);
            
            return listData;
        }
        sqlite3_finalize(statement);
    }
    sqlite3_close(db);
    return listData;
}

//按照主键查询数据方法
- (UserInfoModel *)findById:(UserInfoModel *)model {
    
//    const char *cpath = [self.plistFilePath UTF8String];
//
//    if (sqlite3_open(cpath, &db) != SQLITE_OK) {
//        NSLog(@"数据库打开失败。");
//    } else {
//        NSString *sql = @"SELECT cdate,content FROM Note where cdate =?";
//        const char *cSql = [sql UTF8String];
//
//        //语句对象
//        sqlite3_stmt *statement;
//        //预处理过程
//        if (sqlite3_prepare_v2(db, cSql, -1, &statement, NULL) == SQLITE_OK) {
//            //准备参数
//            NSString *strDate = [self.dateFormatter stringFromDate:model.date];
//            const char *cDate = [strDate UTF8String];
//
//            //绑定参数开始
//            sqlite3_bind_text(statement, 1, cDate, -1, NULL);
//
//            //执行查询
//            if (sqlite3_step(statement) == SQLITE_ROW) {
//
//                char *bufDate = (char *) sqlite3_column_text(statement, 0);
//                NSString *strDate = [[NSString alloc] initWithUTF8String:bufDate];
//                NSDate *date = [self.dateFormatter dateFromString:strDate];
//
//                char *bufContent = (char *) sqlite3_column_text(statement, 1);
//                NSString *strContent = [[NSString alloc] initWithUTF8String:bufContent];
//
//                Note *note = [[Note alloc] initWithDate:date content:strContent];
//
//                sqlite3_finalize(statement);
//                sqlite3_close(db);
//
//                return note;
//            }
//        }
//        sqlite3_finalize(statement);
//    }
//    sqlite3_close(db);
    return nil;
}

@end
