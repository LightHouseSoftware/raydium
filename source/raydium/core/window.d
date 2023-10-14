module raydium.core.window;

import raydium.component;

import std.algorithm;

class Window
{
    private
    {
        string _title;
        uint _width, _height;
        Container _rootContainer;
    }

    this(string title, uint width, uint height)
    {
        _title = title;
        _width = width;
        _height = height;
        info("Initialization window...");
    }

    this(string title, uint width, uint height, ConfigFlags flags)
    {
        this(title, width, height);
        SetConfigFlags(flags);
    }

    void setConfigFlags(ConfigFlags flags)
    {
        SetConfigFlags(flags);
    }

    void setRootContainer(T : Container)(T container)
    {
        container.measure(Rectangle(0, 0, _width, _height));
        _rootContainer = container;
        infof("Root container set as %s", container.id);
    }

    void show()
    {
        info("Show window...");
        InitWindow(_width, _height, _title.ptr);
        SetTargetFPS(60);
        ClearBackground(RAYWHITE);
    }

    void draw()
    {
        if (IsWindowResized())
        {
            _width = GetScreenWidth();
            _height = GetScreenHeight();
            ClearBackground(RAYWHITE);
            if (_rootContainer !is null)
            {
                _rootContainer.measure(Rectangle(0, 0, _width, _height));
                _rootContainer.dirty(true);
            }
        }

        BeginDrawing();

        if(_rootContainer !is null)
        {
            _rootContainer.draw();
        }

        debug {
            DrawFPS(_width - 80, 10);
        }

        EndDrawing();
    }
}