module dsrt.structs.s_environment_event;

struct EnvironmentEvent {
    EnvironmentEventType type; // Тип события
    int x;                     // Позиция X (мышь или каретка)
    int y;                     // Позиция Y (мышь или каретка)
    bool isPressed;            // Состояние кнопки (нажата/отпущена)
    KeyType keyType;         // Если клавиша "скрвисная" не имеет юникода, а является конвертацией хекс кода то она мышь или сервис или стрелки
    dchar key;                 // Символ нажатой клавиши
    uint timestamp; 
}

enum EnvironmentEventType {
    none,      // Ничего не произошло
    mouse,     // Событие мыши
    keyboard   // Событие клавиатуры 
}

enum KeyType {
    none, // для мыши например
    service, // этим кнопкам важно состояние онПрессед и онРелиз (разовые нажатия)
    arrows, // для стрелок 
    unicode // этим важен сам факт нажатия ("залипания")
}

/// Windows Virtual-Key Codes (decimal)
enum Keys : ushort
{
    none = 0,
    // Стрелки
    left  = 37,
    up    = 38,
    right = 39,
    down  = 40,
    // Навигация
    home     = 36,
    end      = 35,
    pageUp   = 33,
    pageDown = 34,
    insert = 45,
    del    = 46,
    // Управляющие
    backspace = 8,
    tab       = 9,
    enter     = 13,
    escape    = 27,
    // Модификаторы
    shift = 16,
    ctrl  = 17,
    alt   = 18,
    leftShift  = 160,
    rightShift = 161,
    leftCtrl   = 162,
    rightCtrl  = 163,
    leftAlt    = 164,
    rightAlt   = 165,
    // Функциональные
    f1  = 112,
    f2  = 113,
    f3  = 114,
    f4  = 115,
    f5  = 116,
    f6  = 117,
    f7  = 118,
    f8  = 119,
    f9  = 120,
    f10 = 121,
    f11 = 122,
    f12 = 123,
    // NumPad
    num0 = 96,
    num1 = 97,
    num2 = 98,
    num3 = 99,
    num4 = 100,
    num5 = 101,
    num6 = 102,
    num7 = 103,
    num8 = 104,
    num9 = 105,
    numMultiply = 106,
    numPlus     = 107,
    numMinus    = 109,
    numDot      = 110,
    numDivide   = 111
}