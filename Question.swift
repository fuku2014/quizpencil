/**
 Question
 
 RealmオブジェクトのQuestionModelクラス
 
 - Author: fuku
 - Copyright: Copyright (c) 2016 fuku. All rights reserved.
 - Date: 2016/6/18
 - Version: 2.0
 */

import RealmSwift

class Question: Object {
    dynamic private var id: String = NSUUID().UUIDString
    dynamic var content: String = ""
    dynamic var answer:  Int    = 0
    dynamic var option0: String = ""
    dynamic var option1: String = ""
    dynamic var option2: String = ""
    dynamic var option3: String = ""
    
    /**
     primaryKey
     */
    override static func primaryKey() -> String? {
        return "id"
    }
    
    /**
     update
     
     データを更新する
     - returns: callback function
     */
    func update(callback : (() -> Void)) {
        let realm = try! Realm()
        try! realm.write {
            callback()
        }
    }
    
    /**
     remove
     
     データを削除する
     - returns: callback function
     */
     func remove(callback : (() -> Void)) {
        let realm = try! Realm()
        try! realm.write {
            realm.delete(self)
            callback()
        }
    }
}
