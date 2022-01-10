#include "test_catch/include/blobstore.h"
#include "test_catch/src/lib.rs.h"



void catch_err()
{
  try
  {
    auto err = ERROR_C();
    printf("%i\n", err);
  }
  catch (std::exception &e)
  {
    printf("catch in c++ %s\n", e.what());
  }
  
}