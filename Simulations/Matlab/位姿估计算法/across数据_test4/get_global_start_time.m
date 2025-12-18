
function globalStart = get_global_start_time(rawTable)
    % 遍历表中的所有 Timetable，找到最早的时间戳
    globalStart = duration(Inf, 0, 0);
    
    for i = 1:height(rawTable)
        tt = rawTable.TopicMessages{i};
        if ~isempty(tt)
            % 【修改点】使用 .timestamp 而不是 .Time
            if tt.timestamp(1) < globalStart
                globalStart = tt.timestamp(1);
            end
        end
    end
    
    if globalStart == duration(Inf, 0, 0)
        globalStart = seconds(0); 
    end
end

function dataStruct = assemble_structure_and_bus(busName, mapConfig, sourceDataDict)
    % 组装结构体并创建 Bus
    dataStruct = struct();
    sourceKeys = fieldnames(mapConfig);
    
    for i = 1:length(sourceKeys)
        srcKey = sourceKeys{i};
        destPath = mapConfig.(srcKey);
        
        if isfield(sourceDataDict, srcKey)
            tsObj = sourceDataDict.(srcKey);
        else
            tsObj = timeseries(0, 0);
        end
        
        pathParts = strsplit(destPath, '.');
        dataStruct = setfield_nested(dataStruct, pathParts, tsObj);
    end
    
    busInfo = Simulink.Bus.createObject(dataStruct);
    assignin('base', busName, evalin('base', busInfo.busName));
    evalin('base', ['clear ', busInfo.busName]);
end