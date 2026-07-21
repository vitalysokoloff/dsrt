module dsrt.interfaces.i_commander;

import dsrt.pkg;

interface ICommander
{
    public void setCursorPosition(Point position);
    public void putTextToBuffer(string text);
}
