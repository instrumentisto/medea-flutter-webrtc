package com.cloudwebrtc.webrtc.model

import org.webrtc.CameraEnumerator

/**
 * Direction in which the camera producing the video.
 *
 * @property value [Int] representation of this enum which will be expected on Flutter side.
 */
enum class FacingMode(val value: Int) {
    /**
     * Indicates that video source is facing toward the user;
     * this includes, for example, the front-facing camera on
     * a smartphone.
     */
    USER(0),

    /**
     * Indicates that video source is facing away from the user,
     * thereby viewing their environment.
     * This is the back camera on a smartphone.
     */
    ENVIRONMENT(1);

    companion object {
        /**
         * Tries to create [FacingMode] based on the provided [Int].
         *
         * @param value [Int] value from which [FacingMode] will be created.
         * @return [FacingMode] based on the provided [Int].
         */
        fun fromInt(value: Int) = values().first { it.value == value }
    }
}

/**
 * Score of [VideoConstraints].
 *
 * This score will be determined by [ConstraintChecker] and based on it, more
 * suitable video device will be selected by gUM request.
 */
enum class ConstraintScore {
    /**
     * Indicates that constraint is not suitable at all.
     *
     * So device with this score wouldn't used event if
     * there is no other devices.
     */
    NO,

    /**
     * Indicates that constraint can be used, but more suitable
     * devices can be found.
     */
    MAYBE,

    /**
     * Indicates that constraint is ideally suits.
     */
    YES;

    companion object {
        /**
         * Calculates total score based on which media devices will be sorted.
         *
         * @param scores list of [ConstraintScore]s of some device.
         * @return total score calculated based on provided list.
         */
        fun totalScore(scores: List<ConstraintScore>): Int? {
            var total = 1
            for (score in scores) {
                when (score) {
                    NO -> return null
                    YES -> total++
                    MAYBE -> {
                    }
                }
            }

            return total
        }
    }
}

/**
 * Interface for the all video constraints which can check suitability of some device.
 */
interface ConstraintChecker {
    /**
     * Indicates that this constraint is mandatory or not.
     */
    val isMandatory: Boolean

    /**
     * Calculates [ConstraintScore] of device based on on underlying algorithm
     * of concrete constraint.
     *
     * @param enumerator object for interaction with Camera API.
     * @param deviceId ID of device which should be checked for this constraint.
     * @return [ConstraintScore] based on underlying scoring algorithm.
     */
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

    /**
     * Calculates suitability of the provided device.
     *
     * @param enumerator object for interaction with Camera API.
     * @param deviceId ID of device which suitability should be checked.
     * @return `true` if device is suitable or `false` if not.
     */
    fun isFits(enumerator: CameraEnumerator, deviceId: String): Boolean
}

/**
 * Constraint which will search for device with some concrete deviceId.
 *
 * @property id concrete deviceId which will be searched.
 * @property isMandatory indicates that this constraint is mandatory.
 */
data class DeviceIdConstraint(val id: String, override val isMandatory: Boolean) :
        ConstraintChecker {
    override fun isFits(enumerator: CameraEnumerator, deviceId: String): Boolean {
        return deviceId == id
    }
}

/**
 * Constraint which will search for device with some [FacingMode].
 *
 * @property facingMode [FacingMode] which will be searched.
 * @property isMandatory indicates that this constraint is mandatory.
 */
data class FacingModeConstraint(val facingMode: FacingMode, override val isMandatory: Boolean) :
        ConstraintChecker {
    override fun isFits(enumerator: CameraEnumerator, deviceId: String): Boolean {
        return when (facingMode) {
            FacingMode.USER -> enumerator.isFrontFacing(deviceId)
            FacingMode.ENVIRONMENT -> enumerator.isBackFacing(deviceId)
        }
    }

}

/**
 * List of constraints for video devices.
 *
 * @property constraints list of [ConstraintChecker] provided by user.
 */
data class VideoConstraints(
        val constraints: List<ConstraintChecker>
) {
    companion object {
        /**
         * Creates new [VideoConstraints] object based on the method call
         * received from the Flutter.
         *
         * @return [VideoConstraints] created from the provided [Map].
         */
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
                if (value != null) {
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
            }

            return VideoConstraints(constraintCheckers)
        }
    }

    /**
     * Calculates score for the device with a provided ID.
     *
     * @param enumerator object for interaction with Camera API.
     * @param deviceId ID of device which suitability should be checked.
     * @return total score calculated based on provided list.
     */
    fun calculateScoreForDeviceId(enumerator: CameraEnumerator, deviceId: String): Int? {
        val scores = mutableListOf<ConstraintScore>();
        for (constraint in constraints) {
            scores.add(constraint.score(enumerator, deviceId))
        }

        return ConstraintScore.totalScore(scores)
    }
}