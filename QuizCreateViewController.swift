/**
 QuizCreateViewController
 
 クイズ作成画面
 
 - Author: fuku
 - Copyright: Copyright (c) 2016 fuku. All rights reserved.
 - Date: 2016/6/18
 - Version: 2.0
 */

import UIKit

class QuizCreateViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var textName:    UITextField!
    @IBOutlet var textContext: UITextField!
    @IBOutlet var btnSubmit:   UIButton!
    
    /**
     onSubmit
     */
    @IBAction func onSubmit(sender: AnyObject) {
        let quiz = Quiz()
        quiz.name    = textName.text!
        quiz.context = textContext.text!
        quiz.save()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    /**
     textFieldShouldReturn
     */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        btnSubmit.enabled = textName.text!.characters.count > 0
        textField.resignFirstResponder()
        return true
    }
}
