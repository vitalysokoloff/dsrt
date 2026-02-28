module dsrt.interfaces.i_environment;

import dsrt.pkg;

interface IEnvironment
{
    // Отрисовка:
    public void drawMatrix(int x, int y, dchar[][] matrix, ushort textColor, ushort bgColor); // отрисовывает в энвайромент //(UI element)
    
    // Окно:
    public void setWindowSize(Point size);
    public Point getWindowSize();
    public void lockSize();

    // Работа с системной кареткой:
    public void setCursorPosition(Point position);
    public Point getCursorPosition();
    
    //Прочее:
    public void makeCyrilic();
    public EnvironmentEvent pollEvent();
    public void disableQuickEdit(); 
}