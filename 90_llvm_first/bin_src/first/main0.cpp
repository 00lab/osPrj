#include "llvm/Support/InitLLVM.h"
#include "llvm/Support/raw_ostream.h"
#include "src/lib0/test_info.h"

int main(int argc, const char **argv)
{
    llvm::InitLLVM X(argc, argv);

    llvm::outs() << "Hello World! (version " << simplelang::getSimpleLangVersion() << ")\n";
}