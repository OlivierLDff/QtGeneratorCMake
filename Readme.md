# QtGeneratorCMake

Collection of CMake function to generate `qrc`, `qmldir` files for qt applications.

## 🧰 Generate Qrc

Generate a qrc file that pack every file inside a folder.

Example:

```cmake
qt_generate_qrc(OUTPUT_QRC_FILENAME
 SOURCE_DIR path/to/qml/folder
 NAME MyQrcFile.qrc
 PREFIX "My/Qrc/Prefix"
 GLOB_EXPRESSION "*.svg;*.qml"
 RECURSE
 ALWAYS_OVERWRITE
 VERBOSE
)
```

Usage: `qt_generate_qrc(<var> [options...])`

* **VAR**: Absolute path to the generated `qrc` file

- **PREFIX**: qrc prefix for every file in folder. `<qresource prefix="/${PREFIX}">`
- **SOURCE_DIR**: folder containing file to pack in `qrc`. The file is also generated in that folder if `DEST_DIR` isn't specified.
- **DEST_DIR**: folder that will contain the output `qrc` file. Default to `SOURCE_DIR` if not specified.
- **NAME**: Name of the file (should include `.qrc` extension, or whatever extension you want)
- **GLOB_EXPRESSION**: Expression to filter which files are going to be embedded in the `qrc`.
- **RECURSE**: Also traverse subdirectory when generating `qrc` file.
- **ALWAYS_OVERWRITE**: By default qrc file is generated only if it doesn't exist. With this option, if force to rewrite qrc if it has changed.
- **VERBOSE**: Dump useful information for developer.

## 🔨 Generate Qmldir

Generate a qmldir file that embed every qml file inside a folder.

Example:

```cmake
qt_generate_qmldir(OUTPUT_QMLDIR_FILENAMES
 SOURCE_DIR path/to/qml/folder
 MODULE "MyModule.Example"
 RECURSE
 VERBOSE)
```

Usage : `qt_generate_qmldir(<var> [options...])`

* **VAR**: Absolute path to the generated qrc file. This variable is a list if `RECURSE` is enabled.

- **SOURCE_DIR**: folder containing file to pack in qrc. The file is also generated in that folder if `DEST_DIR` isn't specified.
- **MODULE**: Name of the module. 
- **RECURSE**: Generate a `qmldir` for every subdirectory too.
- **VERBOSE**: Dump useful information for developer.

> You should call `qt_generate_qmldir` before `qt_generate_qrc` if you want the `qmldir` file to be embedded inside the `qrc` file.

## 🧬 Generate Qrc Alias

Generate a QtObject with property string containing full qrc path to file. This is useful for example if you want a singleton referencing icons or images with readable property name.

Example:

```cmake
qt_generate_qrc_alias_qt_object(GENERATED_ALIAS_QML_FILENAME
  SOURCE_DIR path/to/qml/folder
  NAME path/to/qml/folder/Icons.qml
  PREFIX "My/Qrc/Prefix"
  GLOB_EXPRESSION "*.svg"
  SINGLETON)
```

Usage: `qt_generate_qrc_alias_qt_object(<var> [options...])`

* **VAR**: Absolute path to the generated qml file

- **SOURCE_DIR**: folder containing file to pack in qrc. The file is also generated in that folder.
- **NAME**: Name of the qml file. Can be relative or absolute
- **GLOB_EXPRESSION**: Expression to filter which file are going to be embedded in the qrc.
- **SINGLETON**: Should the object be a singleton. This add a `pragma Singleton` on the first line.

## 🎎 Example

The folder `example` contains an example of every functions in `example/example.cmake`.

Run the example as a script:

```bash
cd example
cmake -P example.cmake
```

Run the example as a cmake project:

```bash
mkdir example/build && cd example/build
cmake ..
```

# 💡 Ideas

* Generate Qrc : 
  * RECURSIVE options
  * OUTPUT_DIR that have relative path to current dir
