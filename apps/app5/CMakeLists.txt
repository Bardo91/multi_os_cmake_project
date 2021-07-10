cmake_minimum_required(VERSION 3.12 FATAL_ERROR)

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()

set(CMAKE_AUTOMOC ON)
find_package(Qt5 5.12 COMPONENTS Widgets Multimedia REQUIRED)


file(GLOB_RECURSE resourceFiles "${CMAKE_CURRENT_SOURCE_DIR}/resources/*")

set(appName app5)
add_executable(${appName} src/main.cpp ${resourceFiles})
set_target_properties(${appName} PROPERTIES CXX_STANDARD 17)
if(UNIX)
    target_link_libraries(${appName} LINK_PUBLIC stdc++fs)
endif()
## Adding dependencies
target_link_libraries(${appName} PUBLIC Qt5::Widgets Qt5::Multimedia)

find_package(OpenCV REQUIRED core highgui)
target_link_libraries(${appName} PUBLIC opencv_core opencv_highgui)

## Setting up OS especific bundles, exe, etc... properties
if(APPLE)
    set_target_properties(  ${appName}  PROPERTIES
                            MACOSX_BUNDLE TRUE
                            MACOSX_BUNDLE_NAME "The Rapp"
                            MACOSX_BUNDLE_ICON_FILE "icon_${appName}"
                            MACOSX_BUNDLE_LONG_VERSION_STRING ${PROJECT_VERSION}
                            )

    set_source_files_properties(${resourceFiles} PROPERTIES 
                                MACOSX_PACKAGE_LOCATION Resources)
elseif(UNIX)
    file(COPY ${resourceFiles} DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}/Resources)
elseif(WIN32)
    set_target_properties(  ${appName}  PROPERTIES
                            WIN32_EXECUTABLE TRUE
                            LINK_FLAGS "/ENTRY:mainCRTStartup")
    file(COPY ${resourceFiles} DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}/Resources)
else()
    message(FATAL_ERROR "Unrecognized OS")
endif()


## Gathering plugins
include(${CMAKE_SOURCE_DIR}/cmake/qtHelpers.cmake)
include(${CMAKE_SOURCE_DIR}/cmake/InstallerHelpers.cmake)
include(${CMAKE_SOURCE_DIR}/cmake/MSIXUtilities.cmake)
include(${CMAKE_SOURCE_DIR}/cmake/NSISUtilities.cmake)
include(${CMAKE_SOURCE_DIR}/cmake/AppImageUtilities.cmake)

# Getting targets of plugins
set(qtPluginslist "")
getQtPluginList(Widgets qtPluginslist)
getQtPluginList(Gui qtPluginslist)
getQtPluginList(Multimedia qtPluginslist)

## Gathering dependencies in a bundle. This only works for MACOSX By now. We will learn later about AppImage
if(APPLE)
    set(finalListPluginDirs "") # By now unused in windows, but essential for bundles in MACos
    copyPluginsToBinTarget( "${CMAKE_CURRENT_BINARY_DIR}/${appName}.app/Contents/PlugIns" # This last folder varies depend on the OS
                            qtPluginslist 
                            finalListPluginDirs)

    # This line should be executed after the app has been generated, lets try to options
    # Option one, tradicionally it is called in the instal step (at least is what I have always seen in tutorials)
    install(CODE    "
                    include(InstallRequiredSystemLibraries)
                    include(BundleUtilities)
                    fixup_bundle(\"${CMAKE_CURRENT_BINARY_DIR}/${appName}.app\" \"${finalListPluginDirs}\" \"\")
                    "
            COMPONENT Runtime)
elseif(WIN32)
    set(finalListPluginDirs \"\") # By now unused in windows, but essential for bundles in MACos
    copyPluginsToBinTarget( ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}/bin # This folder varies depend on the OS
                            qtPluginslist 
                            finalListPluginDirs)     
                            
    file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/${appName}_packageCreation.cmake"
        "
            include(${PROJECT_SOURCE_DIR}/cmake/InstallerHelpers.cmake)
            include(${PROJECT_SOURCE_DIR}/cmake/NSISUtilities.cmake)   

            DownloadDependencyWalker() # 666 This should run post make of app
            set(winDepList \"\")
            GetDependenciesExeWin(${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}/${appName}.exe winDepList)
            file(COPY \$\{winDepList\} DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}/bin)
            file(COPY ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}/${appName}.exe DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}/bin)

            NSIS_createPackage(
                APP_NAME \"app5\" 
                APP_VERSION \"1.0.1.0\"
                COMPANY_NAME \"CoopBardo\" 
                APP_DESCRIPTION \"Not too much to say\" 
                APP_ICON_PATH \"${CMAKE_CURRENT_SOURCE_DIR}/resources/icon_${appName}.ico\"
                LICENSE_PATH \"${CMAKE_CURRENT_SOURCE_DIR}/license\"
                CONFIG_FILE \"${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}/${appName}_installer.nsi\"
            )
        "
    )
    
    add_custom_command( TARGET ${appName} 
                        POST_BUILD 
                        COMMAND ${CMAKE_COMMAND} 
                                -DappName=${appName}
                                -P "${CMAKE_CURRENT_BINARY_DIR}/${appName}_packageCreation.cmake" )

    # MSIX_createPackage(
    #     APP_NAME "app5" 
    #     APP_VERSION "1.0.1.0"
    #     COMPANY_NAME "CoopBardo" 
    #     APP_DESCRIPTION "Not too much to say" 
    #     APP_ICON_PATH "Resources/icon_${appName}.png"
    # )


elseif(UNIX)
    set(finalListPluginDirs "") # By now unused in windows, but essential for bundles in MACos
    copyPluginsToBinTarget( ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}/usr/lib/plugins # This last folder varies depend on the OS
                            qtPluginslist 
                            finalListPluginDirs)   

    # 666 This should run post make of app
    # file(COPY ${CMAKE_CURRENT_BINARY_DIR}/${appName} DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}/)

    GetDependenciesExeLinux(${CMAKE_CURRENT_BINARY_DIR}/${appName} linuxDepList)
    file(COPY ${linuxDepList} DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}/usr/lib)
    
    AppImage_createPackage(
        APP_NAME "app5" 
        APP_VERSION "1.0.1.0"
        COMPANY_NAME "CoopBardo" 
        APP_DESCRIPTION "Not too much to say" 
        APP_ICON_PATH "${CMAKE_CURRENT_SOURCE_DIR}/resources/icon_${appName}.png")

else()
    message(FATAL_ERROR "Unrecognized OS")
endif()
        
