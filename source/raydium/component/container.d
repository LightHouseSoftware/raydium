module raydium.component.container;

import raydium.core;
import raydium.event;
import std.algorithm;

interface IContainer
{
    string id() @property const;

    void style(Style value);
    Style style();
    void dirty(bool value);
   
    void measure(Rectangle rect);
    void doArrange();
    void arrange();

    void doDraw();
    void draw();
}

abstract class Container : IContainer
{
    protected
    {
        string _id;
        bool _dirty;
        Style _style;
        Rectangle _rect;
    }

    this(string id = null)
    {
        _id = id;
        _style = Style.create.build;

        EventBus.subscribe!ResizeEvent((event) {
            this.measure(Rectangle(0, 0, event.width, event.height));
            _dirty = true;
        });
    }

    string id() @property const
    {
        return _id;
    }

    void style(Style value)
    {
        _style = value;
        _dirty = true;
    }

    Style style()
    {
        return _style;
    }

    void dirty(bool value) @property
    {
        _dirty = value;
    }

    override bool opEquals(Object o) const
    {
        if (auto other = cast(Container) o)
            return id == other.id;
        return false;
    }

    void measure(Rectangle rect)
    {
        // больше или равно минимальному, чек
        float width = max(style.width.value(rect.width), style.minWidth.value(rect.width));
        float height = max(style.height.value(rect.height), style.minHeight.value(rect.height));

        // меньше или равно доступному, но больше нуля, чек
        width = (width > 0) ? min(width, rect.width) : rect.width;
        height = (height > 0) ? min(height, rect.height) : rect.height;

        //TODO: применение выравнивания

        _rect = Rectangle(rect.x, rect.y, width, height);
    }

    final void arrange()
    {
        if (!style.visible || style.opacity == 0)
            return;

        doArrange();

        _dirty = false;
    }

    final void draw()
    {
        if (_dirty)
            arrange();

        // Рендерим фон
        drawBackground();

        // Рендерим рамку поверх фона
        drawBorder();

        doDraw();
    }

    protected Rectangle marginBox()
    {
        return _rect;
    }

    protected Rectangle borderBox()
    {
        return calculateBox(_rect, style.margin);
    }

    protected Rectangle paddingBox()
    {
        return calculateBox(borderBox, style.border);
    }

    protected Rectangle contentBox()
    {
        return calculateBox(paddingBox, style.padding);
    }

    protected Rectangle calculateBox(Rectangle rect, BoxSpacing prop)
    {
        Rectangle box;

        box.x = rect.x + prop.left(_rect.width);
        box.y = rect.y + prop.top(_rect.height);
        box.width = rect.width - prop.left(_rect.width) - prop.right(_rect.width);
        box.height = rect.height - prop.top(_rect.height) - prop.bottom(_rect.height);

        return box;
    }

    protected void drawBackground()
    {
        // Рисуем фон    
        if (style.background.type == typeid(Color))
        {
            Color color = style.background.get!Color();

            if (style.borderRadius.empty)
            {
                DrawRectangleRec(paddingBox, color);
            }
            else
            {
                DrawRectangleRounded(paddingBox, style.borderRadius.top.value(_rect.height), 8, color);
            }
        }
        else if (style.background.type == typeid(Texture2D))
        {
            Texture2D texture = style.background.get!Texture2D();
            DrawTextureRec(texture, paddingBox, Vector2(0, 0), WHITE);
        }
    }

    protected void drawBorder()
    {
        if (style.border.empty)
            return;

        if (style.borderRadius.empty)
        {
            DrawRectangleLinesEx(borderBox, style.border.top.value(_rect.height), style
                    .border.color);
        }
        else
        {
            DrawRectangleRoundedLines(borderBox, style.borderRadius.top.value(_rect.height), 8, style.border.top.value(
                    _rect.height), _style.border.color);
        }
    }
}