module component.layout.horizontal;

import component.layout;

class HorizontalLayout : Layout
{
    this(string id)
    {
        super(id);
    }

    override void doArrange()
    {

        auto box = contentBox;
        float currentX = box.x;

        foreach (key, child; _childs)
        {
            float w = max(child.style.width.value(box.width), child.style.minWidth.value(box.width));
            if (_dirty)
            {
                child.measure(Rectangle(currentX, box.y, box.width, box.height));
                child.arrange;
            } 
            currentX += w;
        }
    }
}