/**
 CreatedQuestionListViewController
 
 作成済みクエスチョン一覧を表示させる画面
 
 - Author: fuku
 - Copyright: Copyright (c) 2016 fuku. All rights reserved.
 - Date: 2016/6/18
 - Version: 2.0
 */

import UIKit
import RealmSwift

class CreatedQuestionListViewController: BaseTableViewController {
    
    var selectedQuiz:     Quiz!
    var selectedQuestion: Question?
    var collection:       List<Question>!
    
    /**
     viewWillAppear
     */
    override func viewWillAppear(animated: Bool) {
        fetchQuestionist()
    }
    
    /**
     fetchQuizList
     */
    func fetchQuestionist() {
        collection = selectedQuiz.questions
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
        let cell = tableView.dequeueReusableCellWithIdentifier("questionList", forIndexPath: indexPath)
        
        
        cell.textLabel?.textAlignment       = NSTextAlignment.Left
        cell.textLabel?.font                = UIFont.systemFontOfSize(17)
        cell.detailTextLabel?.textColor     = UIColor.darkGrayColor()
        cell.detailTextLabel?.textAlignment = NSTextAlignment.Left
        cell.detailTextLabel?.font          = UIFont.systemFontOfSize(11)
        cell.backgroundColor                = UIColor.whiteColor()
        
        let model = collection[indexPath.row]
        cell.textLabel?.text       = "第" + String(indexPath.row + 1) + "問"
        cell.detailTextLabel?.text = model.content
        
        return cell
    }

    /**
     didSelectRowAtIndexPath
     */
    override func tableView(table: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath) {
        selectedQuestion = selectedQuiz.questions[indexPath.row]
        if selectedQuestion != nil {
            performSegueWithIdentifier("showEditView", sender: nil)
        }
    }
    
    /**
     prepareForSegue
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        let createVc:  QuestionCreateViewController = (segue.destinationViewController as? QuestionCreateViewController)!
        if (segue.identifier == "showEditView") {
            createVc.selectedQuestion = selectedQuestion
        }
        createVc.selectedQuiz = selectedQuiz
    }
    
    /**
     canEditRowAtIndexPath
     */
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    /**
     commitEditingStyle
     */
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let model = collection[indexPath.row]
            model.remove {
                self.fetchQuestionist()
            }
        }
    }
}
