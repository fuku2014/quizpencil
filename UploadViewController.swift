/**
 UploadedQuizListViewController
 
 作成済みのクイズ一覧を表示し、クイズの公開を実施する画面
 
 - Author: fuku
 - Copyright: Copyright (c) 2016 fuku. All rights reserved.
 - Date: 2016/6/18
 - Version: 2.0
 */

import UIKit
import RealmSwift
import NCMB
import Social
import SVProgressHUD
import GoogleMobileAds

class UploadedQuizListViewController: BaseTableViewController {
    
    var collection:   Results<Quiz>!
    var selectedQuiz: Quiz?
    var interstitial = Admob.shared.createAndLoadInterstitial()

    
    /**
     viewDidLoad
     
     ユーザー登録されているか確認し、されていな場合は登録させる
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        let realm = try! Realm()
        let users = realm.objects(User)
        if users.isEmpty {
            // ユーザー登録
            self.singUp()
        } else {
            // ユーザ登録済み
            let user = users[0]
            let userId = user.id
            SVProgressHUD.show()
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                do {
                    // ログイン
                    try NCMBUser.logInWithUsername(userId, password: userId)
                    dispatch_async(dispatch_get_main_queue(), {
                        SVProgressHUD.dismiss()
                    })
                } catch let err as NSError {
                    SVProgressHUD.showErrorWithStatus(err.localizedDescription)
                    print(err)
                    return
                }
            })
        }
    }
    
    /**
     viewWillAppear
     
     クイズ一覧を取得する
     */
    override func viewWillAppear(animated: Bool) {
        fetchQuizList()
    }
    
    /**
     fetchQuizList
     
     realmからクイズ一覧を取得して表示する
     */
    func fetchQuizList() {
        let realm = try! Realm()
        collection = realm.objects(Quiz).filter("isDownload = false")
        self.tableView.reloadData()
    }
    
    /**
     numberOfSectionsInTableView
     */
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    /**
     numberOfRowsInSection
     */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collection.count
    }
    
    /**
     cellForRowAtIndexPath
     */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("quizList", forIndexPath: indexPath)
        
        
        cell.textLabel?.textAlignment       = NSTextAlignment.Left
        cell.textLabel?.font                = UIFont.systemFontOfSize(17)
        cell.detailTextLabel?.textColor     = UIColor.darkGrayColor()
        cell.detailTextLabel?.textAlignment = NSTextAlignment.Left
        cell.detailTextLabel?.font          = UIFont.systemFontOfSize(11)
        cell.backgroundColor                = UIColor.whiteColor()
        
        let model = collection[indexPath.row]
        cell.textLabel?.text       = model.name
        cell.detailTextLabel?.text = model.context
        
        // isUpload
        if model.isUpload {
            let star = UILabel(frame: CGRectMake(0, 0, 30, 30))
            star.text = "★"
            cell.accessoryView = star
        } else {
            cell.accessoryView = nil
        }
        return cell
    }
    
    /**
     didSelectRowAtIndexPath
     */
    override func tableView(table: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath) {
        let quiz: Quiz = collection[indexPath.row]
        let dialog: UIAlertController = UIAlertController(title: "クイズ公開", message: "クイズをインターネットに公開します", preferredStyle:  UIAlertControllerStyle.ActionSheet)
        
        // 公開する
        let uploadAction: UIAlertAction = UIAlertAction(title: "公開する", style: UIAlertActionStyle.Default, handler:{
            (action: UIAlertAction!) -> Void in
            self.uploadQuiz(quiz)
        })
        
        // 公開を中止する
        let deleteAction: UIAlertAction = UIAlertAction(title: "公開を中止する", style: UIAlertActionStyle.Destructive, handler:{
            (action: UIAlertAction!) -> Void in
            self.deleteQuiz(quiz)
        })
        
        // ツイート
        let tweetAction: UIAlertAction = UIAlertAction(title: "Tweet", style: UIAlertActionStyle.Default, handler:{
            (action: UIAlertAction!) -> Void in
            self.tweet(quiz)
        })
        
        // キャンセル
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.Cancel, handler:{
            (action: UIAlertAction!) -> Void in
            self.fetchQuizList()
        })
        
        if quiz.isUpload {
            dialog.addAction(deleteAction)
            dialog.addAction(tweetAction)
        } else {
            dialog.addAction(uploadAction)
        }
        dialog.addAction(cancelAction)
        
        presentViewController(dialog, animated: true, completion: nil)
        
    }
    
    
    /**
     uploadQuiz
     */
    func uploadQuiz(quiz: Quiz) {
        let dialog: UIAlertController = UIAlertController(title: "クイズ公開", message: "クイズのカテゴリを選択してください", preferredStyle:  UIAlertControllerStyle.ActionSheet)
        
        for index in 1...QuizConfig.CATEGORY_LIST.count - 1 {
            let category = QuizConfig.CATEGORY_LIST[index]
            let action: UIAlertAction = UIAlertAction(title: category, style: UIAlertActionStyle.Default, handler:{
                (action: UIAlertAction!) -> Void in
                self.doUpload(quiz, category: category)
            })
            dialog.addAction(action)
        }
        
        presentViewController(dialog, animated: true, completion: nil)
    }
    
    /**
     doUpload
     */
    func doUpload(quiz: Quiz, category: String) {
        let post:   NCMBObject = NCMBObject(className: "Quiz")
        let user:   NCMBUser   = NCMBUser.currentUser()
        let auther: String     = user.userName
        
        post.setObject(quiz.name, forKey: "quizName")
        post.setObject(quiz.context, forKey: "quizContent")
        post.setObject(quiz.questions.count, forKey: "quizCnt")
        post.setObject(auther, forKey: "auther")
        post.setObject(category, forKey: "category")
        
        SVProgressHUD.show()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            do {
                // 1. Save Quiz to NCMB
                var error: NSError?
                post.save(&error)
                if (error != nil) {
                    throw error!
                }
                dispatch_async(dispatch_get_main_queue(), {
                    // 2. Save Questions to NCMB
                    let quizId = post.objectId
                    for (quizNo, question) in quiz.questions.enumerate() {
                        let postQuestion: NCMBObject = NCMBObject(className: "Question")
                        postQuestion.setObject(quizId, forKey: "quiz")
                        postQuestion.setObject(quizNo + 1, forKey: "quizNo")
                        postQuestion.setObject(question.content, forKey: "questionTxt")
                        postQuestion.setObject(question.option0, forKey: "s1")
                        postQuestion.setObject(question.option1, forKey: "s2")
                        postQuestion.setObject(question.option2, forKey: "s3")
                        postQuestion.setObject(question.option3, forKey: "s4")
                        postQuestion.setObject(["A","B","C","D"][question.answer], forKey: "ans")
                        postQuestion.save(&error)
                        if (error != nil) {
                            SVProgressHUD.showErrorWithStatus(error!.localizedDescription)
                            return
                        }
                    }
                    // 3. Update Model
                    quiz.update {
                        quiz.ncmbId   = post.objectId
                        quiz.isUpload = true
                    }
                    // 4. send push notify
                    let push  = NCMBPush()
                    let query = NCMBInstallation.query()
                    query.whereKey("objectId", notEqualTo: NSUserDefaults.standardUserDefaults().stringForKey("INSTALLATION_ID"))
                    push.setSearchCondition(query)
                    push.setMessage("新しいクイズ[" + quiz.name + "]が公開されました！\n早速プレイしてみましょう")
                    push.setImmediateDeliveryFlag(true)
                    push.setPushToIOS(true)
                    push.sendPushInBackgroundWithBlock(nil)
                    self.fetchQuizList()
                    SVProgressHUD.dismiss()
                    // クイズを２個以上公開する場合は広告を表示する
                    let uploadedCount = try! Realm().objects(Quiz).filter("isUpload = true").count
                    if uploadedCount > 1 {
                        self.interstitial.presentFromRootViewController(self)
                        self.interstitial = Admob.shared.createAndLoadInterstitial()
                    }
                })
            } catch let err as NSError {
                SVProgressHUD.showErrorWithStatus(err.localizedDescription)
                print(err)
            }
        })
    }
    
    /**
     deleteQuiz
     */
    func deleteQuiz(quiz: Quiz) {
        let dialog: UIAlertController = UIAlertController(title: "公開中止", message: "公開したクイズを削除してもよろしいですか？", preferredStyle:  UIAlertControllerStyle.ActionSheet)
        
        // OK
        let okAction: UIAlertAction = UIAlertAction(title: "はい", style: UIAlertActionStyle.Default, handler:{
            (action: UIAlertAction!) -> Void in
            self.doDelete(quiz)
        })
        
        // キャンセル
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.Cancel, handler:{
            (action: UIAlertAction!) -> Void in
            self.fetchQuizList()
        })
        
        dialog.addAction(okAction)
        dialog.addAction(cancelAction)
        
        presentViewController(dialog, animated: true, completion: nil)
    }
    
    /**
     doDelete
     */
    func doDelete(quiz: Quiz) {
        SVProgressHUD.show()
        let targetQuiz = NCMBObject(className: "Quiz")
        let ncmbId     = quiz.ncmbId
        targetQuiz.objectId = ncmbId
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            do {
                var error : NSError?
                // delete quiz
                targetQuiz.delete(&error)
                if error != nil {
                    throw error!
                }
                let query = NCMBQuery(className: "Question")
                query.whereKey("quiz", equalTo: ncmbId)
                let targetQuestions = try query.findObjects() as! [NCMBObject]
                // delete questions
                for targetQuestion in targetQuestions {
                    targetQuestion.delete(&error)
                    if error != nil {
                        throw error!
                    }
                }
                dispatch_async(dispatch_get_main_queue(), {
                    // update model
                    quiz.update {
                        quiz.isUpload = false
                        quiz.ncmbId = ""
                        self.fetchQuizList()
                    }
                    SVProgressHUD.dismiss()
                })
            } catch let err as NSError {
                SVProgressHUD.showErrorWithStatus(err.localizedDescription)
                print(err)
            }
        })
    }
    
    /**
     tweet
     */
    func tweet(quiz: Quiz) {
        let url = "https://itunes.apple.com/us/app/kuizu-qian-bi/id841366181?l=ja&ls=1&mt=8"
        let msg = "クイズ[" + quiz.name + "]を公開したよ！プレイしてみてね！ #クイズ鉛筆"
        
        let cv = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        cv.setInitialText(msg)
        cv.addURL(NSURL(string: url))
        presentViewController(cv, animated: true, completion:nil )
        fetchQuizList()
    }
    
    /**
     singUp
     */
    func singUp() {
        let dialog: UIAlertController = UIAlertController(title: "ユーザ名登録", message: "クイズ公開を利用するために\nユーザー名を登録しておきましょう\nユーザー名を入力してください", preferredStyle:  UIAlertControllerStyle.Alert)
        
        // doSingUp
        let signUpAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:{
            (action: UIAlertAction!) -> Void in
            let user : NCMBUser  = NCMBUser()
            let acl  : NCMBACL   =  NCMBACL()
            let name : String    = dialog.textFields![0].text!
            
            let localUser : User = User()
            localUser.name = name
            user.userName = localUser.id
            user.password = localUser.id
            user.setObject(name, forKey: "ownerName")
            acl.setPublicReadAccess(true)
            acl.setPublicWriteAccess(true)
            user.ACL = acl
            SVProgressHUD.show()
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                do {
                    var error : NSError?
                    user.signUp(&error)
                    if error != nil {
                        throw error!
                    }
                    dispatch_async(dispatch_get_main_queue(), {
                        localUser.save()
                        try! NCMBUser.logInWithUsername(localUser.id, password: localUser.id)
                        SVProgressHUD.dismiss()
                    })
                } catch let err as NSError {
                    SVProgressHUD.showErrorWithStatus(err.localizedDescription)
                    print(err)
                    return
                }
            })
        })
        
        signUpAction.enabled = false
        // UITextField for UserName
        dialog.addTextFieldWithConfigurationHandler {
            (textFieldUser: UITextField!) in
            textFieldUser.placeholder = "1〜6文字"
            textFieldUser.keyboardType = .Default
        }
        
        // Validation
        let textFieldValidationObserver: (NSNotification!) -> Void = { _ in
            let min = 1
            let max = 6
            let userName = dialog.textFields![0].text
            signUpAction.enabled = userName?.characters.count >= min && userName?.characters.count <= max
        }
        
        // Notifications for textField changes
        NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification,
                                                                object: dialog.textFields![0],
                                                                queue: NSOperationQueue.mainQueue(), usingBlock: textFieldValidationObserver)
        
        dialog.addAction(signUpAction)
        self.parentViewController!.presentViewController(dialog, animated: true, completion: nil)
    }
}
