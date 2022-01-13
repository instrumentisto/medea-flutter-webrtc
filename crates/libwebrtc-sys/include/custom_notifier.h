#include <winsock2.h>
#include <windows.h>
#include <dbt.h>
#include <strsafe.h>
#include <functional>

#include "debbouncer.h"

class CustomNotifier {
public:
  CustomNotifier(std::function<void()> cb) : cb_(cb) {
    // CustomNotifier() {
    std::this_thread::get_id;

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
      ShowWindow(hwnd_, SW_HIDE);

      MSG Msg;

      while (GetMessage(&Msg, NULL, 0, 0) > 0) {
        TranslateMessage(&Msg);
        DispatchMessage(&Msg);
      }
      });
    t.detach();
  }

  static LRESULT CALLBACK DWProc(HWND hwnd, UINT msg, WPARAM wp, LPARAM lp) {
    LRESULT result = 0;

    if (msg == WM_CLOSE) {
      exit(0);
    } else if (msg == WM_DEVICECHANGE) {
      if (DBT_DEVICEARRIVAL == wp) {
        printf("pupa\n");
      } else if (DBT_DEVICEREMOVECOMPLETE == wp) {
        printf("lupa\n");
      } else if (DBT_DEVNODES_CHANGED == wp) {
        printf("zupa\n");
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

private:
  std::function<void()> cb_;
  HWND hwnd_;
  CustomTimer* timer_ = new CustomTimer();
};
