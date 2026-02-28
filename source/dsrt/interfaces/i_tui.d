module dsrt.interfaces.i_tui;

import dsrt.pkg;

alias TUIEventHandler = void delegate(EnvironmentEvent e);

enum TUIType {
    ghost = 0,
    box = 1,
    // оставим номер про запас
    label = 10,
    input = 15,
    // оставим номер про запас
    button = 20,
    check = 21,
    switcher = 22,
    image = 30
}

interface ITUI
{ 
    @property public void onEnterPressedAction(TUIEventHandler handler);
    @property public void onEnterReleasedAction(TUIEventHandler handler);
    @property public void onBackPressedAction(TUIEventHandler handler);
    @property public void onBackReleasedAction(TUIEventHandler handler);
    @property public void onAnyServiesKeyPressedAction(TUIEventHandler handler);
    @property public void onAnyServiesKeyReleasedAction(TUIEventHandler handler);
    @property public void onTypingAction(TUIEventHandler handler);

    
    @property public TUIType getType();
    @property public Point getSize();
    @property public Point getPosition();
    @property public dchar[][] getData();
    @property public string getText();
    @property public ushort getTextColor();
    @property public ushort getBgColor();
    @property public Style getStyle();
    @property public bool isPressed();
    @property public bool canPressed();
    @property public bool isActive();
    @property public bool isEnable();
    
    @property public void setPosition(Point position);
    @property public void setText(string text);
    @property public void setStyle(Style style);
    @property public void setActive(bool status);    
    @property public void setEnable(bool status);
    @property public void setPressed(bool status);    

    public void onPressed(EnvironmentEvent e);
    public void onReleased(EnvironmentEvent e);
    public bool intersect(Point target);
    public void generateData();
}