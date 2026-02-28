module dsrt.classes.c_tui_origin;

import dsrt.pkg;


abstract class TUIOrigin : ITUI 
{
    protected
    {
        TUIType _type;
        string _text;
        Point _size;
        Point _position;
        dchar[][] _data;
        ushort _currentTextColor;
        ushort _currentBgColor;
        Style _style;
        bool _isPressed;
        bool _canPressed;
        bool _isActive;
        bool _isEnable;
        TUIEventHandler _onEnterPressedCallback;
        TUIEventHandler _onEnterReleasedCallback;
        TUIEventHandler _onBackPressedCallback;
        TUIEventHandler _onBackReleasedCallback;
        TUIEventHandler _onAnyPressedCallback;
        TUIEventHandler _onAnyReleasedCallback;
        TUIEventHandler _onTypingCallback;
    }

    @property public void onEnterPressedAction(TUIEventHandler handler) { 
        _onEnterPressedCallback = handler; 
    }
    
    @property public void onEnterReleasedAction(TUIEventHandler handler) { 
        _onEnterReleasedCallback = handler; 
    }

    @property public void onBackPressedAction(TUIEventHandler handler) { 
        _onBackPressedCallback = handler; 
    }
    
    @property public void onBackReleasedAction(TUIEventHandler handler) { 
        _onBackReleasedCallback = handler; 
    }

    @property public void onAnyServiesKeyPressedAction(TUIEventHandler handler) { 
        _onAnyPressedCallback = handler; 
    }
    
    @property public void onAnyServiesKeyReleasedAction(TUIEventHandler handler) { 
        _onAnyReleasedCallback = handler; 
    }

    @property public void onTypingAction(TUIEventHandler handler) { 
        _onTypingCallback = handler; 
    }

    @property public TUIType getType() { return _type; }
    @property public string getText() { return _text; }
    @property public Point getSize() { return _size; }
    @property public Point getPosition() { return _position; }
    @property public dchar[][] getData() { return _data; }
    @property public ushort getTextColor() { return _currentTextColor; }
    @property public ushort getBgColor() { return _currentBgColor; }
    @property public Style getStyle() { return _style; }
    @property public bool isPressed() { return _isPressed; }
    @property public bool canPressed() { return _canPressed; }
    @property public bool isActive() { return _isActive; }
    @property public bool isEnable() { return _isEnable; }
    
    @property public void setPosition(Point position) { _position = position; }
    @property public void setText(string text) { _text = text; }
    @property public void setStyle(Style style) { _style = style; }
    @property public void setActive(bool status) 
    { 
        _isActive = status; 
        if (status)
        {
            _currentTextColor = _style.activeTextColor;
            _currentBgColor = _style.activeBgColor;
        }
        else 
        {
            _currentTextColor = _style.inactiveTextColor;
            _currentBgColor = _style.inactiveBgColor; 
        }
    }
    @property public void setEnable(bool status) { _isEnable = status; }
    @property public void setPressed(bool status) 
    {
       _isPressed = status; 
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

    public void onPressed(EnvironmentEvent e) {} 
    public void onReleased(EnvironmentEvent e) {}   

    public bool intersect(Point target)
    {
        bool a = target.x <= _position.x + _size.x - 1;
        bool b = target.x >= _position.x;
        bool c = target.y >= _position.y;
        bool d = target.y <= _position.y + _size.y - 1;

        return (a && b && c && d);
    }

    public void generateData() {}
}