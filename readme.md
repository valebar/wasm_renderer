# Rendering buffer from Odin to HTML canvas

## Building the wasm module
Run the command
```sh
odin build . -no-entry-point -target=freestanding_wasm32 -out:web/wasm_renderer.wasm
```
