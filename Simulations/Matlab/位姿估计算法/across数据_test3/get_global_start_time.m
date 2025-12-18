function globalStart = get_global_start_time(rawTable)
    % 遍历表中的所有 Timetable，找到最早的时间戳
    globalStart = duration(Inf, 0, 0);
    
    for i = 1:height(rawTable)
        tt = rawTable.TopicMessages{i};
        if ~isempty(tt)
            % Timetable 的第一行时间
            if tt.Time(1) < globalStart
                globalStart = tt.Time(1);
            end
        end
    end
    
    if globalStart == duration(Inf, 0, 0)
        globalStart = seconds(0); % 防御性默认
    end
end