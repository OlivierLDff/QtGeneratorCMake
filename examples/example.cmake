cmake_minimum_required(VERSION 3.14.0 FATAL_ERROR)

include(../cmake/GenerateQrc.cmake)
include(../cmake/GenerateQrcAliasQtObject.cmake)
include(../cmake/GenerateQmldir.cmake)

qt_generate_qrc_alias_qt_object(GENERATED_ALIAS_QML_FILENAME
  SOURCE_DIR qml
  NAME qml/Icons.qml
  PREFIX "My/Qrc/Prefix"
  GLOB_EXPRESSION "*.svg"
  SINGLETON)

qt_generate_qmldir(OUTPUT_QMLDIR_FILENAME
  SOURCE_DIR qml
  MODULE "My.Qrc.Prefix")

qt_generate_qrc(OUTPUT_QRC_FILENAME
  SOURCE_DIR qml
  NAME MyQrcFile.qrc
  PREFIX "My/Qrc/Prefix"
  GLOB_EXPRESSION "*.svg;*.qml")

message(STATUS "GENERATED_ALIAS_QML_FILENAME : ${GENERATED_ALIAS_QML_FILENAME}")
message(STATUS "OUTPUT_QMLDIR_FILENAME : ${OUTPUT_QMLDIR_FILENAME}")
message(STATUS "OUTPUT_QRC_FILENAME : ${OUTPUT_QRC_FILENAME}")