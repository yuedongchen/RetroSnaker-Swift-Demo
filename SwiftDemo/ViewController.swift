//
//  ViewController.swift
//  SwiftDemo
//
//  Created by 陈越东 on 2018/7/25.
//  Copyright © 2018年 陈越东. All rights reserved.
//


import UIKit



class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITextViewDelegate {
    
    
    let lineNumber : CGFloat = 25.0

    var currentDirection : Int = 1  // 0 up, 1 left, 2 down, 3 right
    
    var canTurn : Bool = true  //用于控制蛇在移动帧数时间内不能转向
    
    var snakeHead : BoxLocation?
    
    var food : BoxLocation?
    
    var timer : Timer?
    
    //MARK: - lazy
    
    lazy var snakeBodyList : NSMutableArray = {
        
        let snakeBodyList = NSMutableArray();
        
        return snakeBodyList
        
    }()
    
    lazy var scoreLabel : UILabel = {
        
        let scoreLabel = UILabel()
        scoreLabel.textColor = UIColor.red
        scoreLabel.font = UIFont.systemFont(ofSize: 25)
        
        return scoreLabel
    }()
    
    lazy var textView : UITextView = {
       
        let textView = UITextView(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        textView.delegate = self;
        textView.text = "Start"
        textView.font = UIFont.systemFont(ofSize: 30)
        textView.textColor = UIColor.blue
        textView.textAlignment = NSTextAlignment.center
        
        return textView
    }()
    
    lazy var collectionView : UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.size.width / lineNumber, height: UIScreen.main.bounds.size.width / lineNumber)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.black
        collectionView.register(BoxCell.self, forCellWithReuseIdentifier: "BoxCell")
        
        return collectionView
        
    }()
    
    lazy var upBtn : UIButton = {
        
        let upBtn = UIButton()
        upBtn.backgroundColor = UIColor.blue
        upBtn.setTitle("w", for: UIControlState.normal)
        upBtn.setTitleColor(UIColor.white, for: UIControlState.normal)
        upBtn.addTarget(self, action:#selector(upAction), for: UIControlEvents.touchUpInside)
        
        return upBtn
    }()
    
    lazy var downBtn : UIButton = {
        
        let downBtn = UIButton()
        downBtn.backgroundColor = UIColor.blue
        downBtn.setTitle("s", for: UIControlState.normal)
        downBtn.setTitleColor(UIColor.white, for: UIControlState.normal)
        downBtn.addTarget(self, action:#selector(downAction), for: UIControlEvents.touchUpInside)
        
        return downBtn
    }()
    
    lazy var leftBtn : UIButton = {
        
        let leftBtn = UIButton()
        leftBtn.backgroundColor = UIColor.blue
        leftBtn.setTitle("a", for: UIControlState.normal)
        leftBtn.setTitleColor(UIColor.white, for: UIControlState.normal)
        leftBtn.addTarget(self, action:#selector(leftAction), for: UIControlEvents.touchUpInside)
        
        return leftBtn
    }()
    
    lazy var rightBtn : UIButton = {
        
        let rightBtn = UIButton()
        rightBtn.backgroundColor = UIColor.blue
        rightBtn.setTitle("d", for: UIControlState.normal)
        rightBtn.setTitleColor(UIColor.white, for: UIControlState.normal)
        rightBtn.addTarget(self, action:#selector(rightAction), for: UIControlEvents.touchUpInside)
        
        return rightBtn
    }()
    
    //MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.configSubViews()
        self.configOriginLocation()
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Config
    
    func configSubViews() {
        self.view.addSubview(self.collectionView)
        self.collectionView.mas_makeConstraints({ (make:MASConstraintMaker!) in
            make?.centerX.mas_equalTo()(self.view)
            make?.centerY.mas_equalTo()(self.view)?.offset()(-50)
            make?.width.height().mas_equalTo()(UIScreen.main.bounds.size.width)
        })
        
        self.view.addSubview(self.textView)
        self.view.addSubview(self.scoreLabel)
        self.textView.mas_makeConstraints { (make:MASConstraintMaker!) in
            make?.centerX.mas_equalTo()(self.view)
            make?.top.mas_equalTo()(self.view)?.offset()(50);
            make?.width.mas_equalTo()(100)
            make?.height.mas_equalTo()(40)
        }
        self.scoreLabel.mas_makeConstraints { (make:MASConstraintMaker!) in
            make?.centerY.mas_equalTo()(self.textView)
            make?.right.mas_equalTo()(self.view)?.offset()(-20)
        }
        
        self.view.addSubview(self.upBtn)
        self.view.addSubview(self.downBtn)
        self.view.addSubview(self.leftBtn)
        self.view.addSubview(self.rightBtn)
        self.upBtn.mas_makeConstraints { (make:MASConstraintMaker!) in
            make?.centerX.mas_equalTo()(self.view)
            make?.top.mas_equalTo()(self.collectionView.mas_bottom)?.offset()(10);
            make?.width.height().mas_equalTo()(60)
        }
        self.downBtn.mas_makeConstraints { (make:MASConstraintMaker!) in
            make?.centerX.mas_equalTo()(self.view)
            make?.top.mas_equalTo()(self.upBtn.mas_bottom)?.offset()(80);
            make?.width.height().mas_equalTo()(60)
        }
        self.leftBtn.mas_makeConstraints { (make:MASConstraintMaker!) in
            make?.right.mas_equalTo()(self.upBtn.mas_left)?.offset()(-10);
            make?.top.mas_equalTo()(self.upBtn.mas_bottom)?.offset()(10);
            make?.width.height().mas_equalTo()(60)
        }
        self.rightBtn.mas_makeConstraints { (make:MASConstraintMaker!) in
            make?.left.mas_equalTo()(self.upBtn.mas_right)?.offset()(10);
            make?.top.mas_equalTo()(self.upBtn.mas_bottom)?.offset()(10);
            make?.width.height().mas_equalTo()(60)
        }
    }
    
    func configOriginLocation() {
        
        self.snakeHead = BoxLocation(x: 10, y: 10, lineNumber: Int(lineNumber))
        
        self.snakeBodyList.add(self.snakeHead as Any)
        self.snakeBodyList.add(BoxLocation(x: 11, y: 10, lineNumber: Int(lineNumber)))
        self.snakeBodyList.add(BoxLocation(x: 12, y: 10, lineNumber: Int(lineNumber)))
        
        self.putNewFood()
        
        
        self.collectionView.reloadData();
    }
    
    //MARK: - Private
    
    func checkSnakeIsAtIndex(index: NSInteger) -> Bool {   //判断蛇是不是在某个格子上
        
        for location in self.snakeBodyList {
            let snakeBody = location as! BoxLocation
            if snakeBody.index == index {
                return true
            }
        }
        
        return false
    }
    
    func checkSnakeHeadIsImpactBody() -> Bool {   //判断是否撞到自己身体了
        
        var i = 1
        
        while i < self.snakeBodyList.count {
            let snakeBody = self.snakeBodyList[i] as! BoxLocation
            if self.snakeHead?.index == snakeBody.index {
                return true
            }
            i += 1
        }
        
        return false
    }
    
    func putNewFood() {
        
        let ints = NSMutableArray()
        
        var i = 0
        while i < Int(lineNumber * lineNumber) - 1 {
            ints.add(i)
            i += 1
        }
        
        for location in self.snakeBodyList {
            let snakeBody = location as! BoxLocation
            ints.remove(snakeBody.index)
        }
        
        let randomIndex = ints[Int(arc4random() % UInt32(ints.count))] as! Int
        
        self.food = BoxLocation(x: randomIndex % Int(lineNumber) + 1, y: randomIndex / Int(lineNumber) + 1, lineNumber: Int(lineNumber))
    }
    
    func eatFood() -> Bool {
        
        var eat = false
        
        switch self.currentDirection {
            case 0:
                if self.snakeHead!.y! == self.food!.y! + 1 && self.snakeHead!.x! == self.food!.x! {
                    self.snakeBodyList.insert(self.food!, at: 0)
                    self.snakeHead = self.food
                    eat = true
                }
            case 1:
                if self.snakeHead!.x! == self.food!.x! + 1 && self.snakeHead!.y! == self.food!.y! {
                    self.snakeBodyList.insert(self.food!, at: 0)
                    self.snakeHead = self.food
                    eat = true
                }
            case 2:
                if self.snakeHead!.y! == self.food!.y! - 1 && self.snakeHead!.x! == self.food!.x! {
                    self.snakeBodyList.insert(self.food!, at: 0)
                    self.snakeHead = self.food
                    eat = true
                }
            case 3:
                if self.snakeHead!.x! == self.food!.x! - 1 && self.snakeHead!.y! == self.food!.y! {
                    self.snakeBodyList.insert(self.food!, at: 0)
                    self.snakeHead = self.food
                    eat = true
                }
            default: break
            
        }
        
        if eat {
            self.putNewFood()
            self.scoreLabel.text = "\(self.snakeBodyList.count - 3)"
        }
        
        return eat
    }
    
    func showYouLost() {
        
        self.timer?.invalidate()
        
        let alert = UIAlertController(title: "You Lost", message: "you have got \(self.snakeBodyList.count - 3) score", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Play Again", style: .default) { action in
            self.snakeBodyList.removeAllObjects()
            self.configOriginLocation()
            self.collectionView.reloadData()
            self.scoreLabel.text = ""
            self.textView.text = "Start"
            self.textView.resignFirstResponder()
        }
//        let cancelAction = UIAlertAction(title: "NO", style: .cancel, handler: nil)
        alert.addAction(okAction)
//        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @objc func snakeMove() {
        
        switch self.currentDirection {
        case 0:
            if self.snakeHead!.y! <= 1 {
                self.showYouLost()
                return
            }
        case 1:
            if self.snakeHead!.x! <= 1 {
                self.showYouLost()
                return
            }
        case 2:
            if self.snakeHead!.y! >= Int(lineNumber) {
                self.showYouLost()
                return
            }
        case 3:
            if self.snakeHead!.x! >= Int(lineNumber) {
                self.showYouLost()
                return
            }
        default: break
            
        }
        
        
        if self.eatFood() {
            self.collectionView.reloadData()
            return;
        }
        
        var i = self.snakeBodyList.count - 1
        while i >= 1 {
            
            let loction1 = self.snakeBodyList[i] as! BoxLocation
            let loction2 = self.snakeBodyList[i - 1] as! BoxLocation
            
            loction1.x = loction2.x
            loction1.y = loction2.y
            
            i -= 1
        }
        
        switch self.currentDirection {
        case 0:
            self.snakeHead!.y = self.snakeHead!.y! - 1
        case 1:
            self.snakeHead!.x = self.snakeHead!.x! - 1
        case 2:
            self.snakeHead!.y = self.snakeHead!.y! + 1
        case 3:
            self.snakeHead!.x = self.snakeHead!.x! + 1
        default: break
            
        }
        
        self.collectionView.reloadData()
        
        if self.checkSnakeHeadIsImpactBody() {
            self.showYouLost()
        }
        
        self.canTurn = true
    }
    
    //MARK: - Action
    
    @objc func upAction() {
        
        if !self.canTurn || self.currentDirection == 2 || self.currentDirection == 0 {
            self.snakeMove()
            NSLog("keep up")
            return
        }
        
        NSLog("turn up")
        self.canTurn = false
        self.currentDirection = 0
    }
    
    @objc func leftAction() {
        
        if !self.canTurn || self.currentDirection == 3 || self.currentDirection == 1 {
            self.snakeMove()
            NSLog("keep left")
            return
        }

        NSLog("turn left")
        self.canTurn = false
        self.currentDirection = 1
    }
    
    @objc func downAction() {
        
        if !self.canTurn || self.currentDirection == 0 || self.currentDirection == 2 {
            self.snakeMove()
            NSLog("keep down")
            return
        }
        
        NSLog("turn down")
        self.canTurn = false
        self.currentDirection = 2
    }
    
    @objc func rightAction() {
        
        if !self.canTurn || self.currentDirection == 1 || self.currentDirection == 3 {
            self.snakeMove()
            NSLog("keep right")
            return
        }

        NSLog("turn right")
        self.canTurn = false
        self.currentDirection = 3
    }
    
    func startAction() {
        
        self.currentDirection = 1
        self.timer = Timer.scheduledTimer(timeInterval: 0.13, target: self, selector: #selector(snakeMove), userInfo: nil, repeats: true)
        
    }
    
    //MARK: - UITextViewDelegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Start" {
            self.startAction()
        }
        textView.text = ""
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        //模拟器下方便用键盘操作方向
        if text.lowercased() == "w" {
            self.upAction()
        } else if text.lowercased() == "a" {
            self.leftAction()
        } else if text.lowercased() == "d" {
            self.rightAction()
        } else if text.lowercased() == "s" {
            self.downAction()
        }
        
        return false
    }
    
    //MARK: - CollectionView
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Int(lineNumber * lineNumber)
//        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BoxCell", for: indexPath) as! BoxCell
        
        if self.checkSnakeIsAtIndex(index: indexPath.item) {
            cell.updateBodyColor(bodyColor: UIColor.blue)
        } else if self.food?.index == indexPath.item {
            cell.updateBodyColor(bodyColor: UIColor.green)
        } else {
            cell.updateBodyColor(bodyColor: UIColor.clear)
        }
        
        return cell
    }

}

