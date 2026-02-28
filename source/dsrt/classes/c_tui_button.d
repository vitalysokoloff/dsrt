module dsrt.classes.c_tui_button;

import std.conv;
import dsrt.pkg;

class TUIButton : TUIOrigin
{    
    @property override public void setText(string text) 
    { 
        _text = text; 
        dstring dText = _text.to!dstring;
        _size = Point(cast(int)dText.length + 4, 1);
    }   

    this(Point position = Point(0, 0), Style style = Style(15, 0, 8, 7, 15, 3), string text = "Button")
    {
        _type = TUIType.button;
        _position = position;
        _style = style;
        setText(text);
        _currentTextColor = style.activeTextColor;
        _currentBgColor = style.activeBgColor;
        _isPressed = false;
        _canPressed = true;
        _isActive = true;
        _isEnable = true;
    }

    override public void onPressed(EnvironmentEvent e) 
    {
        if (e.keyType != KeyType.unicode && (e.key == Keys.enter || e.key == Keys.none))
        {
            setPressed(true);
            if (_onEnterPressedCallback !is null) 
            {
                _onEnterPressedCallback(e);
            }
        }
    }

    override public void onReleased(EnvironmentEvent e) 
    {
        if (e.keyType != KeyType.unicode && (e.key == Keys.enter || e.key == Keys.none))
        {
            setPressed(false);
            if (_onEnterReleasedCallback !is null) 
            {
                _onEnterReleasedCallback(e);
            }
        }
    }

    override public void generateData()
    {
        _data = new dchar[][1];         
        dstring dText = "[ " ~ _text.to!dstring ~ " ]";
        _data[0] = dText.dup;
    }
}