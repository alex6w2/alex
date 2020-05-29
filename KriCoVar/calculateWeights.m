function [calcWeights, krigingVariance] = calculateWeights( ...
    dataLocations, queryLocations, covarianceOrVariogramModel)

% Berechnung der Gewichte zum Durchf?hren des Kring-Algorythmuses. Abh?ngig
% von ?bergebenen Paramtern (Variogrammmodell oder Kovarianzmatrix)

% Input-Argumente:  dataLocations:      Die x- und y-Koordinaten der n
%                                       Datenpunkte ([n x 2] - Vektor)
%                   queryLocations:     Die x- und y-Koordinaten der m
%                                       Sch?tzpunkte ([m x 2] - Vektor) 
%                   covarianceOrVariogramModel: Eine Instanz der
%                                       Covariance-Klasse oder der
%                                       verschiedenen
%                                       Variogrammmodell-Klassen.
%
% Output:           [n x m] - Vektor mit den Gewichten f?r jeden
%                   Sch?tzpunkt in jeder Spalte



    % Zun?chst Check, ob Variogrammmodell oder Kovarianzmatrix ?bergeben
    % wurde           
    
    if isprop(covarianceOrVariogramModel, 'CovarianceDataDataPoints') ...
            == false
        
        % Berechnen der Varianzmatrix in Abh?ngigkeit des ?bergebenen  
        % Modells ?ber getVarianz-Methode der Klasse der ?bergebenen
        % Instanz.
        leftHandMatrix = getVarianz(covarianceOrVariogramModel, ...
            dataLocations(:,1), dataLocations(:,2), ...
            dataLocations(:,1), dataLocations(:,2));

        %Modifizieren der Koeffizientenmatrix (Lagrange)
        %einsen in letzte Spalte/Zeile und null in rechte untere ecke
        leftHandMatrix(:,end+1) = 1;
        leftHandMatrix(end+1,:) = 1;
        leftHandMatrix(end,end) = 0;                           
            
        %Initialisierung Gewichtematrix 
        calcWeights = zeros([length(dataLocations(:,1)), ...
            length(queryLocations(:,1))]);
        krigingVariance = zeros(length(queryLocations(:,1)), 1);
            
        n = size(dataLocations, 1);       
        
        variance_DataQueryPoints = getVarianz( ...
                covarianceOrVariogramModel, dataLocations(:,1), ...
                dataLocations(:,2), queryLocations(:,1), ...
                queryLocations(:,2));           
    
        % Modifizieren der rechten Zeile, 1 unten ran    
        variance_DataQueryPoints(n+1,:) = 1;  
        
        %Berechnen der Gewichte
        for k = 1 : size(queryLocations, 1)    
            
            % Berechnen von E (Wichtungen und Lagrange Multiplikator)        
            E = leftHandMatrix \ variance_DataQueryPoints(:,k);

            % F?r jeden Sch?tzpunkt kommt neue Spalte in 
            % Gewichtematrix hinzu
            calcWeights(:,k) = E(1:end-1);   
            
            % Berechnen der Kriging-Varianz
            krigingVariance(k) = sum(E(1:end-1,1) .* ...
                variance_DataQueryPoints(1:end-1,k)) + E(end,1);           

        end              
        
    else
        % Falls Kovarianzmatrix ?bergeben wurde, werden die Kovarianzwerte
        % zwischen Daten- und Sch?tzpunkten entweder interpoliert (falls 
        % unbekannt) oder einfach aus der entsprechenden Eigenschaft der 
        % Kovarianzinstanz ausgelesen (falls bekannt und instanziiert).         
        % Dies geschieht in der getVarianz-Funktion der Covariance-Klasse.
        
        covarianceQueryDataPoints = getVarianz(...
            covarianceOrVariogramModel, dataLocations(:,1), ...
            dataLocations(:,2), queryLocations(:,1), ...
            queryLocations(:,2));

        % Modifizieren der rechten Seite
        covarianceQueryDataPoints(end+1,:) = 1;
        
        
        leftHandMatrix = ...
            covarianceOrVariogramModel.CovarianceDataDataPoints;
        
        %Modifizieren der linken Seite
        leftHandMatrix(:,end+1) = 1;
        leftHandMatrix(end+1,:) = 1;
        leftHandMatrix(end,end) = 0;
        
        %LGS l?sen       
        calcWeights = leftHandMatrix \ covarianceQueryDataPoints; 
        
        
        krigingVariance = zeros(length(queryLocations(:,1)), 1);

        for i = 1:size(calcWeights,2)
            krigingVariance(i) = covarianceQueryDataPoints(:,i)' * ...
                calcWeights(:,i);
        end
        
    end           
end

