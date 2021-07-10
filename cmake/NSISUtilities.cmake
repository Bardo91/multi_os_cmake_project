

macro(NSIS_findMakeNsis _path)
    set(${_path} "C:\\Program Files (x86)\\NSIS\\Bin\\makensis.exe")
endmacro(NSIS_findMakeNsis)



macro(NSIS_createPackage)
    set(options IS_x32)
    set(oneValueArgs APP_NAME APP_VERSION COMPANY_NAME APP_DESCRIPTION APP_ICON_PATH LICENSE_PATH CONFIG_FILE)
    set(multiValueArgs "")
    cmake_parse_arguments(NSIS "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )    

    file(WRITE ${NSIS_CONFIG_FILE}
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
            File /r \"bin\"
            File /r \"Resources\"
            # Add any other files for the install directory (license files, app data, etc) here

            # Uninstaller - See function un.onInit and section \"uninstall\" for configuration
            writeUninstaller \"$INSTDIR\\uninstall.exe\"

            createShortCut \"$DESKTOP\\${NSIS_APP_NAME}.lnk\" \"$INSTDIR\\bin\\${NSIS_APP_NAME}.exe\" \"\" \"$INSTDIR\\Resources\\icon_${NSIS_APP_NAME}.ico\"

            # Registry information for add/remove programs
            WriteRegStr HKLM \"Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\${NSIS_COMPANY_NAME} ${NSIS_APP_NAME}\" \"DisplayName\" \"${NSIS_COMPANY_NAME} - ${NSIS_APP_NAME} - ${NSIS_APP_DESCRIPTION}\"
            WriteRegStr HKLM \"Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\${NSIS_COMPANY_NAME} ${NSIS_APP_NAME}\" \"UninstallString\" \"$\\\"$INSTDIR\\uninstall.exe$\\\"\"
            WriteRegStr HKLM \"Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\${NSIS_COMPANY_NAME} ${NSIS_APP_NAME}\" \"QuietUninstallString\" \"$\\\"$INSTDIR\\uninstall.exe$\\\" /S\"
            WriteRegStr HKLM \"Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\${NSIS_COMPANY_NAME} ${NSIS_APP_NAME}\" \"InstallLocation\" \"$\\\"$INSTDIR$\\\"\"
            WriteRegStr HKLM \"Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\${NSIS_COMPANY_NAME} ${NSIS_APP_NAME}\" \"DisplayIcon\" \"$\\\"$INSTDIR\\Resources\\icon_${NSIS_APP_NAME}.ico$\\\"\"
            WriteRegStr HKLM \"Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\${NSIS_COMPANY_NAME} ${NSIS_APP_NAME}\" \"Publisher\" \"$\\\"${NSIS_COMPANY_NAME}$\\\"\"
            # WriteRegStr HKLM \"Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\${NSIS_COMPANY_NAME} ${NSIS_APP_NAME}\" \"HelpLink\" \"$\\\"${HELPURL}$\\\"\"
            # WriteRegStr HKLM \"Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\${NSIS_COMPANY_NAME} ${NSIS_APP_NAME}\" \"URLUpdateInfo\" \"$\\\"${UPDATEURL}$\\\"\"
            # WriteRegStr HKLM \"Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\${NSIS_COMPANY_NAME} ${NSIS_APP_NAME}\" \"URLInfoAbout\" \"$\\\"${ABOUTURL}$\\\"\"
            # WriteRegStr HKLM \"Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\${NSIS_COMPANY_NAME} ${NSIS_APP_NAME}\" \"DisplayVersion\" \"$\\\"${VERSIONMAJOR}.${VERSIONMINOR}.${VERSIONBUILD}$\\\"\"
            # WriteRegDWORD HKLM \"Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\${NSIS_COMPANY_NAME} ${NSIS_APP_NAME}\" \"VersionMajor\" ${VERSIONMAJOR}
            # WriteRegDWORD HKLM \"Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\${NSIS_COMPANY_NAME} ${NSIS_APP_NAME}\" \"VersionMinor\" ${VERSIONMINOR}
            WriteRegDWORD HKLM \"Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\${NSIS_COMPANY_NAME} ${NSIS_APP_NAME}\" \"NoModify\" 1
            WriteRegDWORD HKLM \"Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\${NSIS_COMPANY_NAME} ${NSIS_APP_NAME}\" \"NoRepair\" 1

        sectionEnd

        Section \"Uninstall\"
            # Remove Start Menu launcher
            Delete \"$INSTDIR\\bin\\*.*\"
            RMDir /r \"$INSTDIR\\bin\"
            Delete \"$INSTDIR\\Resources\\*.*\"
            RMDir /r \"$INSTDIR\\Resources\"
            Delete \"$DESKTOP\\${NSIS_APP_NAME}.lnk\"
            Delete \"$INSTDIR\\Uninstall.exe\"
            
            RMDir \"$INSTDIR\"
            
            DeleteRegKey HKLM \"Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\${NSIS_COMPANY_NAME} ${NSIS_APP_NAME}\"
        SectionEnd
        ")


    set(makeNsisPath "")
    NSIS_findMakeNsis(makeNsisPath)

    execute_process(COMMAND ${makeNsisPath} "${NSIS_CONFIG_FILE}")
endmacro(NSIS_createPackage)

