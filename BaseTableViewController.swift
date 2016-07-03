/**
 BaseTabTableViewController
 
 共通のベースとなるTableViewControllerクラス
 
 - Author: fuku
 - Copyright: Copyright (c) 2016 fuku. All rights reserved.
 - Date: 2016/6/18
 - Version: 2.0
 */

import UIKit

class BaseTableViewController: UITableViewController {
    
    /**
     viewDidLoad
     
     Admobをツールバーに表示させる
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setToolbarHidden(false, animated: true)
        let admobView = Admob.shared.createAndLoadBanner(self)
        self.navigationController!.toolbar.addSubview(admobView)
    }
    
    /**
     willDisplayCell
     
     セルを画像で装飾する
     */
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundView = UIImageView(image: UIImage(named: "custom_cell"))
    }


}
