module dsrt.classes.c_txt_environment;

import std.stdio;
import std.file;
import std.conv;
import std.array;
import dsrt.pkg;

class TxtEnvironment : IEnvironment
{
    protected
    {
        Point _size;
        dchar[][] _buffer;
        string _outPath = "render.txt";
    }

    @property void setOutPath(string path) { _outPath = path; }
    @property string getOutPath() { return _outPath; }

    public void drawMatrix(int x, int y, dchar[][] matrix, ushort textColor, ushort bgColor)
    {
        int rows = cast(int)matrix.length;
        int cols = cast(int)matrix[0].length;
        
        for (int j = 0; j < rows; j++)
        {
            for (int i = 0; i < cols; i++)
            {
                _buffer[j + y][i + x] = matrix[j][i];
            }
        }

        // 1. Создаем буфер-накопитель для итоговой строки
        auto res = appender!string();

        // 2. Проходим по каждой строке массива
        foreach (row; _buffer) {
            res.put(row.to!string);
            res.put("\n");
        }

        // 3. Получаем готовую переменную
        string output = res.data;
        std.file.write(_outPath, output);
    }
    
    public void setWindowSize(Point size)
    {
        _size = size;
        _buffer = new dchar[][size.y];

        foreach (y; 0 .. _size.y) 
        {
            dchar[] row = new dchar[_size.x];
            row[] = ' ';
            _buffer[y] = row;
        }
    }
    
    public Point getWindowSize()
    {
        return _size;
    }
    
    public void lockSize(){}

    public void makeCyrilic(){}

    public EnvironmentEvent pollEvent() { return EnvironmentEvent(EnvironmentEventType.none); }

    void setCursorPosition(Point position) {}

    Point getCursorPosition() 
    {
        return Point(0, 0);
    }

    void disableQuickEdit() {}
}