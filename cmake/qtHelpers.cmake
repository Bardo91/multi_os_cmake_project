


macro(getQtPluginList _qtLibName _pluginList)
    # This variables exists from 5.12 and above!
    if(Qt5${_qtLibName}_VERSION_STRING VERSION_LESS "5.12.0")
        message(FATAL_ERROR "Plugin variables does only existe from version 5.12 and above. This script does not work yet in previous versions")
    endif()
    
    foreach(plugin ${Qt5${_qtLibName}_PLUGINS})
        list(APPEND ${_pluginList} ${plugin})
    endforeach()
endmacro(getQtPluginList _qtLibName _pluginList)

