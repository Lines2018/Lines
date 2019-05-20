//
//  ViewController.swift
//  Lines
//
//  Created by Color Lines on 18/05/2019.
//  Copyright © 2019 MacService. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // MARK: Properties
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var gameField: UIImageView!
    @IBOutlet weak var pretenderView: PedestalView!
    @IBOutlet weak var kingView: PedestalView!
    var score = 0 { didSet {
        scoreLabel.text = "\(score)"
        kingView.score = score
        pretenderView.score = score
        }}
    var ballViews = [BallView]()
    var steps = [Ball]()
    var undoNext = [Ball]()
    override var canBecomeFirstResponder: Bool { get { return true } }
    var cellWidth: CGFloat { return gameField.bounds.height / 9 }
    var game = Lines()
    var ballSelected:Ball?
    
    lazy var choosenBall = ballViews[81]
    var nextBallScale: CGFloat {
        return showNext ? 0.5 : 0.1
    }
    var showNext = true {
        didSet { nextViews.forEach { $0.transform = CGAffineTransform(scaleX: nextBallScale, y: nextBallScale)}}
    }
    var nextViews = [BallView]()
    // MARK: Actions
    @IBAction func restartAction(_ sender: UIButton) {
        score = 0
        game.colorsInGame = game.colorsInGame == 7 ? 4 : game.colorsInGame + 1
        newGame()
    }
    @IBAction func tapGameField(_ sender: UITapGestureRecognizer) {
        let point = sender.location(in: gameField)
        let cellWidth = gameField.frame.width / 9.0
        let row = Int(point.y / cellWidth) + 1
        let column = Int(point.x / cellWidth) + 1
        if let ball = ballSelected {
            switch game.ways[row][column] {
            case 0:
                stopJumpAnimation()
            case -1:
                let ballView = getBallView(row: ball.row, column: ball.column)
                ballView.isHidden = false
                game.cells[ball.row][ball.column] = ball.color
                configureBallSelected(row: row, column: column)
            case -2:
                stopJumpAnimation()
            default:
                let ballView = getBallView(row: row, column: column)
                ballView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                ballView.isHidden = true
                steps = game.getSteps(row: row, column: column)
                stepAnimation()
            }
        } else {
            if game.cells[row][column] > 0 {
                configureBallSelected(row: row, column: column)
            } else {
                showNext.toggle()
            }
        }
    }

    func configureBallSelected(row: Int, column: Int) {
        ballSelected = Ball(row: row, column: column, color: game.cells[row][column])
        let ball = getBallView(row: row, column: column)
        ball.isHidden = true
        choosenBall.row = CGFloat(row - 1)
        choosenBall.column = CGFloat(column - 1)
        choosenBall.color = game.cells[row][column]
        choosenBall.isHidden = false
        startJumpAnimation()
        game.undo = game.cells
        undoNext = game.nextBalls
        game.cells[row][column] = 0
        game.setWays(row: row, column: column)
    }
    func createBallViews() {
        for index in 0...81 {
            let ball = BallView()
            ball.backgroundColor = UIColor.clear
            ball.isHidden = true
            ball.isUserInteractionEnabled = false
            ball.row = CGFloat(index / 9)
            ball.column = CGFloat(index % 9)
            ballViews.append(ball)
            gameField.addSubview(ball)
        }
    }
    func configureGameField() {
        for i in 1...9 {
            for j in 1...9 {
                let ball = getBallView(row: i, column: j)
                if game.cells[i][j] > 0 {
                    ball.color = game.cells[i][j]
                    ball.isHidden = false
                } else {
                    ball.isHidden = true
                }
            }
        }
    }
    func getBallView(row: Int, column: Int) -> BallView {
        let index = (row - 1) * 9 + column - 1
        return ballViews[index]
    }
    override func viewDidLayoutSubviews() {
        if choosenBall.cellWidth != cellWidth {
            for ball in nextViews {
                ball.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
            ballViews.forEach {$0.cellWidth = cellWidth}
            for ball in nextViews {
                ball.transform = CGAffineTransform(scaleX: nextBallScale, y: nextBallScale)
            }
            if ballSelected != nil {
                startJumpAnimation()
            }
        }
    }
    @objc func appCameToForeground() {
        if ballSelected != nil {
            startJumpAnimation()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        createBallViews()
        newGame()
        self.becomeFirstResponder()
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(appCameToForeground),
                                       name: UIApplication.willEnterForegroundNotification,
                                       object: nil)
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            if undoNext.count > 0 {
                if ballSelected != nil {
                    stopJumpAnimation()
                }
                game.cells = game.undo
                game.nextBalls = undoNext
                undoNext = []
                configureGameField()
                configureNextBalls()
            }
        }
    }
    func dropNextBalls() {
        var c = 0
        for ball in game.nextBalls {
            if game.cells[ball.row][ball.column] > 0 {
                c = ball.color
            } else {
                _ = dropLines(ball: ball)
            }
        }
        if c > 0 {
            game.setNextBalls(count: 1)
            game.nextBalls[0].color = c
            _ = dropLines(ball: game.nextBalls[0])
        }
        game.setNextBalls(count: 3)
    }
    func newGame() {
        if ballSelected != nil {
            stopJumpAnimation()
        }
        if nextViews.count > 0 {
            for ball in nextViews {
                ball.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
            nextViews = []
        }
        game.newGame()
        game.setNextBalls(count: game.ballsInGame)
        dropNextBalls()
        configureGameField()
        configureNextBalls()
    }
    func configureNextBalls() {
        for next in game.nextBalls {
            let ball = getBallView(row: next.row, column: next.column)
            if ball.isHidden {
                ball.transform = CGAffineTransform(scaleX: nextBallScale, y: nextBallScale)
                ball.isHidden = false
                ball.color = next.color
                nextViews.append(ball)
            }
        }
    }
}
extension ViewController {
    // MARK: Animations
    func startJumpAnimation() {
        choosenBall.cellWidth = cellWidth
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       options: [.repeat, .autoreverse, .curveEaseInOut],
                       animations: { self.choosenBall.center.y -= 10 })
    }
    func stopJumpAnimation() {
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       options: [.beginFromCurrentState],
                       animations: { self.choosenBall.cellWidth = self.cellWidth },
                       completion: {finished in
                        self.choosenBall.isHidden = true
                        if let cell = self.ballSelected {
                            let ball = self.getBallView(row: cell.row, column: cell.column)
                            ball.isHidden = false
                            self.game.cells[cell.row][cell.column] = cell.color
                            self.ballSelected = nil
                        }
        })
    }
    func stepAnimation() {
        if steps.count > 0 {
            let ball = steps.remove(at: steps.count - 1)
            UIView.animate(withDuration: 0.1,
                           delay: 0,
                           options: [.curveEaseInOut],
                           animations: {
                            self.choosenBall.row = CGFloat(ball.row - 1)
                            self.choosenBall.column = CGFloat(ball.column - 1)
            },
                           completion: { finished in
                            self.stepAnimation()
            })
        } else {
            moveCompletion(row: Int(choosenBall.row + 1), column: Int(choosenBall.column + 1))
        }
    }
    func dropLines(ball: Ball) -> Int {
        let lines = game.insert(new: ball)
        if lines.count > 4 {
            for cell in lines {
                let ball = getBallView(row: cell.row, column: cell.column)
                UIView.animate(withDuration: 0.5,
                               delay: 0,
                               options: [],
                               animations: { ball.alpha = 0 },
                               completion: { finished in
                                ball.isHidden = true
                                ball.alpha = 1
                                self.game.cells[cell.row][cell.column] = 0
                                for next in self.game.nextBalls {
                                    if (next.row == cell.row) && (next.column == cell.column) {
                                        let nextView = self.getBallView(row: next.row, column: next.column)
                                        nextView.color = next.color
                                        nextView.isHidden = false
                                        nextView.transform = CGAffineTransform(scaleX: self.nextBallScale, y: self.nextBallScale)
                                    }
                                }
                })
            }
        } else {
            game.cells[lines[0].row][lines[0].column] = lines[0].color
            let ballView = getBallView(row: lines[0].row, column: lines[0].column)
            ballView.transform = CGAffineTransform(scaleX: 1, y: 1)
            ballView.isHidden = false
            ballView.color = game.cells[lines[0].row][lines[0].column]
        }
        return lines.count
    }
    func moveCompletion(row: Int, column: Int) {
        choosenBall.isHidden = true
        let ball = getBallView(row: row, column: column)
        ball.isHidden = false
        ball.color = choosenBall.color
        ballSelected = nil
        let count = dropLines(ball: Ball(row: row, column: column, color: choosenBall.color))
        if count < 5 {
            self.appearanceAnimation()
        } else {
            score += 2 * count
        }
    }
    func appearanceAnimation(){
        for (index, ball) in self.nextViews.enumerated() {
            let delay = Double(index) * 0.2
            UIView.animate(withDuration: 0.6,
                           delay: delay,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 0,
                           options: .curveEaseInOut,
                           animations: { ball.transform = CGAffineTransform(scaleX: 1, y: 1) },
                           completion: {finished in
                            if index == self.nextViews.count - 1 {
                                self.dropNextBalls()
                                self.nextViews = []
                                self.configureNextBalls()
                            }
                            
            })
        }
    }
}
