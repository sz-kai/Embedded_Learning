function dataStruct = create_bus_object(busName, signalConfig, time)
% create_bus_object - 从信号配置动态创建Simulink总线和数据结构体
%
% 输入:
%   busName      - (string) 要在base工作区中创建的Simulink.Bus对象的名称
%   signalConfig - (struct) 定义了信号来源和在结构体中路径的配置
%                示例: 
%                signalConfig.IMU_AccX = 'Acc.X';
%                signalConfig.IMU_AccY = 'Acc.Y';
%   time         - (vector) 与所有信号相关联的时间向量
%
% 输出:
%   dataStruct   - (struct) 包含timeseries对象的已创建的数据结构体

    dataStruct = struct();
    
    % 获取所有字段名（即原始变量名）
    sourceVarNames = fieldnames(signalConfig);
    
    fprintf('正在为 %s 创建数据结构和总线...\n', busName);

    % 1. 遍历配置，创建timeseries并构建结构体
    for i = 1:length(sourceVarNames)
        sourceVarName = sourceVarNames{i};
        destPath = signalConfig.(sourceVarName);
        
        % 从调用者的工作区获取原始数据
        try
            rawData = evalin('caller', sourceVarName);
        catch ME
            error('无法在工作区中找到变量 "%s". 请确保数据已加载. 错误: %s', sourceVarName, ME.message);
        end
        
        % 创建 timeseries 对象
        ts = timeseries(rawData, time, 'Name', sourceVarName);
        
        % 使用动态字段名将ts对象放入结构体中
        % strsplit将 'Acc.X' 分割成 {'Acc', 'X'}
        % setfield可以处理嵌套结构体的创建
        pathParts = strsplit(destPath, '.');
        dataStruct = setfield(dataStruct, pathParts{:}, ts);
    end
    
    % 2. 从结构体创建 Simulink.Bus 对象
    busInfo = Simulink.Bus.createObject(dataStruct);
    
    % 3. 将自动生成的总线对象重命名为期望的 busName
    % assignin/evalin 是在base工作区进行操作的标准方法
    assignin('base', busName, evalin('base', busInfo.busName));
    evalin('base', ['clear ', busInfo.busName]);
    
    fprintf('成功创建总线对象: %s\n', busName);
end