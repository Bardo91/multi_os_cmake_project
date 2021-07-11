cmake_minimum_required(VERSION 3.12 FATAL_ERROR)

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()

set(CMAKE_AUTOMOC ON)
find_package(Qt5 5.12 COMPONENTS Widgets Multimedia REQUIRED)


file(GLOB_RECURSE resourceFiles "${CMAKE_CURRENT_SOURCE_DIR}/resources/*")

set(appName app6)
add_executable(${appName} src/main.cpp ${resourceFiles})
set_target_properties(${appName} PROPERTIES CXX_STANDARD 17)
if(UNIX AND NOT APPLE)
    target_link_libraries(${appName} LINK_PUBLIC stdc++fs)
endif()
## Adding dependencies
target_link_libraries(${appName} PUBLIC Qt5::Widgets Qt5::Multimedia)

find_package(OpenCV REQUIRED core highgui)
target_link_libraries(${appName} PUBLIC opencv_core opencv_highgui)

include(${CMAKE_SOURCE_DIR}/cmake/deployUtilities.cmake)

deployApplication(  APP_NAME ${appName}
                    APP_VERSION  "1.1.0.0"
                    COMPANY_NAME "BardoCoorp"
                    APP_DESCRIPTION "The very last one"
                    APP_ICON_PATH ${CMAKE_CURRENT_SOURCE_DIR}/resources/icon_app6.png
                    LICENSE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/license)