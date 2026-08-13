/*
 * flashlight.sysml
 *
 * A minimal end-to-end SysML v2 model. Demonstrates:
 *   - package + imports
 *   - item / port / part definitions
 *   - port conjugation with ~
 *   - composition via nested parts
 *   - typed connections
 *   - state machine on a part
 *   - a formal requirement with satisfy + verify
 *
 * Use as a smoke-test fixture for the parser, the language server,
 * and AI-agent output.
 */

package FlashlightModel {

    private import ISQ::*;
    private import ISQBase::*;
    private import ISQElectromagnetism::*;
    private import ScalarValues::*;
    private import SI::*;

    // --------------------------------------------------------------
    // Items: things that flow
    // --------------------------------------------------------------

    item def Light;
    item def Electricity;
    attribute def VoltageValue : ElectricPotentialValue;

    // --------------------------------------------------------------
    // Port definitions
    // --------------------------------------------------------------

    port def PowerOutPort {
        out current : Electricity;
    }

    port def PowerInPort :> ~PowerOutPort;     // conjugate of PowerOutPort

    port def LightOutPort {
        out emitted : Light;
    }

    // --------------------------------------------------------------
    // Component definitions
    // --------------------------------------------------------------

    part def Battery {
        doc /* DC power source for the flashlight. */
        port supply : PowerOutPort;
        attribute capacity : ElectricChargeValue;
        attribute nominalVoltage : VoltageValue;
        attribute age : Real;
    }

    part def Bulb {
        doc /* Light-emitting element. */
        port supply  : PowerInPort;
        port emit    : LightOutPort;
        attribute lumens : LuminousIntensityValue;
    }

    part def Switch {
        doc /* Manually operated single-pole power switch. */
        port in     : PowerInPort;
        port out    : PowerOutPort;
        attribute contactClosed : Boolean = false;
    }

    // --------------------------------------------------------------
    // The flashlight as a system
    // --------------------------------------------------------------

    part def Flashlight {
        doc /* A simple battery-powered flashlight with a manual switch. */

        part battery : Battery;
        part switch  : Switch;
        part bulb    : Bulb;

        // Power flow: battery → switch → bulb
        connect battery.supply to switch.in;
        connect switch.out     to bulb.supply;

        // Operating modes
        exhibit state mode {
            state off;
            state on;

            transition pressOn  first off accept signal: PressEvent then on;
            transition pressOff first on  accept signal: PressEvent then off;
        }
    }

    item def PressEvent;

    // --------------------------------------------------------------
    // Requirements
    // --------------------------------------------------------------

    requirement def MinimumBrightness {
        doc /* The flashlight shall emit at least 50 lumens when on. */

        subject flashlight : Flashlight;
        attribute minLumens : LuminousIntensityValue = 50 [cd];

        require constraint { flashlight.bulb.lumens >= minLumens }
    }

    // --------------------------------------------------------------
    // A specific instance
    // --------------------------------------------------------------

    part myFlashlight : Flashlight {
        attribute :>> bulb.lumens = 80 [cd];

        satisfy MinimumBrightness;
    }

    // --------------------------------------------------------------
    // Verification
    // --------------------------------------------------------------

    verification def BrightnessTest {
        doc /* Measure the lumens output of a flashlight under nominal voltage. */

        subject flashlight : Flashlight;
        objective verifyBrightness {
            verify MinimumBrightness;
        }

        action installFreshBatteries;
        action turnOn;
        action measureLumens;
        action recordResult;

        first installFreshBatteries
        then  turnOn
        then  measureLumens
        then  recordResult;
    }

    verification testMyFlashlight : BrightnessTest {
        subject = myFlashlight;
    }
}
