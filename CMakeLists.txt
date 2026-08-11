cmake_minimum_required(VERSION 3.16)

project(searchfv VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick QuickControls2)
find_package(pugixml REQUIRED)

qt_standard_project_setup(REQUIRES 6.10)

if(WIN32)
    set(WIN_RESOURCES "resources.rc")
elseif(APPLE)
    set(MACOS_ICON "icon.icns")

    set_source_files_properties(${MACOS_ICON} PROPERTIES
        MACOSX_PACKAGE_LOCATION "Resources"
    )

    set(MACOS_BUNDLE_FLAG MACOSX_BUNDLE)
endif()

qt_add_executable(appsearchfv ${MACOS_BUNDLE_FLAG}
    main.cpp
        stringlistmodel.cpp
        stringlistmodel.h
        detailsprovider.cpp
        detailsprovider.h
        controller.cpp
        controller.h

        ${WIN_RESOURCES}
        ${MACOS_ICON}
)

qt_add_qml_module(appsearchfv
    URI searchfv
        VERSION 1.0
    QML_FILES
        Main.qml
)

qt_add_resources(appsearchfv "rec_files"
    PREFIX "/"
    FILES
        "assets/icon512.png"
        "assets/icon16.png"
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appsearchfv PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER appsearchfv
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    MACOSX_BUNDLE_ICON_FILE "icon.icns"
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appsearchfv
    PRIVATE
        Qt6::Quick
        Qt6::QuickControls2
        pugixml::pugixml
)

install(TARGETS appsearchfv
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
