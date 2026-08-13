package CruiseShipExample {
    private import ScalarValues::Boolean;
    private import ScalarValues::Integer;
    private import ScalarValues::Real;
    private import ScalarValues::String;

    // ─── Value types ───────────────────────────────────────────────────────────

    attribute def Mass { attribute :>> num; attribute :>> mRef; }
    attribute def Length { attribute :>> num; attribute :>> mRef; }
    attribute def Speed { attribute :>> num; attribute :>> mRef; }
    attribute def Power { attribute :>> num; attribute :>> mRef; }
    attribute def PassengerCount { attribute :>> num; }

    item def Fuel;
    item def ElectricPower;
    item def ControlSignal;
    item def NavigationData;
    item def PassengerFlow;
    item def SafetyAlert;
    item def Thrust;

    port def FuelInPort { in fuel : Fuel; }
    port def FuelOutPort :> ~FuelInPort;
    port def PowerOutPort { out current : ElectricPower; }
    port def PowerInPort :> ~PowerOutPort;
    port def ControlOutPort { out command : ControlSignal; }
    port def ControlInPort :> ~ControlOutPort;
    port def NavigationOutPort { out direction : NavigationData; }
    port def NavigationInPort :> ~NavigationOutPort;
    port def PassengerOutPort { out flow : PassengerFlow; }
    port def PassengerInPort :> ~PassengerOutPort;
    port def SafetyOutPort { out alert : SafetyAlert; }
    port def SafetyInPort :> ~SafetyOutPort;
    port def ThrustOutPort { out thrust : Thrust; }
    port def ThrustInPort :> ~ThrustOutPort;

    // ─── Enumerations ──────────────────────────────────────────────────────────

    enum def DeckClass {
        enum POOL_DECK;
        enum LIDO_DECK;
        enum PROMENADE_DECK;
        enum ENGINE_DECK;
    }

    enum def PropulsionMode {
        enum DIESEL;
        enum DIESEL_ELECTRIC;
        enum LNG;
        enum HYBRID;
    }

    // ─── Parts ─────────────────────────────────────────────────────────────────

    part def Propeller {
        port power   : PowerInPort;
        port thrust  : ThrustOutPort;
        attribute diameter   : Length;
        attribute bladeCount : Integer;
        attribute maxRpm     : Real;
    }

    part def Engine {
        port fuel    : FuelInPort;
        port power   : PowerOutPort;
        port thrust  : ThrustOutPort;
        attribute mode        : PropulsionMode;
        attribute ratedPower  : Power;
        attribute fuelConsumption : Real;

        perform action generateThrust {
            out thrust : Real;
        }
    }

    part def PropulsionSystem {
        port powerIn : PowerInPort;
        port control : ControlInPort;
        port thrust  : ThrustOutPort;
        part port1 : Engine;
        part port2 : Engine;
        part starboardPropeller : Propeller;
        part portPropeller      : Propeller;

        attribute combinedPower : Power;

        action drive {
            in  demand : Speed;
            out actual : Speed;
        }

        connect port1.power to starboardPropeller.power;
        connect port2.power to portPropeller.power;
    }

    part def Bridge {
        port nav     : NavigationInPort;
        port command : ControlOutPort;
        port status  : SafetyInPort;
        attribute hasIACS       : Boolean;
        attribute hasECDIS      : Boolean;
        attribute hasAutopilot  : Boolean;

        perform action navigate {
            in  waypoints : String[*];
            out currentHeading : Real;
        }
    }

    part def Cabin {
        port passengerIn : PassengerInPort;
        attribute cabinNumber  : String;
        attribute maxOccupancy : Integer;
        attribute hasBalcony   : Boolean;
        attribute deck         : DeckClass;
    }

    part def PassengerDeck {
        port boarding : PassengerInPort;
        port service  : ControlInPort;
        attribute deckId      : DeckClass;
        attribute cabinCount  : Integer;
        part cabins : Cabin[1..*];

        connect boarding to cabins.passengerIn;
    }

    part def Restaurant {
        port service : ControlInPort;
        attribute name        : String;
        attribute seatingCap  : Integer;
        attribute isBuffet    : Boolean;
    }

    part def MedicalCenter {
        port intake : PassengerInPort;
        port service : ControlInPort;
        port alert  : SafetyInPort;
        attribute bedCount    : Integer;
        attribute hasICU      : Boolean;
        attribute hasSurgery  : Boolean;
    }

    part def SafetySystem {
        port command : ControlInPort;
        port alert   : SafetyOutPort;
        attribute lifeboatCount    : Integer;
        attribute liferaftCount    : Integer;
        attribute lifejacketCount  : Integer;
        attribute solasCertified   : Boolean;
    }

    // ─── Top-level cruise ship ─────────────────────────────────────────────────

    part def CruiseShip {

        // Identity & size
        attribute name           : String;
        attribute imoNumber      : String;
        attribute grossTonnage   : Real;
        attribute overallLength  : Length;
        attribute beam           : Length;
        attribute maxDraft       : Length;
        attribute maxPassengers  : PassengerCount;
        attribute maxCrew        : PassengerCount;

        // System ports
        port power    : PowerOutPort;
        port control  : ControlOutPort;
        port navigation : NavigationOutPort;
        port safetyAlert : SafetyInPort;

        // Sub-systems
        part propulsion   : PropulsionSystem;
        part bridge       : Bridge;
        part medical      : MedicalCenter;
        part safety       : SafetySystem;

        // Decks
        part poolDeck      : PassengerDeck {
            attribute :>> deckId = DeckClass::POOL_DECK;
        }
        part lidoDeck      : PassengerDeck {
            attribute :>> deckId = DeckClass::LIDO_DECK;
        }
        part promenadeDeck : PassengerDeck {
            attribute :>> deckId = DeckClass::PROMENADE_DECK;
        }

        // Dining
        part mainDiningRoom  : Restaurant {
            attribute :>> isBuffet = false;
        }
        part buffetRestaurant: Restaurant {
            attribute :>> isBuffet = true;
        }

        // Derived speed capability
        attribute maxSpeed    : Speed;
        attribute cruiseSpeed : Speed;

        // Top-level operations
        action depart {
            in  port      : String;
            in  manifest  : String;
            out departureConfirmed : Boolean;
        }

        connect power to propulsion.powerIn;
        connect control to bridge.command;
        connect control to safety.command;
        connect control to medical.service;
        connect control to mainDiningRoom.service;
        connect control to buffetRestaurant.service;
        connect navigation to bridge.nav;
        connect safety.alert to bridge.status;

        action arrive {
            in  port      : String;
            out berthed   : Boolean;
        }

        action emergencyMuster {
            out allPassengersAccounted : Boolean;
        }
    }

    // ─── Specialised vessel ────────────────────────────────────────────────────

    part def LuxuryCruiseShip :> CruiseShip {
        attribute starRating   : Integer;
        attribute spaDecks     : Integer;
        attribute conciergeStaff : Integer;

        part spa         : PassengerDeck;
        part fineDining  : Restaurant { attribute :>> isBuffet = false; }

        connect control to spa.service;
        connect control to fineDining.service;
    }

    // ─── Example instance ──────────────────────────────────────────────────────

    part oceanDream : LuxuryCruiseShip {
        attribute :>> name          = "Ocean Dream";
        attribute :>> imoNumber     = "IMO9876543";
        attribute :>> grossTonnage  = 228000.0;
        attribute :>> maxPassengers = PassengerCount { attribute :>> num = 6600; };
        attribute :>> maxCrew       = PassengerCount { attribute :>> num = 2300; };
        attribute :>> starRating    = 5;

        part :>> propulsion : PropulsionSystem {
            part :>> port1 : Engine {
                attribute :>> mode       = PropulsionMode::LNG;
                attribute :>> ratedPower = Power { attribute :>> num = 22000.0; };
            }
            part :>> port2 : Engine {
                attribute :>> mode       = PropulsionMode::LNG;
                attribute :>> ratedPower = Power { attribute :>> num = 22000.0; };
            }
        }

        part :>> bridge : Bridge {
            attribute :>> hasIACS      = true;
            attribute :>> hasECDIS     = true;
            attribute :>> hasAutopilot = true;
        }

        part :>> safety : SafetySystem {
            attribute :>> lifeboatCount   = 20;
            attribute :>> liferaftCount   = 40;
            attribute :>> lifejacketCount = 9500;
            attribute :>> solasCertified  = true;
        }
    }

}
