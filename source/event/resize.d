module event.resize;

import seb;

class ResizeEvent : Event
{
    private {
        uint _width;
        uint _height;
    }

    this(uint width, uint height)
    {
        _width = width;
        _height = height;
    }

    auto width() @property const { return _width; }
    auto height() @property const { return _height; }
}
