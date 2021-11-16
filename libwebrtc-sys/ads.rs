#![feature(prelude_import)]
#[prelude_import]
use std::prelude::rust_2018::*;
#[macro_use]
extern crate std;
#[deny(improper_ctypes, improper_ctypes_definitions)]
#[allow(clippy::unknown_clippy_lints)]
#[allow(non_camel_case_types, non_snake_case, clippy::upper_case_acronyms)]
mod rtc {
    #[repr(C)]
    pub struct TaskQueueFactory {
        _private: ::cxx::private::Opaque,
    }
    unsafe impl ::cxx::ExternType for TaskQueueFactory {
        #[doc(hidden)]
        type Id = (
            ::cxx::R,
            ::cxx::T,
            ::cxx::C,
            (),
            ::cxx::T,
            ::cxx::a,
            ::cxx::s,
            ::cxx::k,
            ::cxx::Q,
            ::cxx::u,
            ::cxx::e,
            ::cxx::u,
            ::cxx::e,
            ::cxx::F,
            ::cxx::a,
            ::cxx::c,
            ::cxx::t,
            ::cxx::o,
            ::cxx::r,
            ::cxx::y,
        );
        type Kind = ::cxx::kind::Opaque;
    }
    #[repr(C)]
    pub struct AudioDeviceModule {
        _private: ::cxx::private::Opaque,
    }
    unsafe impl ::cxx::ExternType for AudioDeviceModule {
        #[doc(hidden)]
        type Id = (
            ::cxx::R,
            ::cxx::T,
            ::cxx::C,
            (),
            ::cxx::A,
            ::cxx::u,
            ::cxx::d,
            ::cxx::i,
            ::cxx::o,
            ::cxx::D,
            ::cxx::e,
            ::cxx::v,
            ::cxx::i,
            ::cxx::c,
            ::cxx::e,
            ::cxx::M,
            ::cxx::o,
            ::cxx::d,
            ::cxx::u,
            ::cxx::l,
            ::cxx::e,
        );
        type Kind = ::cxx::kind::Opaque;
    }
    pub fn SystemTimeMillis() -> ::cxx::UniquePtr<::cxx::CxxString> {
        extern "C" {
            #[link_name = "RTC$cxxbridge1$SystemTimeMillis"]
            fn __SystemTimeMillis() -> *mut ::cxx::CxxString;
        }
        unsafe { ::cxx::UniquePtr::from_raw(__SystemTimeMillis()) }
    }
    pub fn CreateDefaultTaskQueueFactory() -> ::cxx::UniquePtr<TaskQueueFactory> {
        extern "C" {
            #[link_name = "RTC$cxxbridge1$CreateDefaultTaskQueueFactory"]
            fn __CreateDefaultTaskQueueFactory() -> *mut TaskQueueFactory;
        }
        unsafe { ::cxx::UniquePtr::from_raw(__CreateDefaultTaskQueueFactory()) }
    }
    pub fn InitAudioDeviceModule(
        TaskQueueFactory: ::cxx::UniquePtr<TaskQueueFactory>,
    ) -> *mut AudioDeviceModule {
        extern "C" {
            #[link_name = "RTC$cxxbridge1$InitAudioDeviceModule"]
            fn __InitAudioDeviceModule(
                TaskQueueFactory: *mut TaskQueueFactory,
            ) -> *mut AudioDeviceModule;
        }
        unsafe { __InitAudioDeviceModule(::cxx::UniquePtr::into_raw(TaskQueueFactory)) }
    }
    pub fn customGetSource() {
        extern "C" {
            #[link_name = "RTC$cxxbridge1$customGetSource"]
            fn __customGetSource();
        }
        unsafe { __customGetSource() }
    }
    unsafe impl ::cxx::private::UniquePtrTarget for TaskQueueFactory {
        #[doc(hidden)]
        fn __typename(f: &mut ::std::fmt::Formatter) -> ::std::fmt::Result {
            f.write_str("TaskQueueFactory")
        }
        #[doc(hidden)]
        fn __null() -> ::std::mem::MaybeUninit<*mut ::std::ffi::c_void> {
            extern "C" {
                #[link_name = "cxxbridge1$unique_ptr$RTC$TaskQueueFactory$null"]
                fn __null(this: *mut ::std::mem::MaybeUninit<*mut ::std::ffi::c_void>);
            }
            let mut repr = ::std::mem::MaybeUninit::uninit();
            unsafe { __null(&mut repr) }
            repr
        }
        #[doc(hidden)]
        unsafe fn __raw(raw: *mut Self) -> ::std::mem::MaybeUninit<*mut ::std::ffi::c_void> {
            extern "C" {
                #[link_name = "cxxbridge1$unique_ptr$RTC$TaskQueueFactory$raw"]
                fn __raw(
                    this: *mut ::std::mem::MaybeUninit<*mut ::std::ffi::c_void>,
                    raw: *mut ::std::ffi::c_void,
                );
            }
            let mut repr = ::std::mem::MaybeUninit::uninit();
            __raw(&mut repr, raw.cast());
            repr
        }
        #[doc(hidden)]
        unsafe fn __get(repr: ::std::mem::MaybeUninit<*mut ::std::ffi::c_void>) -> *const Self {
            extern "C" {
                #[link_name = "cxxbridge1$unique_ptr$RTC$TaskQueueFactory$get"]
                fn __get(
                    this: *const ::std::mem::MaybeUninit<*mut ::std::ffi::c_void>,
                ) -> *const ::std::ffi::c_void;
            }
            __get(&repr).cast()
        }
        #[doc(hidden)]
        unsafe fn __release(
            mut repr: ::std::mem::MaybeUninit<*mut ::std::ffi::c_void>,
        ) -> *mut Self {
            extern "C" {
                #[link_name = "cxxbridge1$unique_ptr$RTC$TaskQueueFactory$release"]
                fn __release(
                    this: *mut ::std::mem::MaybeUninit<*mut ::std::ffi::c_void>,
                ) -> *mut ::std::ffi::c_void;
            }
            __release(&mut repr).cast()
        }
        #[doc(hidden)]
        unsafe fn __drop(mut repr: ::std::mem::MaybeUninit<*mut ::std::ffi::c_void>) {
            extern "C" {
                #[link_name = "cxxbridge1$unique_ptr$RTC$TaskQueueFactory$drop"]
                fn __drop(this: *mut ::std::mem::MaybeUninit<*mut ::std::ffi::c_void>);
            }
            __drop(&mut repr);
        }
    }
    #[doc(hidden)]
    const _: () = {
        let _ = {
            trait __AmbiguousIfImpl<A> {
                fn infer() {}
            }
            impl<T> __AmbiguousIfImpl<()> for T where T: ?::std::marker::Sized {}
            #[allow(dead_code)]
            struct __Invalid;
            impl<T> __AmbiguousIfImpl<__Invalid> for T where T: ?::std::marker::Sized + ::std::marker::Unpin {}
            <TaskQueueFactory as __AmbiguousIfImpl<_>>::infer
        };
        let _ = {
            trait __AmbiguousIfImpl<A> {
                fn infer() {}
            }
            impl<T> __AmbiguousIfImpl<()> for T where T: ?::std::marker::Sized {}
            #[allow(dead_code)]
            struct __Invalid;
            impl<T> __AmbiguousIfImpl<__Invalid> for T where T: ?::std::marker::Sized + ::std::marker::Unpin {}
            <AudioDeviceModule as __AmbiguousIfImpl<_>>::infer
        };
    };
}
pub fn system_time_millis() -> String {
    rtc::customGetSource();
    let a = rtc::CreateDefaultTaskQueueFactory();
    let b = rtc::InitAudioDeviceModule(a);
    rtc::SystemTimeMillis().to_string()
}
