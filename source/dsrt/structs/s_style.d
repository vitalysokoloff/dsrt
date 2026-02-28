module dsrt.structs.s_style;

enum Color : ushort
{
    black,
    darkBlue,
    darkGreen,
    darkCyan,
    darkRed,
    darkMagenta,
    darkYellow,
    Gray,
    darkGray,
    blue,
    green,
    cyan,
    red,
    magenta,
    yellow,
    white
}

struct Style
{
    ushort  activeTextColor, 
            activeBgColor,
            inactiveTextColor, 
            inactiveBgColor,
            pressedTextColor, 
            pressedBgColor;
}