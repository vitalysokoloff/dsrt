module dsrt.classes.c_tui_check;

import std.conv;
import dsrt.pkg;

class TUICheck : TUIOrigin
{ 
    protected
    {
        dchar[][] _enableData;
        dchar[][] _disableData;
    }

    @property override public void setActive(bool status) 
    { 
        _isActive = status; 
        if (status)
        {
            if (_isEnable)
            {
                _currentTextColor = _style.pressedTextColor;
                _currentBgColor = _style.pressedBgColor;
            }
            else
            {
                _currentTextColor = _style.activeTextColor;
                _currentBgColor = _style.activeBgColor;
            }
        }
        else 
        {
            _currentTextColor = _style.inactiveTextColor;
            _currentBgColor = _style.inactiveBgColor; 
        }
    }
    @property override public void setEnable(bool status) 
    { 
        _isEnable = status; 
        if (status)
        {
            _currentTextColor = _style.pressedTextColor;
            _currentBgColor = _style.pressedBgColor;
        }
        else 
        {
            _currentTextColor = _style.activeTextColor;
            _currentBgColor = _style.activeBgColor; 
        }
    }
    @property override public void setPressed(bool status) { _isPressed = status; }

    this(Point position = Point(0, 0), Style style = Style(15, 0, 8, 7, 15, 2), bool on = false)
    {
        _type = TUIType.check;
        _position = position;
        _style = style;
        _size = Point(3, 1);
        _text = "check";
        _currentTextColor = style.activeTextColor;
        _currentBgColor = style.activeBgColor;
        _isPressed = false;
        _canPressed = true;
        _isActive = true;
        _isEnable = on;
        _enableData = [['[','●',']']];
        _disableData = [['[','-',']']]; 
    }

    override public void onPressed(EnvironmentEvent e) 
    {
        if (e.keyType != KeyType.unicode && (e.key == Keys.enter || e.key == Keys.none))
        {
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
            setEnable(!_isEnable);
            if (_onEnterReleasedCallback !is null) 
            {
                _onEnterReleasedCallback(e);
            }
        }
    }

    override public void generateData()
    {
        if (_isEnable)
        {
            _data = _enableData;
        }
        else
        {
            _data = _disableData;
        }
    }
}