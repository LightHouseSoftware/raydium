module raydium.component.widget.widget;

import raydium.component;
import raydium.core;

abstract class Widget : Container
{
    private
    {
        WidgetState _state;
        Signal!() _clickSignal; // Сигнал для оповещения о клике
        SignalConnection _clickConnection; // Соединение для сигнала
    }

    this(string id = null)
    {
        super(id);
    }

    auto state() @property const
    {
        return _state;
    }

    void state(WidgetState value) @property
    {
        _state = value;
    }

    override void update()
    {
        if (CheckCollisionPointRec(GetMousePosition(), borderBox))
        {
            if (IsMouseButtonDown(MOUSE_BUTTON_LEFT))
            {
                state = WidgetState.Active;
            }
            else
                state = WidgetState.Focus;

            if (IsMouseButtonReleased(MOUSE_BUTTON_LEFT))
            {
                state = WidgetState.Focus;
                _clickSignal.emit();
            }
        }
    }

    void onClick(void delegate() slot)
    {
        _clickSignal.socket.connect(_clickConnection, slot);
    }

    abstract void doArrange();
    abstract void doDraw();
}