module dsrt.interfaces.i_canvas;

import dsrt.pkg;

interface ICanvas
{
    @property int getWidth();
    @property int getHeight();
    public void draw(ITUI content); // отрисовывает в энвайромент //(UI element)
    public void clear();
}