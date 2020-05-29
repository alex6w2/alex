clear; clc;

filepath = 'Beispieldaten\';

%Laden der gegebenen Daten und der Daten an den Observationspunkten
DataSet = load([filepath,'Data_EGM_201.mat']);

%Laden der gegebenen Daten und der Daten an den Auswertepunkten
QuerySet = load([filepath,'Query_EGM_7381.mat']);


%% Selektieren der Datenpunkte, Observationspunkte und Datenwerte

DataLocations = [DataSet.x DataSet.y];
QueryLocations = [QuerySet.x QuerySet.y];
DataValues = DataSet.z;
QueryValues = QuerySet.z;


%% Korreliertes Rauschen
% 10000 Rauschwerte
Values_Noise = [[DataValues;QueryValues] ...
     createNoiseSet([DataValues;QueryValues] , ...
     [DataLocations;QueryLocations], 10000)];

DataValues_Noise = Values_Noise(1:length(DataValues), :);
QueryValues_Noise = Values_Noise(length(DataValues)+1:end, :);


%
%Berechne Kovarianzmatrix zwischen Datenpunkten
covarianceMatrix_DataPoints = calculateCovariance(DataValues_Noise);

%Instanziieren Kovarianzobjekt
covarianceMatrix_int = CovarianceMatrix(covarianceMatrix_DataPoints, 0);

% Berechnen der Gewichte
[weights_int, krigVariance_int] = calculateWeights(DataLocations, ...
    QueryLocations, covarianceMatrix_int);

predValues_int = interpol(DataValues, weights_int);



%Simuliere Kovarianzen zwischen Daten- und Sch?tzpunkten
covarianceMatrix_QueryDataPoints_sim = calculateCovariance(...
    DataValues_Noise, QueryValues_Noise);

covarianceMatrix_sim = CovarianceMatrix(covarianceMatrix_DataPoints, ...
    covarianceMatrix_QueryDataPoints_sim);
 
[weights_sim, krigVariance_sim] = calculateWeights(DataLocations, ...
    QueryLocations, covarianceMatrix_sim);

predValues_sim = interpol(DataValues, weights_sim);



% Variogramm anpassen
% matchVariogram(DataSet, 'gaussian', 100, 950, 3400, 0);

% Instanziieren eines Variogrammmodells
GauModel_1_EGM = GaussVariogram(100, 950, 3000);

% Berechnen der Gewichte
[weights_Var, krigVariance] = calculateWeights(DataLocations,QueryLocations,...
    GauModel_1_EGM);

% Kriging ausf?hren
predValues_var = interpol(DataValues, weights_Var);


% Errors
error_int = predValues_int - QueryValues;
error_sim = predValues_sim - QueryValues;
error_var = predValues_var - QueryValues;

% Mittlerer Quadratischer Fehler
mqf_int = mean(error_int .^ 2);
mqf_sim = mean(error_sim .^ 2);
mqf_var = mean(error_var .^ 2);  


  
% Darstellung predValues

% XLong = reshape(QueryLocations(:,1),121,[]);
% YLong = reshape(QueryLocations(:,2),121,[]);
% GeoidH = reshape(predValues_sim_400,121,[]);
% 
% 
% figure('name','geoidGrid')
% h = pcolor(XLong, YLong, GeoidH);
% set(h, 'EdgeColor', 'none');
% xlim([-180 180]);
% ylim([-90 90]);
% colorbar
% hold on
% % caxis([min(QueryValues) max(QueryValues)]);
% plot(DataLocations(:,1),DataLocations(:,2),'.','color','black')
% grid on
% hold off

