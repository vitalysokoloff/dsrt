module dsrt.classes.c_tui_box;

import std.conv;
import dsrt.pkg;

class TUIBox : TUIOrigin
{   this(Point size, Point position = Point(0, 0), Style style = Style (0, 15, 0, 7, 0, 7), string text = "box")
    {
        _type = TUIType.box;
        _size = size;
        _position = position;
        _style = style;
        _text = text;
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
        _data = new dchar[][_size.y];
        dstring dText = _text.to!dstring;

        foreach (y; 0 .. _size.y) 
        {
            dchar[] row = new dchar[_size.x];

            if (y == 0) {
                // ВЕРХ: ┌── Текст ──┐
                row[] = '─'; // Горизонтальная линия
                row[0] = '┌';
                row[$-1] = '┐';
                
                if (_size.x > 4) 
                {
                    int maxLen = _size.x - 4;
                    dstring toPrint = (dText.length > maxLen) ? dText[0 .. maxLen] : dText;
                    int xOffset = (_size.x - cast(int)toPrint.length) / 2;
                    
                    // добавляем пробелы вокруг текста для красоты
                    row[xOffset-1] = ' '; 
                    row[xOffset .. xOffset + toPrint.length] = toPrint[];
                    row[xOffset + toPrint.length] = ' ';
                }
            } 
            else if (y == _size.y - 1) 
            {
                // НИЗ: └───────────┘
                row[] = '─';
                row[0] = '└';
                row[$-1] = '┘';
            } 
            else 
            {
                // БОКА: │           │
                row[] = ' ';
                row[0] = '│'; // Вертикальная линия
                row[$-1] = '│';
            }
            _data[y] = row;
        }
    }
}
