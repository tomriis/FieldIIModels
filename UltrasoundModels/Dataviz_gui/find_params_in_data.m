function [handles] = find_params_in_data(handles)
    fname = fieldname_from_params(handles.current_params);
    try 
        handles = txfield_to_db(handles,fname);
        handles.plot_flag = true;
        set(handles.text10, 'String', '');
        k = strfind(fname, 'Ro');
        caption = sprintf('R Focus: %s (mm)', fname(k+2:k+4));
        set(handles.text8,'String',caption);
        k = strfind(fname, 'Q');
        caption = sprintf('Frequency: %s KHz', fname(k+1:k+3));
        set(handles.text17, 'String',sprintf('Max Pressure: %d',handles.maxtxfield));
        set(handles.text12,'String',caption);
    catch
        % Check if angle of extent is too large, if so dont plot
        str = sprintf('Current parameters not in %s \n \n',handles.filename);
        AngleOfExtent = (handles.current_params.W+0.4) * handles.current_params.NX/handles.current_params.ROC;
        if AngleOfExtent > pi
            str=strcat(str, ' Angle of Extent: ',...
                num2str(AngleOfExtent),' > 3.14 rad');
        end
        set(handles.text10,'String',str);
        handles.plot_flag = false;
        % Check if 
    end
end