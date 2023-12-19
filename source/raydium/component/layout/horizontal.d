module raydium.component.layout.horizontal;

import raydium.component;

class HorizontalLayout : Layout
{
    this(string id, string styleId = null)
    {
        super(id, styleId);
    }

    override void measure(Rectangle rect)
    {
        _rect = rect;

        auto box = contentBox;

        float totalFixedWidth = 0; // Суммарная ширина всех элементов с фиксированной шириной
        int numFlexChildren = 0; // Количество элементов без фиксированной ширины

        // Предварительный проход для расчета общей фиксированной ширины и подсчета "гибких" элементов
        foreach (child; _childs)
        {
            auto w = child.property!Dimension(StyleProperty.width);

            if (w.isNull)
            {
                numFlexChildren++;
            }
            else
            {
                float width = min(w.get.toPixels(box.width), box.width);
                totalFixedWidth += width;
            }
        }

        float remainingWidth = box.width - totalFixedWidth; // Оставшееся пространство для "гибких" элементов
        remainingWidth = max(0, remainingWidth);
        float flexChildWidth = numFlexChildren > 0 ? remainingWidth / numFlexChildren : 0; // Ширина для каждого "гибкого" элемента

        float currentX = box.x;
        foreach (child; _childs)
        {
            auto w = child.property!Dimension(StyleProperty.width);

            float width;
            if (w.isNull)
            {
                width = flexChildWidth; // Распределяем оставшееся пространство
            }
            else
            {
                width = min(w.get.toPixels(box.width), remainingWidth); // Используем фиксированную ширину, но не больше оставшегося пространства
            }

            child.measure(Rectangle(currentX, box.y, width, box.height));
            currentX += width; // Обновляем текущую X-позицию

            remainingWidth -= width; // Уменьшаем оставшееся пространство
        }

        debug infof("Container %s measured as Rect(%0.f, %0.f, %0.f, %0.f)", id, _rect.x, _rect.y, _rect.width, _rect
                .height);
    }

    override void arrange()
    {
        // Расположение дочерних виджетов в их _rect
        foreach (child; _childs)
        {
            child.arrange();
        }
    }

    override void update()
    {
    }

    override void draw()
    {
    }
}