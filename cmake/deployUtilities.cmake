

macro(deployApplication)
    # Parse arguments
    set(options IS_x32)
    set(oneValueArgs APP_NAME APP_VERSION COMPANY_NAME APP_DESCRIPTION APP_ICON_PATH LICENSE_PATH)
    set(multiValueArgs "")
    cmake_parse_arguments(DEPLOY "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )    

    ## Gathering macros
    include(${CMAKE_SOURCE_DIR}/cmake/qtHelpers.cmake)
    include(${CMAKE_SOURCE_DIR}/cmake/installerHelpers.cmake)
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
        set_target_properties(  ${DEPLOY_APP_NAME}  PROPERTIES
            MACOSX_BUNDLE TRUE
            MACOSX_BUNDLE_NAME "${DEPLOY_APP_NAME}"
            MACOSX_BUNDLE_ICON_FILE "icon_${DEPLOY_APP_NAME}"
            MACOSX_BUNDLE_LONG_VERSION_STRING ${DEPLOY_APP_VERSION}
        )

        set_source_files_properties(${resourceFiles} PROPERTIES  MACOSX_PACKAGE_LOCATION Resources)

        set(finalListPluginDirs "") # By now unused in windows, but essential for bundles in MACos
        copyPluginsToBinTarget( "${CMAKE_CURRENT_BINARY_DIR}/${DEPLOY_APP_NAME}.app/Contents/PlugIns" # This last folder varies depend on the OS
                                qtPluginslist 
                                finalListPluginDirs)
        file(WRITE  "${CMAKE_CURRENT_BINARY_DIR}/${DEPLOY_APP_NAME}_packageFix.cmake"  
                    "
                    include(InstallRequiredSystemLibraries)
                    include(BundleUtilities)
                    fixup_bundle(\"${CMAKE_CURRENT_BINARY_DIR}/${DEPLOY_APP_NAME}.app\" \"${finalListPluginDirs}\" \"\")
                    ")

        add_custom_target(  ${DEPLOY_APP_NAME}_deploy
                    DEPENDS ${DEPLOY_APP_NAME} 
                    COMMAND ${CMAKE_COMMAND} 
                                    -P "${CMAKE_CURRENT_BINARY_DIR}/${DEPLOY_APP_NAME}_packageFix.cmake" )

    elseif(WIN32)
        set_target_properties(  ${DEPLOY_APP_NAME}  PROPERTIES
                                WIN32_EXECUTABLE TRUE
                                LINK_FLAGS "/ENTRY:mainCRTStartup")
        file(COPY ${resourceFiles} DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}/Resources)

        set(finalListPluginDirs \"\") # By now unused in windows, but essential for bundles in MACos
        copyPluginsToBinTarget( ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}/bin # This folder varies depend on the OS
                                qtPluginslist 
                                finalListPluginDirs)     
                                
        file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/${DEPLOY_APP_NAME}_packageCreation.cmake"
            "
                include(${PROJECT_SOURCE_DIR}/cmake/installerHelpers.cmake)
                include(${PROJECT_SOURCE_DIR}/cmake/NSISUtilities.cmake)   

                DownloadDependencyWalker() # 666 This should run post make of app
                set(winDepList \"\")
                GetDependenciesExeWin(${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}/${DEPLOY_APP_NAME}.exe winDepList)
                file(COPY \$\{winDepList\} DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}/bin)
                file(COPY ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}/${DEPLOY_APP_NAME}.exe DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}/bin)

                NSIS_createPackage(
                    APP_NAME \"${DEPLOY_APP_NAME}\" 
                    APP_VERSION \"${DEPLOY_APP_VERSION}\"
                    COMPANY_NAME \"${DEPLOY_COMPANY_NAME}\" 
                    APP_DESCRIPTION \"${DEPLOY_APP_DESCRIPTION}\" 
                    APP_ICON_PATH \"${CMAKE_CURRENT_SOURCE_DIR}/resources/icon_${DEPLOY_APP_NAME}.ico\"
                    LICENSE_PATH \"${CMAKE_CURRENT_SOURCE_DIR}/license\"
                    CONFIG_FILE \"${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}/${DEPLOY_APP_NAME}_installer.nsi\"
                )
            "
        )

        add_custom_target(  ${DEPLOY_APP_NAME}_deploy
                            DEPENDS ${DEPLOY_APP_NAME} 
                            COMMAND ${CMAKE_COMMAND} 
                                    -DappName=${DEPLOY_APP_NAME}
                                    -P "${CMAKE_CURRENT_BINARY_DIR}/${DEPLOY_APP_NAME}_packageCreation.cmake" )

    elseif(UNIX)
        file(COPY ${resourceFiles} DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}/Resources)

        file(WRITE  "${CMAKE_CURRENT_BINARY_DIR}/${DEPLOY_APP_NAME}_packageCreation.cmake"  
                    "
                    set(CMAKE_CURRENT_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR})
                    set(CMAKE_BUILD_TYPE ${CMAKE_BUILD_TYPE})

                    include(${PROJECT_SOURCE_DIR}/cmake/installerHelpers.cmake)
                    include(${PROJECT_SOURCE_DIR}/cmake/AppImageUtilities.cmake)   

                    GetDependenciesExeLinux(EXECUTABLE ${CMAKE_CURRENT_BINARY_DIR}/${DEPLOY_APP_NAME} 
                                            APPDIR ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}
                                            HAS_QT)

                    AppImage_createPackage(
                        APP_NAME \"${DEPLOY_APP_NAME}\" 
                        APP_VERSION \"${DEPLOY_APP_VERSION}\"
                        COMPANY_NAME \"${DEPLOY_COMPANY_NAME}\" 
                        APP_DESCRIPTION \"${APP_DESCRIPTION}\" 
                        APP_ICON_PATH \"${CMAKE_CURRENT_SOURCE_DIR}/resources/icon_${DEPLOY_APP_NAME}.png\")
                    ")

        add_custom_target(  ${DEPLOY_APP_NAME}_deploy
                            DEPENDS ${DEPLOY_APP_NAME} 
                            COMMAND ${CMAKE_COMMAND} 
                            -P "${CMAKE_CURRENT_BINARY_DIR}/${DEPLOY_APP_NAME}_packageCreation.cmake" )


    else()
        message(FATAL_ERROR "Unrecognized OS")
    endif()
endmacro(deployApplication)
