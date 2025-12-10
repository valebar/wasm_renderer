#+build wasm32
package main

import "core:slice"

@(export)
web_draw_buffer :: proc(data : uintptr, length : int, width : int, height : int) {
    byte_data := slice.bytes_from_ptr(rawptr(data), length)
    draw_buffer(&byte_data, width, height)
}
