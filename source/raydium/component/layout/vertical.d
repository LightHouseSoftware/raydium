module raydium.component.layout.vertical;

import raydium.component;

class VerticalLayout : Layout
{
    
    this(string id, string styleId = null)
    {
        super(id, styleId);
    }

    override void doArrange()
    {
        auto box = contentBox;
        float currentY = box.y;

        float prevMarginBottom = 0;

        foreach (key, child; _childs)
        {
            float height = 0;
            float minHeight = 0;
            
            auto m = child.property!Dimensions(StyleProperty.margin);
            auto h = child.property!Dimension(StyleProperty.height);
            auto mh = child.property!Dimension(StyleProperty.minHeight);
            
            if (!h.isNull)
                height = h.get.toPixels(box.height);

            if (!mh.isNull)
                minHeight = mh.get.toPixels(box.height);

            height = max(height, minHeight);

            if(height <= 0)
            {
                height = box.height;
            }

            // Вычисляем позицию Y с учетом collapse                
            float y = currentY + max(prevMarginBottom, (m.isNull) ? 0.0f : m.get.top.toPixels(box.height));
            
            if(_dirty)
            {
                child.measure(Rectangle(box.x, y, box.width, box.height));
                child.arrange;
            }

            prevMarginBottom = (m.isNull) ? 0.0f : m.get.bottom.toPixels(box.height);

            // Переходим к следующему элементу                
            currentY = y + height + prevMarginBottom;
        }
    }

    override void update(){}
}