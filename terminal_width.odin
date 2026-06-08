package main
import "core:os"
import "core:strconv"


get_term_width :: proc() -> (uint, bool) {
    process_desc := os.Process_Desc{
        "", []string{"resize", "-s"}, nil, nil, nil, nil
    }
    res, stdout, stderr, err := os.process_exec(process_desc, context.temp_allocator)
    defer delete(stdout, context.temp_allocator)
    defer delete(stderr, context.temp_allocator)
    if(err != nil) {
        return 0, false
    }
    stdout_str := string(stdout)
    stdout_str = stdout_str[8:]
    first_semicolon: int = 0
    for r, idx in stdout_str {
        if (r == ';') {
            first_semicolon = idx
            break
        }
    }
    stdout_str = stdout_str[:first_semicolon]
    num, parse_succ := strconv.parse_uint(stdout_str)
    if (!parse_succ) {
        return 0, false
    }
    return num, true
}
