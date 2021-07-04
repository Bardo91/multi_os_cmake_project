


function(getQtPluginList _qtLibName _pluginList)
    message(STATUS "Analyzing plugins from ${_qtLibName}")
    message(STATUS "Found: ${Qt5${_qtLibName}_PLUGINS}")
    set(${_pluginList} "" PARENT_SCOPE)
    foreach(plugin ${Qt5${_qtLibName}_PLUGINS})
        list(APPEND ${_pluginList} ${plugin})
    endforeach()
    message(STATUS "final list: ${${_pluginList}}")
endfunction(getQtPluginList _qtLibName _pluginList)
