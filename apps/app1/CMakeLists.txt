cmake_minimum_required(VERSION 3.12 FATAL_ERROR)

file(GLOB_RECURSE resourceFiles "${CMAKE_CURRENT_SOURCE_DIR}/resources/*")

set(appName app1)
add_executable(${appName} src/main.cpp ${resourceFiles})

## Setting up OS especific bundles, exe, etc... properties
if(APPLE)
    set_target_properties(  ${appName}  PROPERTIES
                            MACOSX_BUNDLE TRUE
                            MACOSX_BUNDLE_NAME "The Rapp"
                            MACOSX_BUNDLE_ICON_FILE "icon_${appName}"
                            MACOSX_BUNDLE_LONG_VERSION_STRING ${PROJECT_VERSION}
                            )

    # set_target_properties(  ${appName} PROPERTIES
    #                         RESOURCE ${resourceFiles})

    set_source_files_properties(${resourceFiles} PROPERTIES 
                                MACOSX_PACKAGE_LOCATION Resources)
elseif(UNIX)
    file(COPY ${resourceFiles} DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/Resources)
elseif(WIN32)
    # set_target_properties(  ${appName}  PROPERTIES
    #                         WIN32_EXECUTABLE TRUE
    #                         LINK_FLAGS "/ENTRY:mainCRTStartup")
    file(COPY ${resourceFiles} DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/Resources)
else()
    message(FATAL_ERROR "Unrecognized OS")
endif()



