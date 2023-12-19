module raydium.core.app;

import raydium.component;
import raydium.core;

class Application {
	private {
		Window _window;
	}

	this(string title, uint width = 800, uint height = 600)
	{
		initialization();
		_window = new Window(title, width, height);
	}

	this(string title, uint width, uint height, ConfigFlags flags) {
		initialization();
		_window = new Window(title, width, height, flags);
	}

	void setMinSize(uint width, uint height) @property
	{
		window.minSize(width, height);
	}

	Window window() { return _window; }

	void run()
	{
		info("Running...");

		scope (exit)
		{
			CloseAudioDevice();
			CloseWindow();
		}

		_window.show();

		while (!WindowShouldClose())
		{
			_window.draw();
		}
	}

	private void initialization()
	{
		validateRaylibBinding();
		InitAudioDevice();
		// FTSupport ret = loadFreeType();
		// if (ret != ftSupport)
		// {
		// 	if (ret == FTSupport.noLibrary)
		// 	{
		// 		throw new Exception("FreeType shared library failed to load");
		// 	}
		// 	else if (FTSupport.badLibrary)
		// 	{
		// 		throw new Exception("FreeType shared library error: one or more symbols failed to load.");
		// 	}
		// }
	}
}