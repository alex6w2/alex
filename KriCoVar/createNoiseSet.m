function noisyData = createNoiseSet(inputSet, positionSet, ...
    numberOfNewSets)

% Erzeugt m normalverteilte zuf?llige Werte mit Mittelwert der einzelnen
% Werte des eingehenden Datensatzes und jeweils 5% Standartabweichung. 

% Input-Argumente:  inputSet:           Die (gemessenen) Werte an den n
%                                       Punkten ([n x 1] - Vektor)
%                   positionSet:        Die x- und y-Koordinaten an den n
%                                       Punkten ([n x 2] - Vektor)
%                   numberOfNewSets:    Anzahl der zu erzeugenden
%                                       Rauschwerte (int-Wert)
%
% Output:           [n x m] - Matrix. In den Zeilen stehen jeweils die m
%                   Realisierungen der n ?bergebenen Punkte


       
    %Erstelle Matrix; inputSet wird n mal kopiert
   	inputSet = inputSet';
    
    %Distanzen zwischen den Punkten
%     % euklid
%     distances = squareform(pdist(positionSet,'euclidean'));
    
    % spherisch
    positionSetRad = deg2rad(positionSet);
    
    [lat1,lat2] = meshgrid(positionSetRad(:,1));
    [lon1,lon2] = meshgrid(positionSetRad(:,2));
    
    r = 6378.388;
    %6371000.8 in m
    distances = r .* abs(acos(sin(lat1) .* sin(lat2) + ...
        cos(lat1) .* cos(lat2) .* cos(lon2 - lon1)));
    
    % Nullen auf Hauptdiagonale
    distances = distances - diag(diag(distances));
    
%     a1 = cos(lon1) .* cos(lat1);
%     a2 = cos(lon1) .* cos(lat1);
%     a3 = sin(lon1);
%     
%     b1 = cos(lon2) .* cos(lat2);
%     b2 = cos(lon2) .* cos(lat2);
%     b3 = sin(lon2);
%     
%     distances_2 = r .* abs(acos(a1.*b1 + a2.*b2 + a3.*b3));

%    inverseDistances = 1 ./ distances;
%     inverseDistances = exp(-distances .^ 2);
    modifiedDistances = exp(-distances ./ 1000);
    
    modifiedDistances = modifiedDistances + ...
        eye(size(modifiedDistances,1)) * abs(min(eig(modifiedDistances)));
    
    A = chol(modifiedDistances);

    %Normalverteilte Zufallswerte mit mean = 0 und 
    %std = 5% des inputSets 
    meanOfRandom = 0;   
    stdOfRandom = 5;
    
    noise = stdOfRandom .* randn(numberOfNewSets, length(inputSet)) ...
        * A + meanOfRandom;
    
    %Noise zum inputSet hinzuf?gen
    noisyData = noise + repmat(inputSet, numberOfNewSets, 1);
    
    noisyData = noisyData';
    
end

