package main
import "core:os"
import "core:strconv"

Color :: struct {
    r, g, b: u8,
}

default_colors := [?]Color{ // i cannot make this constant
    Color{255, 0, 0},
    Color{0, 255, 0},
    Color{0, 0, 255}
}

ColorFileParsingError :: enum {
    None,
    FileDoesNotExist,
    InvalidFile,
    FileReadingError,
}

parse_color_file :: proc(path: string) -> ([]Color, ColorFileParsingError) {
    file, open_error := os.open(path)
    if (open_error != nil) {
        return nil, .FileReadingError
    }
    defer os.close(file)
    colors := [dynamic]Color{}
    buffer : [2]u8 = ---
    rgb: [3]u8 = ---
    offset: i64 = 0
    for {
        for i in 0..<3 {
            read, err := os.read(file, buffer[:])
            offset += 2
            if(err != nil) {
                // if (err == .EOF) {
                //     shrink(&colors)
                //     return colors[:], nil
                // }
                return nil, .FileReadingError
            }
            num, is_succeful := strconv.parse_uint(string(buffer[:]), 16)
            if (!is_succeful) {
                return nil, .InvalidFile
            }
            rgb[i] = cast(u8)num
        }
        append(&colors, Color{rgb[0], rgb[1], rgb[2]})
        read, err := os.read(file, buffer[:1])
        offset += 1
        if(err != nil) {
            if (err == .EOF) {
                break
            }
            return nil, .FileReadingError
        }
        if(buffer[0] != '\n' && buffer[0] != ';') {
            return nil, .InvalidFile
        }
        _, check_err := os.read_at(file, buffer[:1],offset)
        if (check_err == .EOF) {
            break
        }
    }
    shrink(&colors)
    return colors[:], nil
}
