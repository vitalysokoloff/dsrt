module dsrt.classes.c_windows_cmd_environment;

import core.sys.windows.windows;
import core.sys.windows.winuser;
import std.stdio;
import std.traits;

import dsrt.pkg;

pragma(lib, "user32");
pragma(lib, "kernel32");

class WindowsCmdEnviroment : IEnvironment
{
    public void drawMatrix(int x, int y, dchar[][] matrix, ushort textColor, ushort bgColor)
    {  
        HANDLE hConsole = GetStdHandle(STD_OUTPUT_HANDLE);
        
        short rows = cast(short)matrix.length;
        // Оставляем cols как размер области отрисовки
        short cols = cast(short)matrix[0].length;

        // Создаем плоский буфер структур CHAR_INFO
        CHAR_INFO[] buffer = new CHAR_INFO[rows * cols];
        
        // Формируем байт атрибутов: фон сдвигается на 4 бита влево
        ushort attributes = cast(ushort)(textColor | (bgColor << 4));

        foreach (r; 0 .. rows) 
        {
            import std.conv : to;
            
            // ВАЖНО: Декодируем UTF-8 (char[]) в UTF-16 (wstring).
            // Это превратит двухбайтовую 'к' (0xD0 0xBA) в один символ 0x043A.
            wstring wideRow;
            try 
            {
                wideRow = matrix[r].to!wstring;
            } catch (Exception e) {
                // Если в данных битый UTF-8, заменяем строку на пустую
                wideRow = ""w;
            }

            foreach (c; 0 .. cols) 
            {
                int index = r * cols + c;
                
                // Если текущий индекс колонки в пределах декодированной строки
                if (c < wideRow.length) {
                    buffer[index].UnicodeChar = wideRow[c];
                } else {
                    // Если строка короче ширины матрицы (после декодирования) — ставим пробел
                    buffer[index].UnicodeChar = ' ';
                }
                
                buffer[index].Attributes = attributes;
            }
        }

        COORD bufferSize = {cols, rows};
        COORD bufferCoord = {0, 0};
        SMALL_RECT writeRegion = {
            cast(short)x, 
            cast(short)y, 
            cast(short)(x + cols - 1), 
            cast(short)(y + rows - 1)
        };

        // Используем WriteConsoleOutputW (Wide-версия для Unicode)
        WriteConsoleOutputW(hConsole, buffer.ptr, bufferSize, bufferCoord, &writeRegion);
    }

    public void setWindowSize(Point size)
    {
        HANDLE hConsole = GetStdHandle(STD_OUTPUT_HANDLE);
        if (hConsole == INVALID_HANDLE_VALUE) return;

        // 1. Сначала «схлопываем» окно до минимального размера (1x1),
        // чтобы при изменении буфера не возникло ошибки несоответствия размеров.
        SMALL_RECT tmpRect = {0, 0, 0, 0};
        SetConsoleWindowInfo(hConsole, TRUE, &tmpRect);

        // 2. Устанавливаем размер буфера точно по нужным размерам.
        COORD coord = { cast(short)size.x, cast(short)size.y };
        SetConsoleScreenBufferSize(hConsole, coord);

        // 3. Растягиваем окно под новый размер буфера.
        SMALL_RECT rect = {
            0, 0, 
            cast(short)(size.x - 1), 
            cast(short)(size.y - 1)
        };
        SetConsoleWindowInfo(hConsole, TRUE, &rect);

        // 4. Блокируем рамки, чтобы пользователь не вернул прокрутку сам
        HWND hWnd = GetConsoleWindow();
        if (hWnd) 
        {
            LONG_PTR style = GetWindowLongPtr(hWnd, GWL_STYLE);
            style &= ~WS_THICKFRAME;
            style &= ~WS_MAXIMIZEBOX;
            SetWindowLongPtr(hWnd, GWL_STYLE, style);
            
            // Применяем стили
            SetWindowPos(hWnd, null, 0, 0, 0, 0, 
                SWP_FRAMECHANGED | SWP_NOSIZE | SWP_NOMOVE | SWP_NOZORDER);
        }
    }
    
    public Point getWindowSize()
    {
        HANDLE hConsole = GetStdHandle(STD_OUTPUT_HANDLE);
        CONSOLE_SCREEN_BUFFER_INFO csbi;
        
        if (GetConsoleScreenBufferInfo(hConsole, &csbi)) 
        {
            // Вычисляем размер на основе прямоугольника видимой области
            return Point(
                csbi.srWindow.Right - csbi.srWindow.Left + 1,
                csbi.srWindow.Bottom - csbi.srWindow.Top + 1
            );
        }
        return Point(0, 0);        
    }

    public void lockSize()
    {        
        // 1. Получаем хендл окна консоли
        HWND hWnd = GetConsoleWindow();
        if (hWnd == null) return;

        // 2. Получаем текущий стиль окна
        // На 64-битных системах важно использовать GetWindowLongPtr
        LONG_PTR currentStyle = GetWindowLongPtr(hWnd, GWL_STYLE);

        // 3. Отключаем рамку изменения размера (WS_THICKFRAME) 
        // и кнопку "Развернуть" (WS_MAXIMIZEBOX)
        currentStyle &= ~WS_THICKFRAME;
        currentStyle &= ~WS_MAXIMIZEBOX;

        // 4. Применяем новый стиль
        SetWindowLongPtr(hWnd, GWL_STYLE, currentStyle);

        // 5. Обновляем окно, чтобы изменения вступили в силу
        SetWindowPos(hWnd, null, 0, 0, 0, 0, 
            SWP_FRAMECHANGED | SWP_NOSIZE | SWP_NOMOVE | SWP_NOZORDER);
    }

    public void makeCyrilic()
    {
        SetConsoleCP(1200); 
        SetConsoleOutputCP(1200);
    }

    public EnvironmentEvent pollEvent()
    {
        // Вспомогательная функция, чтобы не городить switch
        bool isServiceKey(ushort vk) 
        {
            import std.traits : EnumMembers;
            static foreach (m; EnumMembers!Keys) {
                if (vk == m) return true;
            }
            return false;
        }

        // Служебные переменные для WinAPI
        DWORD cNumRead; // Сюда Windows запишет, сколько событий реально поймано
        INPUT_RECORD[128] irInBuf;// Буфер-накопитель (на 128 событий за раз)
        HANDLE hInput = GetStdHandle(STD_INPUT_HANDLE);// Ссылка на поток ввода консоли

        // Ждем сигнала от ОС о событии
        // Поток полностью засыпает (0% CPU) и ждет сигнала от ОС.
        // Просыпается только если в консоли что-то произошло (клик, кнопка и т.д.)
        WaitForSingleObject(hInput, 30);

        // Читаем пачку событий из системного буфера
        if (!ReadConsoleInputW(hInput, irInBuf.ptr, 128, &cNumRead))
        {
            return EnvironmentEvent(EnvironmentEventType.none);
        }

        // Перебираем всё, что прочитали (от 1 до 128 штук)
        foreach (i; 0 .. cNumRead)
        {
            if (irInBuf[i].EventType == KEY_EVENT)
            {
                Point cursor = getCursorPosition();
                auto keyEvent = irInBuf[i].Event.KeyEvent;
                ushort vk = keyEvent.wVirtualKeyCode;
                dchar uChar = keyEvent.UnicodeChar;
                uint now = GetTickCount();
                
                dsrt.pkg.KeyType type;
                dchar finalCode;

                // 1. Стрелки
                if (vk >= Keys.left && vk <= Keys.down)
                {
                    type = dsrt.pkg.KeyType.arrows;
                    finalCode = cast(dchar)vk;
                }
                // 2. Сервисные клавиши
                else if (isServiceKey(vk))
                {
                    type = dsrt.pkg.KeyType.service;
                    finalCode = cast(dchar)vk;
                }
                // 3. Всё остальное — символы юникод
                else
                {
                    // Если Windows дала символ — берём его
                    if (uChar != 0)
                    {
                        type = dsrt.pkg.KeyType.unicode;
                        finalCode = uChar;
                    }
                    else
                    {
                        // Пытаемся получить символ через ToUnicodeEx
                        wchar[16] buf = 0;
                        HKL hkl = GetKeyboardLayout(0);
                        BYTE[256] keyState;
                        GetKeyboardState(&keyState[0]);

                        int ret = ToUnicodeEx(
                            vk,
                            keyEvent.wVirtualScanCode,
                            &keyState[0],
                            buf.ptr,
                            buf.length,
                            0,
                            hkl
                        );

                        if (ret > 0)
                        {
                            type = dsrt.pkg.KeyType.unicode;
                            finalCode = buf[0];
                        }
                        else
                        {
                            type = dsrt.pkg.KeyType.service;
                            finalCode = cast(dchar)vk;
                        }
                    }
                }

                return EnvironmentEvent(
                    EnvironmentEventType.keyboard,
                    cursor.x,
                    cursor.y,
                    cast(bool)keyEvent.bKeyDown,
                    type,
                    finalCode,
                    GetTickCount()
                );
            }            

            // ОБРАБОТКА МЫШИ
            if (irInBuf[i].EventType == MOUSE_EVENT)
            {
                auto mouseEvent = irInBuf[i].Event.MouseEvent;
                
                return EnvironmentEvent(
                    EnvironmentEventType.mouse,           // Это мышь
                    mouseEvent.dwMousePosition.X,         // Координата X мыши
                    mouseEvent.dwMousePosition.Y,         // Координата Y мыши
                    (mouseEvent.dwButtonState & FROM_LEFT_1ST_BUTTON_PRESSED) != 0, // ЛКМ,
                    dsrt.pkg.KeyType.none,
                    0,                                     // Клавиша не используется
                    GetTickCount()
                );
            }
        }

        return EnvironmentEvent(EnvironmentEventType.none);
    }

    public void  setCursorPosition(Point position) 
    {
        HANDLE hOut = GetStdHandle(STD_OUTPUT_HANDLE);
        COORD coord;
        coord.X = cast(short)position.x;
        coord.Y = cast(short)position.y;
        SetConsoleCursorPosition(hOut, coord);
    }

    public Point getCursorPosition() 
    {
        HANDLE hOut = GetStdHandle(STD_OUTPUT_HANDLE);
        CONSOLE_SCREEN_BUFFER_INFO csbi;
        GetConsoleScreenBufferInfo(hOut, &csbi);
        return Point(csbi.dwCursorPosition.X, csbi.dwCursorPosition.Y);
    }

    void disableQuickEdit() 
    {
        HANDLE hInput = GetStdHandle(STD_INPUT_HANDLE);
        DWORD mode;
        
        // Получаем текущий режим
        GetConsoleMode(hInput, &mode);
        
        // Отключаем ENABLE_QUICK_EDIT_MODE и включаем обработку мыши
        // Используем побитовое И-НЕ, чтобы убрать флаг выделения
        mode &= ~ENABLE_QUICK_EDIT_MODE;
        
        // Включаем расширенный флаг, чтобы изменения вступили в силу
        mode |= ENABLE_EXTENDED_FLAGS;
        
        // Также убедимся, что включен ввод мыши
        mode |= ENABLE_MOUSE_INPUT;
        
        SetConsoleMode(hInput, mode);
    }
}
