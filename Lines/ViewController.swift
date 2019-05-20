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
    var ballViews = [BallView]()
    var cellWidth: CGFloat { return gameField.bounds.height / 9 }
    var game = Lines()
    var ballSelected:Ball?
    var score = 0 { didSet { scoreLabel.text = "\(score)" }}
    lazy var choosenBall = ballViews[81]
    // MARK: Actions
    @IBAction func restartAction(_ sender: UIButton) {
        score = 0
        newGame()
    }
    @IBAction func tapGameField(_ sender: UITapGestureRecognizer) {
        let point = sender.location(in: gameField)
        let cellWidth = gameField.frame.width / 9.0
        let row = Int(point.y / cellWidth) + 1
        let column = Int(point.x / cellWidth) + 1
        if let ball = ballSelected {
            ballSelected = nil
            switch game.ways[row][column] {
            case 0:
                game.cells[ball.row][ball.column] = ball.color
            case -1:
                game.cells[ball.row][ball.column] = ball.color
                configureBallSelected(row: row, column: column)
            case -2:
                game.cells[ball.row][ball.column] = ball.color
            default:
                let count = dropLines(ball: Ball(row: row, column: column, color: ball.color))
                if count < 5 {
                    dropNextBalls()
                } else {
                    score += 2 * count
                }
            }
        } else {
            if game.cells[row][column] > 0 {
                configureBallSelected(row: row, column: column)
            }
        }
    }
    func dropLines(ball: Ball) -> Int {
        let lines = game.insert(new: ball)
        if lines.count > 4 {
            for cell in lines {
                game.cells[cell.row][cell.column] = 0
            }
        } else {
            game.cells[lines[0].row][lines[0].column] = lines[0].color
        }
        return lines.count
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
            ballViews.forEach {$0.cellWidth = cellWidth}
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
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(appCameToForeground),
                                       name: UIApplication.willEnterForegroundNotification,
                                       object: nil)
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
        game.newGame()
        game.setNextBalls(count: game.ballsInGame)
        dropNextBalls()
        configureGameField()
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
}
