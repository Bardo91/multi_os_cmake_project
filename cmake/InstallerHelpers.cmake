
set(dpWalkerDir "${CMAKE_BINARY_DIR}/dependencyWalker")
macro(DownloadDependencyWalker)
    if(NOT EXISTS ${dpWalkerDir})
        set(dependencyWalkerRelease "https://github.com/lucasg/Dependencies/releases/download/v1.10/Dependencies_x64_Release.zip")
        
        file(DOWNLOAD ${dependencyWalkerRelease} ${CMAKE_BINARY_DIR}/dependencyWalker.zip)
        file(ARCHIVE_EXTRACT INPUT ${CMAKE_BINARY_DIR}/dependencyWalker.zip DESTINATION ${dpWalkerDir})
    endif()
endmacro(DownloadDependencyWalker)


macro(GetDependenciesExeWin _executable _depList)
    execute_process(COMMAND ${dpWalkerDir}/Dependencies.exe -modules ${_executable}
                    COMMAND grep -E MSV|CONCRT|VCRUNTIME|Environment
                    OUTPUT_VARIABLE externalDeps )
    

    string(REPLACE "\n" ";" listRawDeps ${externalDeps})    
    foreach(rawDep ${listRawDeps})
        string(REPLACE " : " ";" elements ${rawDep})  
        list(GET elements 1 depPath)
        list(APPEND ${_depList} ${depPath})
    endforeach(rawDep)
    # .\dp\Dependencies.exe -modules .\app5.exe | grep Environment
endmacro(GetDependenciesExeWin)



macro(GetDependenciesExeLinux _executable _depList)
    execute_process(COMMAND ldd ${_executable}
                    OUTPUT_VARIABLE externalDeps )
                    
    string(REPLACE "\n" ";" listRawDeps ${externalDeps})    
    foreach(rawDep ${listRawDeps})
        string(REPLACE " => " ";" elements ${rawDep})  
        list(LENGTH elements nElems)
        if(${nElems} EQUAL 2)
            list(GET elements 1 depPathPlusAddress)
            string(REPLACE " (" ";" elements2 ${depPathPlusAddress})  
            list(GET elements2 0 depPathSym)

            # Resolve symbolink links
            execute_process(COMMAND readlink -f ${depPathSym} OUTPUT_VARIABLE depPath)
            string(REPLACE "\n" "" depPath ${depPath})  
            message(STATUS "SYM : ${depPathSym} . REAL: ${depPath}")
            list(APPEND ${_depList} ${depPath})
        endif()
    endforeach(rawDep)
endmacro(GetDependenciesExeLinux)

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
