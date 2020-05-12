#if canImport(Darwin)
import Darwin
import SwiftCursesMac
#else
import Glibc
import SwiftCursesLinux
#endif


// This is a test program for raw ncurses->swift functionality. This program will
// change as the need arises to test out something. It does nothing useful but display
// some random text copied from various *.wikipedia.org front pages as well as emojis
//
// to run:
//   swift run -Xcc -DNCURSES_WIDECHAR -Xcc -DCURSES_NEED_WIDE -Xcc -DCURSES_NEED_NCURSES -Xcc -D_XOPEN_SOURCE_EXTENDED
//
// Note that the defines are necessary becaue otherwise mvwaddwstr will not be defined
// from ncurses.h (also, you may notice that, if your editor of choice is configured to
// use sourcekit-lsp, it will complain that mvwaddwstr is undefined; the program *will*
// run if using the command line above)



// This extension gives us the wid character type (wchar_t) that the ncurses functions
// that take window parameters want (see below)
extension String {
    func asWideChars<Result>(_ body: (UnsafePointer<wchar_t>) -> Result) -> Result {
        let u32 = self.unicodeScalars.map { wchar_t(bitPattern: $0.value) } + [0]
        return u32.withUnsafeBufferPointer { body($0.baseAddress!) }
    }
}

// Create a new ncurses window handle. Window handles are necessary for 
// working with the wide versions of the addstr family of functions
// We break out the function between macOS and Linux because they both
// have different ways of returning a WINDOW handle
#if canImport(Darwin)
func create_newwin(height: Int, width: Int, starty: Int, startx: Int) -> Optional<OpaquePointer> {
    let my_win = newwin(Int32(height), Int32(width), Int32(starty), Int32(startx))
    box(my_win, 0, 0)
    wrefresh(my_win)

    return my_win
}
#else
func create_newwin(height: Int, width: Int, starty: Int, startx: Int) -> UnsafeMutablePointer<WINDOW>? {
    let my_win = newwin(Int32(height), Int32(width), Int32(starty), Int32(startx))
    box(my_win, 0, 0)
    wrefresh(my_win)

    return my_win
}
#endif


// This is necessary to get the emojis et al to show correctly
setlocale(LC_ALL, "")

initscr()
cbreak()
// variadic functions won't work
//printw("Hello World !!!")      /* Print Hello World              */

// Character-by-character
/*
move(0,0)
addch(72)
move(0,1)
addch(105)
*/
let height = 0
let width = 0
let starty = 0 // (Int(LINES) - height) / 2
let startx = 0 // (Int(COLS) - width) / 2
refresh()
let my_win = create_newwin(height: height, width: width, starty: starty, startx: startx)

// Let's use the addstr-family of functions to place a string of characters/bytes/etc.

let x = "水深200mより深い海域に住む魚類を深海魚と呼んでい"
mvaddstr(0, 0, x.withCString{ return $0 })
mvwaddwstr(my_win, 10, 10, x.asWideChars { return $0 })
//mvwaddstr(my_win, 10, 10, x.withCString { return $0 })

let c = "🙃🍎🍒🥥🥑🍞🌮🍔🍟🍰🧁🎂🪁🧘🚣🚣♀️🚜"
mvwaddwstr(my_win, 5, 11, c.asWideChars { return $0 })
let d = "მოზოჯით ვიკიპედიაშა!"
mvwaddwstr(my_win, 3, 5, d.asWideChars { return $0 })

let e = "😀 😁 😂 🤣 😃 😄 😅 😆 😉 😊 😋 😎 😍 😘 "
mvwaddwstr(my_win, 15, 9, e.asWideChars { return $0 })

let f = "🍟 🍕 🥪 🥙 🌮 🌯 🥗 🥘 🥫 🍝 🍜 🍲 🍛 🍣"
mvwaddwstr(my_win, 24, 19, f.asWideChars { return $0 })
mvaddstr(26, 19, f.withCString { return $0 })

mvwaddstr(my_win, 25, 25, "hello world")
wrefresh(my_win)
refresh()                      /* Print it on to the real screen */
getch()                        /* Wait for user input */
endwin()                       /* End curses mode                */

print("Hello, world!")
