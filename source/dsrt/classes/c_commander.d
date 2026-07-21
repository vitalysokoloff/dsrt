module dsrt.classes.c_commander;

import  dsrt.pkg;

class Commander : ICommander
{
    protected
    {
        IEnvironment _env;
    }

    this(IEnvironment env)
    {
        _env = env;
    }

    public void setCursorPosition(Point position)
    {
        _env.setCursorPosition(position);
    }

    public void putTextToBuffer(string text)
    {
        _env.putText(text);
    }
}
