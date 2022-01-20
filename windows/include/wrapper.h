#pragma once

#include <functional>
#include <iostream>
#include <memory>

template <int Ind, typename R, typename... Args>
struct Wrapper;

template <int Ind, typename Callable, typename R, typename... Args>
R wrapper(Args... args);

template <int Ind, typename Callable>
struct CallableStorage {
  static void store(Callable callable_) {
    callable = std::make_unique<Callable>(callable_);
  }

  template <typename R, typename... Args>
  static R invoke(Args... args) {
    return (*callable)(args...);
  }

 private:
  static std::unique_ptr<Callable> callable;
};

template <int Ind, typename Callable>
std::unique_ptr<Callable> CallableStorage<Ind, Callable>::callable;

template <int Ind, typename R, typename... Args>
struct Wrapper<Ind, R(Args...)> {
  using RawType = R (*)(Args...);

  template <typename Callable>
  static RawType wrap(Callable callable) {
    CallableStorage<Ind, Callable>::store(callable);
    return wrapper<Ind, Callable, R, Args...>;
  }
};

template <int Ind, typename Callable, typename R, typename... Args>
R wrapper(Args... args) {
  return CallableStorage<Ind, Callable>::template invoke<R>(args...);
}
