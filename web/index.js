(async () => {
	const response = await fetch("wasm_renderer.wasm");
	const buffer = await response.arrayBuffer();

	const canvas = document.getElementById('canvas');
	const ctx = canvas.getContext('2d');
	const BYTES_PER_PIXEL = 4; // RGBA

	const { instance, module } = await WebAssembly.instantiate(buffer,
		{
			env: {
				sinf: Math.sin,
				cosf: Math.cos,
				tanf: Math.tan,
				sqrtf: Math.sqrt,
				powf: Math.pow,
				expf: Math.exp,
				logf: Math.log,
				floorf: Math.floor,
				ceilf: Math.ceil,
				fabsf: Math.abs,
				fmodf: (x, y) => x % y,
			}
		}
	);

	const memory = instance.exports.memory;
	console.log("WASM memory pages:", memory.buffer.byteLength / 65536);
	console.log("Exported functions:", Object.keys(instance.exports));

	function render() {
		const WIDTH = canvas.width;
		const HEIGHT = canvas.height;
		const BUFFER_SIZE = WIDTH * HEIGHT * BYTES_PER_PIXEL;

		console.log(`Rendering at ${WIDTH}x${HEIGHT}`);

		const bufferPtr = 1024 * 1024; // Start at 1MB offset

		// Calculate pages needed
		const currentBytes = memory.buffer.byteLength;
		const bytesNeeded = bufferPtr + BUFFER_SIZE;
		const PAGES_NEEDED = Math.ceil(bytesNeeded / 65536);
		const currentPages = currentBytes / 65536;

		if (currentPages < PAGES_NEEDED) {
			const pagesToGrow = PAGES_NEEDED - currentPages;
			console.log(`Growing memory by ${pagesToGrow} pages`);
			memory.grow(pagesToGrow);
			console.log(`New memory size: ${memory.buffer.byteLength} bytes`);
		}

		instance.exports.web_draw_buffer(bufferPtr, BUFFER_SIZE, WIDTH, HEIGHT);

		// Read back the pixel data
		const pixelData = new Uint8Array(memory.buffer, bufferPtr, BUFFER_SIZE);

		// Create ImageData from the pixel buffer and draw to canvas
		const imageData = ctx.createImageData(WIDTH, HEIGHT);
		imageData.data.set(pixelData);
		ctx.putImageData(imageData, 0, 0);

		console.log("Image rendered to canvas!");
	}

	// Function to update canvas resolution to match display size
	function updateCanvasSize() {
		const rect = canvas.getBoundingClientRect();
		const dpr = window.devicePixelRatio || 1;

		// Set canvas resolution to match display size (with device pixel ratio)
		canvas.width = rect.width * dpr;
		canvas.height = rect.height * dpr;

		console.log(`Canvas resized to ${canvas.width}x${canvas.height} (display: ${rect.width}x${rect.height})`);
		render();
	}

	// Initial render
	updateCanvasSize();

	// Re-render on window resize
	window.addEventListener('resize', updateCanvasSize);
})();
