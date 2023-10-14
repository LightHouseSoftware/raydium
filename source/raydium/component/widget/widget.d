module raydium.component.widget.widget;

import raydium.component;
import raydium.core;

abstract class Widget : Container
{
    private
    {
        Signal!() _clickSignal; // Сигнал для оповещения о клике
        SignalConnection _clickConnection; // Соединение для сигнала
    }

    this(string id = null, string styleId = null)
    {
        super(id, styleId);
    }

    override void update()
    {
        if (CheckCollisionPointRec(GetMousePosition(), borderBox))
        {
            state = ContainerState.FOCUS;

            if (IsMouseButtonDown(MOUSE_BUTTON_LEFT))
            {
                state = ContainerState.ACTIVE;
            }

            if (IsMouseButtonReleased(MOUSE_BUTTON_LEFT))
            {
                state = ContainerState.FOCUS;
                _clickSignal.emit();
            }
        }
        else {
            state = ContainerState.NORMAL;
        }
    }

    void onClick(void delegate() slot)
    {
        void delegate() @system nothrow wrappedSlot = () nothrow {
            try
            {
                slot();
            }
            catch (Exception e)
            {
                //TODO: Обработка исключения, возможно, с записью в лог или выводом предупреждения
                // притом, тут только nothrow
            }
        };
        _clickSignal.socket.connect(_clickConnection, wrappedSlot);
    }

    abstract void doArrange();
    abstract void doDraw();
}