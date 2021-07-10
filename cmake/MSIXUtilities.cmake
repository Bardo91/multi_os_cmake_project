

macro(MSIX_findMakeAppx _makeAppxPath)
# find_file(_loc NAMES "MakeAppx.exe" PATHS "C:\\Program Files (x86)\\Windows Kits\\10\\bin" NO_DEFAULT_PATH)
set(windowsKitDir "C:/Program Files (x86)/Windows Kits/10/bin")
file(GLOB children RELATIVE ${windowsKitDir} ${windowsKitDir}/*)

foreach(child ${children})
    if(EXISTS ${windowsKitDir}/${child}/x64/makeappx.exe)
        set(${_makeAppxPath} "${windowsKitDir}/${child}/x64/makeappx.exe")
    endif()
endforeach()
endmacro(MSIX_findMakeAppx)


macro(MSIX_findSignTool _signToolPath)
    # find_file(_loc NAMES "MakeAppx.exe" PATHS "C:\\Program Files (x86)\\Windows Kits\\10\\bin" NO_DEFAULT_PATH)
    set(windowsKitDir "C:/Program Files (x86)/Windows Kits/10/bin")
    file(GLOB children RELATIVE ${windowsKitDir} ${windowsKitDir}/*)
    
    foreach(child ${children})
        if(EXISTS ${windowsKitDir}/${child}/x64/signtool.exe)
            set(${_signToolPath} "${windowsKitDir}/${child}/x64/signtool.exe")
        endif()
    endforeach()
endmacro(MSIX_findSignTool)



macro(MSIX_createPackage)
    set(options IS_x32)
    set(oneValueArgs APP_NAME APP_VERSION COMPANY_NAME APP_DESCRIPTION APP_ICON_PATH LICENSE_PATH)
    set(multiValueArgs "")
    cmake_parse_arguments(MSIX "${options}" "${oneValueArgs}"
                        "${multiValueArgs}" ${ARGN} )    

    if(${IS_x32})
        set(MSIX_ARCHITECTURE "x32")
    else()
        set(MSIX_ARCHITECTURE "x64")
    endif()
    
    file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}/appxmanifest.xml" 
                        "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                        "    <Package\n"
                        "        xmlns=\"http://schemas.microsoft.com/appx/manifest/foundation/windows10\"\n"
                        "    xmlns:uap=\"http://schemas.microsoft.com/appx/manifest/uap/windows10\"\n"
                        "    xmlns:rescap=\"http://schemas.microsoft.com/appx/manifest/foundation/windows10/restrictedcapabilities\">\n"
                        "    <Identity  Name=\"${MSIX_APP_NAME}\"\n"
                        "               Version=\"${MSIX_APP_VERSION}\"\n"
                        "               Publisher=\"CN=${MSIX_COMPANY_NAME}, O=${MSIX_COMPANY_NAME}, C=US\"\n"
                        "               ProcessorArchitecture=\"${MSIX_ARCHITECTURE}\"/>\n"  
                        "        <Properties>\n"
                        "           <DisplayName>${MSIX_APP_NAME}</DisplayName>\n"
                        "           <PublisherDisplayName>${MSIX_COMPANY_NAME}</PublisherDisplayName>\n"
                        "           <Description>${MSIX_APP_DESCRIPTION}</Description>\n"
                        "           <Logo>${MSIX_APP_ICON_PATH}</Logo>\n"
                        "        </Properties>\n"
                        "        <Resources>\n"
                        "           <Resource Language=\"en-us\" />\n"
                        "        </Resources>\n"
                        "        <Dependencies>\n"
                        "           <TargetDeviceFamily Name=\"Windows.Desktop\" MinVersion=\"10.0.14316.0\" MaxVersionTested=\"10.0.15063.0\"  />\n"
                        "        </Dependencies>\n"
                        "        <Capabilities>\n"
                        "            <rescap:Capability Name=\"runFullTrust\"/>\n"
                        "        </Capabilities>\n"
                        "        <Applications>\n"
                        "           <Application Id=\"${MSIX_APP_NAME}\" Executable=\"${MSIX_APP_NAME}.exe\" EntryPoint=\"Windows.FullTrustApplication\">\n"
                        "                <uap:VisualElements    DisplayName=\"${MSIX_APP_NAME}\"\n"
                        "                                       Description=\"${MSIX_APP_DESCRIPTION}\"\n"
                        "                                       Square150x150Logo=\"${MSIX_APP_ICON_PATH}\"\n"
                        "                                       Square44x44Logo=\"${MSIX_APP_ICON_PATH}\"\n"	
                        "                                       BackgroundColor=\"#454545\" />\n"
                        "           </Application>\n"
                        "        </Applications>\n"
                        "    </Package>\n"
                        )


    
    set(makeappxPath "")
    MSIX_findMakeAppx(makeappxPath)

    # Create signature This must be done by no by the user...
    # file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}/CreateCertificate.bat"
    #             "powershell.exe -Command {New-SelfSignedCertificate -Type Custom -Subject \"CN=${MSIX_COMPANY_NAME}, O=${MSIX_COMPANY_NAME}, C=US\" -KeyUsage DigitalSignature -FriendlyName \"${MSIX_COMPANY_NAME}_msix_auto_installer\" -CertStoreLocation \"Cert:\\CurrentUser\\My\"}"
    #             )
    # execute_process(COMMAND powershell ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}/CreateCertificate.bat)
    

    execute_process(COMMAND ${makeappxPath} pack -d "${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}" -p "${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}/app.msix")


    set(signToolPath "")
    MSIX_findSignTool(signToolPath)

endmacro(MSIX_createPackage)
