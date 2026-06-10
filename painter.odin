package main
import "core:terminal/ansi"
import "core:fmt"
import "core:os"
Painter :: struct {
    colors: []Color,
    current_color: int,
    thickness: uint,
    current_thickness: uint,
    distance: uint,
}
PainterCreatorError :: enum {
    None,
    ColorFileParsingError,
}

create_painter :: proc(args : ArgumentParseResult) -> (Painter, PainterCreatorError){
    painter := Painter{}
    if(len(args.color_file) != 0) {
        colors, err := parse_color_file(args.color_file)
        if (err != nil) {
            fmt.eprintfln("Error parsing colorfile: {}", err)
            return painter, .ColorFileParsingError
        }
        painter.colors = colors[:]
    } else {
        painter.colors = default_colors[:]
    }
    painter.thickness = args.thickness
    painter.distance = 0
    return painter, nil
}

current_painter_color :: proc(painter: ^Painter) -> Color {
    return painter.colors[painter.current_color]
}

advance_painter :: proc(painter: ^Painter) {
    painter.current_thickness += 1
    if(painter.current_thickness == painter.thickness) {
        painter.current_thickness = 0
        painter.current_color += 1
        if(painter.current_color == len(painter.colors)) {
            painter.current_color = 0
        }
    }
}

PainterError :: enum {
    None,
    FileOpeningError
}

color_terminal :: proc(color: Color) {
    fmt.printf("{}{};{};{};{}{}", ansi.CSI,ansi.FG_COLOR_24_BIT, color.r, color.g, color.b, ansi.SGR)
}

reset_terminal_color :: proc() {
    fmt.print(ansi.CSI + ansi.FG_DEFAULT + ansi.SGR)
}

update_color :: proc(painter: ^Painter) {
    if(painter.current_thickness == 0) {
        color_terminal(current_painter_color(painter))
    }
}

paint_string :: proc(painter: ^Painter, str: string, terminal_width: uint) {
    update_color(painter)
    offset: uint = 0
    current_distance: uint = painter.distance
    string_start: uint = 0
    for r in str {
        if (r == '\n' || (terminal_width != 0 && current_distance == terminal_width)) {
            fmt.print(str[offset:string_start + offset])
            // fmt.eprintln(str[offset:])
            if (r != '\n' ) { fmt.println() }// i guess it works
            offset += string_start
            current_distance = 0
            string_start = 0
            advance_painter(painter)
            update_color(painter)
        }
        current_distance += 1
        string_start += 1
    }
    if (current_distance != 0) {
        fmt.print(str[offset:string_start + offset]) // i forgot to flush leftover string ig lmao :p
    }
    painter.distance = current_distance
}
paint_fd :: proc(painter: ^Painter, file: ^os.File, terminal_width: uint) -> PainterError {
    buffer: [4096]u8 = ---
    for {
        read, err := os.read(file, buffer[:])
        if (err != nil) {
            return nil
        }
        str := string(buffer[:read])
        paint_string(painter, str, terminal_width)
    }
    return nil
}

paint_file :: proc(painter: ^Painter, path: string, terminal_width: uint) -> PainterError {
    file, file_err := os.open(path)
    if(file_err != nil) {
        return .FileOpeningError
    }
    defer os.close(file)
    return paint_fd(painter, file, terminal_width)
}


paint_files :: proc(painter: ^Painter, paths: []string, terminal_width: uint) -> PainterError {
    for p in paths {
        err := paint_file(painter, p, terminal_width)
        if (err != nil) {
            return err
        }
    }
    reset_terminal_color()
    fmt.println()
    return nil
}
