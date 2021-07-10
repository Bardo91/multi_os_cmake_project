

macro(AppImage_downloadAndGetPath _exePath)
    set(${_exePath} "${CMAKE_CURRENT_BINARY_DIR}/appimagetool-${CMAKE_SYSTEM_PROCESSOR}.AppImage")
    if(NOT EXISTS ${${_exePath}})
        execute_process(COMMAND wget "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-${CMAKE_SYSTEM_PROCESSOR}.AppImage" -O "${${_exePath}}")
        execute_process(COMMAND chmod +x "${${_exePath}}")
    endif()
endmacro(AppImage_downloadAndGetPath)

macro(AppImage_createPackage)
    # Parse arguments
    set(options IS_x32)
    set(oneValueArgs APP_NAME APP_VERSION COMPANY_NAME APP_DESCRIPTION APP_ICON_PATH )
    set(multiValueArgs "")
    cmake_parse_arguments(AI "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )    

    # Copy Icon
    file(COPY ${AI_APP_ICON_PATH} DESTINATION "${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}")
    get_filename_component(iconFileName ${AI_APP_ICON_PATH} NAME_WE)

    # Copy exe
    file(COPY "${CMAKE_CURRENT_BINARY_DIR}/${AI_APP_NAME}" DESTINATION "${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}")
    file(WRITE  "${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}/AppRun"
                "#!/bin/sh\n"
                "\n"
                "cd \"$(dirname \"$0\")\"\n"
                "exec ./${AI_APP_NAME}\n"
    )
    execute_process(COMMAND chmod a+x "${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}/AppRun")

    # file(COPY "${CMAKE_CURRENT_BINARY_DIR}/${AI_APP_NAME}" DESTINATION "${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}/bin")
    # file(RENAME "${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}/bin/${AI_APP_NAME}" "${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}/bin/AppRun")
    # execute_process(COMMAND chmod a+x "${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}/bin/AppRun")

    #Configure Desktop file
    file(WRITE  "${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}/${AI_APP_NAME}.desktop"
                "[Desktop Entry]\n"
                "Name=${AI_APP_NAME}\n"
                "Exec=AppRun\n"
                "Icon=${iconFileName}\n"
                "Type=Application\n"
                "Categories=Utility\n"
                "Terminal=true\n"
                "X-AppImage-Version=0.1.09\n"
    )

    # Run app image
    set(appImageToolPath "")
    AppImage_downloadAndGetPath(appImageToolPath)
    execute_process(COMMAND "${appImageToolPath}" "${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}")
    
endmacro(AppImage_createPackage)

