module raydium.core.types.style;

import std.format;

import raydium.core;

class Style
{
    private
    {
        string _id;

        SizeValue _width;
        SizeValue _height;
        SizeValue _minWidth;
        SizeValue _minHeight;
        BoxSpacing _margin;
        BoxSpacing _padding;
        Border _border;
        BorderRadius _radius;
        BoxShadow _shadow;
        Background _background;
        Align _alignment;
        bool _visible;
        float _opacity;
    }

    private this(string id)
    {
        _id = id;
        _width = SizeValue(100, SizeUnit.Percentage);
        _height = SizeValue(100, SizeUnit.Percentage);
        _minWidth = SizeValue(0);
        _minHeight = SizeValue(0);
        _margin = BoxSpacing(SizeValue(0));
        _padding = BoxSpacing(SizeValue(0));
        _border = Border(BoxSpacing(SizeValue(0)), BLANK, BorderStyle.None);
        _radius = BorderRadius(BoxSpacing(SizeValue(0)));
        _shadow = BoxShadow(0, 0, 0, 0, BLANK);
        _background = Background(BLANK);
        _alignment = Align(HAlign.Left, VAlign.Top);
        _visible = true;
        _opacity = 1.0;
    }

    SizeValue width() @property const
    {
        return _width;
    }

    SizeValue height() @property const
    {
        return _height;
    }

    SizeValue minWidth() @property const
    {
        return _minWidth;
    }

    SizeValue minHeight() @property const
    {
        return _minHeight;
    }

    BoxSpacing margin() @property const
    {
        return _margin;
    }

    BoxSpacing padding() @property const
    {
        return _padding;
    }

    Border border() @property const
    {
        return _border;
    }

    BorderRadius borderRadius() @property const
    {
        return _radius;
    }

    BoxShadow shadow() @property const
    {
        return _shadow;
    }

    Background background() @property const
    {
        return _background;
    }

    Align alignment() @property const
    {
        return _alignment;
    }

    bool visible() @property const
    {
        return _visible;
    }

    float opacity() @property const
    {
        return _opacity;
    }

    Style copy() const
    {
        Style newStyle = new Style(this._id);
        newStyle._width = this._width;
        newStyle._height = this._height;
        newStyle._minWidth = this._minWidth;
        newStyle._minHeight = this._minHeight;
        newStyle._margin = this._margin;
        newStyle._padding = this._padding;
        newStyle._border = this._border;
        newStyle._radius = this._radius;
        newStyle._shadow = this._shadow;
        newStyle._background = this._background;
        newStyle._alignment = this._alignment;
        newStyle._visible = this._visible;
        newStyle._opacity = this._opacity;
        return newStyle;
    }

    override string toString() const
    {
        return format(
            "Style(\n" ~
                "  ID: %s\n" ~
                "  Width: %s\n" ~
                "  Height: %s\n" ~
                "  MinWidth: %s\n" ~
                "  MinHeight: %s\n" ~
                "  Margin: %s\n" ~
                "  Padding: %s\n" ~
                "  Border: %s\n" ~
                 // "  BorderRadius: %s\n" ~
                // "  Shadow: %s\n" ~
                // "  Background: %s\n" ~
                // "  Alignment: H[%s] V[%s]\n" ~
                "  Visible: %s\n" ~
                "  Opacity: %s\n" ~
                ")",
            _id,
            _width.toString(),
            _height.toString(),
            _minWidth.toString(),
            _minHeight.toString(),
            _margin.toString(),
            _padding.toString(),
            _border.toString(),// _radius.toString(),
            // _shadow.toString(),
            // _background.toString(),
            // _alignment.horizontal.toString(),
            // _alignment.vertical.toString(),
            _visible ? "true" : "false",
            format("%.2f", _opacity)
        );
    }

    private static class StyleBuilder
    {
        Style style;

        this(string id)
        {
            style = new Style(id);
        }

        StyleBuilder width(SizeValue value) @property
        {
            style._width = value;
            return this;
        }

        StyleBuilder height(SizeValue value) @property
        {
            style._height = value;
            return this;
        }

        StyleBuilder minWidth(SizeValue value) @property
        {
            style._minWidth = value;
            return this;
        }

        StyleBuilder minHeight(SizeValue value) @property
        {
            style._minHeight = value;
            return this;
        }

        StyleBuilder margin(BoxSpacing value) @property
        {
            style._margin = value;
            return this;
        }

        StyleBuilder padding(BoxSpacing value) @property
        {
            style._padding = value;
            return this;
        }

        StyleBuilder border(Border value) @property
        {
            style._border = value;
            return this;
        }

        StyleBuilder borderRadius(BorderRadius value) @property
        {
            style._radius = value;
            return this;
        }

        StyleBuilder shadow(BoxShadow value) @property
        {
            style._shadow = value;
            return this;
        }

        StyleBuilder background(Background value) @property
        {
            style._background = value;
            return this;
        }

        StyleBuilder alignment(Align value) @property
        {
            style._alignment = value;
            return this;
        }

        StyleBuilder visible(bool value) @property
        {
            style._visible = value;
            return this;
        }

        StyleBuilder opacity(float value) @property
        {
            style._opacity = value;
            return this;
        }

        Style build()
        {
            return style.copy();
        }
    }

    static StyleBuilder create(string id = null)
    {
        return new StyleBuilder(id);
    }
}
