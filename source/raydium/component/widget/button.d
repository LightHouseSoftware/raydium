module raydium.component.widget.button;

import raydium.component;

class Button : Widget
{
    private
    {
        string _text;
    }

    this(string text = "", string id = null, string styleId = null)
    {
        super(id, styleId);
        _text = text;
    }

    void text(string value) @property
    {
        _text = value;
    }
    
    auto text() @property const
    {
        return _text;
    }

    override void doArrange()
    {
    }

    override void doDraw()
    {
        DrawText(text.ptr, cast(int)contentBox.x, cast(int)contentBox.y, 40, DARKBLUE);
    }
}