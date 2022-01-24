package com.cloudwebrtc.webrtc.model

import org.webrtc.CameraEnumerator

enum class FacingMode(val value: Int) {
    USER(0),
    ENVIRONMENT(1);

    companion object {
        fun fromInt(value: Int) = values().first { it.value == value }
    }
}

enum class ConstraintScore {
    NO,
    MAYBE,
    YES;

    companion object {
        fun totalScore(scores: List<ConstraintScore>): Int? {
            var total = 1
            for (score in scores) {
                when (score) {
                    NO -> return null
                    YES -> total++
                    MAYBE -> {}
                }
            }

            return total
        }
    }
}

interface ConstraintChecker {
    val isMandatory: Boolean

    fun score(enumerator: CameraEnumerator, deviceId: String): ConstraintScore {
        val fits = isFits(enumerator, deviceId)
        return when {
            fits -> {
                ConstraintScore.YES
            }
            isMandatory && !fits -> {
                ConstraintScore.NO
            }
            else -> {
                ConstraintScore.MAYBE
            }
        }
    }

    fun isFits(enumerator: CameraEnumerator, deviceId: String): Boolean
}

data class DeviceIdConstraint(val id: String, override val isMandatory: Boolean) :
    ConstraintChecker {
    override fun isFits(enumerator: CameraEnumerator, deviceId: String): Boolean {
        return deviceId == id
    }
}

data class FacingModeConstraint(val facingMode: FacingMode, override val isMandatory: Boolean) :
    ConstraintChecker {
    override fun isFits(enumerator: CameraEnumerator, deviceId: String): Boolean {
        return when (facingMode) {
            FacingMode.USER -> enumerator.isFrontFacing(deviceId)
            FacingMode.ENVIRONMENT -> enumerator.isBackFacing(deviceId)
        }
    }

}

data class VideoConstraints(
    val constraints: List<ConstraintChecker>
) {
    companion object {
        fun fromMap(map: Map<*, *>): VideoConstraints {
            val constraintCheckers = mutableListOf<ConstraintChecker>()

            val mandatoryArg =
                map["mandatory"] as Map<*, *>?
            for ((key, value) in mandatoryArg ?: mapOf<Any, Any>()) {
                when (key as String) {
                    "deviceId" -> {
                        constraintCheckers.add(DeviceIdConstraint(value as String, true))
                    }
                    "facingMode" -> {
                        constraintCheckers.add(
                            FacingModeConstraint(
                                FacingMode.fromInt(value as Int),
                                true
                            )
                        )
                    }
                }
            }

            val optionalArg = map["optional"] as Map<*, *>?
            for ((key, value) in optionalArg ?: mapOf<Any, Any>()) {
                when (key as String) {
                    "deviceId" -> {
                        constraintCheckers.add(DeviceIdConstraint(value as String, false))
                    }
                    "facingMode" -> {
                        constraintCheckers.add(
                            FacingModeConstraint(
                                FacingMode.fromInt(value as Int),
                                false
                            )
                        )
                    }
                }
            }

            return VideoConstraints(constraintCheckers)
        }
    }

    fun calculateScoreForDeviceId(enumerator: CameraEnumerator, deviceId: String): Int? {
        val scores = mutableListOf<ConstraintScore>();
        for (constraint in constraints) {
            scores.add(constraint.score(enumerator, deviceId))
        }

        return ConstraintScore.totalScore(scores)
    }
}