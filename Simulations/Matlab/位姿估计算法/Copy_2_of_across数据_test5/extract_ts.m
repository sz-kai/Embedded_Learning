function ts = extract_ts(rawTable, topicName, instanceID, fieldName, startTime, colIndex)
    if nargin < 6, colIndex = 0; end
    
    tt = get_topic_timetable(rawTable, topicName, instanceID);
    
    if isempty(tt)
        warning('未找到话题: %s (Instance %d)', topicName, instanceID);
        ts = timeseries(0, 0);
        return;
    end
    
    if ismember(fieldName, tt.Properties.VariableNames)
        val = tt.(fieldName);
        
        % 处理数组列
        if colIndex > 0 && size(val, 2) >= colIndex
            val = val(:, colIndex);
        end
        
        % 【修改点】使用 .timestamp 而不是 .Time
        t_sec = seconds(tt.timestamp - startTime);
        
        ts = timeseries(val, t_sec);
        ts.Name = fieldName;
    else
        warning('话题 %s 中不存在字段 %s', topicName, fieldName);
        ts = timeseries(0, 0);
    end
end
