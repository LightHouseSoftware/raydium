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

	Window window() { return _window; }

	void run()
	{
		info("Running...");

		scope (exit)
		{
			EventBus.stop;
			CloseAudioDevice();
			CloseWindow();
			unloadRaylib();
		}

		_window.show();

		while (!WindowShouldClose())
		{
			_window.draw();
		}
	}

	private void initialization()
	{
		info("Initialization...");

		RaylibSupport retVal = loadRaylib();
		if (retVal != raylibSupport)
		{
			if (retVal == RaylibSupport.noLibrary)
			{
				throw new Exception("raylib shared library failed to load");
			}
			else if (retVal == RaylibSupport.badLibrary)
			{
				throw new Exception("One or more symbols failed to load. The likely cause is that the shared library is for a lower version than bindbc-raylib was configured to load.");
			}
			else {
				throw new Exception("Unknown error with raylib load");
			}
		}

		InitAudioDevice();

		EventBus.start;

		debug
		{
			info("Loaded: ", loadedRaylibVersion);
		}
	}
}