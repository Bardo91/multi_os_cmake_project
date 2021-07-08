

macro(NSIS_findMakeNsis _path)
    set(${_path} "C:\\Program Files (x86)\\NSIS\\Bin\\makensis.exe")
endmacro(NSIS_findMakeNsis)



macro(NSIS_createPackage)
    set(options IS_x32)
    set(oneValueArgs APP_NAME APP_VERSION COMPANY_NAME APP_DESCRIPTION APP_ICON_PATH LICENSE_PATH)
    set(multiValueArgs "")
    cmake_parse_arguments(NSIS "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )    

    file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/installer.nsi
        "
        Name \"${NSIS_APP_NAME} Installer\"
        Outfile \"${NSIS_APP_NAME}_installer.exe\"
        InstallDir \"$PROGRAMFILES\\${NSIS_COMPANY_NAME}\\${NSIS_APP_NAME}\"
        LicenseData \"${NSIS_LICENSE_PATH}\"
        Icon \"${NSIS_APP_ICON_PATH}\"

        # Get installation folder from registry if available
        InstallDirRegKey HKCU \"${NSIS_COMPANY_NAME}\\${NSIS_APP_NAME}\" \"\"
        
        section \"install\"
            # Files for the install directory - to build the installer, these should be in the same directory as the install script (this file)
            setOutPath $INSTDIR
            # Files added here should be removed by the uninstaller (see section \"uninstall\")
            file \"${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}/${NSIS_APP_NAME}.exe\"
            file \"${NSIS_APP_ICON_PATH}\"
            # Add any other files for the install directory (license files, app data, etc) here

            # Uninstaller - See function un.onInit and section \"uninstall\" for configuration
            writeUninstaller \"$INSTDIR\\uninstall.exe\"

            # Start Menu
            createDirectory \"$SMPROGRAMS\${COMPANYNAME}\"
            createShortCut \"$SMPROGRAMS\\${COMPANYNAME}\\${APPNAME}.lnk\" \"$INSTDIR\\app.exe\" \"\" \"$INSTDIR\\logo.ico\"
        sectionEnd

        Section \"Uninstall\"
            # ADD YOUR OWN FILES HERE...
            
            Delete \"$INSTDIR\\Uninstall.exe\"
            
            RMDir \"$INSTDIR\"
            
            DeleteRegKey /ifempty HKCU \"${NSIS_COMPANY_NAME}\\${NSIS_APP_NAME}\"
        SectionEnd
        ")


    set(makeNsisPath "")
    NSIS_findMakeNsis(makeNsisPath)

    execute_process(COMMAND ${makeNsisPath} "${CMAKE_CURRENT_BINARY_DIR}/installer.nsi")
endmacro(NSIS_createPackage)

