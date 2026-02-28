module dsrt.classes.c_tui_ghost;

import std.conv;
import dsrt.pkg;

class TUIGhost : TUIOrigin
{  
    @property override public TUIType getType() { return TUIType.ghost; }
    @property override  public string getText() { return "Ghost"; }
    @property override  public Point getSize() { return Point(0, 0); }
    @property override  public Point getPosition() { return Point(0, 0); }
    @property override  public dchar[][] getData() { return null; }
    @property override  public ushort getTextColor() { return 0; }
    @property override  public ushort getBgColor() { return 0; }
    @property override  public Style getStyle() { return Style(0, 0, 0, 0, 0, 0); }
    @property override  public bool isPressed() { return false; }
    @property override  public bool canPressed() { return false; }
    @property override  public bool isActive() { return false; }
    @property override  public bool isEnable() { return false; }
    
    @property override  public void setText(string text) {}
    @property override  public void setActive(bool status) {}
    @property override  public void setEnable(bool status) {}
    @property override  public void setPressed(bool status) {}

    override public bool intersect(Point target)
    {
        return false;
    }
}
