function SliderValueChanged(app, event)
    value = app.Slider.Value;
    % determine which discrete option the current value is closest to.
    [~, minIdx] = min(abs(value - event.Source.MajorTicks(:)));
    % move the slider to that option
    event.Source.Value = event.Source.MajorTicks(minIdx);
    % Override the selected value if you plan on using it within this function
    value = event.Source.MajorTicks(minIdx);
end