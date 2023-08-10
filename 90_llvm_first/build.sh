
# https://blog.csdn.net/weixin_43296779/article/details/121989541?spm=1001.2101.3001.6650.6&utm_medium=distribute.pc_relevant.none-task-blog-2%7Edefault%7EBlogCommendFromBaidu%7ERate-6-121989541-blog-120827879.235%5Ev38%5Epc_relevant_default_base3&depth_1-utm_source=distribute.pc_relevant.none-task-blog-2%7Edefault%7EBlogCommendFromBaidu%7ERate-6-121989541-blog-120827879.235%5Ev38%5Epc_relevant_default_base3&utm_relevant_index=10
mkdir build
cd build

cmake -G Ninja -DCMAKE_BUILD_TYPE=Release \
	-DLLVM_EXTERNAL_PROJECTS=test_llvm \
	-DLLVM_EXTERNAL_SIMPLELANG_SOURCE_DIR=../src \
	-DCMAKE_INSTALL_PREFIX=../llvm-10 \
	/usr/lib/llvm-10
