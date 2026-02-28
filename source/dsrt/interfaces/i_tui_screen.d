module dsrt.interfaces.i_tui_screen;

import dsrt.pkg;

interface ITUIScreen
{
    @property public string[] getElementsErrorLog();

    public ITUI opIndex(string name); // для доступа через индекс, через ["name"]
    public void addElement(string name, ITUI element);
    public void addError(string msg);
    public ITUI getElement(string name);
    public ITUI getElementByNumber(int n);
    public int getElementCount();
    public string getElementName(ITUI element);
    public void saveElementsErrorLog();
}