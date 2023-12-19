module raydium.component.widget.label;

import raydium.component;

import std.math;
import std.array;
import std.typecons;
import std.string;

class Label : Widget
{
    private
    {
        string _text;
        float _fontSize;
        Font _font;
        Color _color;
    }
    
    this(string id = null, string styleId = null, string text = "")
    {
        super(id, styleId);
        _text = textСleaning(text);
        _fontSize = 12;
        _font = GetFontDefault();
        _color = Colors.BLACK;

        auto fontSize = property!Dimension(StyleProperty.fontSize);
        if (!fontSize.isNull)
        {
            _fontSize = fontSize.get.toPixels;
        }

        auto fontfamily = property!FontFamily(StyleProperty.fontFamily);
        if (!fontfamily.isNull)
        {
            _font = FontHelper.loadFontFromMemory(fontfamily.get.fonts[0], cast(int) _fontSize);
        }

        auto textColor = property!Color(StyleProperty.textColor);
        if (!textColor.isNull)
        {
            _color = textColor.get;
        }
    }

    void text(string value) @property
    {
        _text = textСleaning(value);
        dirty(true);
    }
    
    auto text() @property const
    {
        return _text;
    }

    override void measure(Rectangle rect)
    {
        _rect = rect;

        auto margin = property!Dimensions(StyleProperty.margin);
        auto padding = property!Dimensions(StyleProperty.padding);
        auto border = property!Border(StyleProperty.border);
        auto textSize = MeasureTextEx(_font, _text.ptr, _fontSize, 1.0f);

        float width = textSize.x;
        float height = textSize.y;

        if(!margin.isNull)
        {
            width += margin.get.left.toPixels(_rect.width) + margin.get.right.toPixels(_rect.width);
            height += margin.get.top.toPixels(_rect.height) + margin.get.bottom.toPixels(_rect.height);
        }

        if (!padding.isNull)
        {
            width += padding.get.left.toPixels(_rect.width) + padding.get.right.toPixels(_rect.width);
            height += padding.get.top.toPixels(_rect.height) + padding.get.bottom.toPixels(_rect.height);
        }

        if (!border.isNull)
        {
            auto borderWidth = border.get.width.toPixels(_rect.width) * 2;
            width += borderWidth;
            height += borderWidth;
        }

        width = min(_rect.width, width);
        height = min(_rect.height, height);

        _rect = Rectangle(rect.x, rect.y, width, height);

        debug infof("Container %s measured as Rect(%0.f, %0.f, %0.f, %0.f)", id, _rect.x, _rect.y, _rect.width, _rect
                .height);
    }

    override void arrange()
    {

    }

    override void draw()
    {
   
        Rectangle contentRect = contentBox; // Получение размера контента

        // Включение scissor mode для обрезки текста
        BeginScissorMode(cast(int) contentRect.x, cast(int) contentRect.y, cast(int) contentRect.width, cast(int) contentRect.height);

        // Рисование текста
        DrawTextEx(_font, _text.ptr, Vector2(contentRect.x, contentRect.y), _fontSize, 1.0f, _color);
        SetTextureFilter(_font.texture, TextureFilter.TEXTURE_FILTER_BILINEAR);

        // Отключение scissor mode
        EndScissorMode();

        //DrawTextEx(_font, displayText.ptr, Vector2(contentRect.x, contentRect.y), _fontSize, 1.0f, _color);
    }

    private string textСleaning(string value)
    {
        return value.replace("\n", "");
    }
}