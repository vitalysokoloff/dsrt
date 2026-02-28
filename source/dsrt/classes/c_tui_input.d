module dsrt.classes.c_tui_input;

import std.conv;
import dsrt.pkg;

class TUIInput : TUIOrigin
{
    protected
    {
        dstring _dText;
    }
    @property override public string getText() { return _dText.to!string; }  
    
    @property override public void setText(string text) { _dText = text.to!dstring; }
    @property override public void setPressed(bool status) { _isPressed = status; }    

    this(int width, Point position = Point(0, 0), Style style = Style(15, 0, 8, 7, 15, 3), string text = "input text")
    {
        _type = TUIType.input;
        _position = position;
        _style = style;
        _size = Point(width, 1);
        _dText = text.to!dstring;
        _currentTextColor = style.activeTextColor;
        _currentBgColor = style.activeBgColor;
        _isPressed = false;
        _canPressed = true;
        _isActive = true;
        _isEnable = true;
    }

    override public void onPressed(EnvironmentEvent e) 
    {
        ulong visibleIndex = e.x - _position.x;
        ulong realIndex;

        if (_dText.length <= _size.x)
        {
            realIndex = visibleIndex;
        }
        else
        {
            int avail = _size.x - 3;
            if (visibleIndex < 3)
                realIndex = _dText.length - avail;
            else
                realIndex = _dText.length - avail + (visibleIndex - 3);
        }

        if (e.keyType != KeyType.unicode )
        {
            setPressed(true);
            if (e.key == Keys.enter || e.key == Keys.none)
            {
                if (_onEnterPressedCallback !is null) 
                {
                    _onEnterPressedCallback(e);
                }
            }
            else if (e.key == Keys.backspace)
            {
                if (realIndex > 0 && realIndex < _dText.length)
                {
                    _dText = _dText[0 .. realIndex] ~ _dText[realIndex + 1 .. $];
                }
                else if (realIndex >= _dText.length && _dText.length > 0)
                {
                    _dText = _dText[0 .. $ - 1];
                }
            }
        }
        else if (e.keyType == KeyType.unicode)
        {   
            if (_onTypingCallback !is null) 
            {
                _onTypingCallback(e);
            }
            
            if (realIndex == 0)
            {
                _dText = e.key ~ _dText;
            }
            else if (realIndex >= _dText.length)
            {
                _dText ~= e.key;
            }
            else
            {
                _dText = _dText[0 .. realIndex] ~ e.key ~ _dText[realIndex .. $];
            }
        }
    }

    override public void onReleased(EnvironmentEvent e) 
    {
        if (e.keyType != KeyType.unicode)
        {
            setPressed(false);
            if (e.key == Keys.enter || e.key == Keys.none)
            {
                if (_onEnterReleasedCallback !is null) 
                {
                    _onEnterReleasedCallback(e);
                }
            }
            else if (e.key == Keys.backspace)
            {
                if (_onBackReleasedCallback !is null) 
                {
                    _onBackReleasedCallback(e);
                }
            }
        }
    }

    override public void generateData()
    {
        dstring dText = _dText;
        dchar[] row = new dchar[_size.x];
        row[] = ' ';  

        int textLen = cast(int)dText.length;
        int maxVisible = _size.x - 1;  // одна колонка справа всегда пустая
        row[_size.x - 1] = '<';

        if (textLen <= maxVisible)
        {
            // Текст помещается — показываем с начала
            row[0 .. textLen] = dText[];
        }
        else
        {
            // Текст длиннее — показываем конец с троеточием
            int dots = 3;
            int avail = maxVisible - dots;  // сколько символов после точек

            if (avail > 0)
            {
                row[0] = '.';
                row[1] = '.';
                row[2] = '.';
                // Последние 'avail' символов текста
                row[dots .. maxVisible] = dText[$ - avail .. $];                
            }
            else
            {
                // Слишком узко даже для трёх точек — просто обрезаем
                row[0 .. maxVisible] = dText[0 .. maxVisible];
            }
        }

        _data = [ row ];
    }
}