module dsrt.classes.c_dsrtio;

import std.format;
import std.file;
import std.array;
import std.algorithm;
import std.json;
import std.conv;

import dsrt.pkg;

JSONValue toJson(Point p) {
    return JSONValue(["x": p.x, "y": p.y]);
}

JSONValue toJson(Style s) {
    return JSONValue([
        "activeTextColor":   (cast(Color)s.activeTextColor).to!string,
        "activeBgColor":     (cast(Color)s.activeBgColor).to!string,
        "inactiveTextColor": (cast(Color)s.inactiveTextColor).to!string,
        "inactiveBgColor":   (cast(Color)s.inactiveBgColor).to!string,
        "pressedTextColor":  (cast(Color)s.pressedTextColor).to!string,
        "pressedBgColor":    (cast(Color)s.pressedBgColor).to!string
    ]);
}

class DsrtIO
{
    public static void saveScreen(ITUIScreen screen, string path)
    {
        string[] entries;
        int count = screen.getElementCount();

        for (int i; i < count; i++)
        {
            ITUI tui = screen.getElementByNumber(i);
            // Собираем объект вручную строкой, чтобы поля не прыгали
            string entry = format(
`{
    "name": %s,
    "type": %s,
    "position": %s,
    "size": %s,
    "style": %s,
    "text": %s,
    "isEnable": %s,
    "isActive": %s
}`,                 
                JSONValue(screen.getElementName(tui)),             // "name"
                JSONValue(JSONValue(tui.getType().to!string)), // "type"
                tui.getPosition().toJson(),
                tui.getSize().toJson(),
                tui.getStyle().toJson(),
                JSONValue(tui.getText()), // Авто-экранирование текста
                JSONValue(tui.isEnable()),// true/false
                JSONValue(tui.isActive()) 
            );
            entries ~= entry;
        }        

        // Собираем всё в массив JSON
        string finalJson = "[\n" ~ entries.join(",\n") ~ "\n]";
        write(path, finalJson);
    }

    public static ITUIScreen loadScreen(string path)
    {
        ITUIScreen answer = new TUIScreen();
        // проверка на существование файла
        if (!exists(path))
        {
            string str = format("file is not exists, name: [%s]", path);
            answer.addError(str);
            return answer;
        }

        JSONValue root;
        // Парсинг
        try
        {
            root = parseJSON(readText(path));
        }
        catch (Exception ex)
        {
            string str = format("file is broken, name:  [%s]", path);
            answer.addError(str);
            return answer;
        }

        // Работа с массивом объектов
        if (root.type != JSONType.array)
        {
            string str = format("file does not contain array, name: [%s]", path);
            answer.addError(str);
            return answer;
        }

        JSONValue[] objectsArray = root.array;

        foreach (i, obj; objectsArray)
        {
            string name;
            TUIType type;
            Point position;
            Point size;
            Style style;
            string text;
            bool enable;
            bool active;

            if (obj.type == JSONType.object)
            {
                // name
                if (auto value = "name" in obj.object)
                {
                    if (value.type == JSONType.string)
                    {
                        name = value.str;
                    }
                    else
                    {                        
                        continue;
                    }
                }
                else
                {
                    string str = format("Object has no name");
                    answer.addError(str);
                    continue;
                }

                // type
                if (auto value = "type" in obj.object)
                {
                    if (value.type == JSONType.string)
                    {
                        try
                        {
                            type = value.str.to!TUIType;
                        }
                        catch(Exception e)
                        {
                            string str = format("Object [%s] has not correct type, name:", name);
                            answer.addError(str);
                            continue;
                        }
                    }
                    else
                    {
                        continue;
                    }
                }
                else
                {
                    string str = format("Object [%s] has no type: name", name);
                    answer.addError(str);
                    continue;
                }

                // position
                position = Point(0, 0);

                if (auto value = "position" in obj.object)
                {
                    if (value.type == JSONType.object)
                    {
                        if (auto x = "x" in value.object)
                        {
                            if (x.type == JSONType.integer)
                            {
                                position.x = x.integer.to!int;
                            }
                        }
                        if (auto y = "y" in value.object)
                        {
                            if (y.type == JSONType.integer)
                            {
                                position.y = y.integer.to!int;
                            }
                        }
                    }
                }

                // size
                size = Point(1, 1);

                if (auto value = "size" in obj.object)
                {
                    if (value.type == JSONType.object)
                    {
                        if (auto x = "x" in value.object)
                        {
                            if (x.type == JSONType.integer)
                            {
                                size.x = x.integer.to!int;
                            }
                        }
                        if (auto y = "y" in value.object)
                        {
                            if (y.type == JSONType.integer)
                            {
                                size.y = y.integer.to!int;
                            }
                        }
                    }
                }

                // style
                ushort at, ab, it, ib, pt, pb;

                if (auto value = "style" in obj.object)
                {
                    if (value.type == JSONType.object)
                    {
                        if (auto ObjValue = "activeTextColor" in value.object)
                        {
                            if (ObjValue.type == JSONType.string)
                            {
                                try
                                {
                                    at = ObjValue.str.to!Color;
                                }
                                catch(Exception e)
                                {
                                    string str = format("Object [%s] has not correct Color, name:", name);
                                    answer.addError(str);
                                    at = 0;
                                }
                                
                            }
                        }
                        if (auto ObjValue  = "activeBgColor" in value.object)
                        {
                            if (ObjValue.type == JSONType.string)
                            {
                                try
                                {
                                    ab = ObjValue.str.to!Color;
                                }
                                catch(Exception e)
                                {
                                    string str = format("Object [%s] has not correct Color, name:", name);
                                    answer.addError(str);
                                    ab = 0;
                                }                                
                            }
                        }
                        if (auto ObjValue  = "inactiveTextColor" in value.object)
                        {
                            if (ObjValue.type == JSONType.string)
                            {
                                try
                                {
                                    it = ObjValue.str.to!Color;
                                }
                                catch(Exception e)
                                {
                                    string str = format("Object [%s] has not correct Color, name:", name);
                                    answer.addError(str);
                                    it = 0;
                                }                                 
                            }
                        }
                        if (auto ObjValue = "inactiveBgColor" in value.object)
                        {
                            if (ObjValue.type == JSONType.string)
                            {
                                try
                                {
                                    ib = ObjValue.str.to!Color;
                                }
                                catch(Exception e)
                                {
                                    string str = format("Object [%s] has not correct Color, name:", name);
                                    answer.addError(str);
                                    ib = 0;
                                } 
                            }
                        }
                        if (auto ObjValue = "pressedTextColor" in value.object)
                        {
                            if (ObjValue.type == JSONType.string)
                            {
                                try
                                {
                                    pt = ObjValue.str.to!Color;
                                }
                                catch(Exception e)
                                {
                                    string str = format("Object [%s] has not correct Color, name:", name);
                                    answer.addError(str);
                                    pt = 0;
                                }                                 
                            }
                        }
                        if (auto ObjValue = "pressedBgColor" in value.object)
                        {
                            if (ObjValue.type == JSONType.string)
                            {
                                try
                                {
                                    pb = ObjValue.str.to!Color;
                                }
                                catch(Exception e)
                                {
                                    string str = format("Object [%s] has not correct Color, name:", name);
                                    answer.addError(str);
                                    pb = 0;
                                }
                            }
                        }    
                    }

                    style = Style(at, ab, it, ib, pt, pb);
                }

                // text
                if (auto value = "text" in obj.object)
                {
                    if (value.type == JSONType.string)
                    {
                        text = value.str;
                    }
                    else
                    {
                        text = name;
                    }
                }
                else
                {
                    text = name;
                }

                // isEnable
                enable = true;                
                if (auto value = "isEnable" in obj.object)
                {
                    if (value.type == JSONType.true_ || value.type == JSONType.false_)
                    {
                        enable = value.boolean;
                    }
                }

                // isActive
                active = true;                
                if (auto value = "isActive" in obj.object)
                {
                    if (value.type == JSONType.true_ || value.type == JSONType.false_)
                    {
                        active = value.boolean;
                    }
                }

            }

            ITUI tui = makeTUI(type, position, size, style, text, enable, active);
            answer.addElement(name, tui);
        }

        return answer;
    }

    protected static ITUI makeTUI(TUIType type, Point position, Point size, Style style, string text, bool enable, bool active)
    {
        ITUI answer;
        Style boxStyle = Style(0, 15, 0, 7, 0, 7);
        Style btnStyle = Style(15, 0, 8, 7, 15, 3);
        Style checkStyle = Style(15, 0, 8, 7, 15, 2);
        Style imgStyle = Style(0, 15, 0, 7, 0, 7);
        Style inputStyle = Style(15, 0, 8, 7, 15, 3);
        Style lblStyle = Style (0, 15, 8, 15, 8, 15);
        Style switcherStyle = Style(15, 0, 8, 7, 15, 2);

        switch (type)
        {
            case TUIType.box:
                if (style == Style.init)
                {
                    style = boxStyle;
                }
                answer = new TUIBox(size, position, style, text);
            break;
            case TUIType.button:
                if (style == Style.init)
                {
                    style = btnStyle;
                }
                answer = new TUIButton(position, style, text);
            break;
            case TUIType.check:
                if (style == Style.init)
                {
                    style = checkStyle;
                }
                answer = new TUICheck(position, style, enable);
            break;
            case TUIType.image:
                if (style == Style.init)
                {
                    style = imgStyle;
                }
                answer = TUIImage.loadFromFile(text);
                answer.setPosition(position);
                answer.setStyle(style);
            break;
            case TUIType.input:
                if (style == Style.init)
                {
                    style = inputStyle;
                }
                answer = new TUIInput(size.x, position, style, text);
            break;
            case TUIType.label:
                if (style == Style.init)
                {
                    style = lblStyle;
                }
                answer = new TUILabel(position, style, text);
            break;
            case TUIType.switcher:
                if (style == Style.init)
                {
                    style = switcherStyle;
                }
                answer = new TUISwitcher(position, style, enable);
            break;
            default:
                if (style == Style.init)
                {
                    style = lblStyle;
                }
                answer = new TUILabel(position, style, "unknown type");
            break;
        }

        answer.setActive(active);
        return answer;
    }
}