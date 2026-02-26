import Foundation

// MARK: - ANSI Color Codes for Terminal Output
struct ANSI {
    static let reset  = "\u{001B}[0m"
    static let red    = "\u{001B}[31m"
    static let green  = "\u{001B}[32m"
    static let cyan   = "\u{001B}[36m"
    static let bold   = "\u{001B}[1m"
    static let yellow = "\u{001B}[33m"
}

// MARK: - Diff Result Types
enum DiffLine {
    case unchanged(String)
    case added(String)
    case removed(String)
    case separator(Int, Int)
}

// MARK: - LCS-Based Diff Engine
func lcs(_ a: [String], _ b: [String]) -> [[Int]] {
    let m = a.count, n = b.count
    var dp = Array(repeating: Array(repeating: 0, count: n + 1), count: m + 1)

    for i in 1...m {
        for j in 1...n {
            dp[i][j] = (a[i - 1] == b[j - 1])
                ? dp[i - 1][j - 1] + 1
                : max(dp[i - 1][j], dp[i][j - 1])
        }
    }
    return dp
}

func buildDiff(_ a: [String], _ b: [String], _ dp: [[Int]], _ i: Int, _ j: Int) -> [DiffLine] {
    if i == 0 && j == 0 { return [] }
    if i == 0 { return buildDiff(a, b, dp, i, j - 1) + [.added(b[j - 1])] }
    if j == 0 { return buildDiff(a, b, dp, i - 1, j) + [.removed(a[i - 1])] }

    if a[i - 1] == b[j - 1] {
        return buildDiff(a, b, dp, i - 1, j - 1) + [.unchanged(a[i - 1])]
    } else if dp[i - 1][j] >= dp[i][j - 1] {
        return buildDiff(a, b, dp, i - 1, j) + [.removed(a[i - 1])]
    } else {
        return buildDiff(a, b, dp, i, j - 1) + [.added(b[j - 1])]
    }
}

// MARK: - Diff Printer
func printDiff(_ diffs: [DiffLine], context: Int = 3) {

    var changedIndices = Set<Int>()
    for (i, diff) in diffs.enumerated() {
        if case .unchanged = diff {} else { changedIndices.insert(i) }
    }

    var printIndices = Set<Int>()
    for idx in changedIndices {
        for offset in -context...context {
            let neighbor = idx + offset
            if neighbor >= 0 && neighbor < diffs.count {
                printIndices.insert(neighbor)
            }
        }
    }

    if printIndices.isEmpty {
        print("\(ANSI.bold)\(ANSI.cyan)✓ Files are identical.\(ANSI.reset)")
        return
    }

    let sorted = printIndices.sorted()
    var lastPrinted: Int? = nil

    for idx in sorted {
        if let last = lastPrinted, idx > last + 1 {
            print("\(ANSI.cyan)@@ ...\(ANSI.reset)")
        }
        lastPrinted = idx

        switch diffs[idx] {
        case .unchanged(let line):
            print("  \(line)")
        case .added(let line):
            print("\(ANSI.green)+ \(line)\(ANSI.reset)")
        case .removed(let line):
            print("\(ANSI.red)- \(line)\(ANSI.reset)")
        case .separator:
            break
        }
    }
}

// MARK: - Summary
func printSummary(_ diffs: [DiffLine]) {
    var added = 0, removed = 0, unchanged = 0

    for d in diffs {
        switch d {
        case .added: added += 1
        case .removed: removed += 1
        case .unchanged: unchanged += 1
        default: break
        }
    }

    print("")
    print("\(ANSI.bold)── Summary ────────────────────────────────\(ANSI.reset)")
    print("\(ANSI.green)  Lines added    : \(added)\(ANSI.reset)")
    print("\(ANSI.red)  Lines removed  : \(removed)\(ANSI.reset)")
    print("  Lines unchanged: \(unchanged)")
    print("\(ANSI.bold)───────────────────────────────────────────\(ANSI.reset)")
}

// MARK: - File Reading
func readLines(from path: String) -> [String]? {
    let url = URL(fileURLWithPath: (path as NSString).expandingTildeInPath)

    guard let content = try? String(contentsOf: url, encoding: .utf8) else {
        fputs("Error: Could not read file at path: \(path)\n", stderr)
        return nil
    }

    var lines = content.components(separatedBy: "\n")
    if lines.last == "" { lines.removeLast() }

    return lines
}

// MARK: - Entry Point
func run() {
    let args = CommandLine.arguments

    guard args.count == 3 else {
        print("\(ANSI.bold)Usage:\(ANSI.reset) filediff <file1> <file2>")
        print("  Compares two text files and outputs their differences.")
        exit(1)
    }

    let path1 = args[1]
    let path2 = args[2]

    guard let lines1 = readLines(from: path1),
          let lines2 = readLines(from: path2) else {
        exit(1)
    }

    print("\(ANSI.bold)── File Diff ───────────────────────────────\(ANSI.reset)")
    print("\(ANSI.red)--- \(path1)\(ANSI.reset)")
    print("\(ANSI.green)+++ \(path2)\(ANSI.reset)")
    print("\(ANSI.bold)───────────────────────────────────────────\(ANSI.reset)\n")

    let dp = lcs(lines1, lines2)
    let diffs = buildDiff(lines1, lines2, dp, lines1.count, lines2.count)

    printDiff(diffs, context: 3)
    printSummary(diffs)
}

run()
