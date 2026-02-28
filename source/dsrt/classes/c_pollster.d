module dsrt.classes.c_pollster;

import std.stdio;
import dsrt.pkg;

class Pollster : IPollster
{
    protected 
    {
        IEnvironment _env;
        ClickHandler _clickHandler;
        
        // Две переменные для разделения состояний по твоему совету
        bool _wasMouseButtonPressed; 
        bool[dchar] _wasKeyboardKeyPressed; 
    }

    this(IEnvironment env)
    {
        _env = env;
        _env.disableQuickEdit();
        _wasMouseButtonPressed = false;
    }

    // Тот самый метод, который требовал компилятор
    @property public void onClickAction(ClickHandler handler)
    {
        _clickHandler = handler;
    }

    public void update()
    {
        EnvironmentEvent e = _env.pollEvent();

        if (e.type == EnvironmentEventType.none) return;

        // 1. ОБРАБОТКА МЫШИ
        if (e.type == EnvironmentEventType.mouse)
        {
            if (e.isPressed != _wasMouseButtonPressed)
            {
                if (e.isPressed)
                {
                    _env.setCursorPosition(Point(e.x, e.y));
                }

                if (_clickHandler !is null)
                {
                    _clickHandler(e);
                }

                _wasMouseButtonPressed = e.isPressed;
            }
            return;
        }
        // 2. ОБРАБОТКА КЛАВИАТУРЫ
        else if (e.type == EnvironmentEventType.keyboard)
        {
            int keyCode = cast(ushort)e.key;

            //Стрелки
            if (e.keyType == KeyType.arrows)
            {
                if (e.isPressed) // Двигаем только когда кнопка нажата
                {
                    Point currentPos = _env.getCursorPosition();
                    
                    if (keyCode == Keys.left) // Влево
                        _env.setCursorPosition(Point(currentPos.x - 1, currentPos.y));
                    else if (keyCode == Keys.up) // Вверх
                        _env.setCursorPosition(Point(currentPos.x, currentPos.y - 1));
                    else if (keyCode == Keys.right) // Вправо
                        _env.setCursorPosition(Point(currentPos.x + 1, currentPos.y));
                    else if (keyCode == Keys.down) // Вниз
                        _env.setCursorPosition(Point(currentPos.x, currentPos.y + 1));
                }
                return; // Поглощаем событие, чтобы оно не улетело в ClickHandler
            }

            // Остальные клавиши
            if (e.type.keyboard) 
            {
                if (e.isPressed != _wasKeyboardKeyPressed.get(e.key, false))
                {                    
                    if (_clickHandler !is null)
                    {
                        _clickHandler(e);
                    }

                    _wasKeyboardKeyPressed[e.key] = e.isPressed;
                    
                    foreach (k; _wasKeyboardKeyPressed.keys) 
                    {
                        if (k != e.key)
                        {
                            _wasKeyboardKeyPressed[k] = false;
                        }
                    }  
                }
                return;
            }
        }
    }
}