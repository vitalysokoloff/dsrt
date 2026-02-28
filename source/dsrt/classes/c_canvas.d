module dsrt.classes.c_canvas;

import dsrt.pkg;

class Canvas : ICanvas
{
    protected
    {
        IEnvironment _environment;
    }

    /// Ширина консоли (экрана)
    @property int getWidth() { return _environment.getWindowSize().x; }
    /// Высота консоли (экрана)
    @property int getHeight() { return _environment.getWindowSize().y; }

    /// Params:
    ///   enviroment = среда отрисовки
    this(IEnvironment environment, Point windowSize) 
    {
        _environment = environment;
        _environment.setWindowSize(windowSize);
        _environment.lockSize();
        _environment.makeCyrilic();
    }

    // Проверка на пустую матрицу

    public void draw(ITUI element) 
    {
        element.generateData();
        int leftBoreder = element.getPosition().x;
        int upBorder = element.getPosition().y;
        int rightBorder = leftBoreder + element.getSize().x;
        int bottomBorder = upBorder + element.getSize().y;
        if (leftBoreder > -1 && upBorder > -1 && rightBorder < _environment.getWindowSize().x +1 && bottomBorder < _environment.getWindowSize().y + 1)
            if (element.getData().length != 0 && element.getData()[].length != 0) // Проверка на пустую матрицу
                _environment.drawMatrix(element.getPosition().x, 
                    element.getPosition().y,
                    element.getData(),
                    element.getTextColor(),
                    element.getBgColor()
                    );
    }

    public void clear()
    {

    }
}