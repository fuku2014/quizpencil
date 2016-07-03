/**
 User
 
 RealmオブジェクトのUserModelクラス
 
 - Author: fuku
 - Copyright: Copyright (c) 2016 fuku. All rights reserved.
 - Date: 2016/6/18
 - Version: 2.0
 */

import RealmSwift

class User: Object {
    dynamic var name: String = ""
    dynamic var id:   String = NSUUID().UUIDString
    
    
    /**
     save
     
     データを保存する
     */
    func save() {
        let realm = try! Realm()
        try! realm.write {
            realm.add(self)
        }
    }

}
