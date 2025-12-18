function tt = get_topic_timetable(rawTable, topicName, instanceID)
    % 从表中筛选特定 Topic 和 Instance 的 Timetable
    rowIdx = strcmp(rawTable.TopicNames, topicName) & rawTable.InstanceID == instanceID;
    if any(rowIdx)
        % 获取 TopicMessages 列中的数据
        tt = rawTable.TopicMessages{rowIdx};
    else
        tt = [];
    end
end