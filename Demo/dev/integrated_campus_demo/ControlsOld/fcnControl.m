function Inputs = fcn(Campus_Outputs, Weather, Time, Price, Signal)
%% CONTROL LOOP FOR BUILDING
lights = Signal(1);
chiller = Signal(2);
room = Signal(3);
plant = Signal(4);

%% Lights Schedule
if Time < 8
    LightsSch1 = 0.05;
    LightsSch2 = 0.05;
elseif Time < 9
    LightsSch1 = 0.9;
    LightsSch2 = 0.9;
elseif Time < 10
    LightsSch1 = 0.95;
    LightsSch2 = 0.95;
elseif Time < 11
    LightsSch1 = 1;
    LightsSch2 = 1;
elseif Time < 12
    LightsSch1 = 0.95;
    LightsSch2 = 0.95;
elseif Time < 13
    LightsSch1 = 0.8;
    LightsSch2 = 0.8;
elseif Time < 14
    LightsSch1 = 0.9;
    LightsSch2 = 0.9;
elseif Time < 18
    LightsSch1 = 1;
    LightsSch2 = 1;
elseif Time < 19
    LightsSch1 = 0.6;
    LightsSch2 = 0.6;
elseif Time < 21
    LightsSch1 = 0.2;
    LightsSch2 = 0.2;
else
    LightsSch1 = 0.05;
    LightsSch2 = 0.05;
end

%% CONTROL
ChilledWaterSetpoint = 7.22;
LightsSch1 = 1;
LightsSch2 = 1;
Room1CoolingSetpoint = 22;
Room2CoolingSetpoint = 23;
Room1HeatingSetpoint = 20;
Room2HeatingSetpoint = 20;
PlantAct = 1;
%% Lights
if lights == 1
    LightsFactor = 0.5 - (Price-0.045);
    LightsSch1 = LightsSch1*LightsFactor;
    LightsSch2 = LightsSch2*LightsFactor;
end
%% Chiller
if chiller == 1
    ChilledWaterSetpoint = 7.22 + (Price-0.045)*2;
end
%% Room Setpoints
if room == 1
    Room1CoolingSetpoint = 22 + (Price-0.045)*1;
    Room2CoolingSetpoint = 23 + (Price-0.045)*2;
    Room1HeatingSetpoint = 20;
    Room2HeatingSetpoint = 20;
end
%% Plant
if plant == 1
    PlantAct = 1;
    if Price > 0.058
        PlantAct = 0;
    end
end
%% SET OUTPUTS
Inputs = [ChilledWaterSetpoint,...
    Room1CoolingSetpoint,...
    Room2CoolingSetpoint,...
    Room1HeatingSetpoint,...
    Room2HeatingSetpoint,...
    PlantAct,...
    LightsSch1,...
    LightsSch2];