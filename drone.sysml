package DroneSystem {

    private import ScalarValues::*;
    private import SI::*;

    item def Thrust;
    item def Power;
    item def ControlEnvelope;
    item def NavigationPlan;
    item def Telemetry;
    item def DiagnosticMessage;

    attribute def Voltage : Real;
    attribute def Current : Real;
    attribute def Mass : Real;
    attribute def Speed : Real;
    attribute def Altitude : Real;
    attribute def ChargeLevel : Real;

    port def PowerOutPort {
        out energy : Power;
        out voltage : Voltage;
        out current : Current;
    }

    port def PowerInPort :> ~PowerOutPort;

    port def ControlOutPort {
        out command : ControlEnvelope;
    }

    port def ControlInPort :> ~ControlOutPort;

    port def ThrustOutPort {
        out thrust : Thrust;
    }

    port def ThrustInPort :> ~ThrustOutPort;

    port def NavigationOutPort {
        out plan : NavigationPlan;
    }

    port def NavigationInPort :> ~NavigationOutPort;

    port def TelemetryOutPort {
        out heartbeat : Telemetry;
    }

    port def TelemetryInPort :> ~TelemetryOutPort;

    part def Battery {
        doc /* A battery module that supplies power to the drone. */
        port output : PowerOutPort;
        attribute capacity : ChargeLevel = 100.0;
        attribute mass : Mass = 1.2;
        attribute nominalVoltage : Voltage = 22.2;
    }

    part def FlightController {
        doc /* The flight computer that issues motor commands and receives navigation data. */
        port power : PowerInPort;
        port navigation : NavigationInPort;
        port motors : ControlOutPort;
        port telemetry : TelemetryOutPort;
        attribute firmwareVersion : String = "v1.0";

        exhibit state operationalMode {
            state standby;
            state armed;
            state flight;
            transition arm first standby then armed;
            transition takeOff first armed then flight;
            transition land first flight then standby;
        }
    }

    part def ElectronicSpeedController {
        doc /* Converts control commands into motor drive signals for a single motor. */
        port powerInput : PowerInPort;
        port controlIn : ControlInPort;
        port motorPower : PowerOutPort;
        attribute firmwareVersion : String = "ESC-1.0";
    }

    part def Motor {
        doc /* Brushless motor coupled to a propeller. */
        port power : PowerInPort;
        port command : ControlInPort;
        port thrust : ThrustOutPort;
        attribute kvRating : Real = 920.0; // RPM per Volt
        attribute mass : Mass = 0.3;
    }

    part def Propeller {
        doc /* Propeller generates thrust from motor output. */
        port drive : ThrustInPort;
        attribute diameter : Real = 0.254; // 10 inches in meters
        attribute mass : Mass = 0.05;
    }

    part def Arm {
        doc /* One motor arm of the quadcopter. */
        part esc : ElectronicSpeedController;
        part motor : Motor;
        part propeller : Propeller;
        
        port powerTap : PowerOutPort {
            out energy : Power;
            out voltage : Voltage;
            out current : Current;
        }

        connect esc.motorPower to motor.power;
        connect esc.controlIn to motor.command;
        connect motor.thrust to propeller.drive;
    }

    part def Frame {
        doc /* Structure that holds four arms and provides power distribution. */
        part frontLeft : Arm;
        part frontRight : Arm;
        part rearLeft : Arm;
        part rearRight : Arm;

        port powerBus : PowerOutPort {
            out energy : Power;
            out voltage : Voltage;
            out current : Current;
        }
    }

    part def PayloadBay {
        doc /* Payload bay for sensors or cargo. */
        port telemetry : TelemetryOutPort;
        attribute mass : Mass = 0.8;
    }

    part def Drone {
        doc /* A quadcopter drone with power, navigation, and payload subsystems. */
        part battery : Battery {
            port power;
        }
        part flightController : FlightController;
        part frame : Frame;
        part payload : PayloadBay;

        connect battery.output to flightController.power;
        connect battery.power to frame.powerBus;
        connect flightController.motors to frame.frontLeft.esc.controlIn;
        connect flightController.motors to frame.frontRight.esc.controlIn;
        connect flightController.motors to frame.rearLeft.esc.controlIn;
        connect flightController.motors to frame.rearRight.esc.controlIn;
        connect flightController.telemetry to payload.telemetry;
    }

    requirement def MinimalTakeoffThrust {
        doc /* The drone shall generate enough thrust to lift its mass and payload. */
        subject drone : Drone;
        attribute requiredThrust : Thrust = 15.0;
        require constraint { drone.frame.frontLeft.motor.kvRating + drone.frame.frontRight.motor.kvRating + drone.frame.rearLeft.motor.kvRating + drone.frame.rearRight.motor.kvRating >= 3600.0 }
    }

    requirement def BatteryReserve {
        doc /* The drone shall retain a reserve charge level for safe return. */
        subject drone : Drone;
        attribute minimumReserve : ChargeLevel = 20.0;
        require constraint { drone.battery.capacity >= minimumReserve }
    }

    action def PreflightChecklist {
        action verifyBattery;
        action calibrateSensors;
        action armMotors;
        first verifyBattery then calibrateSensors then armMotors;
    }

    action def FlightMission {
        action takeOff;
        action climb;
        action navigate;
        action hover;
        action land;
        first takeOff then climb then navigate then hover then land;
    }

    part myDrone : Drone {
        attribute :>> battery.capacity = 95.0;
        attribute :>> frame.frontLeft.motor.kvRating = 920.0;
        attribute :>> frame.frontRight.motor.kvRating = 920.0;
        attribute :>> frame.rearLeft.motor.kvRating = 920.0;
        attribute :>> frame.rearRight.motor.kvRating = 920.0;
        satisfy MinimalTakeoffThrust;
        satisfy BatteryReserve;
    }

    verification def MissionVerification {
        subject drone : Drone;
        objective verifyFlightSafety {
            verify MinimalTakeoffThrust;
            verify BatteryReserve;
        }
        action powerOn;
        action loadFlightPlan;
        action startMotors;
        action completeMission;
        first powerOn then loadFlightPlan then startMotors then completeMission;
    }

    verification testMyDrone : MissionVerification {
        subject = myDrone;
    }
    connect rearLeft.powerTap to rearRight.powerTap;
    connect rearLeft.powerTap to rearRight.powerTap;
    connect rearRight.powerTap to rearLeft.powerTap;
    connect frontRight.powerTap to frontLeft.powerTap;
}
