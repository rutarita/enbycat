package main
import "core:os"
// import "core:strings"
import "core:strconv"
ArgumentParseResult :: struct {
    help: bool,
    files: []string,
    number: bool,
    thickness: uint,
    color_file: string,
}

ParsingError :: enum {
    None,
    UnknownArgument,
    InvalidArgument,
    MissingArgument,
}

parse_args :: proc() -> (ArgumentParseResult, ParsingError) {
    res := ArgumentParseResult{}
    res.thickness = 1
    files := [dynamic]string{}
    args := os.args[1:]
    reserve(&files, len(args))
    next_is_thickness := false
    next_is_color := false
    for arg in args {
        if (next_is_thickness) {
            num, successful := strconv.parse_uint(arg)
            if (!successful) {
                return res, .InvalidArgument
            }
            next_is_thickness = false
            res.thickness = num
            continue
        }
        if (next_is_color) {
            next_is_color = false
            res.color_file = arg
            continue
        }
        if (arg[0] == '-') {
            if (arg[1] == '-') {
                argname := arg[2:]
                switch argname {
                    case "help":
                        res.help = true
                    case "number":
                        res.number = true
                    case "thickness":
                        next_is_thickness = true
                    case "color":
                        next_is_color = true
                    case:
                        return res, .UnknownArgument
                }
            } else {
                for letter in arg[1:] {
                    switch letter {
                        case 'n':
                            res.number = true
                        case 'h':
                            res.help = true
                        case 't':
                            next_is_thickness = true
                        case 'c':
                            next_is_color = true
                        case:
                            return res, .UnknownArgument
                    }
                }
            }
            continue
        }
        append(&files, arg)
    }
    if(next_is_color || next_is_thickness) {
        return res, .MissingArgument
    }
    shrink(&files)
    res.files = files[:]
    return res, nil
}
