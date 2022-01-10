
use anyhow::*;
#[cxx::bridge]
mod ffi {

    // Rust types and signatures exposed to C++.
    extern "Rust" {
        #[cxx_name = "ERROR_C"]
        fn err() -> Result<i32>;
    }

    // C++ types and signatures exposed to Rust.
    unsafe extern "C++" {
        include!("test_catch/include/blobstore.h");
        fn catch_err();
    }
}


pub fn err() -> anyhow::Result<i32>
{
    return Err(anyhow::Error::msg("TEST CATCH"));
    //return Ok(42);
}


#[cfg(test)]
mod test {
    use crate::ffi;
    #[test]
    fn error() {
        ffi::catch_err();
    }
}