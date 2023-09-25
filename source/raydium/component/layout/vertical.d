module raydium.component.layout.vertical;

import raydium.core;
import raydium.component;

class VerticalLayout : Layout
{
    
    this(string id)
    {
        super(id);
    }

    override void doArrange()
    {
        auto box = contentBox;
        float currentY = box.y;

        float prevMarginBottom = 0;

        foreach (key, child; _childs)
        {
            float h = max(child.style.height.value(box.height), child.style.minHeight.value(box.height));
            // Вычисляем позицию Y с учетом collapse                
            float y = currentY + max(prevMarginBottom, child.style.margin.top.value(box.height));
            
            if(_dirty)
            {
                child.measure(Rectangle(box.x, y, box.width, box.height));
                child.arrange;
            }

            prevMarginBottom = child.style.margin.bottom.value(box.height);

            // Переходим к следующему элементу                
            currentY = y + h + prevMarginBottom;
        }
    }
}