module dsrt.classes.c_tui_screen;

import std.stdio;
import std.format;
import std.file;
import std.array;
import std.algorithm;
import std.json;
import std.conv;

import dsrt.pkg;


class TUIScreen : ITUIScreen
{
    protected
    {
        ITUI _ghostElement; // для избежания null при обращении по несуществующему имени элемента
        string[] _errors;
        ITUI[string] _elements; // массив элементов
        ITUI[] _orderedElements; // массив для хранения элементов по порядку, для отрисовки по очереди, так как принципиально нет Z-буфера
        string[ITUI] _elementKeys;
    }

    @property public string[] getElementsErrorLog()
    {
        return _errors;
    }    

    this()
    {
        _ghostElement = new TUIGhost();
        addError("Errors:");
    }    

    public ITUI opIndex(string name)
    {
        return getElement(name);
    }

    public void addError(string msg)
    {
        if (!_errors.canFind(msg)) 
        {
            _errors ~= msg;
        }
    }

    public void addElement(string name, ITUI element)
    {
        _orderedElements ~= element;
        _elements[name] = element;
        _elementKeys[element] = name;
    }

    public ITUI getElement(string name)
    {
        if (name in _elements)
        {
            return _elements[name];
        }
        else
        {
            string str = format("wrong element name: [%s]", name);
            addError(str);
            
            return _ghostElement;
        }
    }

    public ITUI getElementByNumber(int n)
    {
        if (n > -1 && n < _orderedElements.length)
        {
            return _orderedElements[n];
        }
        else
        {
            string str = format("array out of bounds: [%n] // [%n]", n, _orderedElements.length);
            addError(str);
            
            return _ghostElement;
        }
    }

    public int getElementCount()
    {
        return _orderedElements.length.to!int;
    }

    public string getElementName(ITUI element)
    {
        if (element in _elementKeys)
        {
            return _elementKeys[element];
        }
        else
        {
            return "there is no it";
        }
    }

    public void saveElementsErrorLog()
    {
        string content = _errors.join("\n"); 
        std.file.write("logs.txt", content);
    }
}