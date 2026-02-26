# Swift File Diff Utility

A lightweight Command Line Interface (CLI) tool written in Swift that compares two text files and highlights the differences using the Longest Common Subsequence (LCS) algorithm.

## 🚀 Features
* **LCS Algorithm:** Uses dynamic programming to find the most accurate minimal edit script.
* **Colorized Output:** Uses ANSI escape codes for clear, readable terminal diffs (Red for removals, Green for additions).
* **Context Awareness:** Shows surrounding unchanged lines to provide context for changes.
* **Summary Statistics:** Provides a quick count of lines added, removed, and kept.



## 🛠 Installation & Requirements
* **Language:** Swift 5.0+
* **Platform:** macOS or Linux (with Swift installed)

No installation is required. You can simply download `filediff.swift` and run it using the Swift interpreter.

## 💻 Usage
To compare two files, run the following command in your terminal:

```bash
swift filediff.swift <path_to_file_1> <path_to_file_2>
