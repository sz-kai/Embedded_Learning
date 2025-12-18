function s = setfield_nested(s, fields, value)
    if isempty(fields)
        s = value;
    else
        field = fields{1};
        if length(fields) == 1
            s.(field) = value;
        else
            if ~isfield(s, field)
                s.(field) = struct();
            end
            s.(field) = setfield_nested(s.(field), fields(2:end), value);
        end
    end
end