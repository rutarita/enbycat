package main
import "core:fmt"
import "core:os"

help :: proc() {
    fmt.println("WElcome to enbycat\n i am gay\n how it works meow: enbycat [FILES..] -c|--color [COLOR FILE] -t|--thickness [LINE THICKNESS]")
}

main :: proc() {
    args, parse_err := parse_args()
    if (parse_err != nil) {
        fmt.eprintfln("Error parsing arguments: {}", parse_err)
        return
    }
    if(args.help) {
        help()
        return
    }
    painter, painter_creation_error := create_painter(args)
    if(painter_creation_error != nil) {
        // this is starting to piss me off
        fmt.eprintfln("Error with painter: {}", painter_creation_error)
        return
    }
    term_width, term_width_success := get_term_width()
    if (!term_width_success) {
        term_width = 0
    }
    if (len(args.files) > 0) {
        err := paint_files(&painter, args.files[:], term_width)
        if (err != nil) {
            fmt.eprintfln("Error with files: {}", err)
        }
    } else {
        err := paint_fd(&painter, os.stdin, term_width)
        if (err != nil) {
            fmt.eprintfln("Error with stdin: {}", err)
        }
        fmt.println()
        reset_terminal_color()
    }
}
