package main

import "core:math"

draw_buffer :: proc(data : ^[]u8, width : int, height: int) {
    pixels := transmute([^]u32)raw_data(data^)

    for idx in 0..<(width * height) {
        col := idx % width
        row := idx / width

        // Normalize coordinates to 0-1 range
        x := f32(col) / f32(width)
        y := f32(row) / f32(height)

        // Create plasma effect with multiple sine waves
        v1 := math.sin(x * 10.0)
        v2 := math.sin(y * 10.0)
        v3 := math.sin((x + y) * 10.0)
        v4 := math.sin(math.sqrt(x*x + y*y) * 20.0)

        // Combine the waves
        plasma := (v1 + v2 + v3 + v4) / 4.0

        // Map to RGB colors
        r := u32((math.sin(plasma * math.PI + 0.0) * 0.5 + 0.5) * 255.0)
        g := u32((math.sin(plasma * math.PI + 2.0) * 0.5 + 0.5) * 255.0)
        b := u32((math.sin(plasma * math.PI + 4.0) * 0.5 + 0.5) * 255.0)

        // RGBA8888 format: 0xAABBGGRR
        pixel := u32(0xFF000000) | (b << 16) | (g << 8) | r

        pixels[idx] = pixel
    }
}
