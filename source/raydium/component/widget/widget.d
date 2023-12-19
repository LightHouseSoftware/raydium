module raydium.component.widget.widget;

import raydium.component;
import raydium.core;

abstract class Widget : Container
{
    private
    {
        Signal!() _clickSignal; // Сигнал для оповещения о клике
        Signal!int _keySignal;
        SignalConnection _clickConnection; // Соединение для сигнала
        SignalConnection _keyConnection;
    }

    this(string id = null, string styleId = null)
    {
        super(id, styleId);
    }

    @property ref SignalSocket!() clickSignal()
    {
        return _clickSignal.socket;
    }

    @property ref SignalSocket!int keySignal()
    {
        return _keySignal.socket;
    }

    override void update()
    {
        //TODO: проверка сложных фигур
        //CheckCollisionPointPoly() 
        if (CheckCollisionPointRec(GetMousePosition(), borderBox))
        {
            state = ContainerState.FOCUS;

            if (IsMouseButtonDown(MOUSE_LEFT_BUTTON))
            {
                state = ContainerState.ACTIVE;
            }

            if (IsMouseButtonReleased(MOUSE_LEFT_BUTTON))
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

        clickSignal.connect(_clickConnection, wrappedSlot);
    }

    void onKey(void delegate(int) slot)
    {
        void delegate(int) @system nothrow wrappedSlot = (int key) nothrow{
            try
            {
                slot(key);
            }
            catch (Exception e)
            {
                // Обработка исключения, например, запись в лог или вывод предупреждения
                // Так как обертка nothrow, исключения здесь обрабатываются, а не пробрасываются
            }
        };
        
        keySignal.connect(_keyConnection, wrappedSlot);
    }
}