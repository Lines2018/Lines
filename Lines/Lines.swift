//
//  Lines.swift
//  Lines
//
//  Created by Color Lines on 19/05/2019.
//  Copyright © 2019 MacService. All rights reserved.
//

import Foundation
struct Ball {
    var row: Int
    var column: Int
    var color: Int
}
struct Lines {
    var colorsInGame = 5
    var ballsInGame = 10
    var nextBalls = [Ball]()
    var cells = Array(repeating: Array(repeating: -1, count:11), count: 11)
    var ways = Array(repeating: Array(repeating: -1, count:11), count: 11)
    lazy var undo = cells
    mutating func newGame() {
        for i in 1...9 {
            for j in 1...9 {
                cells[i][j] = 0
            }
        }
    }
    func insert(new: Ball) -> [Ball] {
        let shiftRow  = [-1, -1, -1, 0, 1, 1,  1,  0]
        let shiftColumn = [-1,  0,  1, 1, 1, 0, -1, -1]
        var lines = Array(repeating: [Ball](), count: 8)
        var ball = new
        var fullLines = [new]
        for k in 0..<8 {
            ball.row = new.row + shiftRow[k]
            ball.column = new.column + shiftColumn[k]
            while cells[ball.row][ball.column] == new.color {
                lines[k].append(ball)
                ball.row += shiftRow[k]
                ball.column += shiftColumn[k]
            }
        }
        for k in 0..<4 {
            if lines[k].count + lines[k+4].count > 3 {
                fullLines += lines[k] + lines[k+4]
            }
        }
        return fullLines
    }
    mutating func setWays(row: Int, column: Int) {
        let shiftRow = [1,  -1,  0, 0]
        let shiftColumn = [0, 0, -1, 1]
        var current = [Ball]()
        var previous = [Ball]()
        for i in 1...9 {
            for j in 1...9 {
                ways[i][j] = (cells[i][j] > 0) ? -1 : -2
            }
        }
        ways[row][column] = 0
        current = [Ball(row: row, column: column, color: 0)]
        repeat {
            previous = current
            current.removeAll()
            for ball in previous {
                for i in 0..<4 {
                    if ways[ball.row + shiftRow[i]][ball.column + shiftColumn[i]] == -2 {
                        ways[ball.row + shiftRow[i]][ball.column + shiftColumn[i]] = ball.color + 1
                        current.append(Ball(row: ball.row + shiftRow[i],
                                            column: ball.column + shiftColumn[i],
                                            color: ball.color + 1))
                    }
                }
            }
        } while !current.isEmpty
    }
    func getSteps(row: Int, column: Int) -> [Ball]{
        var steps = [Ball]()
        var i = row
        var j = column
        steps.append(Ball(row: i, column: j, color: 0))
        while ways[i][j] > 0 {
            if (ways[i][j] - 1) == ways[i+1][j] {
                i += 1
            } else if (ways[i][j] - 1) == ways[i-1][j] {
                i -= 1
            } else if (ways[i][j] - 1) == ways[i][j + 1] {
                j += 1
            } else {
                j -= 1
            }
            steps.append(Ball(row: i, column: j, color: 0))
        }
        return steps
    }
    mutating func setNextBalls(count: Int) {
        var emptyCells = [Ball]()
        for i in 1...9 {
            for j in 1...9 {
                if cells[i][j]==0 {
                    emptyCells.append(Ball(row: i, column: j, color: colorsInGame.arc4random + 1))
                }
            }
        }
        nextBalls.removeAll()
        for _ in 0..<count {
            if !emptyCells.isEmpty {
                nextBalls.append(emptyCells.remove(at: emptyCells.count.arc4random))
            }
        }
    }
}
extension Int {
    var arc4random: Int {
        if self > 0 {
            return Int(arc4random_uniform(UInt32(self)))
        } else {
            return 0
        }
    }
}
