module dsrt.classes.c_tui_image;

import std.conv;
import std.file;
import std.string;
import std.array;

import dsrt.pkg;

class TUIImage : TUIOrigin
{    
    @property override public Point getSize() { return Point(_data[0].length.to!int, _data.length.to!int); }
    
    this(Point position = Point(0, 0), Style style = Style(0, 15, 0, 7, 0, 7), dchar[][] source = null)
    {   
        if (source == null)
        {
            _data = [['E','R','R','O','R']];
        }
        else
        {
            _data = source;
        }

        _type = TUIType.image;
        _position = position;
        _style = style;
        _size = Point(5, 1);
        _text = "no path image";
        _currentTextColor = style.activeTextColor;
        _currentBgColor = style.activeBgColor;
        _isPressed = false;
        _canPressed = true;
        _isActive = true;
        _isEnable = false;
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

    public static TUIImage loadFromFile(string path)
    {
        dchar[][] data;

        if (exists(path))
        {
            string content = readText(path);

            string[] lines = content.splitLines(); 

            data = new dchar[][](lines.length);

            foreach (i;0 .. lines.length)
            {
                dstring dline = lines[i].to!dstring;
                data[i] = dline.dup;
            }
        }
        else 
        {
            data = [['E','R','R','O','R']];
        }

        TUIImage answer = new TUIImage(Point(0, 0), Style(0, 15, 0, 7, 0, 7), data);
        answer.setText(path);
        return answer;
    }
}