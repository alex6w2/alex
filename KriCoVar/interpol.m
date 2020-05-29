function predictedValues = interpol(dataValues, weights)

% Berechnet die Werte der Sch�tzpunkte auf Grundlage der Kriging-Gewichte

% Input-Argumente:  dataValues:     Die (gemessenen) Werte an den n
%                                   Datenpunkten ([n x 1] - Vektor)
%                   weights:        Die n berechneten Kriging-Gewichte f�r
%                                   jeden der m Sch�tzpunkte
%                                   ([n x m] - Vektor)
%
% Output:           [n x 1] - Vektor mit den Werten an jedem Sch�tzpunkt


    
    %Speicherzuweisung Vektor mit Sch�tzwerten 
    predictedValues = zeros(length(weights(1,:)), 1);
    
    for i = 1:length(weights(1,:))
        
        predictedValues(i) = sum(dataValues .* ...
            weights(1:length(dataValues), i));
        
    end
    
    predictedValues = reshape(predictedValues,[],1);
    
end

