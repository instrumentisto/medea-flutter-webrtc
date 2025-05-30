package com.instrumentisto.medea_flutter_webrtc.controller

import android.util.Log
import java.util.TreeMap
import org.webrtc.ThreadUtils

private val TAG = ControllerRegistry::class.java.simpleName

/** Interface for all the controllers with unique IDs. */
object ControllerRegistry {
  /** All currently registered [ControllerRegistry]s. */
  private val controllers: TreeMap<Int, HashSet<IdentifiableController>> = TreeMap()

  /** Registers the provided [IdentifiableController] as active. */
  fun register(controller: IdentifiableController) {
    ThreadUtils.checkIsOnMainThread()

    val set = controllers.getOrPut(controller.disposeOrder) { HashSet() }
    set.add(controller)
  }

  /** Unregisters the provided [IdentifiableController] when it is disposed. */
  fun unregister(controller: IdentifiableController) {
    ThreadUtils.checkIsOnMainThread()

    controllers[controller.disposeOrder]?.let { set ->
      set.remove(controller)
      if (set.isEmpty()) {
        controllers.remove(controller.disposeOrder)
      }
    }
  }

  /** Disposes all registered [IdentifiableController]s. */
  fun disposeAll() {
    ThreadUtils.checkIsOnMainThread()

    // Clone since calling dispose() modifies `controllers` map
    val all = controllers.values.flatten().toList()

    all.forEach {
      try {
        it.dispose()
      } catch (e: Throwable) {
        Log.e(TAG, "Exception while disposing controller: $e")
      }
    }

    if (controllers.isNotEmpty()) {
      Log.e(TAG, "Controllers list is not empty after disposeAll()")
    }
  }
}
