import SwiftCurses
#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif

import Foundation

///////////////////////////////////////////////////////////
//
// E X T E N S I O N S
//
///////////////////////////////////////////////////////////

// This extension gives us the wid character type (wchar_t) that the ncurses functions
// that take window parameters want (see below)
extension String {
        func asWideChars<Result>(_ body: (UnsafePointer<wchar_t>) -> Result) -> Result {
                    let u32 = self.unicodeScalars.map { wchar_t(bitPattern: $0.value) } + [0]
                            return u32.withUnsafeBufferPointer { body($0.baseAddress!) }
                                }
}


///////////////////////////////////////////////////////////
//
// I N I T / D E I N I T
//
///////////////////////////////////////////////////////////

// Must be called first before using the library
initSK() {
    setlocale(LC_ALL, "")   // Allow the entire locale to be used
    initscr()               // Initialize the ncurses library
    cbreak()                // Disable line buffering
}

// Must be called at the end to indicate we're
// done with SwiftKicks
deinitSK() {
    endwin()                // End curses mode
}
