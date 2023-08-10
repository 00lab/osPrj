cmake_minimum_required(VERSION 3.10)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 11) # 设置至少C++ 11

project(test_llvm)

# 引入llvm
# HINTS参数用来指定搜索文件时的提示路径，如果没找到，去LLVM_CMAKE_PATH路径下找
# find_package(LLVM REQUIRED HINTS "${LLVM_CMAKE_PATH}")
find_package(LLVM REQUIRED)
list(APPEND CMAKE_MODULE_PATH ${LLVM_DIR})

include(AddLLVM)
include(HandleLLVMOptions)

include_directories("${LLVM_BINARY_DIR}/include" "${LLVM_INCLUDE_DIR}")
link_directories(${LLVM_LIBRARY_DIR})
set(SIMPLELANG_BUILT_STANDALONE 1)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

message(FATAL_ERROR "In-source builds are not allowed.${CMAKE_BINARY_DIR}")

set(TEST_VERSION "0.1")

# 参考https://www.jianshu.com/p/2946eeec2489
# CMAKE_CURRENT_BINARY_DIR，就是当前的build目录，一般在工程下建立个build目录构建，=xxx/build
# CMAKE_CURRENT_SOURCE_DIR就是当前CMakeLists.txt源文件所在目录
configure_file(
  ${CMAKE_CURRENT_SOURCE_DIR}/include/simplelang/Basic/Version.inc.in
  ${CMAKE_CURRENT_BINARY_DIR}/include/simplelang/Basic/Version.inc
)

# 添加cmake下的test_cmake_modu.cmake
# 先设置SET(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake)
# 然后用include来调cmake下的模块
include(test_cmake_modu)

#[[
include_directories 将指定目录添加到编译器的头文件搜索路径中，指定的目录被解释成当前源码路径的相对路径。
语法格式： include_directories ([AFTER|BEFORE] [SYSTEM] dir1 [dir2 ...])
1）默认include_directories命令会将目录添加到列表最后（AFTER选项）。
可以通过set命令设置CMAKE_INCLUDE_DIRECTORIES_BEFORE 变量为ON来改变它的默认行为，将目录添加到列表前面。
也可以在每次调用include_directories命令时使用AFTER或BEFORE选项来指定是添加到列表的前面或者后面。

2）如果使用SYSTEM选项，会把指定目录当成系统的搜索目录。该命令作用范围只在当前的CMakeLists.txt。
例如，在Linux下，C编译器默认搜索路径：
/usr/include
/usr/local/include
若我们项目有公共头文件目录include1、include2需要添加到C编译器的默认搜索路径，可以在CMakeLists.txt中添加：
include_directories(include1) # 注意当前CMakeLists.txt和include1相对路径关系, 此时必须是在同一个目录下
include_directories(${PROJECT_SOURCE_DIR}/include2) # 通过源码根目录来找到include2

#####################分割线############################

target_include_directories
为指定目标（target）添加搜索路径，指定目标是指通过如add_executable()，add_library()这样的命令生成的，并且决不能是alias target（引用目标，别名目标）。
语法格式：
target_include_directories(<target> [SYSTEM] [AFTER|BEFORE]  <INTERFACE|PUBLIC|PRIVATE> [items1...]  [<INTERFACE|PUBLIC|PRIVATE> [items2...] ...])
1）AFTER或BEFORE：可以选择让添加的路径位于搜索列表的开头或结尾。缺省时，默认是AFTER。

INTERFACE，PUBLIC，PRIVATE
指定接下来的参数item（即路径）的作用域：
  INTERFACE target对应的头文件才能使用，会指定target的属性 INTERFACE_INCLUDE_DIRECTORIES
  PUBLIC target对应头文件和源文件都能使用，会指定target的属性 INCLUDE_DIRECTORIES 和INTERFACE_INCLUDE_DIRECTORIES
  PRIVATE target对应源文件使用，会指定target的属性 INCLUDE_DIRECTORIES
注意：
1）所谓使用是指添加头文件搜索路径（item）。
2）target的属性可以通过set_property()修改。

例如，单独为目标projectA添加搜索路径include1。

target_include_directories(projectA ./include1) # 注意当前CMakeLists.txt与include1路径的相对位置关系

add_executable(projectA main.cpp)
SYSTEM
如果指定SYSTEM，在一些平台上，编译器会将路径作系统包含目录路径，可能对包含的头文件在依赖计算时的警告或者忽略，有一些影响。如果SYSTEM和PUBLIC或INTERFACE同时指定，target的属性INTERFACE_SYSTEM_INCLUDE_DIRECTORIES将填充指定目录。

include_directories与target_include_directories区别
include_directories 会为当前CMakeLists.txt的所有目标，以及之后添加的所有子目录的目标添加头文件搜索路径。因此，慎用target_include_directories，因为会影响全局target。
target_include_directories 只会为指定目标包含头文件搜索路径。如果想为不同目标设置不同的搜索路径，那么用target_include_directories更合适。
]]
include_directories(BEFORE
  ${CMAKE_CURRENT_BINARY_DIR}/src/lib0
  ${CMAKE_CURRENT_SOURCE_DIR}/src/lib0
)
add_subdirectory(src)
add_subdirectory(bin_src)
