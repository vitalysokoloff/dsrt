module dsrt.classes.c_tui_manager;

import std.stdio;
import std.conv;

import dsrt.pkg;

class TUIManager : ITUIManager
{
    protected
    {
        ICanvas _canvas;
        IPollster _pollster;
        ITUIScreen[string] _screens; // массив экранов
        ITUIScreen[] _orderedScreens; // массив для хранения экранов по порядку
        string[ITUIScreen] _screenKeys;
        ITUIScreen _ghostScreen;
        ITUIScreen _activeScreen;
    }

    this(ICanvas canvas, IPollster pollster)
    {
        _canvas = canvas;
        _pollster = pollster;
        _pollster.onClickAction = &this.onScreenClick;

        _ghostScreen = new TUIScreen();
        
        ITUI lbl = new TUILabel(Point(0, 0));
        lbl.setText("404!!! There is no this screen");
        ITUI btn = new TUIButton(Point(0,1));
        btn.setText("back");
        
        btn.onEnterReleasedAction = (e)
        {
            setActive(getScreenName(getScreenByNumber(0)));
        };        
        
        _ghostScreen.addElement("element1", lbl);
        _ghostScreen.addElement("element2", btn);
        
        _activeScreen = _ghostScreen;
    }

    public void update()
    {
        _pollster.update();
    }

    public void draw()
    {
        for (int i; i < _activeScreen.getElementCount(); i++) 
        { 
            _canvas.draw(_activeScreen.getElementByNumber(i));
        }
    }

    public ITUIScreen opIndex(string name)
    {
        return getScreen(name);
    }

    public void addScreen(string name, ITUIScreen screen)
    {
        _orderedScreens ~= screen;
        _screens[name] = screen;
        _screenKeys[screen] = name;
    }

    public void setActive(string name)
    {
        if (name in _screens)
        {
            _activeScreen = _screens[name];
        }
        else
        {
            _activeScreen = _ghostScreen;
        }
    }    

    public ITUIScreen getScreen(string name)
    {
        if (name in _screens)
        {
            return _screens[name];
        }
        else
        {            
            return _ghostScreen;
        }
    }

    public ITUIScreen getScreenByNumber(int n)
    {
        if (n > -1 && n < _orderedScreens.length)
        {
            return _orderedScreens[n];
        }
        else
        {            
            return _ghostScreen;
        }
    }

    public int getScreenCount()
    {
        return _orderedScreens.length.to!int;
    }

    public string getScreenName(ITUIScreen screen)
    {
        if (screen in _screenKeys)
        {
            return _screenKeys[screen];
        }
        else
        {
            return "there is no it";
        }
    }

    protected void onScreenClick(EnvironmentEvent e)
    {
        for (int i; i < _activeScreen.getElementCount(); i++) 
        { 
            ITUI element = _activeScreen.getElementByNumber(i);
            if (element.isActive && element.canPressed)
            {
                if(element.intersect(Point(e.x, e.y)))
                {
                    if (e.type == EnvironmentEventType.keyboard)
                    {
                        if (e.keyType == KeyType.service) 
                        {
                            if (e.isPressed) 
                            {
                                element.onPressed(e);
                            }
                            else 
                            {
                                element.onReleased(e);
                            }
                        }
                        if (e.keyType == KeyType.unicode) 
                        {
                            if (e.isPressed) 
                            {
                                element.onPressed(e);
                            }
                        }
                    }
                    // Логика для мыши
                    else if (e.type == EnvironmentEventType.mouse)
                    {
                        if (e.isPressed) 
                        {
                            element.onPressed(e);
                        }
                        else 
                        {
                            element.onReleased(e);
                        }
                    }
                }
                draw();
            }
        }
    }
}
