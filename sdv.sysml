package SoftwareDefinedVehicle {
    doc /* Production-oriented showcase model of a Software-Defined Vehicle (SDV).
         *
         * The model is intentionally architecture-first: external systems are
         * represented explicitly, vehicle subsystems exchange typed payloads
         * through named ports, interfaces document the contents that cross each
         * boundary, and sequence contexts show the main end-to-end interactions
         * between vehicle parts and the outside world. */

    locale "en_US" /* SDV terminology follows SAE J3016 automation levels and the English-language usage of ISO 26262 / UNECE WP.29. */;

    private import CausationConnections::*;
    private import DerivationConnections::*;
    private import ISQ::*;
    private import ScalarValues::*;
    // Geometry-library solid shapes for the 3D Geometry View (VehicleVolumeLayout).
    private import ShapeItems::*;
    private import SI::*;

    // ----------------------------------------------------------------------
    // Metadata, enumerations, and exchanged items
    // ----------------------------------------------------------------------

    metadata def SafetyCritical {
        attribute asil : String;
    }

    metadata def CyberCritical {
        attribute threatClass : String;
    }

    enum def LockState {
        unlocked;
        locked;
        secured;
    }

    enum def DriveLevel {
        manual;
        assisted;
        automated;
        fallback;
    }

    enum def UpdateState {
        idle;
        downloading;
        verifying;
        installed;
        active;
        rolledBack;
    }

    item def SensorFrame;
    item def ObjectList;
    item def LocalizationState;
    item def RoadContext;
    item def TrajectoryPlan;
    item def MotionCommand;
    item def ActuatorStatus;
    item def VehicleTelemetry;
    item def DiagnosticReport;
    item def DiagnosticRequest;
    item def HealthEvent;
    item def UpdateManifest;
    item def UpdateBundle;
    item def InstallVerdict;
    item def PolicyPackage;
    item def RemoteCommand;
    item def KeyCredential;
    item def AccessDecision;
    item def LockCommand;
    item def DoorStatus;
    item def DriverIntent;
    item def HmiNotification;
    item def ChargeCommand;
    item def ChargeStatus;
    item def EnergyRequest;
    item def V2XMessage;
    item def EmergencyAlert;
    item def MinimalRiskCommand;

    // ----------------------------------------------------------------------
    // Attributes, calculations, and constraints
    // ----------------------------------------------------------------------

    attribute def RangeEstimate {
        attribute kilometers : Real;
    }

    calc def RemainingRange {
        in batteryEnergy : Real;
        in consumptionPerKm : Real;
        return : Real;
        batteryEnergy / consumptionPerKm
    }

    constraint def MinimumComputePower {
        in available : Real;
        in required : Real;
        available >= required
    }

    constraint def OtaSignatureStrength {
        in signatureBits : Real;
        signatureBits >= 256.0
    }

    attribute def BitLength;
    enum def SignatureBitLength :> BitLength {
        = 256;
        = 384;
        = 512;
    }

    // ----------------------------------------------------------------------
    // Port definitions. Each port declares the payloads visible at the boundary.
    // ----------------------------------------------------------------------

    port def EnvironmentObservationPort {
        out road : RoadContext;
        out frames : SensorFrame [0..*];
    }
    port def VehicleObservationPort :> ~EnvironmentObservationPort;

    port def SensorDataPort {
        out frames : SensorFrame [0..*];
        out sensorHealth : DiagnosticReport;
    }
    port def SensorConsumerPort :> ~SensorDataPort;

    port def PerceptionProductPort {
        out objects : ObjectList;
        out localization : LocalizationState;
    }
    port def PerceptionConsumerPort :> ~PerceptionProductPort;

    port def MotionRequestPort {
        out command : MotionCommand;
        in status : ActuatorStatus;
    }
    port def MotionControlPort :> ~MotionRequestPort;

    port def ServiceBusPort {
        inout telemetry : VehicleTelemetry;
        inout diagnostics : DiagnosticReport;
        inout health : HealthEvent;
        inout updateBundle : UpdateBundle;
        inout policy : PolicyPackage;
        inout remoteCommand : RemoteCommand;
    }

    port def CloudVehiclePort {
        out updateManifest : UpdateManifest;
        out updateBundle : UpdateBundle;
        out policy : PolicyPackage;
        out remoteCommand : RemoteCommand;
        in telemetry : VehicleTelemetry;
        in diagnosticReport : DiagnosticReport;
        in installVerdict : InstallVerdict;
    }
    port def VehicleCloudPort :> ~CloudVehiclePort;

    port def DigitalKeyDevicePort {
        out credential : KeyCredential;
        in decision : AccessDecision;
        in notification : HmiNotification;
    }
    port def DigitalKeyVehiclePort :> ~DigitalKeyDevicePort;

    port def BodyCommandPort {
        out lockCommand : LockCommand;
        in doorStatus : DoorStatus [0..*];
    }
    port def DoorControllerPort :> ~BodyCommandPort;

    port def DriverHmiPort {
        out intent : DriverIntent;
        in notification : HmiNotification;
        in mode : DriveLevel;
    }
    port def VehicleHmiPort :> ~DriverHmiPort;

    port def ChargingStationPort {
        out command : ChargeCommand;
        out energyRequest : EnergyRequest;
        in status : ChargeStatus;
        in telemetry : VehicleTelemetry;
    }
    port def VehicleChargePort :> ~ChargingStationPort;

    port def V2XRoadsidePort {
        out v2xMessage : V2XMessage;
        in telemetry : VehicleTelemetry;
    }
    port def VehicleV2XPort :> ~V2XRoadsidePort;

    port def EmergencyDispatchPort {
        in alert : EmergencyAlert;
        out minimalRiskCommand : MinimalRiskCommand;
    }
    port def VehicleEmergencyPort :> ~EmergencyDispatchPort;

    port def DiagnosticsToolPort {
        out request : DiagnosticRequest;
        in report : DiagnosticReport;
    }
    port def VehicleDiagnosticsPort :> ~DiagnosticsToolPort;

    // ----------------------------------------------------------------------
    // Interface definitions. These are the contracts between parts.
    // ----------------------------------------------------------------------

    interface def EnvironmentSensing {
        end environment : EnvironmentObservationPort;
        end vehicle : VehicleObservationPort;
        flow roadContext : RoadContext from environment.road to vehicle.road;
        flow rawFrames : SensorFrame [0..*] from environment.frames to vehicle.frames;
    }

    interface def SensorToPerception {
        end sensors : SensorDataPort;
        end perception : SensorConsumerPort;
        flow sensorFrames : SensorFrame [0..*] from sensors.frames to perception.frames;
        flow sensorHealth : DiagnosticReport from sensors.sensorHealth to perception.sensorHealth;
    }

    interface def PerceptionToPlanner {
        end perception : PerceptionProductPort;
        end planner : PerceptionConsumerPort;
        flow objects : ObjectList from perception.objects to planner.objects;
        flow localization : LocalizationState from perception.localization to planner.localization;
    }

    interface def PlannerToMotionController {
        end planner : MotionRequestPort;
        end controller : MotionControlPort;
        flow command : MotionCommand from planner.command to controller.command;
        flow status : ActuatorStatus from controller.status to planner.status;
    }

    interface def CloudOperations {
        end cloud : CloudVehiclePort;
        end vehicle : VehicleCloudPort;
        flow manifest : UpdateManifest from cloud.updateManifest to vehicle.updateManifest;
        flow bundle : UpdateBundle from cloud.updateBundle to vehicle.updateBundle;
        flow policy : PolicyPackage from cloud.policy to vehicle.policy;
        flow command : RemoteCommand from cloud.remoteCommand to vehicle.remoteCommand;
        flow telemetry : VehicleTelemetry from vehicle.telemetry to cloud.telemetry;
        flow diagnostics : DiagnosticReport from vehicle.diagnosticReport to cloud.diagnosticReport;
        flow verdict : InstallVerdict from vehicle.installVerdict to cloud.installVerdict;
    }

    interface def DigitalKeySession {
        end device : DigitalKeyDevicePort;
        end vehicle : DigitalKeyVehiclePort;
        flow credential : KeyCredential from device.credential to vehicle.credential;
        flow decision : AccessDecision from vehicle.decision to device.decision;
        flow notification : HmiNotification from vehicle.notification to device.notification;
    }

    interface def BodyAccessControl {
        end controller : BodyCommandPort;
        end door : DoorControllerPort;
        flow lockRequest : LockCommand from controller.lockCommand to door.lockCommand;
        flow doorState : DoorStatus from door.doorStatus to controller.doorStatus;
    }

    interface def DriverInteraction {
        end driver : DriverHmiPort;
        end cockpit : VehicleHmiPort;
        flow intent : DriverIntent from driver.intent to cockpit.intent;
        flow notification : HmiNotification from cockpit.notification to driver.notification;
        flow mode : DriveLevel from cockpit.mode to driver.mode;
    }

    interface def ChargingSession {
        end station : ChargingStationPort;
        end vehicle : VehicleChargePort;
        flow command : ChargeCommand from station.command to vehicle.command;
        flow energyRequest : EnergyRequest from station.energyRequest to vehicle.energyRequest;
        flow status : ChargeStatus from vehicle.status to station.status;
        flow telemetry : VehicleTelemetry from vehicle.telemetry to station.telemetry;
    }

    interface def EmergencyAssistance {
        end vehicle : VehicleEmergencyPort;
        end responder : EmergencyDispatchPort;
        flow alert : EmergencyAlert from vehicle.alert to responder.alert;
        flow fallbackCommand : MinimalRiskCommand from responder.minimalRiskCommand to vehicle.minimalRiskCommand;
    }

    interface def DiagnosticsSession {
        end tool : DiagnosticsToolPort;
        end vehicle : VehicleDiagnosticsPort;
        flow request : DiagnosticRequest from tool.request to vehicle.request;
        flow report : DiagnosticReport from vehicle.report to tool.report;
    }

    interface def V2XRoadLink {
        end roadside : V2XRoadsidePort;
        end vehicle : VehicleV2XPort;
        flow v2xPacket : V2XMessage from roadside.v2xMessage to vehicle.v2xMessage;
        flow telemetry : VehicleTelemetry from vehicle.telemetry to roadside.telemetry;
    }

    connection def SecureChannel {
        end source : ServiceBusPort;
        end sink : ServiceBusPort;
    }

    allocation def BehaviorToCompute {
        end behaviorEnd : AutonomousDrivingCycle;
        end compute : Ecu;
    }

    // ----------------------------------------------------------------------
    // External actors and infrastructure
    // ----------------------------------------------------------------------

    part def Driver {
        doc /* Human driver interacting through the cockpit and mobile key. */
        attribute name : String;
        port hmi : DriverHmiPort;
    }

    part def MobileDevice {
        doc /* Phone or watch holding a digital-key credential. */
        port keyWallet : DigitalKeyDevicePort;
    }

    part def FleetCloud {
        doc /* OEM/fleet backend for OTA, fleet diagnostics, and policy delivery. */
        port vehicleApi : CloudVehiclePort;
        port diagnosticTool : DiagnosticsToolPort;
    }

    part def ChargingDepot {
        doc /* AC/DC charging equipment and site energy controller. */
        port charger : ChargingStationPort;
    }

    part def RoadEnvironment {
        doc /* The physical environment seen by cameras, radar, lidar, and V2X. */
        port scene : EnvironmentObservationPort;
        port roadsideUnit : V2XRoadsidePort;
    }

    part def EmergencyResponder {
        doc /* Public-safety or fleet operations center receiving fallback alerts. */
        port dispatch : EmergencyDispatchPort;
    }

    // ----------------------------------------------------------------------
    // Vehicle subsystem definitions
    // ----------------------------------------------------------------------

    abstract part def Ecu {
        attribute computePower : Real;
        port serviceBus : ServiceBusPort;
    }

    part def SensorSuite {
        doc /* Cameras, radar, lidar, and ultrasonic sensors plus local health checks. */
        port environment : VehicleObservationPort;
        out port frames : SensorDataPort;
    }

    part def PerceptionStack :> Ecu {
        doc /* Fuses sensor frames into tracked objects and localization estimates. */
        port sensorInput : SensorConsumerPort;
        port sceneOut : PerceptionProductPort;
    }

    part def AutonomyPlanner :> Ecu {
        doc /* Plans trajectories and asks the motion layer to execute them. */
        port sceneIn : PerceptionConsumerPort;
        port motion : MotionRequestPort;
        port fallback : VehicleEmergencyPort;
    }

    part def MotionController :> Ecu {
        doc /* Chassis and powertrain command arbitration. */
        port commandIn : MotionControlPort;
    }

    part def BatteryManagementSystem :> Ecu {
        doc /* Tracks energy, charge limits, and battery health. */
        port charge : VehicleChargePort;
    }

    part def ChargingController :> Ecu {
        doc /* Mediates depot charging, BMS limits, and user-visible charging state. */
        port station : VehicleChargePort;
        port battery : ChargingStationPort;
    }

    part def ConnectivityGateway :> Ecu {
        doc /* Telematics, V2X radio, secure cloud tunnel, and fleet diagnostics ingress. */
        port cloud : VehicleCloudPort;
        port diagnostics : VehicleDiagnosticsPort;
        port v2x : VehicleV2XPort;
    }

    part def CybersecurityGateway :> Ecu {
        doc /* Authenticates update bundles, remote commands, and digital-key sessions. */
        @CyberCritical {
            threatClass = "remote-entry";
        }
        port serviceIngress : ServiceBusPort;
        attribute signatureBits : Real = 384.0;
        private ref #CyberCritical remoteCommandChannel : RemoteCommand;
    }

    part def OtaUpdateManager :> Ecu {
        doc /* Downloads, verifies, installs, and rolls back software bundles. */
        port cloud : VehicleCloudPort;
        attribute updateState : UpdateState;
        attribute installedVersion : String;
    }

    part def DigitalKeyManager :> Ecu {
        doc /* Validates phone credentials and turns access decisions into body commands. */
        port phone : DigitalKeyVehiclePort;
        port body : BodyCommandPort;
    }

    part def BodyDomainController :> Ecu {
        doc /* Owns doors, locks, lighting, mirrors, and access feedback. */
        port keyCommands : DoorControllerPort;
        port doorCommands : BodyCommandPort;
    }

    part def DoorController :> Ecu {
        doc /* Local door actuator and latch sensor. */
        port body : DoorControllerPort;
        attribute latchState : LockState;
    }

    part def CockpitHmi :> Ecu {
        doc /* Driver displays, notifications, and mode requests. */
        port driver : VehicleHmiPort;
    }

    part def DiagnosticsAgent :> Ecu {
        doc /* Aggregates health events and produces service/fleet diagnostics. */
        port tool : VehicleDiagnosticsPort;
    }

    part def DataRecorder :> Ecu {
        doc /* Stores event data, model inputs, and safety evidence for audit. */
        attribute retentionDays : Real = 90.0;
    }

    part def SafetySupervisor :> Ecu {
        doc /* Monitors degraded operation and coordinates minimal-risk maneuvers. */
        port emergency : VehicleEmergencyPort;
        port plannerFallback : EmergencyDispatchPort;
    }

    // Variability: the same electrical/electronic architecture ships with
    // different autonomy packages.
    variation part def AutonomyPackage {
        variant part highwayAssist : AutonomyPlanner;
        variant part urbanPilot : AutonomyPlanner;
        variant part valetParking : AutonomyPlanner;
        connect urbanPilot.motion to highwayAssist.motion;
    }

    // ----------------------------------------------------------------------
    // Vehicle composition and internal/external boundary ports
    // ----------------------------------------------------------------------

    part def Vehicle {
        @SafetyCritical {
            asil = "D";
        }

        attribute vin : String;
        attribute curbMass : MassValue;
        attribute range : RangeEstimate;
        derived attribute online : Boolean = vin != "";
        attribute maxDeceleration : Real = 8.5 ['m/s²'];
        attribute regenBrakingFraction : Real = .35;

        port cloud : VehicleCloudPort;
        port digitalKey : DigitalKeyVehiclePort;
        port driverHmi : VehicleHmiPort;
        port charging : VehicleChargePort;
        port environment : VehicleObservationPort;
        port roadside : VehicleV2XPort;
        port emergency : VehicleEmergencyPort;
        port diagnosticAccess : VehicleDiagnosticsPort;

        part sensors : SensorSuite {
            satisfy objectDetectionRange;                  // PR-06
        }
        part perception : PerceptionStack {
            attribute :>> computePower = 48.0;
            satisfy perceptionFrameRate;                   // PR-02
            satisfy localizationAccuracy;                  // PR-05
        }
        part planner : AutonomyPlanner {
            attribute :>> computePower = 196.0;
            satisfy laneKeeping;                           // FR-03
            satisfy adaptiveDistanceKeeping;               // FR-04
            satisfy plannerCompute;                        // PR-03
            satisfy uneceR157Alks;                         // REG-04
        }
        part motion : MotionController {
            attribute :>> computePower = 64.0;
            satisfy automaticEmergencyBraking;             // FR-05
            satisfy sensorToActuatorLatency;               // PR-04
            satisfy brakeRedundancy;                       // SAF-04
            satisfy steeringSafeState;                     // SAF-07
        }
        part battery : BatteryManagementSystem {
            attribute :>> computePower = 24.0;
            satisfy batteryThermalContainment;             // SAF-08
            satisfy wltpRange;                             // REG-10
        }
        part chargingController : ChargingController {
            attribute :>> computePower = 32.0;
            satisfy DriverVisibleCharging;                 // R-5
            satisfy smartCharging;                         // FR-07
        }
        part connectivity : ConnectivityGateway {
            attribute :>> computePower = 48.0;
            satisfy telemetryPublishing;                   // FR-09
            satisfy v2xHazardReception;                    // FR-11
            satisfy bootToReady;                           // PR-08
            satisfy telemetryInterval;                     // PR-09
            satisfy otaDownloadThroughput;                 // PR-10
            satisfy encryptedCloudTunnel;                  // SEC-04
            satisfy gdprTelemetry;                         // REG-05
            satisfy unR10Emc;                              // REG-06
            satisfy ecallMandate;                          // REG-08
        }
        part security : CybersecurityGateway {
            attribute :>> computePower = 64.0;
            satisfy SecureUpdates;                         // R-1
            satisfy signedUpdates;                         // SEC-01
            satisfy digitalKeyAuthentication;              // SEC-02
            satisfy verifiedBoot;                          // SEC-03
            satisfy intrusionDetection;                    // SEC-05
            satisfy replayProtection;                      // SEC-07
            satisfy secureCredentialStorage;               // SEC-08
            satisfy v2xMessageAuthentication;              // SEC-09
            satisfy uneceR155;                             // REG-01
            satisfy iso21434Process;                       // REG-09
        }
        part ota : OtaUpdateManager {
            attribute :>> computePower = 32.0;
            satisfy VerifiedInstallation;                  // R-2
            satisfy overTheAirUpdate;                      // FR-06
            satisfy uneceR156;                             // REG-02
        }
        part keyManager : DigitalKeyManager {
            attribute :>> computePower = 24.0;
            satisfy phoneAsKeyUnlock;                      // FR-01
            satisfy remoteLockUnlock;                      // FR-02
            satisfy keyRevocation;                         // SEC-06
        }
        part body : BodyDomainController {
            attribute :>> computePower = 36.0;
            satisfy CentralLocking;                        // R-3
            satisfy doorLatchFeedback;                     // FR-10
            satisfy lockLatency;                           // PR-01
            satisfy crashDoorRelease;                      // SAF-10
        }
        part doorsController : DoorController [4..5];
        part leftFrontDoor :> doorsController;
        part rightFrontDoor :> doorsController;
        part leftRearDoor :> doorsController;
        part rightRearDoor :> doorsController;
        part optionalHatch : DoorController [0..1] {
            attribute latchState : LockState = LockState::locked;
        }

        part cockpit : CockpitHmi {
            attribute :>> computePower = 24.0;
            satisfy driveModeSelection;                    // FR-08
            satisfy driverTakeoverRequest;                 // SAF-05
        }
        part diagnostics : DiagnosticsAgent {
            attribute :>> computePower = 16.0;
            not satisfy technicianWantsToolAccess; // STK-09 — not yet authenticated
        }
        part recorder : DataRecorder {
            attribute :>> computePower = 16.0;
            satisfy securityAuditLogging;                  // SEC-10
            satisfy eventDataRecorder;                     // REG-07
        }
        part supervisor : SafetySupervisor {
            attribute :>> computePower = 48.0;
            satisfy MinimalRiskManeuver;                   // R-4
            satisfy minimalRiskManeuver;                   // SAF-01
            satisfy degradedOnPerceptionLoss;              // SAF-02
            satisfy independentSupervisor;                 // SAF-03
            satisfy plannerWatchdog;                       // SAF-06
            satisfy crashEmergencyAlert;                   // SAF-09
            satisfy emergencyStopReaction;                 // PR-07
            satisfy iso26262;                              // REG-03
        }

        connect environment to sensors.environment;
        interface sensorBus : SensorToPerception connect (sensors.frames, perception.sensorInput);
        interface sceneBus : PerceptionToPlanner connect (perception.sceneOut, planner.sceneIn);
        interface motionBus : PlannerToMotionController connect (planner.motion, motion.commandIn);
        connect cloud to connectivity.cloud;
        connect diagnosticAccess to connectivity.diagnostics;
        connect roadside to connectivity.v2x;
        connect digitalKey to keyManager.phone;
        interface keyToBody : BodyAccessControl connect (keyManager.body, body.keyCommands);
        interface bodyToDoors : BodyAccessControl connect (body.doorCommands, doors.body);
        connect driverHmi to cockpit.driver;
        connect charging to chargingController.station;
        interface chargerToBattery : ChargingSession connect (chargingController.battery, battery.charge);
        connect emergency to supervisor.emergency;
        connect planner.fallback to supervisor.plannerFallback;

        connect (
            perception.serviceBus,
            planner.serviceBus,
            motion.serviceBus,
            battery.serviceBus,
            chargingController.serviceBus,
            connectivity.serviceBus,
            security.serviceBus,
            security.serviceIngress,
            ota.serviceBus,
            keyManager.serviceBus,
            body.serviceBus,
            cockpit.serviceBus,
            diagnostics.serviceBus,
            recorder.serviceBus,
            supervisor.serviceBus
        );

        connection otaSecureChannel : SecureChannel connect (ota.serviceBus ::> source, security.serviceIngress ::> sink);

        flow of UpdateBundle from connectivity.cloud to ota.cloud;
        flow of PolicyPackage from connectivity.cloud to security.serviceIngress;
        flow of DiagnosticReport from diagnostics.tool to connectivity.diagnostics;
        flow of VehicleTelemetry from recorder.serviceBus to connectivity.serviceBus;
        bind connectivity.cloud = cloud;

        allocate AutonomousDrivingCycle to planner;
        allocate InstallSignedOtaBundle to ota;
        allocate AuthorizeDigitalKey to keyManager;
        allocate ManageSmartCharging to chargingController;
        allocation behaviorToCompute : BehaviorToCompute allocate (behaviorEnd ::> AutonomousDrivingCycle, compute ::> planner);
        allocate SoftwareDefinedVehicle::AutonomousDrivingCycle.commandMotion to motion;

        assert constraint enoughCompute {
            planner.computePower >= 160.0
        }

        assert constraint updateSignatureStrength {
            security.signatureBits >= 256.0
        }

        exhibit state operatingMode {
            entry action publishMode;
            then if driverHmi.mode == DriveLevel::automated {
                action engageAutomationReadiness;
            }
            state parked;
            state ready;
            state autonomous;
            state charging;
            state degraded;
            state emergencyStop;
            transition wake first parked accept driverIntent : DriverIntent then ready;
            transition startAutomation first ready accept autonomyRequest : DriverIntent then autonomous;
            transition plugIn first ready accept charge : ChargeCommand then charging;
            transition degrade first autonomous accept health : HealthEvent then degraded;
            transition minimalRisk first degraded accept alert : EmergencyAlert then emergencyStop;
            transition recover first degraded accept remote : RemoteCommand then ready;
            transition shutdown first emergencyStop then done;
            transition Charged first charging then autonomous;
        }

        exhibit state accessMode {
            entry action refreshAccessPolicy;
            state unlocked;
            parallel state locked {
                state listeningForKey;
                state monitoringIntrusion;
            }
            state secured;
            transition lockAll first unlocked accept command : LockCommand then locked;
            transition unlockByCredential first locked accept credential : KeyCredential then unlocked;
            transition arm first locked then secured;
            transition wake first secured accept credential : KeyCredential then unlocked;
            transition retire first secured then done;
        }
        connect sensors.frames to perception.sensorInput;
    }

    // Top-level ecosystem context: everything the vehicle talks to.
    part def ConnectedVehicleEcosystem {
        part driver : Driver;
        part mobileDevice : MobileDevice;
        part fleetCloud : FleetCloud;
        part chargingDepot : ChargingDepot;
        part roadEnvironment : RoadEnvironment;
        part emergencyResponder : EmergencyResponder;
        part vehicle : Vehicle;

        interface cloudLink : CloudOperations connect (fleetCloud.vehicleApi, vehicle.cloud);
        interface keyLink : DigitalKeySession connect (mobileDevice.keyWallet, vehicle.digitalKey);
        interface driverLink : DriverInteraction connect (driver.hmi, vehicle.driverHmi);
        interface roadLink : EnvironmentSensing connect (roadEnvironment.scene, vehicle.environment);
        interface chargeLink : ChargingSession connect (chargingDepot.charger, vehicle.charging);
        interface emergencyLink : EmergencyAssistance connect (vehicle.emergency, emergencyResponder.dispatch);
        interface diagnosticLink : DiagnosticsSession connect (fleetCloud.diagnosticTool, vehicle.diagnosticAccess);
        interface v2xLink : V2XRoadLink connect (roadEnvironment.roadsideUnit, vehicle.roadside);
    }

    individual part def DemoFleetCar :> Vehicle;
    part demoCar : DemoFleetCar {
        timeslice ref atDelivery;
        snapshot ref afterFirstOta;
    }

    part demonstrationEcosystem : ConnectedVehicleEcosystem {
        doc /* The demonstration configuration. The responder's dispatch port is
             * refined with the two call-handling channels the operator works
             * through, so the Interconnection View has a nested port to draw. */
        part :>> emergencyResponder {
            port :>> dispatch {
                port voiceChannel : EmergencyDispatchPort;
                port dataChannel : EmergencyDispatchPort;
            }
        }
    }

    // ----------------------------------------------------------------------
    // Physical layout (Geometry View). A top-view floor plan of where the
    // sensors and compute modules sit on the vehicle. Coordinates are in
    // millimetres on a frame whose origin is the rear-axle centre:
    //   x  → longitudinal, rear (0) to front (~4800)
    //   y  → lateral, right (−) to left (+)
    //   sizeX / sizeY → the module's footprint along x / y (named to avoid
    //     shadowing the ISQBase::length/width quantity attributes, which are
    //     reachable here via the file's `ISQ::*`/`SI::*` wildcard imports)
    // Parts that omit a footprint (e.g. gpsAntenna) fall back to a default
    // size so they still appear on the frame.
    // ----------------------------------------------------------------------

    part def VehiclePhysicalLayout {
        doc /* Spatial arrangement of perception sensors and E/E compute modules
             * for the Geometry View. The battery pack is the large central
             * footprint; sensors ring the perimeter; ECUs cluster mid-chassis. */

        part batteryPack {
            attribute x : Real = 2300.0;
            attribute y : Real = 0.0;
            attribute sizeX : Real = 2200.0;
            attribute sizeY : Real = 1300.0;
        }

        part rearRadar {
            attribute x : Real = 200.0;
            attribute y : Real = 0.0;
            attribute sizeX : Real = 180.0;
            attribute sizeY : Real = 520.0;
        }
        part frontRadar {
            attribute x : Real = 4650.0;
            attribute y : Real = 0.0;
            attribute sizeX : Real = 180.0;
            attribute sizeY : Real = 520.0;
        }
        part frontCameraLeft {
            attribute x : Real = 4480.0;
            attribute y : Real = 360.0;
            attribute sizeX : Real = 120.0;
            attribute sizeY : Real = 120.0;
        }
        part frontCameraRight {
            attribute x : Real = 4480.0;
            attribute y : Real = -360.0;
            attribute sizeX : Real = 120.0;
            attribute sizeY : Real = 120.0;
        }
        part roofLidar {
            attribute x : Real = 2700.0;
            attribute y : Real = 0.0;
            attribute sizeX : Real = 300.0;
            attribute sizeY : Real = 300.0;
        }
        part leftMirrorCamera {
            attribute x : Real = 3550.0;
            attribute y : Real = 940.0;
            attribute sizeX : Real = 120.0;
            attribute sizeY : Real = 120.0;
        }
        part rightMirrorCamera {
            attribute x : Real = 3550.0;
            attribute y : Real = -940.0;
            attribute sizeX : Real = 120.0;
            attribute sizeY : Real = 120.0;
        }

        part perceptionEcu {
            attribute x : Real = 3850.0;
            attribute y : Real = 320.0;
            attribute sizeX : Real = 320.0;
            attribute sizeY : Real = 300.0;
        }
        part planningEcu {
            attribute x : Real = 3850.0;
            attribute y : Real = -320.0;
            attribute sizeX : Real = 320.0;
            attribute sizeY : Real = 300.0;
        }
        part connectivityModule {
            attribute x : Real = 1250.0;
            attribute y : Real = 520.0;
            attribute sizeX : Real = 280.0;
            attribute sizeY : Real = 260.0;
        }
        part bodyController {
            attribute x : Real = 1250.0;
            attribute y : Real = -520.0;
            attribute sizeX : Real = 280.0;
            attribute sizeY : Real = 260.0;
        }

        // No footprint declared — placed with the default size at the roofline.
        part gpsAntenna {
            attribute x : Real = 1900.0;
            attribute y : Real = 0.0;
        }
    }

    part vehicleLayout : VehiclePhysicalLayout;

    // ----------------------------------------------------------------------
    // 3D volume / packaging massing (Geometry View, isometric). Each part is
    // typed by a Geometry-library solid (Box, RightCircularCylinder, Sphere,
    // RightCircularCone, RightTriangularPrism), so the Geometry View draws the
    // actual shape. Dimensions redefine the library shape's own attributes
    // (`:>> length`, `:>> radius`, …); x/y/z give the centre position in metres
    // (x longitudinal, y lateral, z up — origin at the rear-axle ground centre).
    // ----------------------------------------------------------------------

    attribute def LugBoltPlacement {
        attribute index : Natural;
        attribute angle : Real;
    }

    part def LugBolt {
        attribute placementAngle : Real;
    }

    part def Wheel :> RightCircularCylinder {
        attribute :>> radius = 0.35 [m];
        attribute :>> height = 0.22 [m];
        attribute numberOfLugBolts : Natural = 5;
        attribute lugBoltPlacementRadius : Real = 0.18 [m];
        attribute lugBoltAngleStep : Real = 360/numberOfLugBolts ['°'];
        part lugBolts : LugBolt[1..numberOfLugBolts];
        assert constraint lugBoltsEvenlySpaced {
            (1..numberOfLugBolts)->forAll {
                in i : Natural;
                private attribute lbcf = lugBolts#(i).placementAngle;
                private attribute expected : LugBoltPlacement {
                    :>> index = i;
                    :>> angle = (i-1)*lugBoltAngleStep;
                }
                lbcf == expected.angle
            }
        }
    }

    part def VehicleVolumeLayout {
        doc /* Coarse 3D massing of the major vehicle volumes and roof sensors,
             * for packaging studies in the isometric Geometry View. */

        part batteryPack : Box {
            attribute :>> length = 2.4 [m];
            attribute :>> width = 1.4 [m];
            attribute :>> height = 0.18 [m];
            attribute x = 2.3 [m];
            attribute y = 0.0 [m];
            attribute z = 0.2 [m];
        }
        part cabinModule : Box {
            attribute :>> length = 1.9 [m];
            attribute :>> width = 1.5 [m];
            attribute :>> height = 1.0 [m];
            attribute x = 2.7 [m];
            attribute y = 0.0 [m];
            attribute z = 0.95 [m];
        }
        part frontComputeBox : Box {
            attribute :>> length = 0.5 [m];
            attribute :>> width = 0.6 [m];
            attribute :>> height = 0.3 [m];
            attribute x = 4.1 [m];
            attribute y = 0.0 [m];
            attribute z = 0.5 [m];
        }
        part roofSensorDrum : RightCircularCylinder {
            attribute :>> radius = 0.12 [m];
            attribute :>> height = 0.12 [m];
            attribute x = 2.7 [m];
            attribute y = 0.0 [m];
            attribute z = 1.55 [m];
        }
        part antennaDome : Sphere {
            attribute :>> radius = 0.09 [m];
            attribute x = 1.4 [m];
            attribute y = 0.0 [m];
            attribute z = 1.5 [m];
        }
        part noseSensor : RightCircularCone {
            attribute :>> radius = 0.12 [m];
            attribute :>> height = 0.3 [m];
            attribute x = 4.6 [m];
            attribute y = 0.0 [m];
            attribute z = 0.55 [m];
        }
        part rearSpoiler : RightTriangularPrism {
            attribute :>> length = 0.25 [m];
            attribute :>> width = 1.4 [m];
            attribute :>> height = 0.2 [m];
            attribute x = 0.3 [m];
            attribute y = 0.0 [m];
            attribute z = 1.1 [m];
        }
        part rearLeftWheel : Wheel {
            attribute x = 0.0 [m];
            attribute y = 0.8 [m];
            attribute z = 0.35 [m];
        }
        part rearRightWheel : Wheel {
            attribute x = 0.0 [m];
            attribute y = -0.8 [m];
            attribute z = 0.35 [m];
        }
        part frontLeftWheel : Wheel {
            attribute x = 2.8 [m];
            attribute y = 0.8 [m];
            attribute z = 0.35 [m];
        }
        part frontRightWheel : Wheel {
            attribute x = 2.8 [m];
            attribute y = -0.8 [m];
            attribute z = 0.35 [m];
        }
    }

    part vehicleVolume : VehicleVolumeLayout;

    alias Car for Vehicle;
    comment IntegrationNote about Vehicle
        /* The architecture keeps outside-facing protocols at the connectivity,
         * security, and HMI boundaries. Motion, body, charging, and diagnostics
         * are internal services that exchange typed payloads through explicit
         * ports instead of anonymous dependencies. */
    rep deploymentManifest language "yaml";

    // ----------------------------------------------------------------------
    // Behaviors: action flows with ordering, control nodes, and item flows
    // ----------------------------------------------------------------------

    action def AutonomousDrivingCycle {
        in requestedLevel : DriveLevel;
        action acquireSensorFrames;
        fork splitPerception;
        action fuseObjects;
        action localizeVehicle;
        join sceneReady;
        decide chooseOperatingMode;
        action planTrajectory;
        action enforceSafetyEnvelope;
        action commandMotion;
        action publishTelemetry;
        merge cycleDone;
        first acquireSensorFrames
        then splitPerception
        then fuseObjects
        then localizeVehicle
        then sceneReady
        then chooseOperatingMode
        then planTrajectory
        then enforceSafetyEnvelope
        then commandMotion
        then publishTelemetry
        then cycleDone
        then done;
        flow of SensorFrame from acquireSensorFrames to fuseObjects;
        flow of ObjectList from fuseObjects to planTrajectory;
        flow of LocalizationState from localizeVehicle to planTrajectory;
        flow of TrajectoryPlan from planTrajectory to enforceSafetyEnvelope;
        flow of MotionCommand from enforceSafetyEnvelope to commandMotion;
    }

    action def EmergencyManeuverCycle :> AutonomousDrivingCycle {
        perform AutonomousDrivingCycle::commandMotion redefines commandMotion;
    }

    action def InstallSignedOtaBundle {
        action receiveManifest;
        action downloadBundle;
        action verifySignature;
        decide signatureAccepted;
        action stageBundle;
        action activateOnRestart;
        action reportVerdict;
        merge updateComplete;
        first receiveManifest
            then downloadBundle
            then verifySignature
            then signatureAccepted
            then stageBundle
            then activateOnRestart
            then reportVerdict
            then updateComplete
            then done;
        flow of UpdateManifest from receiveManifest to downloadBundle;
        flow of UpdateBundle from downloadBundle to verifySignature;
    }

    action def AuthorizeDigitalKey {
        action receiveCredential;
        action verifyCredential;
        decide credentialAccepted;
        action requestUnlock;
        action publishAccessDecision;
        first receiveCredential
            then verifyCredential
            then credentialAccepted
            then requestUnlock
            then publishAccessDecision
            then done;
        flow of KeyCredential from receiveCredential to verifyCredential;
    }

    action def ManageSmartCharging {
        action negotiateSession;
        action requestEnergy;
        action applyBatteryLimits;
        action updateChargeStatus;
        action publishChargeTelemetry;
        first negotiateSession
            then requestEnergy
            then applyBatteryLimits
            then updateChargeStatus
            then publishChargeTelemetry
            then done;
        flow of EnergyRequest from requestEnergy to applyBatteryLimits;
        flow of ChargeStatus from updateChargeStatus to publishChargeTelemetry;
    }

    // Performer swimlanes: mobile device presents a credential, the key manager
    // authorizes it, and the body domain acts only after an access decision.
    part def DigitalKeySwimlanes {
        part phone : MobileDevice {
            action presentCredential;
            send KeyCredential() to keyManager;
        }
        part keyManager : DigitalKeyManager {
            accept credential : KeyCredential;
            action validatePolicy;
            send AccessDecision() to bodyController;
        }
        part bodyController : BodyDomainController {
            accept decision : AccessDecision;
            action driveDoorLocks;
            send DoorStatus() via keyCommands to keyManager;
            port :>> keyCommands {
                port latchChannel : DoorControllerPort;
                port statusChannel : DoorControllerPort;
            }
        }
    }

    // ----------------------------------------------------------------------
    // Sequences: ordered interactions between internals and external systems
    // ----------------------------------------------------------------------

    // Modelled as `occurrence def` interactions (OMG SysML v2 8.2.2.9 / the
    // Interaction Sequencing examples): each `ref part` is bound to a concrete
    // occurrence in demonstrationEcosystem. The references therefore select the
    // existing ecosystem participants; they do not declare duplicate subsystem
    // occurrences. Each `message` links two participant lifelines.
    occurrence def AutonomousDriveSequence {
        doc /* Environment and driver intent flow through sensing, perception,
             * planning, safety, motion, telemetry, and cloud reporting. */
        ref part driver = demonstrationEcosystem.driver;
        ref part environment = demonstrationEcosystem.roadEnvironment;
        ref part sensors = demonstrationEcosystem.vehicle.sensors;
        ref part perception = demonstrationEcosystem.vehicle.perception;
        ref part planner = demonstrationEcosystem.vehicle.planner;
        ref part supervisor = demonstrationEcosystem.vehicle.supervisor;
        ref part motion = demonstrationEcosystem.vehicle.motion;
        ref part recorder = demonstrationEcosystem.vehicle.recorder;
        ref part connectivity = demonstrationEcosystem.vehicle.connectivity;
        ref part cloud = demonstrationEcosystem.fleetCloud;

        message requestAutonomy of DriverIntent from driver to planner;
        message observeRoad of RoadContext from environment to sensors;
        message publishFrames of SensorFrame from sensors to perception;
        message publishObjects of ObjectList from perception to planner;
        message publishLocalization of LocalizationState from perception to planner;
        message checkEnvelope of TrajectoryPlan from planner to supervisor;
        message replyFallbackClear of MinimalRiskCommand from supervisor to planner;
        message commandMotion of MotionCommand from planner to motion;
        message replyActuatorStatus of ActuatorStatus from motion to planner;
        message recordEvidence of VehicleTelemetry from planner to recorder;
        message uplinkTelemetry of VehicleTelemetry from connectivity to cloud;
    }

    occurrence def OtaUpdateSequence {
        doc /* Cloud-originated update with manifest, bundle, security gate,
             * installation, telemetry, and user notification. */
        ref part cloud = demonstrationEcosystem.fleetCloud;
        ref part connectivity = demonstrationEcosystem.vehicle.connectivity;
        ref part security = demonstrationEcosystem.vehicle.security;
        ref part ota = demonstrationEcosystem.vehicle.ota;
        ref part diagnostics = demonstrationEcosystem.vehicle.diagnostics;
        ref part cockpit = demonstrationEcosystem.vehicle.cockpit;

        message offerManifest of UpdateManifest from cloud to connectivity;
        message forwardManifest of UpdateManifest from connectivity to ota;
        message requestBundle of UpdateManifest from ota to connectivity;
        message deliverBundle of UpdateBundle from connectivity to security;
        message replySignatureOk of InstallVerdict from security to ota;
        message stageBundle of UpdateBundle from ota to diagnostics;
        message notifyDriver of HmiNotification from ota to cockpit;
        message replyInstallVerdict of InstallVerdict from ota to cloud;
    }

    occurrence def DigitalKeyAccessSequence {
        doc /* Phone credential enters the vehicle, is authenticated, then becomes
             * a body-domain lock command with feedback to the driver. */
        ref part driver = demonstrationEcosystem.driver;
        ref part phone = demonstrationEcosystem.mobileDevice;
        ref part connectivity = demonstrationEcosystem.vehicle.connectivity;
        ref part security = demonstrationEcosystem.vehicle.security;
        ref part keyManager = demonstrationEcosystem.vehicle.keyManager;
        ref part body = demonstrationEcosystem.vehicle.body;
        ref part door = demonstrationEcosystem.vehicle.doorsController;
        ref part cockpit = demonstrationEcosystem.vehicle.cockpit;

        message presentCredential of KeyCredential from driver to phone;
        message transmitCredential of KeyCredential from phone to connectivity;
        message authenticate of KeyCredential from connectivity to security;
        message replyDecision of AccessDecision from security to keyManager;
        message issueUnlock of LockCommand from keyManager to body;
        message driveLatch of LockCommand from body to door;
        message replyDoorStatus of DoorStatus from door to body;
        message notifyAccess of HmiNotification from body to cockpit;
        message replyPhoneStatus of HmiNotification from cockpit to phone;
    }

    occurrence def SmartChargingSequence {
        doc /* Depot charging coordinates external power, BMS limits, cloud
             * telemetry, and user-visible status. */
        ref part depot = demonstrationEcosystem.chargingDepot;
        ref part chargingController = demonstrationEcosystem.vehicle.chargingController;
        ref part battery = demonstrationEcosystem.vehicle.battery;
        ref part connectivity = demonstrationEcosystem.vehicle.connectivity;
        ref part cloud = demonstrationEcosystem.fleetCloud;
        ref part cockpit = demonstrationEcosystem.vehicle.cockpit;

        message plugDetected of ChargeCommand from depot to chargingController;
        message requestEnergy of EnergyRequest from chargingController to battery;
        message replyChargeLimits of ChargeStatus from battery to chargingController;
        message commandDepot of ChargeCommand from chargingController to depot;
        message publishChargeStatus of ChargeStatus from chargingController to cockpit;
        message uplinkChargeTelemetry of VehicleTelemetry from connectivity to cloud;
    }

    occurrence def FaultAndEmergencySequence {
        doc /* A health event degrades automation, records evidence, warns the
             * driver, and escalates to external emergency assistance if needed. */
        ref part diagnostics = demonstrationEcosystem.vehicle.diagnostics;
        ref part planner = demonstrationEcosystem.vehicle.planner;
        ref part supervisor = demonstrationEcosystem.vehicle.supervisor;
        ref part motion = demonstrationEcosystem.vehicle.motion;
        ref part cockpit = demonstrationEcosystem.vehicle.cockpit;
        ref part recorder = demonstrationEcosystem.vehicle.recorder;
        ref part connectivity = demonstrationEcosystem.vehicle.connectivity;
        ref part responder = demonstrationEcosystem.emergencyResponder;

        message detectFault of HealthEvent from diagnostics to supervisor;
        message requestFallback of MinimalRiskCommand from supervisor to planner;
        message commandSafeStop of MotionCommand from planner to motion;
        message replyStopped of ActuatorStatus from motion to planner;
        message warnDriver of HmiNotification from supervisor to cockpit;
        message recordFault of DiagnosticReport from diagnostics to recorder;
        message sendEmergencyAlert of EmergencyAlert from connectivity to responder;
        message replyFallbackInstruction of MinimalRiskCommand from responder to supervisor;
    }

    // ----------------------------------------------------------------------
    // Stakeholders, concerns, viewpoints, and views
    // ----------------------------------------------------------------------

    concern def CyberSecurity {
        doc /* UNECE R155/R156: update, remote command, and key paths resist tampering. */
        stakeholder securityOfficer;
    }

    concern def FunctionalSafety {
        doc /* ISO 26262: degraded automation reaches a controlled minimal-risk state. */
        stakeholder safetyEngineer;
    }

    viewpoint def SafetyAndSecurityViewpoint {
        frame CyberSecurity;
        frame FunctionalSafety;
    }

    rendering def InterconnectionRendering;

    view def VehicleContextView :> SafetyAndSecurityViewpoint {
        expose ConnectedVehicleEcosystem;
        render InterconnectionRendering;
    }

    viewpoint def DataPrivacyViewpoint {
        frame concern dataPrivacy;
    }

    view def VehiclePrivacyView :> DataPrivacyViewpoint {
        expose ConnectedVehicleEcosystem;
        render InterconnectionRendering;
    }

    view def VehicleInternalInterconnectionView :> SafetyAndSecurityViewpoint {
        expose Vehicle;
        filter @SafetyCritical;
        render InterconnectionRendering;
    }

    view def VehicleSequenceView :> SafetyAndSecurityViewpoint {
        expose AutonomousDriveSequence;
        expose OtaUpdateSequence;
        expose DigitalKeyAccessSequence;
        expose SmartChargingSequence;
        expose FaultAndEmergencySequence;
    }

    rendering def GeometryRendering;

    view def VehicleLayoutView {
        expose VehiclePhysicalLayout;
        render GeometryRendering;
    }

    view def VehicleVolumeView {
        expose VehicleVolumeLayout;
        render GeometryRendering;
    }

    // ----------------------------------------------------------------------
    // Requirements and trace relationships
    // ----------------------------------------------------------------------

    requirement def <'R-1'> SecureUpdates {
        doc /* The vehicle shall install only authenticated update bundles. */
        subject vehicle : Vehicle;
        attribute minSignatureBits : Real = 256.0;
        assume constraint { vehicle.online == true }
        require constraint { minSignatureBits >= 256.0 }
        actor backendOperator;
        stakeholder fleetOwner;
        frame CyberSecurity;
    }

    requirement def <'R-2'> VerifiedInstallation {
        doc /* An installed bundle shall report a pass verdict before activation. */
        subject vehicle : Vehicle;
        require constraint { vehicle.ota.installedVersion != "" }
    }

    requirement def <'R-3'> CentralLocking {
        doc /* All doors shall lock within 300 ms of a single accepted lock command. */
        subject vehicle : Vehicle;
        attribute maxLatency : TimeValue = 0.3 [s];
        require constraint { maxLatency <= 0.3 [s] }

        // Decomposition is expressed with a nested requirement *usage*, not a
        // nested `requirement def`. A nested usage is a genuine subrequirement
        // of R-3 (it is part of what R-3 requires); a nested `def` would only
        // introduce a type whose name happens to be scoped under R-3, which is
        // the ambiguity to avoid. See the explanation accompanying this model.
        requirement <'R-3.1'> singleDoorFeedback {
            doc /* Each door shall report its latch status after a lock command. */
            subject door : DoorController;
            require constraint { /* door status is reported after the lock command */ }
        }
    }

    requirement def <'R-4'> MinimalRiskManeuver {
        doc /* A critical automation fault shall command a minimal-risk stop. */
        subject vehicle : Vehicle;
        require constraint { vehicle.supervisor.computePower >= 40.0 }
    }

    requirement def <'R-5'> DriverVisibleCharging {
        doc /* Charging state shall be visible to the driver and fleet backend latest after the defined latency. */
        subject vehicle : Vehicle;
        require constraint { vehicle.online == true }
        attribute maxLatency = 0.5 [s];
    }

    connection deriveInstall : Derivation connect SecureUpdates to VerifiedInstallation;
    connection lockCausation : Multicausation connect CentralLocking to MinimalRiskManeuver;

    // Requirement satisfaction is asserted by the responsible subsystem *inside*
    // the Vehicle definition (see each `part …` usage in `part def Vehicle`),
    // not by a throwaway Vehicle instance. Each `satisfy <req>;` sits in the part
    // that owns the behaviour, so the satisfying subject is that part itself.
    // The stakeholder requests (STK-*) are deliberately left unsatisfied here:
    // they are needs that are refined into the formal requirements above, not
    // claims met by a design element.

    // ----------------------------------------------------------------------
    // Requirement classification library
    //
    // A `requirement def` is used here as a REQUIREMENT TYPE: a reusable
    // template that fixes the attributes relevant to one class of requirement
    // and gives them sensible default values. Concrete requirements are
    // *usages* of these types (`requirement r : FunctionalRequirement { … }`)
    // and override only the defaults that differ for that requirement. The
    // shared management attributes and `subject` live on the abstract base
    // `ManagedRequirement` and are inherited by every type and every usage —
    // this is the legal SysML v2 "type a requirement, then redefine its
    // defaults at the point of use" pattern.
    // ----------------------------------------------------------------------

    // Controlled vocabularies for the requirement-management attributes.
    enum def RequirementPriority { low; medium; high; critical; }
    enum def RequirementStatus { proposed; analyzed; approved; implemented; verified; }
    enum def VerificationMethod { inspection; analysis; demonstration; test; }
    enum def AsilLevel { qm; asilA; asilB; asilC; asilD; }  // ISO 26262 integrity levels
    enum def SecurityAssuranceLevel { cal1; cal2; cal3; cal4; }  // ISO/SAE 21434 CAL

    abstract requirement def ManagedRequirement {
        doc /* Management attributes common to every requirement type. Concrete
             * requirement usages inherit these and redefine only what differs. */
        subject subjectVehicle : Vehicle;
        attribute reqId : String = "";
        attribute priority : RequirementPriority = RequirementPriority::medium;
        attribute status : RequirementStatus = RequirementStatus::proposed;
        attribute verificationMethod : VerificationMethod = VerificationMethod::test;
        attribute rationale : String = "";
    }

    requirement def FunctionalRequirement :> ManagedRequirement {
        doc /* A capability or behaviour the system shall provide. */
        subject :>> subjectVehicle : Vehicle;
        attribute :>> verificationMethod = VerificationMethod::demonstration;
        attribute functionalArea : String = "general";
    }

    requirement def PerformanceRequirement :> ManagedRequirement {
        doc /* A measurable quality-of-service threshold the system shall meet. */
        subject :>> subjectVehicle : Vehicle;
        attribute :>> priority = RequirementPriority::high;
        attribute metric : String = "";
        attribute threshold : Real = 0.0;
        attribute unit : String = "";
    }

    requirement def SecurityRequirement :> ManagedRequirement {
        doc /* A cybersecurity control the system shall enforce (UNECE R155 / ISO 21434). */
        subject :>> subjectVehicle : Vehicle;
        attribute :>> priority = RequirementPriority::high;
        attribute cyberAssuranceLevel : SecurityAssuranceLevel = SecurityAssuranceLevel::cal2;
        attribute threatType : String = "";
        attribute standardRef : String = "ISO/SAE 21434";
    }

    requirement def SafetyRequirement :> ManagedRequirement {
        doc /* A functional-safety constraint the system shall uphold (ISO 26262). */
        subject :>> subjectVehicle : Vehicle;
        attribute :>> priority = RequirementPriority::critical;
        attribute :>> verificationMethod = VerificationMethod::analysis;
        attribute asil : AsilLevel = AsilLevel::asilB;
        attribute safetyGoalRef : String = "";
        attribute standardRef : String = "ISO 26262";
    }

    requirement def Regulation :> ManagedRequirement {
        doc /* An externally mandated rule the system shall comply with for homologation. */
        subject :>> subjectVehicle : Vehicle;
        attribute :>> priority = RequirementPriority::critical;
        attribute :>> status = RequirementStatus::approved;
        attribute :>> verificationMethod = VerificationMethod::inspection;
        attribute regulationRef : String = "";
        attribute authority : String = "";
        attribute mandatory : Boolean = true;
    }

    requirement def StakeholderRequest :> ManagedRequirement {
        doc /* A raw need expressed by a stakeholder, later refined into formal requirements. */
        subject :>> subjectVehicle : Vehicle;
        attribute :>> verificationMethod = VerificationMethod::demonstration;
        attribute stakeholderRole : String = "";
        attribute needStatement : String = "";
    }

    // ----------------------------------------------------------------------
    // Typed requirement catalog
    //
    // The concrete requirements are grouped into six requirement *usages* that
    // act as folders (their nested requirement usages are subrequirements of
    // the folder). Each leaf requirement is a usage of one of the types above
    // and overrides only the defaults that differ. This is the natural place
    // for the usages: a requirement set scoped to the vehicle, with the type
    // supplying the management attributes and the usage supplying the specifics.
    // ----------------------------------------------------------------------

    requirement functionalRequirements {
        doc /* Capabilities the software-defined vehicle shall provide. */

        requirement <'FR-01'> phoneAsKeyUnlock : FunctionalRequirement {
            doc /* The vehicle shall unlock when presented a valid phone digital-key credential. */
            attribute :>> reqId = "FR-01";
            attribute :>> priority = RequirementPriority::high;
            attribute :>> functionalArea = "Access";
        }
        requirement <'FR-02'> remoteLockUnlock : FunctionalRequirement {
            doc /* The vehicle shall lock and unlock on an authenticated remote command from the fleet cloud. */
            attribute :>> reqId = "FR-02";
            attribute :>> functionalArea = "Access";
        }
        requirement <'FR-03'> laneKeeping : FunctionalRequirement {
            doc /* In highway-assist mode the vehicle shall keep its lane without driver steering input. */
            attribute :>> reqId = "FR-03";
            attribute :>> priority = RequirementPriority::high;
            attribute :>> functionalArea = "Automation";
        }
        requirement <'FR-04'> adaptiveDistanceKeeping : FunctionalRequirement {
            doc /* The vehicle shall maintain a configurable following distance to the lead vehicle. */
            attribute :>> reqId = "FR-04";
            attribute :>> functionalArea = "Automation";
        }
        requirement <'FR-05'> automaticEmergencyBraking : FunctionalRequirement {
            doc /* The vehicle shall brake autonomously when a collision is imminent. */
            attribute :>> reqId = "FR-05";
            attribute :>> priority = RequirementPriority::high;
            attribute :>> functionalArea = "Automation";
        }
        requirement <'FR-06'> overTheAirUpdate : FunctionalRequirement {
            doc /* The vehicle shall install software bundles delivered over the air. */
            attribute :>> reqId = "FR-06";
            attribute :>> functionalArea = "Lifecycle";
        }
        requirement <'FR-07'> smartCharging : FunctionalRequirement {
            doc /* The vehicle shall schedule charging against depot energy limits and battery state. */
            attribute :>> reqId = "FR-07";
            attribute :>> functionalArea = "Energy";
        }
        requirement <'FR-08'> driveModeSelection : FunctionalRequirement {
            doc /* The driver shall be able to select manual, assisted, automated, or fallback mode via the HMI. */
            attribute :>> reqId = "FR-08";
            attribute :>> functionalArea = "HMI";
        }
        requirement <'FR-09'> telemetryPublishing : FunctionalRequirement {
            doc /* The vehicle shall publish telemetry to the fleet backend while online. */
            attribute :>> reqId = "FR-09";
            attribute :>> functionalArea = "Connectivity";
        }
        requirement <'FR-10'> doorLatchFeedback : FunctionalRequirement {
            doc /* Each door shall report its latch status after every lock command. */
            attribute :>> reqId = "FR-10";
            attribute :>> functionalArea = "Body";
        }
        requirement <'FR-11'> v2xHazardReception : FunctionalRequirement {
            doc /* The vehicle shall receive and surface V2X hazard messages from roadside units. */
            attribute :>> reqId = "FR-11";
            attribute :>> functionalArea = "Connectivity";
        }
    }

    requirement performanceRequirements {
        doc /* Measurable thresholds the vehicle shall meet. */

        requirement <'PR-01'> lockLatency : PerformanceRequirement {
            doc /* All doors shall lock within 300 ms of an accepted lock command. */
            attribute :>> reqId = "PR-01";
            attribute :>> metric = "centralLockLatency";
            attribute :>> threshold = 0.3;
            attribute :>> unit = "s";
        }
        requirement <'PR-02'> perceptionFrameRate : PerformanceRequirement {
            doc /* The perception stack shall process sensor frames at no less than 30 Hz. */
            attribute :>> reqId = "PR-02";
            attribute :>> metric = "perceptionFrameRate";
            attribute :>> threshold = 30.0;
            attribute :>> unit = "Hz";
        }
        requirement <'PR-03'> plannerCompute : PerformanceRequirement {
            doc /* The autonomy planner shall provide at least 160 TOPS of compute. */
            attribute :>> reqId = "PR-03";
            attribute :>> metric = "plannerComputePower";
            attribute :>> threshold = 160.0;
            attribute :>> unit = "TOPS";
        }
        requirement <'PR-04'> sensorToActuatorLatency : PerformanceRequirement {
            doc /* End-to-end sensor-to-actuator latency shall not exceed 100 ms. */
            attribute :>> reqId = "PR-04";
            attribute :>> metric = "controlLoopLatency";
            attribute :>> threshold = 0.1;
            attribute :>> unit = "s";
        }
        requirement <'PR-05'> localizationAccuracy : PerformanceRequirement {
            doc /* Lateral localization error shall stay within 0.1 m. */
            attribute :>> reqId = "PR-05";
            attribute :>> metric = "localizationError";
            attribute :>> threshold = 0.1;
            attribute :>> unit = "m";
        }
        requirement <'PR-06'> objectDetectionRange : PerformanceRequirement {
            doc /* Forward object detection range shall be at least 200 m. */
            attribute :>> reqId = "PR-06";
            attribute :>> metric = "detectionRange";
            attribute :>> threshold = 200.0;
            attribute :>> unit = "m";
        }
        requirement <'PR-07'> emergencyStopReaction : PerformanceRequirement {
            doc /* A minimal-risk stop shall be commanded within 500 ms of a critical fault. */
            attribute :>> reqId = "PR-07";
            attribute :>> priority = RequirementPriority::critical;
            attribute :>> metric = "emergencyStopReaction";
            attribute :>> threshold = 0.5;
            attribute :>> unit = "s";
        }
        requirement <'PR-08'> bootToReady : PerformanceRequirement {
            doc /* The vehicle shall reach a driveable ready state within 2 s of wake-up. */
            attribute :>> reqId = "PR-08";
            attribute :>> metric = "bootToReadyTime";
            attribute :>> threshold = 2.0;
            attribute :>> unit = "s";
        }
        requirement <'PR-09'> telemetryInterval : PerformanceRequirement {
            doc /* Telemetry shall be uplinked at least once per second while online. */
            attribute :>> reqId = "PR-09";
            attribute :>> metric = "telemetryInterval";
            attribute :>> threshold = 1.0;
            attribute :>> unit = "s";
        }
        requirement <'PR-10'> otaDownloadThroughput : PerformanceRequirement {
            doc /* The connectivity gateway shall sustain at least 50 Mbit/s for update downloads. */
            attribute :>> reqId = "PR-10";
            attribute :>> metric = "otaDownloadThroughput";
            attribute :>> threshold = 50.0;
            attribute :>> unit = "Mbit/s";
        }
    }

    requirement securityRequirements {
        doc /* Cybersecurity controls the vehicle shall enforce. */

        requirement <'SEC-01'> signedUpdates : SecurityRequirement {
            doc /* The vehicle shall install only update bundles whose signature is at least 256-bit. */
            attribute :>> reqId = "SEC-01";
            attribute :>> cyberAssuranceLevel = SecurityAssuranceLevel::cal3;
            attribute :>> threatType = "tampering";
        }
        requirement <'SEC-02'> digitalKeyAuthentication : SecurityRequirement {
            doc /* Digital-key sessions shall be mutually authenticated before granting access. */
            attribute :>> reqId = "SEC-02";
            attribute :>> cyberAssuranceLevel = SecurityAssuranceLevel::cal3;
            attribute :>> threatType = "spoofing";
        }
        requirement <'SEC-03'> verifiedBoot : SecurityRequirement {
            doc /* Each ECU shall verify the integrity of its boot image before execution. */
            attribute :>> reqId = "SEC-03";
            attribute :>> threatType = "tampering";
        }
        requirement <'SEC-04'> encryptedCloudTunnel : SecurityRequirement {
            doc /* All cloud communication shall run over an authenticated, encrypted tunnel. */
            attribute :>> reqId = "SEC-04";
            attribute :>> threatType = "informationDisclosure";
        }
        requirement <'SEC-05'> intrusionDetection : SecurityRequirement {
            doc /* The service bus shall be monitored for anomalous or injected traffic. */
            attribute :>> reqId = "SEC-05";
            attribute :>> threatType = "tampering";
        }
        requirement <'SEC-06'> keyRevocation : SecurityRequirement {
            doc /* Compromised digital keys shall be revocable within one policy refresh cycle. */
            attribute :>> reqId = "SEC-06";
            attribute :>> threatType = "elevationOfPrivilege";
        }
        requirement <'SEC-07'> replayProtection : SecurityRequirement {
            doc /* Remote commands shall be protected against replay. */
            attribute :>> reqId = "SEC-07";
            attribute :>> threatType = "spoofing";
        }
        requirement <'SEC-08'> secureCredentialStorage : SecurityRequirement {
            doc /* Cryptographic keys shall be held in tamper-resistant hardware. */
            attribute :>> reqId = "SEC-08";
            attribute :>> cyberAssuranceLevel = SecurityAssuranceLevel::cal4;
            attribute :>> threatType = "informationDisclosure";
        }
        requirement <'SEC-09'> v2xMessageAuthentication : SecurityRequirement {
            doc /* Received V2X messages shall be authenticated before they influence behaviour. */
            attribute :>> reqId = "SEC-09";
            attribute :>> threatType = "spoofing";
        }
        requirement <'SEC-10'> securityAuditLogging : SecurityRequirement {
            doc /* Security-relevant events shall be logged for forensic audit. */
            attribute :>> reqId = "SEC-10";
            attribute :>> priority = RequirementPriority::medium;
            attribute :>> threatType = "repudiation";
        }
    }

    requirement safetyRequirements {
        doc /* Functional-safety constraints the vehicle shall uphold. */

        requirement <'SAF-01'> minimalRiskManeuver : SafetyRequirement {
            doc /* A critical automation fault shall bring the vehicle to a minimal-risk condition. */
            attribute :>> reqId = "SAF-01";
            attribute :>> asil = AsilLevel::asilD;
            attribute :>> safetyGoalRef = "SG-Automation-01";
        }
        requirement <'SAF-02'> degradedOnPerceptionLoss : SafetyRequirement {
            doc /* Loss of perception shall force a degraded driving mode. */
            attribute :>> reqId = "SAF-02";
            attribute :>> asil = AsilLevel::asilD;
            attribute :>> safetyGoalRef = "SG-Automation-02";
        }
        requirement <'SAF-03'> independentSupervisor : SafetyRequirement {
            doc /* An independent safety supervisor shall monitor the automation stack. */
            attribute :>> reqId = "SAF-03";
            attribute :>> asil = AsilLevel::asilD;
        }
        requirement <'SAF-04'> brakeRedundancy : SafetyRequirement {
            doc /* Braking shall remain available after a single brake-by-wire fault. */
            attribute :>> reqId = "SAF-04";
            attribute :>> asil = AsilLevel::asilD;
            attribute :>> safetyGoalRef = "SG-Chassis-01";
        }
        requirement <'SAF-05'> driverTakeoverRequest : SafetyRequirement {
            doc /* The system shall request driver takeover and act on timeout when leaving its ODD. */
            attribute :>> reqId = "SAF-05";
            attribute :>> asil = AsilLevel::asilC;
        }
        requirement <'SAF-06'> plannerWatchdog : SafetyRequirement {
            doc /* A watchdog shall detect a stalled trajectory planner and trigger fallback. */
            attribute :>> reqId = "SAF-06";
            attribute :>> asil = AsilLevel::asilC;
        }
        requirement <'SAF-07'> steeringSafeState : SafetyRequirement {
            doc /* A steering actuator fault shall lead to a defined safe state. */
            attribute :>> reqId = "SAF-07";
            attribute :>> asil = AsilLevel::asilD;
            attribute :>> safetyGoalRef = "SG-Chassis-02";
        }
        requirement <'SAF-08'> batteryThermalContainment : SafetyRequirement {
            doc /* The battery system shall contain a single-cell thermal runaway. */
            attribute :>> reqId = "SAF-08";
            attribute :>> asil = AsilLevel::asilC;
        }
        requirement <'SAF-09'> crashEmergencyAlert : SafetyRequirement {
            doc /* A detected crash shall raise an emergency alert to external responders. */
            attribute :>> reqId = "SAF-09";
            attribute :>> asil = AsilLevel::asilB;
        }
        requirement <'SAF-10'> crashDoorRelease : SafetyRequirement {
            doc /* Doors shall unlock for egress after a detected crash. */
            attribute :>> reqId = "SAF-10";
            attribute :>> asil = AsilLevel::asilC;
            attribute :>> safetyGoalRef = "SG-Body-01";
        }
    }

    requirement regulatoryRequirements {
        doc /* External regulations the vehicle shall comply with for type approval. */

        requirement <'REG-01'> uneceR155 : Regulation {
            doc /* The vehicle programme shall maintain a UNECE R155 cybersecurity management system. */
            attribute :>> reqId = "REG-01";
            attribute :>> regulationRef = "UNECE R155";
            attribute :>> authority = "UNECE WP.29";
        }
        requirement <'REG-02'> uneceR156 : Regulation {
            doc /* Software updates shall be managed per a UNECE R156 software-update management system. */
            attribute :>> reqId = "REG-02";
            attribute :>> regulationRef = "UNECE R156";
            attribute :>> authority = "UNECE WP.29";
        }
        requirement <'REG-03'> iso26262 : Regulation {
            doc /* Safety-related development shall conform to ISO 26262. */
            attribute :>> reqId = "REG-03";
            attribute :>> regulationRef = "ISO 26262";
            attribute :>> authority = "ISO";
        }
        requirement <'REG-04'> uneceR157Alks : Regulation {
            doc /* Automated lane keeping shall conform to UNECE R157. */
            attribute :>> reqId = "REG-04";
            attribute :>> regulationRef = "UNECE R157";
            attribute :>> authority = "UNECE WP.29";
        }
        requirement <'REG-05'> gdprTelemetry : Regulation {
            doc /* Personal data in telemetry shall be handled per GDPR. */
            attribute :>> reqId = "REG-05";
            attribute :>> regulationRef = "EU 2016/679";
            attribute :>> authority = "European Union";
        }
        requirement <'REG-06'> unR10Emc : Regulation {
            doc /* The vehicle shall meet UN R10 electromagnetic-compatibility limits. */
            attribute :>> reqId = "REG-06";
            attribute :>> regulationRef = "UNECE R10";
            attribute :>> authority = "UNECE WP.29";
        }
        requirement <'REG-07'> eventDataRecorder : Regulation {
            doc /* The vehicle shall provide an event data recorder per the applicable EDR regulation. */
            attribute :>> reqId = "REG-07";
            attribute :>> regulationRef = "EU 2019/2144";
            attribute :>> authority = "European Union";
        }
        requirement <'REG-08'> ecallMandate : Regulation {
            doc /* The vehicle shall provide an eCall emergency-call capability. */
            attribute :>> reqId = "REG-08";
            attribute :>> regulationRef = "EU 2015/758";
            attribute :>> authority = "European Union";
        }
        requirement <'REG-09'> iso21434Process : Regulation {
            doc /* Cybersecurity engineering shall conform to ISO/SAE 21434. */
            attribute :>> reqId = "REG-09";
            attribute :>> regulationRef = "ISO/SAE 21434";
            attribute :>> authority = "ISO / SAE";
        }
        requirement <'REG-10'> wltpRange : Regulation {
            doc /* Declared electric range shall be measured per the WLTP procedure. */
            attribute :>> reqId = "REG-10";
            attribute :>> regulationRef = "UNECE GTR 15";
            attribute :>> authority = "UNECE WP.29";
        }
    }

    requirement stakeholderRequests {
        doc /* Raw stakeholder needs, refined into the formal requirements above. */

        requirement <'STK-01'> driverWantsPhoneKey : StakeholderRequest {
            doc /* As a driver I want to use my phone as the car key so I never carry a fob. */
            attribute :>> reqId = "STK-01";
            attribute :>> stakeholderRole = "Driver";
            attribute :>> needStatement = "Phone-as-key access";
        }
        requirement <'STK-02'> fleetWantsRemoteDiagnostics : StakeholderRequest {
            doc /* As a fleet owner I want remote diagnostics so I can triage faults without a visit. */
            attribute :>> reqId = "STK-02";
            attribute :>> stakeholderRole = "FleetOwner";
            attribute :>> needStatement = "Remote diagnostics";
        }
        requirement <'STK-03'> fleetWantsOtaWithoutVisit : StakeholderRequest {
            doc /* As a fleet owner I want software fixes delivered over the air to avoid service visits. */
            attribute :>> reqId = "STK-03";
            attribute :>> stakeholderRole = "FleetOwner";
            attribute :>> needStatement = "Service-free updates";
        }
        requirement <'STK-04'> driverWantsChargingVisibility : StakeholderRequest {
            doc /* As a driver I want clear charging status so I can plan around charging. */
            attribute :>> reqId = "STK-04";
            attribute :>> stakeholderRole = "Driver";
            attribute :>> needStatement = "Visible charging state";
        }
        requirement <'STK-05'> safetyWantsAuditEvidence : StakeholderRequest {
            doc /* As a safety officer I want retained event evidence to support safety audits. */
            attribute :>> reqId = "STK-05";
            attribute :>> stakeholderRole = "SafetyOfficer";
            attribute :>> needStatement = "Audit evidence retention";
        }
        requirement <'STK-06'> securityWantsTamperResistance : StakeholderRequest {
            doc /* As a security officer I want tamper-resistant key handling to deter theft. */
            attribute :>> reqId = "STK-06";
            attribute :>> stakeholderRole = "SecurityOfficer";
            attribute :>> needStatement = "Tamper resistance";
        }
        requirement <'STK-07'> regulatorWantsTraceability : StakeholderRequest {
            doc /* As a regulator I want requirement-to-evidence traceability for homologation. */
            attribute :>> reqId = "STK-07";
            attribute :>> stakeholderRole = "Regulator";
            attribute :>> needStatement = "Compliance traceability";
        }
        requirement <'STK-08'> driverWantsResponsiveHmi : StakeholderRequest {
            doc /* As a driver I want a fast-booting, responsive cockpit. */
            attribute :>> reqId = "STK-08";
            attribute :>> stakeholderRole = "Driver";
            attribute :>> needStatement = "Responsive HMI";
        }
        requirement <'STK-09'> technicianWantsToolAccess : StakeholderRequest {
            doc /* As a service technician I want authenticated diagnostic-tool access. */
            attribute :>> reqId = "STK-09";
            attribute :>> stakeholderRole = "ServiceTechnician";
            attribute :>> needStatement = "Diagnostic tool access";
        }
        requirement <'STK-10'> oemWantsVariantPackaging : StakeholderRequest {
            doc /* As the OEM I want the same E/E architecture to ship multiple autonomy packages. */
            attribute :>> reqId = "STK-10";
            attribute :>> stakeholderRole = "OEM";
            attribute :>> needStatement = "Variant packaging";
        }
    }

    // ----------------------------------------------------------------------
    // Cases: user-facing behavior, analysis, and verification
    // ----------------------------------------------------------------------

    use case def UnlockWithPhone {
        subject vehicle : Vehicle;
        actor driver : Driver;
        objective grantAccess;
        include AuthenticateKey;
    }

    use case def AuthenticateKey {
        subject vehicle : Vehicle;
        actor phone : MobileDevice;
    }

    use case def ExpressUnlock :> UnlockWithPhone {
        subject vehicle : Vehicle;
    }

    use case def DriveWithAutomation {
        subject vehicle : Vehicle;
        actor driver : Driver;
        objective maintainLaneAndDistance;
    }

    use case def InstallFleetUpdate {
        subject vehicle : Vehicle;
        actor backend : FleetCloud;
        objective updateVehicleSoftware;
    }

    analysis def RangeImpactOfCompute {
        subject vehicle : Vehicle;
        objective quantifyDrain;
        action sampleConsumption;
        action estimateComputeLoad;
        action extrapolateRange;
        first sampleConsumption
            then estimateComputeLoad
            then extrapolateRange;
    }

    verification def VerifySecureUpdates {
        subject vehicle : Vehicle;
        objective checkSignatures {
            verify SecureUpdates;
        }
        return outcome : Boolean;
        action flashUnsignedBundle;
        action observeRejection;
        action flashSignedBundle;
        action observeActivation;
        first flashUnsignedBundle
            then observeRejection
            then flashSignedBundle
            then observeActivation;
    }

    verification def VerifyFallbackBehavior {
        subject vehicle : Vehicle;
        objective checkMinimalRisk {
            verify MinimalRiskManeuver;
        }
        return outcome : Boolean;
        action injectPlannerFault;
        action observeFallbackCommand;
        action observeSafeStop;
        first injectPlannerFault
            then observeFallbackCommand
            then observeSafeStop;
    }

    use case unlockWithPhone : UnlockWithPhone;
    use case authenticateKey : AuthenticateKey;
    use case expressUnlock : ExpressUnlock;
    use case driveWithAutomation : DriveWithAutomation;
    use case installFleetUpdate : InstallFleetUpdate;
    analysis rangeImpact : RangeImpactOfCompute;
    verification verifySecureUpdates : VerifySecureUpdates;
    verification verifyFallbackBehavior : VerifyFallbackBehavior;
    transition first locked then degraded;

    // ----------------------------------------------------------------------
    // Shared platform library (library package, alias, namespace, dependency)
    // ----------------------------------------------------------------------

    package SoftwarePlatform {
        doc /* Reusable platform vocabulary and the project-level dependency on it. */

        private import ISQ::*;
        private import ScalarValues::*;
        private import SI::*;


        library package VehiclePlatformLibrary {
            doc /* Reusable platform vocabulary. A `library package` marks content that
                 * is shared across projects rather than owned by this vehicle model. */

            attribute def PlatformRevision {
                attribute major : Integer;
                attribute minor : Integer;
            }

            part def ComputePlatform {
                attribute revision : PlatformRevision;
                attribute coreCount : Integer;
            }
        }

        alias Platform for VehiclePlatformLibrary::ComputePlatform;

        namespace DiagnosticVocabulary {
            doc /* A bare namespace groups names without asserting that they are a
                 * package of deliverable content. */

            attribute def TroubleCode {
                attribute code : String;
                attribute description : String;
            }

            attribute def FreezeFrame {
                attribute code : TroubleCode;
                attribute odometerReading : LengthValue;
            }
        }

        dependency platformDependency from SoftwareDefinedVehicleAdditions to VehiclePlatformLibrary;
    }

    // ----------------------------------------------------------------------
    // Software lifecycle state machine (states, regions, transitions)
    // ----------------------------------------------------------------------

    package SoftwareLifecycle {
        doc /* The state machine an installed software bundle moves through. */

        private import ISQ::*;
        private import ScalarValues::*;
        private import SI::*;


        item def UpdatePackage {
            attribute bundleSize : Integer;
            attribute signatureValid : Boolean;
        }

        item def OperatorConsent;

        action def PrepareStaging;
        action def VerifySignature;
        action def ApplyBundle;
        action def RollBackBundle;
        action def ReportOutcome;

        state def SoftwareLifecycle {
            doc /* Lifecycle of an installed software bundle, from staged download to
                 * either an activated release or a rollback. */

            entry; then staged;

            state staged {
                entry action beginStaging : PrepareStaging;
                do action holdForConsent;
                exit action closeStaging;
            }

            state verifying {
                do action checkSignature : VerifySignature;
                exit action recordVerdict;
            }

            state applying {
                entry action startApply : ApplyBundle;
                do action monitorApply;
            }

            state active {
                do action serveTraffic;
                exit action drainTraffic;
            }

            state rolledBack {
                entry action restorePrevious : RollBackBundle;
                do action reportRollback : ReportOutcome;
            }

            transition stagedToVerifying
                first staged
                accept consent : OperatorConsent
                then verifying;

            transition verifyingToApplying
                first verifying
                if true
                then applying;

            transition verifyingToRolledBack
                first verifying
                do action noteBadSignature
                then rolledBack;

            transition applyingToActive
                first applying
                accept bundle : UpdatePackage
                if true
                do action commitBundle
                then active;

            transition applyingToRolledBack first applying then rolledBack;
        }

        part def UpdateAgent {
            attribute agentIdentifier : String;
            exhibit state lifecycle : SoftwareLifecycle;
        }
    }

    // ----------------------------------------------------------------------
    // Campaign behaviour (control nodes, action language, loops)
    // ----------------------------------------------------------------------

    package UpdateCampaigns {
        doc /* Fleet-wide rollout behaviour, written in the full action language. */

        private import ISQ::*;
        private import ScalarValues::*;
        private import SI::*;


        item def CampaignReport;

        action def RunUpdateCampaign {
            doc /* The full action-language surface: fork/join concurrency, a decision
                 * with an else branch, assignment, send/accept, loops, and terminate. */

            in item bundle : UpdatePackage;
            out item report : CampaignReport;

            attribute attemptCount : Integer = 0;
            attribute maximumAttempts : Integer = 3;

            action openCampaign;

            then fork distribute;
                then action notifyFleet;
                then action stageBundle;

            join regroup;

            then action measureFleetReadiness {
                out attribute readyFraction : Real;
            }

            action proceedWithRollout;
            action deferRollout;

            decide readinessGate;
                if measureFleetReadiness.readyFraction >= 0.8 then proceedWithRollout;
                else deferRollout;

            merge campaignResumed;

            then assign attemptCount := attemptCount + 1;

            then action requestConsent {
                send OperatorConsent() to fleetOperator;
            }

            then action awaitConsent {
                accept granted : OperatorConsent;
            }

            loop action retryFailedNodes {
                action selectFailedNode;
                then action reapplyBundle;
            } until attemptCount >= maximumAttempts;

            for regionIndex in 1..3 {
                action rolloutRegion;
                then action confirmRegion;
            }

            then if attemptCount >= maximumAttempts {
                action escalateToOperations;
                then action haltCampaign {
                    action recordHalt;
                    then terminate;
                }
            }

            while attemptCount < maximumAttempts {
                action pollNodeStatus;
                then action recordNodeStatus;
            }

            then action closeCampaign;
            then done;

            ref part fleetOperator : UpdateAgent;
            succession deferRollout then campaignResumed;
            succession proceedWithRollout then regroup;
        }
    }

    // ----------------------------------------------------------------------
    // Connection, binding, and flow forms
    // ----------------------------------------------------------------------

    package PowerDistribution {
        doc /* The electrical and thermal assembly, and every connector form. */

        private import ISQ::*;
        private import ScalarValues::*;
        private import SI::*;


        item def PowerDraw;
        item def ThermalLoad;

        port def PowerOutlet {
            out item supplied : PowerDraw;
        }

        port def ThermalPort {
            out item shed : ThermalLoad;
        }

        part def PowerSource {
            port outlet : PowerOutlet;
            attribute ratedDraw : Real;
        }

        part def PowerConsumer {
            port inlet : ~PowerOutlet;
            port radiator : ThermalPort;
            attribute demandedDraw : Real;
        }

        connection def PowerRail {
            end source : PowerSource;
            end sink : PowerConsumer;
        }

        interface def PowerInterface {
            end provider : PowerOutlet;
            end consumer : ~PowerOutlet;
        }

        allocation def ThermalAllocation {
            end logicalLoad : PowerConsumer;
            end coolingPath : PowerConsumer;
        }

        flow def PowerStream {
            end origin : PowerOutlet;
            end destination : ~PowerOutlet;
        }

        part def PowerDistributionAssembly {
            doc /* Every connector form the notation offers, on one assembly: an inline
                 * connect, typed connection/interface/allocation usages, binding in its
                 * three spellings, item flows, a message, and successions. */

            part battery : PowerSource;
            part computer : PowerConsumer;
            part radiatorLoop : PowerConsumer;
            attribute assemblyDraw : Real;

            connect battery.outlet to computer.inlet;

            connection mainRail : PowerRail connect battery to computer;

            interface computeSupply : PowerInterface connect battery.outlet to computer.inlet;

            allocate computer to radiatorLoop;

            allocation coolingAllocation : ThermalAllocation allocate computer to radiatorLoop;

            binding drawBinding bind battery.ratedDraw = computer.demandedDraw;

            bind assemblyDraw = battery.ratedDraw;

            binding [0..1] assemblyDraw = [0..1] computer.demandedDraw;

            flow battery.outlet to computer.inlet;

            flow def PowerStreamUsageHost;

            message powerAdvisory of PowerDraw from battery to computer;

            succession first battery then computer;

            succession flow battery.outlet to computer.inlet;
        }
    }

    // ----------------------------------------------------------------------
    // Occurrence lifetime: individuals, timeslices, snapshots, event occurrences
    // ----------------------------------------------------------------------

    package VehicleLifeHistory {
        doc /* One identified vehicle read four-dimensionally, over its whole life. */

        private import ISQ::*;
        private import ScalarValues::*;
        private import SI::*;


        part def FleetVehicle {
            attribute odometer : LengthValue;
            attribute softwareRevision : String;
        }

        individual def FleetVehicle001 :> FleetVehicle;

        individual fleetVehicle001Life : FleetVehicle001 {
            doc /* The 4D reading of one identified vehicle: its life divides into
                 * timeslices, and a timeslice is bounded by zero-duration snapshots. */

            timeslice preDelivery {
                snapshot :>> start;
                snapshot productionComplete;
                snapshot :>> done;
            }

            then timeslice inCustomerService {
                snapshot handoverToOwner;

                timeslice underWarranty {
                    snapshot warrantyStart;
                    snapshot warrantyExpiry;
                }
            }

            then timeslice retired {
                snapshot decommissioned;
                snapshot recycled;
            }
        }

        part def LifecycleObserver {
            doc /* Event occurrences mark the instants an observer reacts to; the
                 * keyword-less `event` form references an occurrence owned elsewhere. */

            event occurrence vehicleDelivered;
            then event occurrence firstUpdateInstalled;
            then event occurrence warrantyLapsed;
        }

        occurrence def DeliveryObservation {
            ref part observer : LifecycleObserver;
            event observer::vehicleDelivered;
        }
    }

    // ----------------------------------------------------------------------
    // Expression surface (calculations and constraints)
    // ----------------------------------------------------------------------

    package EnergyBudgeting {
        doc /* Energy accounting, and with it every expression form the notation defines. */

        private import ISQ::*;
        private import ScalarValues::*;
        private import SI::*;


        item def EnergySample {
            attribute drawn : Real;
            attribute withinBudget : Boolean;
        }

        part def EnergyLedger {
            attribute samples : EnergySample[0..*];
            attribute headroom : Real;
        }

        calc def EnergyExpressionTour {
            doc /* One calculation exercising every expression form the notation
                 * defines, so the editor's completion, hover, and evaluation paths all
                 * have a worked example to read. */

            in attribute measured : Real;
            in attribute cycles : Integer;
            in attribute enabled : Boolean;
            in attribute optional : Real[0..1];
            in attribute ledger : EnergyLedger;

            attribute conditional : Real = if enabled ? measured else 0.0;
            attribute coalesced : Real = optional ?? 0.0;
            attribute disjunction : Boolean = enabled or measured > 1.0;
            attribute exclusive : Boolean = enabled xor measured > 1.0;
            attribute conjunction : Boolean = enabled and measured < 9.0;
            attribute implication : Boolean = enabled implies measured >= 0.0;
            attribute negation : Boolean = not enabled;
            attribute classification : Boolean = ledger istype EnergyLedger;
            attribute metaClassification : Boolean = ledger hastype EnergyLedger;
            attribute castLedger : EnergyLedger = ledger as EnergyLedger;
            attribute inequality : Boolean = measured != 0.0;
            attribute cycleRange : Integer[0..*] = 1..cycles;
            attribute additive : Real = measured + 1.0 - 0.5;
            attribute multiplicative : Real = measured * 2.0 / 4.0;
            attribute remainder : Integer = cycles % 3;
            attribute exponent : Real = measured ** 2;
            attribute negated : Real = -measured;
            attribute wheelbase : LengthValue = 2.9 [m];
            attribute firstSample : EnergySample = ledger.samples[1];
            attribute overBudget : EnergySample[0..*] =
                ledger.samples->select { in candidate : EnergySample; not candidate.withinBudget };
            attribute drawnValues : Real[0..*] =
                ledger.samples->collect { in candidate : EnergySample; candidate.drawn };
            attribute allWithinBudget : Boolean =
                ledger.samples->forAll { in candidate : EnergySample; candidate.withinBudget };
            attribute dotted : Real = ledger.headroom;
            attribute freshSample : EnergySample = new EnergySample();
            attribute grouped : Real = (measured + 1.0) * 2.0;
            attribute triple : Real[3] = (1.0, 2.0, 3.0);
            attribute absent : Real[0..1] = null;
            attribute label : String = "software-defined";
            attribute affirmative : Boolean = true;

            return attribute score : Real = additive + multiplicative;
        }

        constraint def WithinEnergyBudget {
            in attribute drawn : Real;
            in attribute budget : Real;
            drawn >= 0.0 and drawn <= budget
        }

        part def BudgetedController {
            attribute drawnEnergy : Real;
            attribute energyBudget : Real;

            assert constraint budgetHolds : WithinEnergyBudget {
                in drawn = drawnEnergy;
                in budget = energyBudget;
            }

            inv nonNegativeBudget { energyBudget >= 0.0 }
        }
    }

    // ----------------------------------------------------------------------
    // Feature-level statement forms
    // ----------------------------------------------------------------------

    package SensorConfiguration {
        doc /* Sensor coverage, and with it the feature-level statement forms. */

        private import ISQ::*;
        private import ScalarValues::*;
        private import SI::*;


        part def SensorSuite {
            attribute frontRange : LengthValue;
            attribute rearRange : LengthValue;
            attribute nominalRange : LengthValue default 150.0 [m];

            part cameras : FleetVehicle[0..*];
            part frontCameras : FleetVehicle[0..*] subsets cameras;

            subset frontCameras subsets cameras;
            disjoint frontRange from rearRange;

            ref part pairedSuite : SensorSuite[0..1];
        }

        part def RefinedSensorSuite :> SensorSuite {
            doc /* Shorthand feature forms: a redefinition shorthand retypes an
                 * inherited feature, and a plain shorthand adds a modified one. */

            :>> nominalRange = 220.0 [m];
            ref :>> pairedSuite : RefinedSensorSuite[0..1];
            derived attribute rangeSpread : LengthValue = frontRange - rearRange;
        }

        variation attribute def RangeProfile {
            variant attribute urbanProfile : LengthValue;
            variant attribute highwayProfile : LengthValue;
        }
    }

}
