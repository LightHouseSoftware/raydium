module raydium.core.window;

import raydium.component;

import std.algorithm;

class Window
{
    private
    {
        string _title;
        uint _width, _height;
        uint _minWidth, _minHeight;
        Container _rootContainer;
    }

    this(string title, uint width, uint height, uint minWidth, uint minHeight, ConfigFlags flags)
    {
        SetConfigFlags(flags);
        this(title, width, height, minWidth, minHeight);
    }

    this(string title, uint width, uint height, uint minWidth = 100, uint minHeight = 100)
    {
        _title = title;
        _width = width;
        _height = height;
        _minWidth = minWidth;
        _minHeight = minHeight;
        info("Initialization window...");
        InitWindow(_width, _height, _title.ptr);
    }

    this(string title, uint width, uint height, ConfigFlags flags)
    {
        SetConfigFlags(flags);
        this(title, width, height, 100, 100);
    }

    void minSize(uint width, uint height) @property
    {
        _minWidth = width;
        _minHeight = height;
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
        SetTargetFPS(60);
        ClearBackground(Colors.WHITE);
    }

    void draw()
    {
        if (IsWindowResized())
        {
            _width = GetScreenWidth();
            _height = GetScreenHeight();
            if (_width < _minWidth || _height < _minHeight)
            {
                // Установка нового размера окна, если он меньше минимального
                SetWindowSize(max(_width, _minWidth), max(_height, _minHeight));
                _width = GetScreenWidth();
                _height = GetScreenHeight();
            }

            ClearBackground(RayColors.RAYWHITE);
            if (_rootContainer !is null)
            {
                _rootContainer.measure(Rectangle(0, 0, _width, _height));
                _rootContainer.dirty(true);
            }
        }

        BeginDrawing;

        if(_rootContainer !is null)
        {
            _rootContainer.render();
        }

        debug {
            DrawFPS(_width - 80, 10);
        }

        scope (exit)
            EndDrawing;
    }
}