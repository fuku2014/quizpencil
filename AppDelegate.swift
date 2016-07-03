/**
 AppDelegate
 
 AppDelegateクラス
 
 - Author: fuku
 - Copyright: Copyright (c) 2016 fuku. All rights reserved.
 - Date: 2016/6/18
 - Version: 2.0
 */

import UIKit
import NCMB
import FMDB

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    /**
     didFinishLaunchingWithOptions
     
     NiftyCloudの初期化とプッシュ通知の確認を実施する
     */
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // initialize NCMB
        NCMB.setApplicationKey(NCMBConfig.API_KEY, clientKey: NCMBConfig.CLI_KEY)
        // Push Notification
        let settings = UIUserNotificationSettings(forTypes: [.Badge, .Sound, .Alert], categories:nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        UIApplication.sharedApplication().registerForRemoteNotifications()
        // dbMigration
        dbMigration()
        return true
    }
    
    /**
     didFailToRegisterForRemoteNotificationsWithError
     
     Push通知確認が失敗した場合の処理、とりあえずエラーログを出力しとく
     */
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError ) {
        print("didFailToRegisterForRemoteNotificationsWithError: " + error.localizedDescription )
        NSUserDefaults.standardUserDefaults().setObject("", forKey: "INSTALLATION_ID")
    }
    
    /**
     didRegisterForRemoteNotificationsWithDeviceToken
     
     デバイストークンをncmbに送信する
     */
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData ) {
        let installation : NCMBInstallation = NCMBInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackgroundWithBlock { (actualError) in
            // save objectId
            NSUserDefaults.standardUserDefaults().setObject(installation.objectId, forKey: "INSTALLATION_ID")
            // duplicate error
            if actualError != nil && actualError.code == 409001 {
                self.updateExistInstallation(installation)
            }
        }
    }
    
    /**
     updateExistInstallation
     
     デバイストークンが重複している場合上書きする
     */
    func updateExistInstallation(installation : NCMBInstallation) {
        let installationQuery : NCMBQuery = NCMBInstallation.query()
        installationQuery.whereKey("deviceToken", equalTo: installation.deviceToken)
        var error: NSError?
        let searchDevice : NCMBInstallation = try! installationQuery.getFirstObject() as! NCMBInstallation
        installation.objectId = searchDevice.objectId;
        installation.save(&error)
    }
    
    /**
     dbMigration
     
     既存ユーザーがローカルで持っているsqliteをRealmにマイグレーションする
     */
    func dbMigration() {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let file = paths[0] + "/MAINDB.db"
        //DBファイルがあるか確認
        if NSFileManager.defaultManager().fileExistsAtPath(file) {
            let db = FMDatabase(path: file)
            var update = ""
            var ncmbId = ""
            db.open()
            var sql = "SELECT * FROM UpdateList;"
            var results = db.executeQuery(sql, withArgumentsInArray: nil)
            while results.next() {
                update = results.stringForColumn("categoryName")
                ncmbId = results.stringForColumn("objectId")
            }
            sql = "SELECT * FROM Category ORDER BY categoryId;"
            results = db.executeQuery(sql, withArgumentsInArray: nil)
            while results.next() {
                let quiz     = Quiz()
                let name     = results.stringForColumn("categoryName")
                let context  = results.stringForColumn("categoryContext")
                let id       = results.intForColumn("categoryId")
                
                quiz.name    = name
                quiz.context = context
                
                if update == name {
                    quiz.isUpload = true
                    quiz.ncmbId   = ncmbId
                }
                
                let sql = "SELECT * FROM Question WHERE categoryId = " + String(id) + " ORDER BY questionId;"
                let results = db.executeQuery(sql, withArgumentsInArray: nil)
                while results.next() {
                    let question = Question()
                    question.content = results.stringForColumn("questionTxt")
                    question.option0 = results.stringForColumn("select1")
                    question.option1 = results.stringForColumn("select2")
                    question.option2 = results.stringForColumn("select3")
                    question.option3 = results.stringForColumn("select4")
                    question.answer  = ["A","B","C","D"].indexOf(results.stringForColumn("answer"))!
                    quiz.questions.append(question)
                }
                quiz.save()
            }
            db.close()
            try! NSFileManager.defaultManager().removeItemAtPath(file)
        }
        // ユーザー名のマイグレーション
        let userId = NSUserDefaults.standardUserDefaults().stringForKey("UUID")
        if userId != nil {
            let user  = User()
            user.id   = userId!
            user.name = NSUserDefaults.standardUserDefaults().stringForKey("OWNER")!
            user.save()
            NSUserDefaults.standardUserDefaults().removeObjectForKey("UUID")
            NSUserDefaults.standardUserDefaults().removeObjectForKey("OWNER")
        }
    }
}

