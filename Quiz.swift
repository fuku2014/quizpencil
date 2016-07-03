/**
 Quiz
 
 RealmオブジェクトのQuizModelクラス
 
 - Author: fuku
 - Copyright: Copyright (c) 2016 fuku. All rights reserved.
 - Date: 2016/6/18
 - Version: 2.0
 */

import RealmSwift

class Quiz: Object {
    dynamic private var id: String = NSUUID().UUIDString
    dynamic var name:       String = ""
    dynamic var context:    String = ""
    dynamic var ncmbId:     String = ""
    dynamic var category:   String = ""
    dynamic var isDownload: Bool   = false
    dynamic var isUpload:   Bool   = false
    let questions = List<Question>()
    

    /**
     primaryKey
     */
    override static func primaryKey() -> String? {
        return "id"
    }

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
