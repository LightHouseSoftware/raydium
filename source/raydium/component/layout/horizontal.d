module raydium.component.layout.horizontal;

import raydium.component;

class HorizontalLayout : Layout
{
    this(string id, string styleId = null)
    {
        super(id, styleId);
    }

    override void doArrange()
    {

        auto box = contentBox;
        float currentX = box.x;

        foreach (key, child; _childs)
        {
            float width = 0;
            float minWidth = 0;

            auto w = child.property!Dimension(StyleProperty.width);
            auto mw = child.property!Dimension(StyleProperty.minWidth);

            if(!w.isNull)
                width = w.get.toPixels(box.width);

            if (!mw.isNull)
                minWidth = mw.get.toPixels(box.width);

            width = max(width, minWidth);

            if (_dirty)
            {
                child.measure(Rectangle(currentX, box.y, box.width, box.height));
                child.arrange;
            } 
            currentX += width;
        }
    }

    override void update()
    {
    }
}