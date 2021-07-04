


macro(getQtPluginList _qtLibName _pluginList)
    foreach(plugin ${Qt5${_qtLibName}_PLUGINS})
        list(APPEND ${_pluginList} ${plugin})
    endforeach()
endmacro(getQtPluginList _qtLibName _pluginList)


macro(getLocationTargets _targetList _targetsLocation)
    foreach(target ${${_targetList}})
        get_target_property(loc ${target} LOCATION)
        list(APPEND ${_targetsLocation} ${loc})
    endforeach()
endmacro(getLocationTargets _targetList _targetsLocation)

macro(copyPluginsToBinTarget _targetLocation _pluginsList _copiedPluginList)
    set(pluginsLocation "")
    getLocationTargets(${_pluginsList} pluginsLocation)
    
    foreach(plugin ${pluginsLocation})
        get_filename_component(file ${plugin} NAME)
        get_filename_component(loc ${plugin} DIRECTORY)
        get_filename_component(pluginDir ${loc} NAME)

        file(COPY ${plugin} DESTINATION ${_targetLocation}/${pluginDir})
        
        list(APPEND ${_copiedPluginList} ${_targetLocation}/${pluginDir}/${file})
    endforeach()
endmacro(copyPluginsToBinTarget _target _pluginsList )
