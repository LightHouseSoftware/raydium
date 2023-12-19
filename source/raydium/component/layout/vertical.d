module raydium.component.layout.vertical;

import raydium.component;

class VerticalLayout : Layout
{
    
    this(string id, string styleId = null)
    {
        super(id, styleId);
    }

    override void measure(Rectangle rect)
    {
        _rect = rect;

        auto box = contentBox;

        float totalFixedHeight = 0; // Суммарная высота всех элементов с фиксированной высотой
        int numFlexChildren = 0; // Количество элементов без фиксированной высоты

        // Предварительный проход для расчета общей фиксированной высоты и подсчета "гибких" элементов
        foreach (child; _childs)
        {
            auto h = child.property!Dimension(StyleProperty.height);

            if (h.isNull)
            {
                numFlexChildren++;
            }
            else
            {
                float height = min(h.get.toPixels(box.height), box.height);
                totalFixedHeight += height;
            }
        }

        float remainingHeight = box.height - totalFixedHeight; // Оставшееся пространство для "гибких" элементов
        remainingHeight = max(0, remainingHeight);
        float flexChildHeight = numFlexChildren > 0 ? remainingHeight / numFlexChildren : 0; // Высота для каждого "гибкого" элемента

        float currentY = box.y;
        foreach (child; _childs)
        {
            auto h = child.property!Dimension(StyleProperty.height);

            float height;
            if (h.isNull)
            {
                height = flexChildHeight; // Распределяем оставшееся пространство
            }
            else
            {
                height = min(h.get.toPixels(box.height), remainingHeight); // Используем фиксированную высоту, но не больше оставшегося пространства
            }

            child.measure(Rectangle(box.x, currentY, box.width, height));
                currentY += height; // Обновляем текущую Y-позицию

            remainingHeight -= height; // Уменьшаем оставшееся пространство
        }

        debug infof("Container %s measured as Rect(%0.f, %0.f, %0.f, %0.f)", id, _rect.x, _rect.y, _rect.width, _rect.height);
    }

    override void arrange()
    {
        //TODO: расположение текущего виджета в его _rect

        // расположение дочерних виджетов в их _rect
        foreach (child; _childs)
        {
            child.arrange();
        }
    }

    override void update(){}
    override void draw(){}
}