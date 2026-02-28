module dsrt.interfaces.i_tui_manager;

import dsrt.pkg;


interface  ITUIManager
{
    public void update();
    public void draw(); // перебор и отрисовка всех элементов
    public ITUIScreen opIndex(string name); // для доступа через индекс, через ["name"]
    public void addScreen(string name, ITUIScreen screen);    
    public void setActive(string name);
    public ITUIScreen getScreen(string name);
    public ITUIScreen getScreenByNumber(int n);
    public int getScreenCount();
    public string getScreenName(ITUIScreen screen);
}