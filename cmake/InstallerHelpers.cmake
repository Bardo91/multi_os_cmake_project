
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
                    COMMAND grep -E MSV\|CONCRT\|VCRUNTIME\|Environment
                    OUTPUT_VARIABLE externalDeps )

    message(STATUS ${externalDeps})
    string(REPLACE "\n" ";" listRawDeps ${externalDeps})    
    foreach(rawDep ${listRawDeps})
        string(REPLACE " : " ";" elements ${rawDep})  
        list(GET elements 1 depPath)
        list(APPEND ${_depList} ${depPath})
    endforeach(rawDep)
    # .\dp\Dependencies.exe -modules .\app5.exe | grep Environment
endmacro(GetDependenciesExeWin)