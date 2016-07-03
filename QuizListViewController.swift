/**
 QuizListViewController
 
 クイズ一覧表示画面
 
 - Author: fuku
 - Copyright: Copyright (c) 2016 fuku. All rights reserved.
 - Date: 2016/6/18
 - Version: 2.0
 */

import UIKit
import RealmSwift

class QuizListViewController: BaseTableViewController {
    
    var collection:   Results<Quiz>!
    var selectedQuiz: Quiz?
    
    /**
     viewWillAppear
     */
    override func viewWillAppear(animated: Bool) {
        fetchQuizList()
    }
    
    /**
     fetchQuizList
     */
    func fetchQuizList() {
        let realm = try! Realm()
        collection = realm.objects(Quiz).filter("questions.@count > 0")
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
        
        return cell
    }
    
    /**
     didSelectRowAtIndexPath
     */
    override func tableView(table: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath) {
        selectedQuiz = collection[indexPath.row]
        if selectedQuiz != nil {
            performSegueWithIdentifier("showPlayView", sender: nil)
        }
    }
    
    /**
     prepareForSegue
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "showPlayView") {
            let cqlvc: PlayViewController = (segue.destinationViewController as? PlayViewController)!
            cqlvc.selectedQuiz = selectedQuiz
        }
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
            if model.isUpload {
                let dialog: UIAlertController = UIAlertController(title: model.name, message: "このクイズは公開済みのため削除できません。削除する前に「クイズ公開画面」より公開中止を実施してください", preferredStyle:  UIAlertControllerStyle.Alert)
                // OK
                let okAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:{
                    (action: UIAlertAction!) -> Void in
                    return
                })
                dialog.addAction(okAction)
                self.presentViewController(dialog, animated: true, completion: nil)
                return
            }
            let dialog: UIAlertController = UIAlertController(title: model.name, message: "クイズを削除してもよろしいですか？", preferredStyle:  UIAlertControllerStyle.ActionSheet)
            
            // OK
            let okAction: UIAlertAction = UIAlertAction(title: "はい", style: UIAlertActionStyle.Default, handler:{
                (action: UIAlertAction!) -> Void in
                model.remove {
                    self.fetchQuizList()
                }
            })
            
            // キャンセル
            let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.Cancel, handler:{
                (action: UIAlertAction!) -> Void in
                return
            })
            
            dialog.addAction(okAction)
            dialog.addAction(cancelAction)
            
            presentViewController(dialog, animated: true, completion: nil)
        }
    }
}

