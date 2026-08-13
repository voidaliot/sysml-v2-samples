/*
 * e-mountainbike.sysml
 *
 * A SysML v2 model of a trail-oriented electric mountain bike.
 * The model covers the bike's physical composition, power and control
 * flows, riding states, system requirements, and a verification case.
 */

package EMountainBikeModel {

    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;

    // ===== Items =====================================================

    item def Electricity;
    item def Torque;
    item def RideCommand;
    item def SensorData;
    item def BrakePressure;

    // ===== Ports =====================================================

    port def PowerOutPort {
        out current : Electricity;
    }

    port def PowerInPort :> ~PowerOutPort;

    port def TorqueOutPort {
        out torque : Torque;
    }

    port def TorqueInPort :> ~TorqueOutPort;

    port def CommandOutPort {
        out command : RideCommand;
    }

    port def CommandInPort :> ~CommandOutPort;

    port def SensorOutPort {
        out measurement : SensorData;
    }

    port def SensorInPort :> ~SensorOutPort;

    port def BrakeOutPort {
        out pressure : BrakePressure;
    }

    port def BrakeInPort :> ~BrakeOutPort;

    // ===== Components ===============================================

    part def Battery {
        doc /* Removable traction battery for the electric drive system. */
        port output : PowerOutPort;
        attribute capacity : ElectricChargeValue;
        attribute nominalVoltage : ElectricPotentialValue;
        attribute mass : MassValue;
    }

    part def Motor {
        doc /* Mid-drive motor that provides pedal assistance. */
        port power : PowerInPort;
        port command : CommandInPort;
        port torque : TorqueOutPort;
        attribute peakPower : PowerValue;
        attribute peakTorque : TorqueValue;
        attribute mass : MassValue;
    }

    part def Wheel {
        doc /* Wheel and tire assembly. */
        port drive : TorqueInPort;
        port brake : BrakeInPort;
        attribute diameter : LengthValue;
        attribute mass : MassValue;
    }

    part def Frame {
        doc /* Structural frame with trail geometry and suspension mounts. */
        attribute frameSize : LengthValue;
        attribute mass : MassValue;
    }

    part def RiderInterface {
        doc /* Handlebar controls used by the rider. */
        port command : CommandOutPort;
        port brake : CommandOutPort;
    }

    part def PedalAssistSensor {
        doc /* Measures rider cadence and applied pedal effort. */
        port measurement : SensorOutPort;
        attribute cadence : Real;
    }

    part def BrakeSystem {
        doc /* Hydraulic disc-brake system for both wheels. */
        port command : CommandInPort;
        port front : BrakeOutPort;
        port rear : BrakeOutPort;
        attribute rotorDiameter : LengthValue;
    }

    part def DriveController {
        doc /* Supervises pedal assistance, battery power, and rider commands. */
        port power : PowerInPort;
        port riderCommand : CommandInPort;
        port pedalSensor : SensorInPort;
        port motorPower : PowerOutPort;
        port motorCommand : CommandOutPort;
        attribute maxAssistSpeed : SpeedValue;
        attribute assistLevel : Integer;

        exhibit state operatingMode {
            state off;
            state ready;
            state assisting;
            state charging;
            state fault;

            transition powerOn first off then ready;
            transition pedal first ready then assisting;
            transition stopPedaling first assisting then ready;
            transition plugIn first ready then charging;
            transition unplug first charging then ready;
            transition error first ready then fault;
            transition recover first fault then off;
        }
    }

    // ===== System ====================================================

    part def EMountainBike {
        doc /* A trail-capable electric mountain bike with pedal assistance. */

        part battery : Battery;
        part motor : Motor;
        part controller : DriveController;
        part frame : Frame;
        part frontWheel : Wheel;
        part rearWheel : Wheel;
        part riderInterface : RiderInterface;
        part pedalSensor : PedalAssistSensor;
        part brakes : BrakeSystem;

        connect battery.output to controller.power;
        connect controller.motorPower to motor.power;
        connect controller.motorCommand to motor.command;
        connect motor.torque to rearWheel.drive;
        connect riderInterface.command to controller.riderCommand;
        connect pedalSensor.measurement to controller.pedalSensor;
        connect riderInterface.brake to brakes.command;
        connect brakes.front to frontWheel.brake;
        connect brakes.rear to rearWheel.brake;
    }

    // ===== Operating events and actions =============================

    item def PowerOn;
    item def Pedal;
    item def StopPedaling;
    item def PlugIn;
    item def Unplug;
    item def FaultDetected;
    item def Reset;

    action def TrailRide {
        action inspectBike;
        action powerOn;
        action selectAssist;
        action rideTrail;
        action chargeBattery;

        first inspectBike
        then powerOn
        then selectAssist
        then rideTrail
        then chargeBattery;
    }

    // ===== Requirements ==============================================

    requirement def TrailMassLimit {
        doc /* The complete bike shall be light enough for trail handling. */
        subject bike : EMountainBike;
        attribute maximumMass : MassValue = 25 [kg];
        require constraint { bike.frame.mass + bike.battery.mass + bike.motor.mass + bike.frontWheel.mass + bike.rearWheel.mass <= maximumMass }
    }

    requirement def AssistedSpeedLimit {
        doc /* Pedal assistance shall be limited to the intended trail speed. */
        subject bike : EMountainBike;
        attribute maximumSpeed : SpeedValue = 25 [km/h];
        require constraint { bike.controller.maxAssistSpeed <= maximumSpeed }
    }

    requirement def BatteryCapacity {
        doc /* The battery shall provide enough charge for a substantial trail ride. */
        subject bike : EMountainBike;
        attribute minimumCapacity : ElectricChargeValue = 54000 [C];
        require constraint { bike.battery.capacity >= minimumCapacity }
    }

    requirement def HillClimbTorque {
        doc /* The motor shall provide enough torque for steep trail sections. */
        subject bike : EMountainBike;
        attribute minimumTorque : TorqueValue = 70 [N*m];
        require constraint { bike.motor.peakTorque >= minimumTorque }
    }

    // ===== Concrete bike and verification ===========================

    part myEMountainBike : EMountainBike {
        attribute :>> frame.mass = 11 [kg];
        attribute :>> battery.mass = 4 [kg];
        attribute :>> motor.mass = 3 [kg];
        attribute :>> frontWheel.mass = 2 [kg];
        attribute :>> rearWheel.mass = 2.5 [kg];
        attribute :>> battery.capacity = 72000 [C];
        attribute :>> battery.nominalVoltage = 48 [V];
        attribute :>> controller.maxAssistSpeed = 25 [km/h];
        attribute :>> motor.peakPower = 0.5 [kW];
        attribute :>> motor.peakTorque = 85 [N*m];

        satisfy TrailMassLimit;
        satisfy AssistedSpeedLimit;
        satisfy BatteryCapacity;
        satisfy HillClimbTorque;
    }

    verification def EMountainBikeVerification {
        doc /* Verify the mass, speed, battery, and hill-climb requirements. */
        subject bike : EMountainBike;

        objective verifyTrailMass {
            verify TrailMassLimit;
        }

        objective verifySpeedLimit {
            verify AssistedSpeedLimit;
        }

        objective verifyBattery {
            verify BatteryCapacity;
        }

        objective verifyTorque {
            verify HillClimbTorque;
        }

        action weighBike;
        action configureController;
        action inspectBattery;
        action runHillTest;
        action recordResults;

        first weighBike
        then configureController
        then inspectBattery
        then runHillTest
        then recordResults;
    }

    verification verifyMyEMountainBike : EMountainBikeVerification {
        subject = myEMountainBike;
    }
}
