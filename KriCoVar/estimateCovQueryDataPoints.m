function covarianceQueryDataPoints = estimateCovQueryDataPoints ...
    (queryLocations, dataLocations, covarianceMatrixDataPoints)

% Interpoliert die Kovrianz zwischen Daten- und Sch�tzpunkten aus den
% gegebenen Kovarianzen zwischen den Datenpunkten

% Input-Argumente:  queryLocations:     Die x- und y-Koordinaten der m
%                                       Sch�tzpunkte ([m x 2] - Vektor)
%                   dataLocations:      Die x- und y-Koordinaten der n
%                                       Datenpunkte ([n x 2] - Vektor)
%                   covarianceMatrixDataPoints: Kovarianzmatrix zwischen
%                                       den Datenpunkten ([n x n] - Vektor)
%                      
%   Output:         [n x m] - Matrix: Kovarianz zwischen den n Daten- und 
%                   m Sch�tzpunkten.


    %Initialisierung der Matrix, in welcher die Kovarianzwerte zwischen
    %Daten- und Sch�tzpunkten gespeichert werden. b ist ein variabler
    %Vektor, in welchem die Kovarianzen zwischengespeichert werden.
    covarianceQueryDataPoints = zeros(size(dataLocations, 1), ...
        size(queryLocations, 1));
    b = zeros(length(dataLocations), 1);
    
    
    %Interpolation der Kovarianz zwischen allen Daten- und Sch�tzpunkten.
    for i = 1:size(queryLocations, 1)        
        for j = 1:size(dataLocations, 1)
            covarianceData = covarianceMatrixDataPoints(:,j);

            interpol = scatteredInterpolant(dataLocations(:,1), ...
                dataLocations(:,2), covarianceData);
            interpol.Method = 'natural';
            interpol.ExtrapolationMethod = 'linear';

            % Vektor b speichert die Kovarianz zwischen einem Sch�tzpunkt
            % und allen Datenpunkten zwischen
            b(j) = interpol(queryLocations(i,1), queryLocations(i,2));             
        end
        
        % Die Kovarianzen zwischen allen Daten- und Sch�tzpunkten in Matrix
        % speichern
        covarianceQueryDataPoints(:,i) = b;
    end    
end

