module dsrt.interfaces.i_pollster;

import dsrt.pkg;

alias ClickHandler = void delegate(EnvironmentEvent e);

interface IPollster
{
    @property public void onClickAction(ClickHandler handler);
    public void update();
}
