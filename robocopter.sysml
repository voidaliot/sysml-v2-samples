package RoboCopterPkg {

	// Generic leaf component type
	part def Component {}

	// Top-level system decomposition
	part def RoboCopterTaxi {
		part airframe : Airframe;
		part propulsionSystem : PropulsionSystem[0..*];
		part energySystem : EnergySystem;
		part flightControlSystem : FlightControlSystem;
		part autonomySystem : AutonomySystem;
		part navigationSystem : NavigationSystem;
		part communicationSystem : CommunicationSystem;
		part landingSystem : LandingSystem;
		part cabinSystem : CabinSystem;
		part environmentalControlSystem : EnvironmentalControlSystem;
		part thermalManagementSystem : ThermalManagementSystem;
		part safetySystem : SafetySystem;
		part lightingSystem : LightingSystem;
		part healthManagementSystem : HealthManagementSystem;
		part cybersecuritySystem : CybersecuritySystem;
		part humanMachineInterface : HumanMachineInterface;
		part remoteOperationInterface : RemoteOperationInterface;
	}

	// 1. Air vehicle
	part def Airframe {
		part centralFuselage : Component;
		part forwardFuselage : Component;
		part rearFuselage : Component;
		part upperFuselageShell : Component;
		part lowerFuselageShell : Component;
		part structuralFrame : Component;
		part longerons : Component;
		part framesAndBulkheads : Component;
		part floorStructure : Component;
		part roofStructure : Component;
		part crashEnergyAbsorption : Component;
		part equipmentBays : Component;
		part batteryCompartments : Component;
		part avionicsCompartments : Component;
		part accessPanels : Component;
		part servicePanels : Component;
		part inspectionPanels : Component;
		part externalFairings : Component;
		part aerodynamicCovers : Component;
		part drainageChannels : Component;
		part lightningProtectionMesh : Component;
		part bondingStraps : Component;
		part structuralJoints : Component;
		part vibrationIsolators : Component;
		part fireBarriers : Component;
		part thermalBarriers : Component;
		part doors : DoorsAndOpenings;
		part windows : WindowsAndTransparentSurfaces;
	}

	// 1.2 Rotor-support structure (configuration-dependent)
	part def RotorSupportStructure {
		part wings : Component[0..*];
		part stubWings : Component[0..*];
		part rotorArms : Component[0..*];
		part booms : Component[0..*];
		part pylons : Component[0..*];
		part nacelles : Component[0..*];
		part motorMounts : Component[0..*];
		part rotorMounts : Component[0..*];
		part tiltMechanisms : Component[0..*];
		part tiltAxisBearings : Component[0..*];
		part tiltActuators : Component[0..*];
		part tiltLockMechanisms : Component[0..*];
		part positionSensors : Component[0..*];
		part mechanicalStops : Component[0..*];
		part structuralBraces : Component[0..*];
		part loadTransferFittings : Component[0..*];
	}

	part def DoorsAndOpenings {
		part passengerDoors : Component[0..*];
		part emergencyExitDoors : Component[0..*];
		part cargoDoors : Component[0..*];
		part batteryServiceDoors : Component[0..*];
		part chargingPortDoors : Component[0..*];
		part doorHinges : Component[0..*];
		part doorLatches : Component[0..*];
		part lockingMechanisms : Component[0..*];
		part doorActuators : Component[0..*];
		part doorSeals : Component[0..*];
		part doorOpenSensors : Component[0..*];
		part manualReleaseHandles : Component[0..*];
		part emergencyReleaseHandles : Component[0..*];
		part steps : Component[0..*];
		part handholds : Component[0..*];
	}

	part def WindowsAndTransparentSurfaces {
		part windscreen : Component;
		part sideWindows : Component[0..*];
		part roofWindows : Component[0..*];
		part emergencyExitWindows : Component[0..*];
		part windowFrames : Component[0..*];
		part windowSeals : Component[0..*];
		part heatingElements : Component[0..*];
		part antiFogCoatings : Component[0..*];
		part sunShades : Component[0..*];
	}

	// 2. Lift and propulsion system
	part def PropulsionSystem {
		part rotorPropAssemblies : RotorPropAssembly[0..*];
		part electricMotors : ElectricMotor[0..*];
		part motorControlElectronics : MotorControlElectronics[0..*];
		part mechanicalTransmissions : MechanicalTransmission[0..*];
		part propulsionCooling : PropulsionCooling[0..*];
		part rotorSupport : RotorSupportStructure;
	}

	part def RotorPropAssembly {
		part hub : Component;
		part blades : Component[1..*];
		part bladeRoots : Component[1..*];
		part bladeRetentionHardware : Component;
		part pitchMechanism : Component[0..1];
		part pitchLinks : Component[0..*];
		part pitchBearings : Component[0..*];
		part spinner : Component[0..1];
		part erosionProtection : Component[0..1];
		part iceProtection : Component[0..1];
		part balancingWeights : Component[0..*];
		part speedSensor : Component[0..1];
		part bladeConditionSensors : Component[0..*];
	}

	part def ElectricMotor {
		part stator : Component;
		part rotor : Component;
		part shaft : Component;
		part bearings : Component[0..*];
		part motorHousing : Component;
		part coolingJacket : Component[0..1];
		part temperatureSensors : Component[0..*];
		part speedSensor : Component[0..1];
		part positionSensor : Component[0..1];
		part motorConnectors : Component[0..*];
		part motorMountingInterface : Component;
		part electricalInsulation : Component;
		part electromagneticShielding : Component[0..1];
	}

	part def MotorControlElectronics {
		part inverter : Component;
		part gateDriverElectronics : Component;
		part powerSemiconductorModules : Component[0..*];
		part dcLinkCapacitors : Component[0..*];
		part currentSensors : Component[0..*];
		part voltageSensors : Component[0..*];
		part temperatureSensors : Component[0..*];
		part inverterController : Component;
		part inverterCoolingPlate : Component[0..1];
		part highVoltageConnectors : Component[0..*];
		part lowVoltageConnectors : Component[0..*];
		part shieldingEnclosure : Component[0..1];
		part contactorOrIsolationDevice : Component[0..1];
	}

	part def MechanicalTransmission {
		part reductionGearbox : Component[0..1];
		part gearStages : Component[0..*];
		part bearings : Component[0..*];
		part lubricationSystem : Component[0..1];
		part oilReservoir : Component[0..1];
		part oilPump : Component[0..1];
		part filters : Component[0..*];
		part oilTemperatureSensor : Component[0..1];
		part oilPressureSensor : Component[0..1];
		part clutch : Component[0..1];
		part coupling : Component[0..1];
		part freewheel : Component[0..1];
		part torqueSensor : Component[0..1];
	}

	part def PropulsionCooling {
		part coolingChannels : Component[0..*];
		part coolantLines : Component[0..*];
		part coolantPumps : Component[0..*];
		part heatExchangers : Component[0..*];
		part radiators : Component[0..*];
		part fans : Component[0..*];
		part expansionTank : Component[0..1];
		part valves : Component[0..*];
		part temperatureSensors : Component[0..*];
		part leakSensors : Component[0..*];
	}

	// 3. Electrical-energy system
	part def EnergySystem {
		part tractionBatteryPacks : TractionBatteryPack[0..*];
		part highVoltageDistribution : HighVoltageDistribution;
		part lowVoltageSystem : LowVoltageSystem;
		part chargingSystem : ChargingSystem[0..1];
		part alternativeEnergySources : AlternativeEnergySources[0..1];
	}

	part def TractionBatteryPack {
		part batteryEnclosure : Component;
		part batteryModules : Component[0..*];
		part batteryCells : Component[0..*];
		part cellHolders : Component[0..*];
		part busbars : Component[0..*];
		part cMUs : Component[0..*];
		part moduleMonitoringUnits : Component[0..*];
		part bms : Component;
		part packController : Component;
		part mainContactors : Component[0..*];
		part preChargeContactors : Component[0..*];
		part preChargeResistors : Component[0..*];
		part currentSensors : Component[0..*];
		part voltageSensors : Component[0..*];
		part temperatureSensors : Component[0..*];
		part serviceDisconnect : Component[0..1];
		part highVoltageFuse : Component[0..1];
		part pyrotechnicDisconnect : Component[0..1];
		part pressureReliefDevice : Component[0..1];
		part ventingSystem : Component[0..1];
		part fireDetectionSensors : Component[0..*];
		part fireContainment : Component[0..1];
		part thermalBarriers : Component[0..*];
		part coolingPlates : Component[0..*];
		part coolantManifolds : Component[0..*];
		part coolantConnectors : Component[0..*];
		part insulationMonitoringDevice : Component[0..1];
		part crashDisconnectInterface : Component[0..1];
		part batteryMountingStructure : Component;
	}

	part def HighVoltageDistribution {
		part hvJunctionBox : Component;
		part pdu : Component;
		part mainHvBus : Component;
		part hvCables : Component[0..*];
		part shieldedConnectors : Component[0..*];
		part contactors : Component[0..*];
		part fuses : Component[0..*];
		part circuitBreakers : Component[0..*];
		part isolationMonitors : Component[0..*];
		part currentSensors : Component[0..*];
		part voltageSensors : Component[0..*];
		part groundFaultDetection : Component[0..1];
		part hvilLoop : Component[0..1];
		part dischargeResistors : Component[0..*];
		part emergencyIsolationDevices : Component[0..*];
	}

	part def LowVoltageSystem {
		part lvBatteries : Component[0..*];
		part dcDcConverters : Component[0..*];
		part lvPdus : Component[0..*];
		part fuseBoxes : Component[0..*];
		part circuitBreakers : Component[0..*];
		part relays : Component[0..*];
		part wiringHarnesses : Component[0..*];
		part groundingNetwork : Component;
		part bondingNetwork : Component;
		part powerQualityMonitoring : Component[0..1];
		part emergencyPowerBus : Component[0..1];
		part essentialAvionicsBus : Component[0..1];
		part cabinServicesBus : Component[0..1];
	}

	part def ChargingSystem {
		part externalChargingConnector : Component;
		part chargingPortHousing : Component;
		part chargingPortLock : Component;
		part chargingCommunicationController : Component;
		part onboardCharger : Component[0..1];
		part dcFastChargingInterface : Component[0..1];
		part acChargingInterface : Component[0..1];
		part chargingContactors : Component[0..*];
		part chargingFuses : Component[0..*];
		part chargingCables : Component[0..*];
		part coolingInterface : Component[0..1];
		part groundingInterface : Component[0..1];
		part isolationMonitoring : Component[0..1];
		part chargeStatusIndicators : Component[0..*];
		part wirelessChargingReceiver : Component[0..1];
	}

	part def AlternativeEnergySources {
		part hydrogenTank : Component[0..1];
		part fuelCellStack : Component[0..1];
		part hydrogenRegulator : Component[0..1];
		part hydrogenShutOffValve : Component[0..1];
		part hydrogenLeakSensors : Component[0..*];
		part fuelCellAirCompressor : Component[0..1];
		part humidifier : Component[0..1];
		part fuelCellCooling : Component[0..1];
		part fuelCellDcDcConverter : Component[0..1];
		part rangeExtenderGenerator : Component[0..1];
		part turbineGenerator : Component[0..1];
		part fuelTank : Component[0..1];
		part fuelPumps : Component[0..*];
		part fuelLines : Component[0..*];
		part fuelFilters : Component[0..*];
	}

	// 4. Flight-control system
	part def FlightControlSystem {
		part primaryFcc : Component;
		part secondaryFcc : Component[0..1];
		part tertiaryMonitor : Component[0..1];
		part safetyMonitor : Component[0..1];
		part ioModules : Component[0..*];
		part processingBoards : Component[0..*];
		part memoryModules : Component[0..*];
		part powerSupplyModules : Component[0..*];
		part timeSyncModule : Component[0..1];
		part fcsCooling : Component[0..1];
		part fccEnclosures : Component[0..*];
		part connectors : Component[0..*];
		part mountingRacks : Component[0..*];
		part vibrationIsolators : Component[0..*];
		part sensors : FlightControlSensors;
		part actuators : FlightControlActuators;
		part networks : FlightControlNetworks;
	}

	part def FlightControlSensors {
		part imus : Component[0..*];
		part accelerometers : Component[0..*];
		part gyroscopes : Component[0..*];
		part magnetometers : Component[0..*];
		part baroAltimeters : Component[0..*];
		part radarAltimeters : Component[0..*];
		part laserAltimeters : Component[0..*];
		part airDataComputers : Component[0..*];
		part pitotTubes : Component[0..*];
		part staticPorts : Component[0..*];
		part aoaSensors : Component[0..*];
		part sideslipSensors : Component[0..*];
		part oatSensors : Component[0..*];
		part verticalSpeedSensors : Component[0..*];
		part rotorSpeedSensors : Component[0..*];
		part motorCurrentSensors : Component[0..*];
		part motorPositionSensors : Component[0..*];
		part structuralLoadSensors : Component[0..*];
		part vibrationSensors : Component[0..*];
	}

	part def FlightControlActuators {
		part aileronActuators : Component[0..*];
		part elevatorActuators : Component[0..*];
		part rudderActuators : Component[0..*];
		part flapActuators : Component[0..*];
		part spoilerActuators : Component[0..*];
		part trimActuators : Component[0..*];
		part controlSurfacePositionSensors : Component[0..*];
		part actuatorControlElectronics : Component[0..*];
		part mechanicalLinkages : Component[0..*];
		part controlRods : Component[0..*];
		part hinges : Component[0..*];
		part bearings : Component[0..*];
		part actuatorLocks : Component[0..*];
		part tiltActuators : Component[0..*];
		part thrustVectorActuators : Component[0..*];
		part variablePitchActuators : Component[0..*];
		part actuatorControllers : Component[0..*];
		part positionEncoders : Component[0..*];
		part mechanicalLocks : Component[0..*];
	}

	part def FlightControlNetworks {
		part dataBuses : Component[0..*];
		part redundantEthernet : Component[0..*];
		part canBuses : Component[0..*];
		part tsnSwitches : Component[0..*];
		part afdxSwitches : Component[0..*];
		part networkGateways : Component[0..*];
		part dataConcentrators : Component[0..*];
		part busCouplers : Component[0..*];
		part fibreOpticLinks : Component[0..*];
		part networkMonitoringUnits : Component[0..*];
	}

	// 5. Autonomous-flight system
	part def AutonomySystem {
		part missionComputer : Component;
		part perceptionComputer : Component;
		part pathPlanningComputer : Component;
		part vehicleManagementComputer : Component;
		part safetySupervisionComputer : Component;
		part aiAccelerator : Component[0..1];
		part gpu : Component[0..1];
		part npu : Component[0..1];
		part dataRecordingComputer : Component[0..1];
		part cybersecurityModule : Component[0..1];
		part secureBoot : Component[0..1];
		part hsm : Component[0..1];
		part redundantProcessingChannels : Component[0..*];
		part perceptionSensors : PerceptionSensors;
	}

	part def PerceptionSensors {
		part forwardCameras : Component[0..*];
		part rearCameras : Component[0..*];
		part sideCameras : Component[0..*];
		part downCameras : Component[0..*];
		part stereoCameras : Component[0..*];
		part infraredCameras : Component[0..*];
		part lowLightCameras : Component[0..*];
		part lidars : Component[0..*];
		part longRangeRadar : Component[0..1];
		part shortRangeRadar : Component[0..*];
		part ultrasonicSensors : Component[0..*];
		part opticalFlowCamera : Component[0..1];
		part landingZoneCamera : Component[0..1];
		part weatherRadar : Component[0..1];
		part lightningDetector : Component[0..1];
		part obstacleDetectionSensors : Component[0..*];
		part birdDetectionSensors : Component[0..*];
		part wireDetectionSensors : Component[0..*];
		part sensorCleaningSystems : Component[0..*];
		part sensorHeaters : Component[0..*];
		part sensorCovers : Component[0..*];
		part sensorCalibrationTargets : Component[0..*];
	}

	part def NavigationSystem {
		part gnssReceiver : Component[0..1];
		part gnssAntennas : Component[0..*];
		part rtkReceiver : Component[0..1];
		part differentialGnss : Component[0..1];
		part sbasReceiver : Component[0..1];
		part ins : Component[0..1];
		part visualNavigation : Component[0..1];
		part terrainRelativeNavigation : Component[0..1];
		part mapDatabase : Component[0..1];
		part landingPadLocalisation : Component[0..1];
		part radioNavigation : Component[0..1];
		part additionalNavReceivers : Component[0..*];
	}

	// 6. Communication system
	part def CommunicationSystem {
		part atcCommunication : Component;
		part atcSurveillance : Component;
		part groundCommunication : Component;
		part passengerCommunication : Component;
		part remoteOperationParts : RemoteOperationInterface;
	}

	part def LandingSystem {
		part landingGear : Component;
		part landingAssistance : Component;
		part groundHandling : Component;
	}

	part def CabinSystem {
		part passengerCompartment : Component;
		part cargoArea : Component;
		part cabinControls : Component;
		part cabinLighting : Component;
		part acousticTreatment : Component;
	}

	part def EnvironmentalControlSystem {
		part hvac : Component;
		part windowAndSensorConditioning : Component;
		part pressurisation : Component[0..1];
	}

	part def ThermalManagementSystem {
		part batteryCoolingLoop : Component;
		part motorCoolingLoop : Component;
		part inverterCoolingLoop : Component;
		part avionicsCoolingLoop : Component;
		part cabinThermalLoop : Component;
		part pumps : Component[0..*];
		part reservoirs : Component[0..*];
		part heatExchangers : Component[0..*];
		part coldPlates : Component[0..*];
		part thermostats : Component[0..*];
		part leakDetection : Component[0..*];
	}

	part def SafetySystem {
		part occupantSafety : Component;
		part aircraftEmergencySystems : Component;
		part fireProtection : Component;
		part collisionProtection : Component;
	}

	part def LightingSystem {
		part navigationLights : Component;
		part positionLights : Component;
		part antiCollisionLights : Component;
		part strobeLights : Component;
		part beaconLights : Component;
		part landingLights : Component;
		part taxiLights : Component;
		part lightingController : Component;
		part lightSensors : Component[0..*];
	}

	part def HealthManagementSystem {
		part maintenanceComputer : Component;
		part bitControllers : Component[0..*];
		part faultRecordingUnit : Component;
		part structuralHealthSensors : Component[0..*];
		part strainGauges : Component[0..*];
		part crackDetectionSensors : Component[0..*];
		part vibrationSensors : Component[0..*];
		part acousticEmissionSensors : Component[0..*];
		part batteryHealthMonitoring : Component;
		part motorHealthMonitoring : Component;
		part rotorHealthMonitoring : Component;
		part dataLogger : Component;
		part flightDataRecorder : Component[0..1];
		part voiceRecorder : Component[0..1];
		part maintenanceDataInterface : Component;
		part wirelessMaintenanceInterface : Component;
		part usageMonitoringDatabase : Component;
		part ruluCalcModule : Component; // remaining-useful-life
	}

	part def CybersecuritySystem {
		part hsm : Component;
		part secureBootController : Component;
		part cryptoProcessor : Component;
		part identityCertificates : Component[0..*];
		part keyStorage : Component;
		part networkFirewall : Component;
		part ids : Component;
		part ips : Component;
		part secureCommGateway : Component;
		part secureMaintenanceInterface : Component;
		part secureSoftwareUpdateController : Component;
		part tamperSensors : Component[0..*];
		part accessControlModule : Component;
		part securityEventLogger : Component;
		part segmentationGateway : Component;
	}

	part def HumanMachineInterface {
		part passengerDisplay : Component;
		part destinationInterface : Component;
		part routeDisplay : Component;
		part flightStatusDisplay : Component;
		part arrivalDisplay : Component;
		part safetyInstructionDisplay : Component;
		part doorStatusDisplay : Component;
		part batteryStatusDisplay : Component;
		part communicationControls : Component;
		part emergencyCallInterface : Component;
		part accessibilityInterface : Component;
		part audioAnnouncements : Component;
		part visualWarnings : Component;
		part hapticControls : Component[0..1];
		part pilotControls : Component[0..1];
		part pilotDisplays : Component[0..1];
	}

	part def RemoteOperationInterface {
		part remoteCommandReceiver : Component;
		part telemetryTransmitter : Component;
		part remotePilotCommUnit : Component;
		part videoEncoder : Component;
		part remoteControlGateway : Component;
		part linkQualityMonitor : Component;
		part lostLinkController : Component;
		part independentSafetyChannel : Component;
		part remoteIdentificationUnit : Component;
		part antennas : Component[0..*];
		part encryptionModule : Component;
	}

}