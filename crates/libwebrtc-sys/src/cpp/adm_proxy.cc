#include "adm_proxy.h"

namespace webrtc {
    class TestInterface {
    public:
    virtual std::string FooA() = 0;
    virtual std::string FooB(bool arg1) const = 0;
    virtual std::string FooC(bool arg1) = 0;
    };

    class Test : public TestInterface {
    std::string FooA() {
        return("A");
    }
    std::string FooB(bool arg1) const {
        if(arg1) {
        return("B");
        }
        return("B");
    }
    std::string FooC(bool arg1) {
        return("C");
    }
    };

    BEGIN_PROXY_MAP(Test)
      PROXY_PRIMARY_THREAD_DESTRUCTOR()
      PROXY_METHOD0(std::string, FooA)
      PROXY_CONSTMETHOD1(std::string, FooB, bool)
      PROXY_SECONDARY_METHOD1(std::string, FooC, bool)
    END_PROXY_MAP(Test)
}
