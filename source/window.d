module window;

import bindbc.raylib;
import std.logger;
import std.algorithm;

import component.container;
import event.resize;


import seb;


class Window
{
    private
    {
        string _title;
        uint _width, _height;
        uint _virtualWidth, _virtualHeight;
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
        //SetConfigFlags(ConfigFlags.FLAG_WINDOW_HIGHDPI);
        SetConfigFlags(ConfigFlags.FLAG_VSYNC_HINT);
        SetConfigFlags(FLAG_MSAA_4X_HINT);
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
        
        int m = GetCurrentMonitor();
        _virtualWidth = GetMonitorWidth(m);
        _virtualHeight = GetMonitorHeight(m);

        SetTargetFPS(60);

        ClearBackground(RAYWHITE);

        float screenScale = min(cast(float) GetScreenWidth() / _virtualWidth, cast(float) GetScreenHeight() / _virtualHeight);

        SetMouseScale(1.0 / screenScale, 1.0 / screenScale);
        SetMouseOffset(cast(int)(-(GetScreenWidth() - (_virtualWidth * screenScale)) * 0.5), cast(
                int)(-(GetScreenHeight() - (_virtualHeight * screenScale)) * 0.5));
    }

    void draw()
    {
        if (IsWindowResized())
        {
            _width = GetScreenWidth();
            _height = GetScreenHeight();
            ClearBackground(RAYWHITE);
            EventBus.publish(new ResizeEvent(_width, _height));
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