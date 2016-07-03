/**
 DownloadConfirmViewController
 
 クイズのダウンロードの確認画面
 
 - Author: fuku
 - Copyright: Copyright (c) 2016 fuku. All rights reserved.
 - Date: 2016/6/18
 - Version: 2.0
 */

import UIKit
import NCMB
import SVProgressHUD

class DownloadConfirmViewController: BaseTableViewController {
    
    var selectedQuiz: NCMBObject!
    
    @IBOutlet var cellQuizContent: UITableViewCell!
    @IBOutlet var cellQuizName: UITableViewCell!
    @IBOutlet var cellQuizCnt: UITableViewCell!
    @IBOutlet var cellAuther: UITableViewCell!
    
    /**
     viewDidLoad
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let query: NCMBQuery = NCMBUser.query()
        query.whereKey("userName", equalTo: selectedQuiz.objectForKey("auther") as? String)
        let user : NCMBUser = try! query.getFirstObject() as! NCMBUser
    
        cellQuizContent.textLabel?.font = UIFont.systemFontOfSize(10)
        cellQuizContent.textLabel?.text = selectedQuiz.objectForKey("quizContent") as? String
        cellQuizName.textLabel?.text    = selectedQuiz.objectForKey("quizName") as? String
        cellQuizCnt.textLabel?.text     = (selectedQuiz.objectForKey("quizCnt") as? Int)?.description
        cellAuther.textLabel?.text      = user.objectForKey("ownerName") as? String
    }

    /**
     onDownload
     */
    @IBAction func onDownload(sender: UIButton) {
        SVProgressHUD.show()
        let query = NCMBQuery(className: "Question")
        query.orderByAscending("quizNo")
        query.limit = 2000
        query.whereKey("quiz", equalTo: selectedQuiz.objectId)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            do {
                // 1. Get Questions from NCMB
                let questions = try query.findObjects() as! [NCMBObject]
                dispatch_async(dispatch_get_main_queue(), {
                    // 2. Create Quiz Object and add Questions
                    let quiz        = Quiz()
                    quiz.name       = (self.cellQuizName.textLabel?.text)!
                    quiz.context    = (self.cellQuizContent.textLabel?.text)!
                    quiz.isDownload = true
                    quiz.ncmbId     = self.selectedQuiz.objectId
                    for ncmb_question in questions {
                        let question = Question()
                        question.content = ncmb_question.objectForKey("questionTxt") as! String
                        question.option0 = ncmb_question.objectForKey("s1") as! String
                        question.option1 = ncmb_question.objectForKey("s2") as! String
                        question.option2 = ncmb_question.objectForKey("s3") as! String
                        question.option3 = ncmb_question.objectForKey("s4") as! String
                        question.answer  = ["A","B","C","D"].indexOf(ncmb_question.objectForKey("ans") as! String)!
                        quiz.questions.append(question)
                    }
                    quiz.save()
                    // 3. ダウンロード件数の更新
                    var downloadCount = 0
                    if let remoteData = self.selectedQuiz.objectForKey("downloadCount") as? Int {
                        downloadCount = remoteData
                    }
                    downloadCount = downloadCount + 1
                    self.selectedQuiz.setObject(downloadCount, forKey: "downloadCount")
                    self.selectedQuiz.saveInBackgroundWithBlock(nil)
                    self.navigationController?.popViewControllerAnimated(true)
                    SVProgressHUD.dismiss()
                })
            } catch let err as NSError {
                SVProgressHUD.showErrorWithStatus(err.localizedDescription)
                print(err)
            }
        })
    }
}
