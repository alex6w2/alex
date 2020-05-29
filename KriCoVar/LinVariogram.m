classdef LinVariogram < VariogramModel

% Liefert die Varianzen f?r die rechte Seite des Kriging-Systems f?r ein
% lineares Variogrammmodell

% Properties:   Slope:   Der Anstieg der Variogrammfunktion. double-Wert.
%
% Methoden:     LinVariogram:     Konstruktor. Wird aufgerufen bei
%                                   Instanziieren der Klasse und legt die
%                                   Werte der Properties fest.  
%
%                               Ben?tigte Parameter:
%                                   nugget: Der Nugget-Wert der
%                                   Variogrammfunktion. double-Wert.
%               
%                                   slope: Der Anstieg der 
%                                   Variogrammfunktion. double-Wert.
%
%               getVarianz:         Aufruf aus der Funktion
%                                   calculateWeights().
%
%                                   Berechnet die Semivarianz zwischen 
%                                   Daten- und Sch?tzpunkten
%                       
%                               Ben?tigte Parameter
%                                   obj: Die Instanz der Klasse
%                                   LinVariogram mit ihren Properties.
%                             
%                                   Xd: X-Koordinaten der m Datenpunkte. 
%                                   [m x 1] Vektor.
%
%                                   Yd: Y-Koordinaten der m Datenpunkte. 
%                                   [m x 1] Vektor.
%
%                                   Xq: X-Koordinaten der n Sch?tzpunkte. 
%                                   [n x 1] Vektor.
%
%                                   Yq: Y-Koordinaten der n Sch?tzpunkte. 
%                                   [n x 1] Vektor.
%                                   
%               
    
    properties (GetAccess = public, SetAccess = protected)
        Slope
    end
    
    methods
        %Konstruktor
        function obj = LinVariogram(nugget, slope)
            
            obj.Nugget = nugget;
            obj.Slope = slope;            
        end
        
        function var = getVarianz(obj, Xd, Yd, Xq, Yq)%             
            
            % Distanzen zwischen Daten- und Sch?tzpunkten
%             % euklid
%             dataMat = [Xd, Yd];
%             queryMat = [Xq, Yq];
%             
%             distances = pdist2(dataMat, queryMat);

            % spherisch
            
            % Check, ob zwei gleiche Matrizen ?bergeben wurden (Die Formel
            % zur Distanzberechnung kann nur mit zwei gleich gro?en
            % Matrizen arbeiten)
            if isequal(Xd,Xq) == true
                [lat1,lat2] = meshgrid(Xd);
                [lon1,lon2] = meshgrid(Yd);

                r = 1; %6378.388
                distances = r .* abs(acos(sin(lat1) .* sin(lat2) + ...
                    cos(lat1) .* cos(lat2) .* cos(lon2 - lon1)));
                
            else
                % Falls zwei ungleiche Distanzmatrizen ?bergebn wurden,
                % werden beide Matrizen verkn?pft und nach der Berechnung
                % wieder getrennt.
                lats = vertcat(Xd, Xq);
                longs = vertcat(Yd, Yq);

                [lat1,lat2] = meshgrid(lats);
                [lon1,lon2] = meshgrid(longs);

                r = 1; %6378.388
                distancesAll = r .* abs(acos(sin(lat1) .* sin(lat2) + ...
                    cos(lat1) .* cos(lat2) .* cos(lon2 - lon1)));
                
                % Trennung
                distances = distancesAll( 1:size(Xd,1), size(Xd,1)+1:end);                
                
            end   
            
            %Varianz in Abh?ngigkeit vom Variogrammmodell
            var = obj.Nugget + obj.Slope * distances; 
        end            
    end
end
