import Foundation
import UIKit

func copyScramble(scramble: String) -> Void {
    let str = "Generated by CubeTime\n" + scramble
    UIPasteboard.general.string = str
}

func getShareStr(solve: Solve) -> String {
    var str = "Generated by CubeTime\n"
    let scramble = solve.scramble ?? "Retrieving scramble failed."
    let time = solve.timeText
    
    str += "\(time):\t\(scramble)"
    
    if let comment = solve.comment {
        str += "\n\nComment: \(comment)"
    }

    return str
}

func getShareStr(solves: Set<Solve>) -> String {
    var str = "Generated by CubeTime\n"
    #warning("i force unwrapped")
    for solve in solves.sorted(by: { $0.date! > $1.date! }) {
        let scramble = solve.scramble ?? "Retrieving scramble failed."
        let time = solve.timeText
        
        str += "\n\(time):\t\(scramble)"
    }
    
    return str
}

func getShareStr(solve: Solve, phases: Array<Double>?) -> String {
    let scramble = solve.scramble ?? "Retrieving scramble failed."
    let time = solve.timeText
    
    var str = "Generated by CubeTime\n\(time):\t\(scramble)"
    
    
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
    var str = "Generated by CubeTime\n"
    str += "\(solves.name)"
    if let avg = solves.average {
        str+=": \(formatSolveTime(secs: avg, penalty: solves.totalPen))"
    }
    str += "\n\n"
    
    guard let accountedSolves = solves.accountedSolves else {
        return str + "No times to show."
    }
    
    str += "Time List:"
    
    let sortedAccountedSolves = accountedSolves.sorted(by: { $0.date ?? .distantPast > $1.date ?? .distantPast })
    
    for pair in zip(sortedAccountedSolves.indices, sortedAccountedSolves) {
        str += "\n\(pair.0 + 1). "
        let formattedTime = formatSolveTime(secs: pair.1.time, penalty: Penalty(rawValue: pair.1.penalty))
        if solves.trimmedSolves!.contains(pair.1) {
            str += "(" + formattedTime + ")"
        } else {
            str += formattedTime
        }
        
        str += ":\t"+(pair.1.scramble ?? "Retrieving scramble failed.")
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
