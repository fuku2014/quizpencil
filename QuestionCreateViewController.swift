/**
 QuestionCreateViewController
 
 クエスチョン作成画面
 
 - Author: fuku
 - Copyright: Copyright (c) 2016 fuku. All rights reserved.
 - Date: 2016/6/18
 - Version: 2.0
 */

import UIKit

class QuestionCreateViewController: BaseTableViewController, UITextFieldDelegate, UITextViewDelegate {
    
    var selectedQuiz:     Quiz?
    var selectedQuestion: Question?

    @IBOutlet var textContent: UITextView!

    @IBOutlet var textOptionA: UITextField!
    @IBOutlet var textOptionB: UITextField!
    @IBOutlet var textOptionC: UITextField!
    @IBOutlet var textOptionD: UITextField!
    @IBOutlet var segmentAnswer: UISegmentedControl!
    @IBOutlet var btnSubmit: UIButton!
    

    /**
     viewDidLoad
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create tool bar
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 40))
        toolBar.barStyle = UIBarStyle.Default
        toolBar.sizeToFit()
        let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil)
        let commitButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: #selector(QuestionCreateViewController.onCloseKeyBoad))
        toolBar.items = [spacer, commitButton]
        textContent.inputAccessoryView = toolBar
        
        // current value
        if (selectedQuestion != nil) {
            textContent.text = selectedQuestion?.content
            textOptionA.text = selectedQuestion?.option0
            textOptionB.text = selectedQuestion?.option1
            textOptionC.text = selectedQuestion?.option2
            textOptionD.text = selectedQuestion?.option3
            segmentAnswer.selectedSegmentIndex = (selectedQuestion?.answer)!
        }
        btnSubmit.enabled = !textContent.text.isEmpty
    }
    
    /**
     onSubmit
     */
    @IBAction func onSubmit(sender: AnyObject) {
        if selectedQuestion != nil {
            selectedQuestion!.update {
                self.selectedQuestion?.content = self.textContent.text
                self.selectedQuestion?.option0 = self.textOptionA.text!
                self.selectedQuestion?.option1 = self.textOptionB.text!
                self.selectedQuestion?.option2 = self.textOptionC.text!
                self.selectedQuestion?.option3 = self.textOptionD.text!
                self.selectedQuestion?.answer  = self.segmentAnswer.selectedSegmentIndex
            }
        } else {
            let question = Question()
            question.content = textContent.text
            question.option0 = textOptionA.text!
            question.option1 = textOptionB.text!
            question.option2 = textOptionC.text!
            question.option3 = textOptionD.text!
            question.answer  = segmentAnswer.selectedSegmentIndex
            selectedQuiz?.update {
                self.selectedQuiz?.questions.append(question)
            }
        }
        self.navigationController?.popViewControllerAnimated(true)
    }

    /**
     onCloseKeyBoad
     */
    func onCloseKeyBoad () {
        self.view.endEditing(true)
    }
    
    /**
     textViewDidEndEditing
     */
    func textViewDidEndEditing(textView: UITextView) {
        btnSubmit.enabled = !textContent.text.isEmpty
    }
    
    
    /**
     textFieldShouldReturn
     */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
