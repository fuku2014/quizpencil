/**
 DownloadQuizListViewController
 
 公開されているクイズ一覧を表示し、クイズのダウンロードを実施する画面
 
 - Author: fuku
 - Copyright: Copyright (c) 2016 fuku. All rights reserved.
 - Date: 2016/6/18
 - Version: 2.0
 */

import UIKit
import NCMB
import SVProgressHUD
import RealmSwift

class DownloadQuizListViewController: BaseTableViewController {
    var collection:         [NCMBObject] = []
    var filteredCollection: [NCMBObject] = []
    var containsQuizIdList: [String]     = []
    var selectedQuiz:        NCMBObject?
    let searchController = UISearchController(searchResultsController: nil)
    
    /**
     viewDidLoad
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        // add RefreshControl
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: #selector(self.fetchQuizList), forControlEvents:.ValueChanged)
        self.refreshControl?.tintColor = UIColor.clearColor()
        
        // add SearchControl
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.scopeButtonTitles = QuizConfig.CATEGORY_LIST
        searchController.searchBar.delegate = self
        fetchQuizList()
    }
    
    /**
     viewWillAppear
     */
    override func viewWillAppear(animated: Bool) {
        // 自分でアップロード、またはダウンロード済みのクイズは非活性にする為にIDのリスト取得
        containsQuizIdList = try! Realm().objects(Quiz).map({ (it) -> String in
            it.ncmbId
        })
        self.tableView.reloadData()
    }
    
    /**
     fetchQuizList
     */
    func fetchQuizList() {
        SVProgressHUD.show()
        let query = NCMBQuery(className: "Quiz")
        // 最新3000件まで読み込む
        query.limit = 3000
        // 作成日順ソート
        query.orderByDescending("createDate")
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            do {
                try self.collection = query.findObjects() as! [NCMBObject]
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                    SVProgressHUD.dismiss()
                    self.refreshControl!.endRefreshing()
                })
            } catch let err as NSError {
                SVProgressHUD.showErrorWithStatus(err.localizedDescription)
                print(err)
            }
        })
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
        if searchController.active {
            return filteredCollection.count
        }
        return collection.count
    }
    
    /**
     cellForRowAtIndexPath
     */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "quizList"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        
        
        cell.textLabel?.textAlignment       = NSTextAlignment.Left
        cell.textLabel?.font                = UIFont.systemFontOfSize(17)
        cell.detailTextLabel?.textColor     = UIColor.darkGrayColor()
        cell.detailTextLabel?.textAlignment = NSTextAlignment.Left
        cell.detailTextLabel?.font          = UIFont.systemFontOfSize(11)
        cell.backgroundColor                = UIColor.whiteColor()
        
        let model: NCMBObject
        if searchController.active {
            model = filteredCollection[indexPath.row]
        } else {
            model = collection[indexPath.row]
        }
        
        // 非活性にする
        if containsQuizIdList.contains(model.objectId) {
            cell.userInteractionEnabled     = false
            cell.textLabel?.textColor       = UIColor.grayColor()
            cell.detailTextLabel?.textColor = UIColor.grayColor()
        } else {
            cell.userInteractionEnabled     = true
            cell.textLabel?.textColor       = UIColor.blackColor()
            cell.detailTextLabel?.textColor = UIColor.darkGrayColor()
        }
        
        // ダウンロード数
        var downloadCount = 0
        if let remote = model.objectForKey("downloadCount") as? Int {
            downloadCount = remote
        }
        let countLabel = UILabel(frame: CGRectMake(0, 0, 30, 30))
        countLabel.text = "⭐️" + String(downloadCount)
        countLabel.sizeToFit()
        cell.accessoryView = countLabel
        
        
        cell.textLabel?.text       = model.objectForKey("quizName") as? String
        cell.detailTextLabel?.text = model.objectForKey("quizContent") as? String
        
        return cell
    }
    
    /**
     willDisplayCell
     */
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundView = UIImageView(image: UIImage(named: "custom_cell"))
    }
    
    /**
     didSelectRowAtIndexPath
     */
    override func tableView(table: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath) {
        if searchController.active {
            selectedQuiz = filteredCollection[indexPath.row]
        } else {
            selectedQuiz = collection[indexPath.row]
        }
        if selectedQuiz != nil {
            performSegueWithIdentifier("showConfirm", sender: nil)
        }
    }
    
    /**
     prepareForSegue
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "showConfirm") {
            let cqlvc: DownloadConfirmViewController = (segue.destinationViewController as? DownloadConfirmViewController)!
            cqlvc.selectedQuiz = selectedQuiz
        }
    }
    
    /**
     onRefresh
     */
    @IBAction func onRefresh(sender: UIBarButtonItem) {
        fetchQuizList()
    }
    
    /**
     filterContentForSearchText
     */
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredCollection = collection.filter({( quiz : NCMBObject) -> Bool in
            let categoryMatch = (scope == "All")   || (quiz.objectForKey("category") as? String == scope)
            let searchMatch   = (searchText == "") || (quiz.objectForKey("quizName").lowercaseString.containsString(searchText.lowercaseString))
            return categoryMatch && searchMatch
        })
        tableView.reloadData()
    }
}

/**
 * Extention DownloadQuizListViewController
 *
 * Extention of DownloadQuizListViewController
 */
extension DownloadQuizListViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope     = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
}

/**
 * Extention DownloadQuizListViewController
 *
 * Extention of DownloadQuizListViewController
 */
extension DownloadQuizListViewController: UISearchBarDelegate {
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}

