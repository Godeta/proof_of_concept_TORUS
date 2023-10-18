function sliderSin
f=figure('visible','off','position',...
    [360 500 400 400]);
slhan=uicontrol('style','slider','position',[100 280 200 20],...
    'min',0,'max',4*pi,'callback',@callbackfn);
hsttext=uicontrol('style','text',...
    'position',[170 340 40 15],'visible','off');
axes('units','pixels','position',[100 50 200 200]);
movegui(f,'center')
set(f,'visible','on');
    function callbackfn(source,eventdata)
        num=get(slhan,'value');
        set(hsttext,'visible','on','string',num2str(num))
        x=linspace(0,4*pi);
        y=sin(num*x);
        plot(x,y);
        ax=gca;
        ax.XLim=[0 2*pi]
    end
end
Then I will get a slider gui like