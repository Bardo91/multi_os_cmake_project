
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
                    
    string(REPLACE "\n" ";" listRawDeps ${externalDeps})    
    foreach(rawDep ${listRawDeps})
        string(REPLACE " : " ";" elements ${rawDep})  
        list(GET elements 1 depPath)
        list(APPEND ${_depList} ${depPath})
    endforeach(rawDep)
    # .\dp\Dependencies.exe -modules .\app5.exe | grep Environment
endmacro(GetDependenciesExeWin)



macro(GetDependenciesExeLinux)
    # Parse arguments
    set(options "")
    set(oneValueArgs EXECUTABLE DEPLIST SYMLIST TARGET_DIR)
    set(multiValueArgs "")
    cmake_parse_arguments(DEP "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )    
    

    execute_process(COMMAND ldd ${DEP_EXECUTABLE}
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

            # Get filename
            get_filename_component(depName ${depPath} NAME)
            get_filename_component(depSymName ${depPathSym} NAME)
            
            # Copy dependency
            file(COPY ${depPath} DESTINATION ${DEP_TARGET_DIR})
            # Create symbolic link with expected name
            execute_process(COMMAND ln -s "${DEP_TARGET_DIR}/${depName}" "${DEP_TARGET_DIR}/${depSymName}" ERROR_QUIET)

            if(DEP_SYMLIST)
                list(APPEND ${DEP_SYMLIST} ${depPathSym})
            endif()
            if(DEP_DEPLIST)
                list(APPEND ${DEP_DEPLIST} ${depPath})
            endif()
        endif()
    endforeach(rawDep)
endmacro(GetDependenciesExeLinux)
