#include <winsock2.h>
#include <windows.h>
#include <dbt.h>
#include <strsafe.h>
#include <thread>
#include <functional>

class CustomNotifier {
public:
  CustomNotifier(std::function<void()> cb) : cb_(cb) {
    std::thread t([=]() {
      const wchar_t winClass[] = L"MyNotifyWindow";
      const wchar_t winTitle[] = L"WindowTitle";

      WNDCLASSEXW wcex = { sizeof(WNDCLASSEX) };
      wcex.lpfnWndProc = DWProc;
      wcex.lpszClassName = L"MyNotifyWindow";
      ATOM wnd_class_ = RegisterClassExW(&wcex);

      HINSTANCE hInstance = GetModuleHandle(NULL);
      hwnd_ = CreateWindowW(winClass, winTitle, WS_ICONIC, 0, 0,
        CW_USEDEFAULT, 0, NULL, NULL, hInstance, NULL);
      SetWindowLongPtr(hwnd_, GWLP_USERDATA, (LONG_PTR)this);
      ShowWindow(hwnd_, SW_HIDE);

      MSG Msg;

      while (GetMessage(&Msg, NULL, 0, 0) > 0) {
        TranslateMessage(&Msg);
        DispatchMessage(&Msg);
      }
      });
    t.detach();
  }

private:
  static LRESULT CALLBACK DWProc(HWND hwnd, UINT msg, WPARAM wp, LPARAM lp) {
    LRESULT result = 0;

    auto asdasd = (CustomNotifier*)GetWindowLongPtr(hwnd, GWLP_USERDATA);

    if (msg == WM_CLOSE) {
      exit(0);
    } else if (msg == WM_DEVICECHANGE) {
      if (DBT_DEVNODES_CHANGED == wp) {
        printf("zupa\n");
        asdasd->cb_();
      }
    } else if (msg == WM_ERASEBKGND) {
    } else if (msg == WM_SETFOCUS) {
    } else if (msg == WM_SIZE) {
    } else if (msg == WM_CTLCOLORSTATIC) {
    } else if (msg == WM_COMMAND) {
    } else {
      result = DefWindowProc(hwnd, msg, wp, lp);
    }

    return result;
  };

  std::function<void()> cb_;
  HWND hwnd_;
};
