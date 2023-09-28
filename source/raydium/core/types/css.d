module raydium.core.types.css;

import std.variant;
import std.algorithm;
import std.typecons;
import std.format;
import std.traits;

import raydium.core;

struct BoxSpacing
{
    SizeValue _top;
    SizeValue _right;
    SizeValue _bottom;
    SizeValue _left;

    this(SizeValue top, SizeValue right, SizeValue bottom, SizeValue left)
    {
        _top = top;
        _right = right;
        _bottom = bottom;
        _left = left;
    }

    this(SizeValue top, SizeValue horizontal, SizeValue bottom)
    {
        this(top, horizontal, bottom, horizontal);
    }

    this(SizeValue vertical, SizeValue horizontal)
    {
        this(vertical, horizontal, vertical, horizontal);
    }

    this(SizeValue value)
    {
        _top = value;
        _right = value;
        _bottom = value;
        _left = value;
    }

    this(float top, float right, float bottom, float left)
    {
        _top = SizeValue(top);
        _right = SizeValue(right);
        _bottom = SizeValue(bottom);
        _left = SizeValue(left);
    }

    this(float top, float horizontal, float bottom)
    {
        this(top, horizontal, bottom, horizontal);
    }

    this(float vertical, float horizontal)
    {
        this(vertical, horizontal, vertical, horizontal);
    }

    this(float value)
    {
        _top = SizeValue(value);
        _right = SizeValue(value);
        _bottom = SizeValue(value);
        _left = SizeValue(value);
    }

    auto top() @property const
    {
        return _top;
    }

    auto right() @property const
    {
        return _right;
    }

    auto bottom() @property const
    {
        return _bottom;
    }

    auto left() @property const
    {
        return _left;
    }

    /// in pixels with conversion from %
    float top(float parent = 0) @property const
    {
        return _top.value(parent);
    }

    /// in pixels with conversion from %
    float right(float parent = 0) @property const
    {
        return _right.value(parent);
    }

    /// in pixels with conversion from %
    float bottom(float parent = 0) @property const
    {
        return _bottom.value(parent);
    }

    /// in pixels with conversion from %
    float left(float parent = 0) @property const
    {
        return _left.value(parent);
    }

    bool empty()
    {
        return _top.value == 0
            && _right.value == 0
            && _bottom.value == 0
            && _left.value == 0;
    }

    string toString() const
    {
        return format("Top: %s, Right: %s, Bottom: %s, Left: %s", _top.toString(), _right.toString(), _bottom.toString(), _left
                .toString());
    }
}

struct Background
{
    VariantN!(max(Color.sizeof, Texture2D.sizeof), Color, Texture2D) value;
    alias value this;

    this(Color color)
    {
        value = color;
    }

    this(Texture texture)
    {
        value = texture;
    }
}

struct Border
{
    BoxSpacing _size;
    alias _size this;

    Color color;
    BorderStyle style;

    this(BoxSpacing size, Color col, BorderStyle stl = BorderStyle.Solid)
    {
        _size = size;
        color = col;
        style = stl;
    }

    bool empty()
    {
        return style == BorderStyle.None || _size.empty;
    }
}

struct BorderRadius
{
    BoxSpacing _size;
    alias _size this;

    this(BoxSpacing size)
    {
        _size = size;
    }

    bool empty()
    {
        return _size.empty;
    }
}

struct BoxShadow
{
    float offsetX; // Горизонтальное смещение
    float offsetY; // Вертикальное смещение
    float blurRadius; // Радиус размытия
    float spreadRadius; // Радиус распространения
    Color color; // Цвет тени

    // Конструктор
    this(float offsetX, float offsetY, float blurRadius, float spreadRadius, Color color)
    {
        this.offsetX = offsetX;
        this.offsetY = offsetY;
        this.blurRadius = blurRadius;
        this.spreadRadius = spreadRadius;
        this.color = color;
    }
}

struct Align
{
    HAlign horizontal;
    VAlign vertical;
}

struct SizeValue
{
    private float _value;
    SizeUnit unit;

    this(float value, SizeUnit unit = SizeUnit.Pixels)
    {
        _value = value;
        this.unit = unit;

        if (this.unit == SizeUnit.Percentage && _value > 100)
            _value = 100;
    }

    auto value(float parent = 0) @property const
    {
        if (unit == SizeUnit.Percentage)
        {
            return parent / 100.0f * _value;
        }

        return _value;
    }

    string toString() const
    {
        switch (unit)
        {
        case SizeUnit.Pixels:
            return format("%fpx", _value);
        case SizeUnit.Percentage:
            return format("%f%%", _value);
        default:
            throw new Exception("Unknown size unit.");
        }
    }
}