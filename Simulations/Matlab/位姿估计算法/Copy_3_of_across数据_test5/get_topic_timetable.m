%% 辅助函数 (所有 .Time 均已替换为 .timestamp)
%==========================================================================

function tt = get_topic_timetable(rawTable, topicName, instanceID)
    % 从表中筛选特定 Topic 和 Instance 的 Timetable
    rowIdx = strcmp(rawTable.TopicNames, topicName) & rawTable.InstanceID == instanceID;
    if any(rowIdx)
        tt = rawTable.TopicMessages{rowIdx};
    else
        tt = [];
    end
end

