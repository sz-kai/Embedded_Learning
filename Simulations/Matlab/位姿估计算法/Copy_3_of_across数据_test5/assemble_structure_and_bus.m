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
            % 如果缺失，补一个默认的 timeseries(0,0)
            tsObj = timeseries(0, 0);
        end
        
        pathParts = strsplit(destPath, '.');
        dataStruct = setfield_nested(dataStruct, pathParts, tsObj);
    end
    
    busInfo = Simulink.Bus.createObject(dataStruct);
    assignin('base', busName, evalin('base', busInfo.busName));
    evalin('base', ['clear ', busInfo.busName]);
end