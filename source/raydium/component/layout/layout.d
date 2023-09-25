module raydium.component.layout.layout;

import raydium.core;
import raydium.component;

abstract class Layout : Container
{
    protected
    {
        IContainer[] _childs;
    }

    this(string id)
    {
        super(id);
    }

    void addChild(T : Container)(T child)
    {
        if (_childs.canFind!(a => a.id == child.id))
        {
            errorf("Контейнер с id %s добавлен ранее, добавление дубликата отменено.", child
                    .id);
            return;
        }

        _childs ~= child;

        _dirty = true;

        debug
        {
            infof("Child container %s added for %s container", child.id, id);
        }
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

    Nullable!T findChildById(T : Container)(string childId)
    {
        return _childs.find!(a => a.id == childId);
    }

    /// Компоновка дочерних элементов
    abstract void doArrange();

    /// Отрисовка дочерних элементов
    void doDraw()
    {
        foreach (child; _childs)
        {
            child.draw();
        }
    }
}