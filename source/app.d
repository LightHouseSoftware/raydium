import bindbc.raylib;
import std.logger;
import core.stdc.stdlib;

import seb;

import window;
import component.layout.vertical;
import component.layout.horizontal;
import types;


void main(string[] args)
{
	uint w = 800;
	uint h = 600;
	auto app = new Application("test", w, h, FLAG_WINDOW_RESIZABLE | FLAG_VSYNC_HINT | FLAG_MSAA_4X_HINT);

	Style style1 = Style.create("style1")
		//.margin(BoxSpacing(0, 10))
		.border(Border(BoxSpacing(10), RED, BorderStyle.Solid))
		.height(SizeValue(33.33, SizeUnit.Percentage))
		.background(Background(ORANGE))
		.build;

	Style style2 = Style.create("style2")
		//.margin(BoxSpacing(0, 5))
		.border(Border(BoxSpacing(5), GRAY, BorderStyle.Solid))
		.height(SizeValue(33.33, SizeUnit.Percentage))
		.background(Background(VIOLET))
		.build;

	Style style3 = Style.create("style3")
		.border(Border(BoxSpacing(5), PURPLE, BorderStyle.Solid))
		.height(SizeValue(33.33, SizeUnit.Percentage))
		.width(SizeValue(100, SizeUnit.Percentage))
		.background(Background(YELLOW))
		.build;

	Style style4 = Style.create("style4")
		.border(Border(BoxSpacing(2), BLUE, BorderStyle.Solid))
		.height(SizeValue(50, SizeUnit.Percentage))
		.width(SizeValue(50, SizeUnit.Percentage))
		.borderRadius(BorderRadius(BoxSpacing(0.5, SizeUnit.Percentage)))
		.background(Background(BLANK))
		.build;

	VerticalLayout test1 = new VerticalLayout("vl2");
	test1.style(style1);

	VerticalLayout test2 = new VerticalLayout("vl3");
	test2.style(style2);

	HorizontalLayout test3 = new HorizontalLayout("vl4");
	test3.style(style3);

	VerticalLayout test4 = new VerticalLayout("vl5");
	test4.style(style4);

	VerticalLayout test5 = new VerticalLayout("vl6");
	test5.style(style4);

	test3.addChild(test4);
	test3.addChild(test5);

	Style rootStyle = Style.create("rootStyle")
		.background(Background(GREEN))
		.padding(BoxSpacing(10))
		.build;
	
	VerticalLayout vlayout = new VerticalLayout("vl1");
	vlayout.style(rootStyle);
	vlayout.addChild(test1);
	vlayout.addChild(test2);
	vlayout.addChild(test3);

	app.window.setRootContainer(vlayout);
	
	app.run;
}

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