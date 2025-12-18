function ts = extract_ts(rawTable, topicName, instanceID, fieldName, startTime, colIndex)
    % 通用提取函数
    % colIndex (可选): 如果字段是数组(如 xyz)，指定列索引
    
    if nargin < 6, colIndex = 0; end
    
    tt = get_topic_timetable(rawTable, topicName, instanceID);
    
    if isempty(tt)
        warning('未找到话题: %s (Instance %d)', topicName, instanceID);
        ts = timeseries(0, 0);
        return;
    end
    
    if ismember(fieldName, tt.Properties.VariableNames)
        val = tt.(fieldName);
        
        % 处理数组列 (例如 vehicle_angular_velocity 的 xyz 可能是 nx3 矩阵)
        if colIndex > 0 && size(val, 2) >= colIndex
            val = val(:, colIndex);
        end
        
        % 计算时间 (秒)
        t_sec = seconds(tt.Time - startTime);
        
        ts = timeseries(val, t_sec);
        ts.Name = fieldName;
    else
        warning('话题 %s 中不存在字段 %s', topicName, fieldName);
        ts = timeseries(0, 0);
    end
end