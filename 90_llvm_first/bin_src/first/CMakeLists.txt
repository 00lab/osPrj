set(LLVM_LINK_COMPONENTS
  Support
)

add_bin_src(main0_bin
  main0.cpp
)

target_link_libraries(main0_bin
  PRIVATE
  TestInfoBase
)
