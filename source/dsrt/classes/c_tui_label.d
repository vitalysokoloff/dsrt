module dsrt.classes.c_tui_label;

import std.conv;
import dsrt.pkg;

class TUILabel : TUIOrigin
{ 
    

    @property override public void setText(string text) 
    { 
        _text = text; 
        dstring dText = _text.to!dstring;
        _size = Point(cast(int)dText.length, 1);
    }

    this(Point position = Point(0, 0), Style style = Style (0, 15, 8, 15, 8, 15), string text = "Label")
    {
        _type = TUIType.label;
        _position = position;
        _style = style;
        setText(text);
        _currentTextColor = style.activeTextColor;
        _currentBgColor = style.activeBgColor;
        _isPressed = false;
        _canPressed = false;
        _isActive = true;
        _isEnable = true;
    }

    override public bool intersect(Point target)
    {
        return false;
    }

    override public void generateData()
    {
        _data = new dchar[][1];         
        dstring dText = _text.to!dstring;
        _data[0] = dText.dup;
    }
}