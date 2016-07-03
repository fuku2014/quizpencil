/**
 PlayViewController
 
 クイズプレイ画面
 
 - Author: fuku
 - Copyright: Copyright (c) 2016 fuku. All rights reserved.
 - Date: 2016/6/18
 - Version: 2.0
 */

import UIKit
import Social

class PlayViewController: UIViewController {
    
    var selectedQuiz: Quiz?
    var index: Int = 0
    var img: UIImageView?
    var correctCount: Int = 0
    
    @IBOutlet var answerbar: UIToolbar!
    @IBOutlet var controlbar: UIToolbar!
    @IBOutlet var endBtn: UIButton!
    @IBOutlet var nextBtn: UIButton!
    @IBOutlet var Abtn: UIButton!
    @IBOutlet var Bbtn: UIButton!
    @IBOutlet var Cbtn: UIButton!
    @IBOutlet var Dbtn: UIButton!
    
    @IBOutlet var indexLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var adLabel: UILabel!
    @IBOutlet var textContent: UITextView!
    
    /**
     viewDidLoad
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        // toolbar setting
        [answerbar, controlbar].forEach { (it) in
            it.layer.borderColor = UIColor.grayColor().CGColor
            it.layer.borderWidth  = 0.5
        }
        // on admob
        let admobView = Admob.shared.createAndLoadBanner(self)
        adLabel.addSubview(admobView)
        // title
        self.titleLabel.text = selectedQuiz?.name
        // refresh
        self.refresh()
        
    }
    
    /**
     viewWillAppear
     
     この画面ではナビゲーション、ツールバーを非表示にする
     */
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.navigationController?.setToolbarHidden(true, animated: animated)
    }
    
    /**
     viewWillDisappear
     
     この画面ではナビゲーション、ツールバーを非表示にする
     */
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.setToolbarHidden(false, animated: animated)
    }
    
    /**
     showNext
     
     次へボタン選択時処理、indexを更新させ次の問題を表示、問題を全部解き終わった場合は結果発表を表示させる
     */
    @IBAction func showNext(sender: AnyObject) {
        if selectedQuiz?.questions.count > index + 1 {
            self.index = self.index + 1
            self.refresh()
        } else {
            let dialog: UIAlertController = UIAlertController(title: "結果発表", message: "お疲れ様でした!!\n" + String(self.selectedQuiz!.questions.count) + "問中" + String(correctCount) + "問正解！", preferredStyle:  UIAlertControllerStyle.Alert)
            
            // Tweet
            let tweetAction: UIAlertAction = UIAlertAction(title: "Tweet", style: UIAlertActionStyle.Default, handler:{
                (action: UIAlertAction!) -> Void in
                self.tweet()
            })
            
            // キャンセル
            let cancelAction: UIAlertAction = UIAlertAction(title: "終了", style: UIAlertActionStyle.Cancel, handler:{
                (action: UIAlertAction!) -> Void in
                self.navigationController?.popViewControllerAnimated(true)
            })
            
            dialog.addAction(tweetAction)
            dialog.addAction(cancelAction)
            
            presentViewController(dialog, animated: true, completion: nil)
            
        }
    }
    
    /**
     endPlay
     
     終了ボタン選択時処理、確認アラートを表示させ前の画面に戻る
     */
    @IBAction func endPlay(sender: AnyObject) {
        
        let dialog: UIAlertController = UIAlertController(title: "終了", message: "プレイ中のクイズを終了してもよろしいですか？", preferredStyle:  UIAlertControllerStyle.ActionSheet)
        
        // OK
        let okAction: UIAlertAction = UIAlertAction(title: "はい", style: UIAlertActionStyle.Default, handler:{
            (action: UIAlertAction!) -> Void in
            self.navigationController?.popViewControllerAnimated(true)
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
    
    /**
     refresh
     
     カレントクエスチョンより、画面コンテンツを最新化させる
     */
    func refresh() {
        // アニメーション
        UIView.beginAnimations(nil,context: nil)
        UIView.setAnimationDuration(0.5)
        UIView.setAnimationCurve(UIViewAnimationCurve.EaseOut)
        UIView.setAnimationTransition(UIViewAnimationTransition.CurlUp, forView: self.view, cache: true)
        // 結果
        if selectedQuiz?.questions.count <= index + 1 {
            self.nextBtn.setTitle("📖結果", forState: UIControlState.Normal)
        } else {
            self.nextBtn.setTitle("👉次へ", forState: UIControlState.Normal)
        }
        // インデックス
        self.indexLabel.text = "第" + String(index + 1) + "問　／　全" + String(self.selectedQuiz!.questions.count) + "問"
        // image
        self.img?.removeFromSuperview()
        // Question
        let question = selectedQuiz?.questions[index]
        var str: String = (question?.content)!
        str.appendContentsOf("\n\n\n")
        str.appendContentsOf("A :")
        str.appendContentsOf((question?.option0)!)
        str.appendContentsOf("\n")
        str.appendContentsOf("B :")
        str.appendContentsOf((question?.option1)!)
        str.appendContentsOf("\n")
        str.appendContentsOf("C :")
        str.appendContentsOf((question?.option2)!)
        str.appendContentsOf("\n")
        str.appendContentsOf("D :")
        str.appendContentsOf((question?.option3)!)
        self.textContent.text = str
        // buttons
        self.btnControl(true)
        // end アニメーション
        UIView.commitAnimations()
    }
    
    /**
     selectAnswer
     
     答えの選択時処理
     */
    @IBAction func selectAnswer(sender: AnyObject) {
        let answer = ["A", "B", "C", "D"][(self.selectedQuiz?.questions[index].answer)!]
        // answerボタンを非活性にする
        self.btnControl(false)
        // 色を変える
        let targetBtn: UIButton = sender as! UIButton
        targetBtn.backgroundColor = UIColor.blueColor()
        // 正解 or 不正解の画像表示
        let isCorrect = answer == (targetBtn.titleLabel?.text)!
        let imgTitle = isCorrect ? "maru" : "batu"
        self.img = UIImageView(frame: CGRectMake(self.textContent.frame.origin.x, self.textContent.frame.origin.y, self.textContent.frame.size.width, self.textContent.frame.size.height))
        self.img?.image = UIImage(named: imgTitle)
        self.view.addSubview(self.img!)
        // 正解の色を変える
        let correct = [Abtn, Bbtn, Cbtn, Dbtn].filter { (it) -> Bool in
            return it.titleLabel?.text == answer
        }
        correct[0].layer.borderColor = UIColor.redColor().CGColor
        // 正解数
        correctCount = isCorrect ? correctCount + 1 : correctCount
    }
    
    /**
     btnControl
     
     ボタンの活性、非活性をコントーロールする
     */
    func btnControl(mode: Bool) {
        [nextBtn, endBtn, Abtn, Bbtn, Cbtn, Dbtn].forEach { (it) in
            it.enabled = it == nextBtn ? !mode : mode
            it.backgroundColor = UIColor.clearColor()
            it.layer.borderColor = UIColor.grayColor().CGColor
            it.layer.borderWidth  = 1.0
            it.layer.cornerRadius = 7.5
        }
        endBtn.enabled = true
    }
    
    /**
     tweet
     
     クイズ結果をツイートさせる
     */
    func tweet() {
        let url = "https://itunes.apple.com/us/app/kuizu-qian-bi/id841366181?l=ja&ls=1&mt=8"
        let msg = "クイズ[" + self.selectedQuiz!.name + "]をプレイしたよ！\n" + String(self.selectedQuiz!.questions.count) + "問中" + String(correctCount) + "問正解！\n #クイズ鉛筆"
        
        let cv = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        cv.setInitialText(msg)
        cv.addURL(NSURL(string: url))
        presentViewController(cv, animated: true, completion:nil )
    }
}
