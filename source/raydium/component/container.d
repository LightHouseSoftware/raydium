module raydium.component.container;

import raydium.component;

import std.typecons;

enum ContainerState : string
{
    NORMAL = "normal",
    FOCUS = "focus",
    ACTIVE = "active",
    CHECKED = "checked",
    DISABLED = "disabled"
}

interface IContainer
{
    string id() @property const;

    void styleId(string);
    string styleId();
    ContainerState state() @property const;
    void state(ContainerState value) @property;
    void dirty(bool value);
   
    void update();
    void measure(Rectangle rect);
    void doArrange();
    void arrange();
    T property(T)(string name);

    void doDraw();
    void draw();
}

abstract class Container : IContainer
{
    protected
    {
        string _id;
        bool _dirty;
        string _styleId;
        Rectangle _rect;
        ContainerState _state;
    }

    this(string id = null, string styleId = null)
    {
        _id = id;
        _styleId = styleId;
        if(_styleId is null) _styleId = "container";
        _state = ContainerState.NORMAL;
        _dirty = true;
    }

    string id() @property const
    {
        return _id;
    }

    void styleId(string id)
    {
        if(_styleId != id)
        {
            _styleId = id;
            _dirty = true;
        }
    }

    string styleId()
    {
        return _styleId;
    }

    ContainerState state() @property const
    {
        return _state;
    }

    void state(ContainerState value) @property
    {
        if(_state != value)
        {
            _state = value;
        }
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
        float width = 0;
        float height = 0;
        float minWidth = 0;
        float minHeight = 0;

        auto w = property!Dimension(StyleProperty.width);
        auto h = property!Dimension(StyleProperty.height);
        auto mw = property!Dimension(StyleProperty.minWidth);
        auto mh = property!Dimension(StyleProperty.minHeight);

        if(!w.isNull)
            width = w.get.toPixels(rect.width);

        if(!h.isNull)
            height = h.get.toPixels(rect.height);

        if(!mw.isNull)
            minWidth = mw.get.toPixels(rect.width);

        if(!mh.isNull)
            minHeight = mh.get.toPixels(rect.height);


        // больше или равно минимальному, чек
        width = max(width, minWidth);
        height = max(height, minHeight);

        // меньше или равно доступному, но больше нуля, чек
        width = (width > 0) ? min(width, rect.width) : rect.width;
        height = (height > 0) ? min(height, rect.height) : rect.height;

        //TODO: применение выравнивания

        _rect = Rectangle(rect.x, rect.y, width, height);

        //infof("Measured id `%s`: (%f, %f, %f, %f)" , _id, rect.x, rect.y, width, height);
    }

    final void arrange()
    {
        auto visible = property!bool(StyleProperty.visible);
        auto opacity = property!float(StyleProperty.opacity);

        if ((!visible.isNull && !visible.get) || (!opacity.isNull && opacity.get == 0))
            return;

        doArrange();

        infof("Arrange id `%s`: (%f, %f, %f, %f)", _id, _rect.x, _rect.y, _rect.width, _rect.height);

        _dirty = false;
    }

    final void draw()
    {
        update();

        if (_dirty)
            arrange();

        // Рендерим фон
        drawBackground();

        // Рендерим рамку поверх фона
        drawBorder();

        doDraw();
    }

    abstract void update();

    protected Nullable!T property(T)(string name)
    {
        Nullable!T prop;
        
        if(_state != ContainerState.NORMAL)
        {
            prop = JSL.stateProperty!T(styleId(), state(), name);
        }
        
        if(prop.isNull)
        {
            prop = JSL.property!T(styleId, name);
        }

        return prop;
    }

    protected Rectangle marginBox()
    {
        return _rect;
    }

    protected Rectangle borderBox()
    {
        auto margin = property!Dimensions(StyleProperty.margin);
        if(margin.isNull)
        {
            return _rect;
        }

        return calculateBox(_rect, margin.get);
    }

    protected Rectangle paddingBox()
    {
        auto border = property!Border(StyleProperty.border);
        if (border.isNull)
        {
            return borderBox;
        }

        return calculateBox(borderBox, Dimensions(border.get.width));
    }

    protected Rectangle contentBox()
    {
        auto padding = property!Dimensions(StyleProperty.padding);
        if (padding.isNull)
        {
            return paddingBox;
        }

        return calculateBox(paddingBox, padding.get);
    }

    protected Rectangle calculateBox(Rectangle rect, Dimensions prop)
    {
        Rectangle box;

        //TODO: тоже везде рассчет относительно родителя

        box.x = rect.x + prop.left.toPixels(_rect.width);
        box.y = rect.y + prop.top.toPixels(_rect.height);
        box.width = rect.width - prop.left.toPixels(_rect.width) - prop.right.toPixels(_rect.width);
        box.height = rect.height - prop.top.toPixels(_rect.height) - prop.bottom.toPixels(_rect.height);

        return box;
    }

    protected void drawBackground()
    {
        auto backImage = property!string(StyleProperty.backgroundImage);
        //TODO: gradient
        auto backColor = property!Color(StyleProperty.backgroundColor);

        auto borderRadius = property!BorderRadius(StyleProperty.borderRadius);

        if(!backImage.isNull)
        {
            //TODO: загрузка Texture2D из менеджера ресурсов
            // if(borderRadius.isNull || borderRadius.get.empty)
            // {
            //     DrawTextureRec(texture, paddingBox, Vector2(0, 0), Colors.TRANSPARENT);
            // }
            // else
            // {
                
            // }
        }
        // else if(!backGradient.isNull)
        // {

        // }
        else if (!backColor.isNull)
        {
            if(borderRadius.isNull || borderRadius.get.empty)
            {
                DrawRectangleRec(paddingBox, backColor.get);
            }
            else 
            {
                DrawRectangleRounded(paddingBox, borderRadius.get.topLeft.toPixels(_rect.height), 8, Colors
                        .TRANSPARENT);
            }
        }
    }

    protected void drawBorder()
    {
        auto border = property!Border("border");
        auto borderRadius = property!BorderRadius("border-radius");

        if (border.isNull || border.get.empty)
            return;

        if (borderRadius.isNull || borderRadius.get.empty)
        {
            DrawRectangleLinesEx(borderBox, border.get.width.toPixels(_rect.height), border.get.color);
        }
        else
        {
            float width = border.get.width.toPixels(_rect.width);

            Rectangle bbox = Rectangle(
                        borderBox.x + width, 
                        borderBox.y + width,
                        borderBox.width - width * 2,
                        borderBox.height - width * 2
            );

            DrawRectangleRoundedLines(bbox, borderRadius.get.topLeft.toPixels(_rect.height), 8, border.get.width.toPixels(
                    _rect.height), border.get.color);
        }
    }
}