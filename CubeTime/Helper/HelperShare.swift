import Foundation
import UIKit

func copyScramble(scramble: String) -> Void {
    let str = "Generated by CubeTime.\n" + scramble
    UIPasteboard.general.string = str
}

func getShareStr(solve: Solve) -> String {
    var str = "Generated by CubeTime.\n"
    let scramble = solve.scramble ?? "Retrieving scramble failed."
    let time = solve.timeText
    
    str += "\(time):\t\(scramble)"
    
    if let comment = solve.comment {
        str += "\n\nComment: \(comment)"
    }

    return str
}

func getShareStr(solves: Set<Solve>) -> String {
    var str = "Generated by CubeTime.\n"
    for solve in solves {
        let scramble = solve.scramble ?? "Retrieving scramble failed."
        let time = solve.timeText
        
        str += "\n\(time):\t\(scramble)"
    }
    
    return str
}

func getShareStr(solve: Solve, phases: Array<Double>?) -> String {
    let scramble = solve.scramble ?? "Retrieving scramble failed."
    let time = solve.timeText
    
    var str = "Generated by CubeTime.\n\(time):\t\(scramble)"
    
    
    if let phases = phases {
        str += "\n\nMultiphase Breakdown:"
        
        
        var prevphasetime = 0.0
        for (index, phase) in phases.enumerated() {
            str += "\n\(index + 1): +\(formatSolveTime(secs: phase - prevphasetime)) (\(formatSolveTime(secs: phase)))"
            prevphasetime = phase
        }
    }
    
    if let comment = solve.comment {
        str += "\n\nComment: \(comment)"
    }
    
    return str
}

func getShareStr(solves: CalculatedAverage) -> String {
    var str = "Generated by CubeTime.\n"
    str += "\(solves.name)"
    if let avg = solves.average {
        str+=": \(formatSolveTime(secs: avg, penType: solves.totalPen))"
    }
    str += "\n\n"
    str += "Time List:"
    
    for pair in zip(solves.accountedSolves!.indices, solves.accountedSolves!) {
        str += "\n\(pair.0 + 1). "
        let formattedTime = formatSolveTime(secs: pair.1.time, penType: Penalty(rawValue: pair.1.penalty))
        if solves.trimmedSolves!.contains(pair.1) {
            str += "(" + formattedTime + ")"
        } else {
            str += formattedTime
        }
        
        str += ":\t"+pair.1.scramble!
    }
    
    return str
}


func copySolve(solve: Solve) -> Void {
    UIPasteboard.general.string = getShareStr(solve: solve)
}

func copySolve(solves: Set<Solve>) -> Void {
    UIPasteboard.general.string = getShareStr(solves: solves)
}

func copySolve(solve: Solve, phases: Array<Double>?) -> Void {
    UIPasteboard.general.string = getShareStr(solve: solve, phases: phases)
}

func copySolve(solves: CalculatedAverage) -> Void {
    UIPasteboard.general.string = getShareStr(solves: solves)
}