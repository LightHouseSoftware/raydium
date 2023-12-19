module raydium.component.layout.layout;

import raydium.core;
import raydium.component;

abstract class Layout : Container
{
    protected
    {
        Container[] _childs;
    }

    this(string id, string styleId = null)
    {
        super(id, styleId);
    }

    void addChild(T : Container)(T child)
    {
        if (_childs.canFind!(a => a.id == child.id))
        {
            debug errorf("Контейнер с id %s добавлен ранее, добавление дубликата отменено.", child
                    .id);
            return;
        }

        _childs ~= child;

        _dirty = true;

        debug infof("Child container %s added for %s container", child.id, id);
    }

    void removeChild(T : Container)(T child)
    {
        removeChild(child.id);
    }

    void removeChild(string childId)
    {
        foreach (key, child; _childs)
        {
            if (child.id == childId)
            {
                _childs.remove(key);
                _dirty = true;
            }
        }
    }

    override void dirty(bool value)
    {
        _dirty = value;
        if(_dirty)
        {
            foreach (child; _childs)
            {
                child.dirty(true);
            }
        }
    }

    Nullable!T findChildById(T : Container)(string childId)
    {
        return _childs.find!(a => a.id == childId);
    }

    override void render()
    {
        if (_dirty)
            arrange();

        auto visible = property!bool(StyleProperty.visible);
        auto opacity = property!float(StyleProperty.opacity);
        auto display = property!bool(StyleProperty.display);

        if ((!visible.isNull && !visible.get) || (!opacity.isNull && opacity.get == 0) || (!display.isNull && !display
                .get))
            return;

        // Рендерим фон
        drawBackground();

        // Рендерим рамку поверх фона
        drawBorder();

        // Рендерим контент
        draw();

        update();

        foreach (child; _childs)
        {
            child.render();
        }
    }
}