#+build !wasm32
package main

import sdl "vendor:sdl3"

main :: proc() {
    WIDTH :: 800
    HEIGHT :: 600

    buffer := make([]u8, WIDTH * HEIGHT * 4)  // 4 bytes per pixel (RGBA)
    defer delete(buffer)

    success := sdl.Init({sdl.InitFlag.VIDEO})
    assert(success)
    defer sdl.Quit()

    window : ^sdl.Window
    renderer : ^sdl.Renderer
    success = sdl.CreateWindowAndRenderer("Window", WIDTH, HEIGHT, {sdl.WindowFlag.RESIZABLE, sdl.WindowFlag.OPENGL}, &window, &renderer)
    defer {
        sdl.DestroyRenderer(renderer)
        sdl.DestroyWindow(window)
    }
    sdl.SetRenderLogicalPresentation(renderer, WIDTH, HEIGHT, .STRETCH)

    texture := sdl.CreateTexture(renderer, .RGBA8888, .STREAMING, WIDTH, HEIGHT)
    assert(texture != nil)
    defer sdl.DestroyTexture(texture)

    done := false

    event : sdl.Event
    for !done {
        success = sdl.PollEvent(&event)
        if event.type == .QUIT {
            done = true
        }

        success = sdl.RenderClear(renderer)
        assert(success)

        // Fill the buffer using draw_buffer
        draw_buffer(&buffer, WIDTH, HEIGHT)

        // Lock texture and copy buffer data to surface
        surface : ^sdl.Surface
        if sdl.LockTextureToSurface(texture, nil, &surface) {
            // Copy buffer to surface pixels
            dest := transmute([^]u8)surface.pixels
            for i in 0..<len(buffer) {
                dest[i] = buffer[i]
            }
            sdl.UnlockTexture(texture)
        }

        dst_rect := sdl.FRect{
            x = 0.0,
            y = 0.0,
            w = f32(WIDTH),
            h = f32(HEIGHT),
        }

        sdl.RenderTexture(renderer, texture, nil, &dst_rect)

        success = sdl.RenderPresent(renderer)
        assert(success)
    }
}


