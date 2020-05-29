classdef CovarianceMatrix < Covariance

% Instanzen der Klasse werden zur Durchf?hrung des Kriging-Algorythmusses
% mit Kovarianzen zum Berechnen der Kriging-Gewichte ben?tigt. Die Methode
% Get-Varianz liefert die rechte Seite des Kriging-Systems

% Properies:    Covariance_DataDataPoints:  Die Kovarianzmatrix zwischen 
%                                   den n Datenpunkten. [n x n] - Matrix.
%               Covariance_QueryDataPoints: Die Kovarianzmatrix zwischen 
%                                   den m Datenpunkten und n Sch?tzpunkten.
%                                   [n x n] - Matrix. Ist die Kovarianz
%                                   zwischen Daten und Sch?tzpunkten
%                                   unbekannt, so wird der Wert 0
%                                   ?bergeben.
% 
% Methoden:     CovarianceMatrix:   Konstruktor. Wird aufgerufen bei
%                                   Instanziieren der Klasse und legt die
%                                   Werte der Properties fest.    
%
%                               Ben?tigte Parameter: 
%                                   covariance_DataDataPoints: Die 
%                                   Kovarianzmatrix zwischen den n 
%                                   Datenpunkten. [n x n] - Matrix.
%
%                                   covariance_QueryDataPoints: Die 
%                                   Kovarianzmatrix zwischen den m 
%                                   Datenpunkten und n Sch?tzpunkten.
%                                   [m x n] - Matrix. Ist die Kovarianz
%                                   zwischen Daten und Sch?tzpunkten
%                                   unbekannt, so wird der Wert 0
%                                   ?bergeben.      
%
%               getVarianz:         Aufruf aus der Funktion
%                                   calculateWeights().
%
%                                   Es wird zwischen zwei F?llen
%                                   unterschieden: 1. Kovarianz zwischen
%                                   Daten- und Sch?tzpunkten bekannt. 2.
%                                   Kovarianz zwischen Daten und
%                                   Sch?tzpunkten unbekannt.
%
%                                   zu 1.: Die Property 
%                                   Covariance_QueryDataPoints ist eine
%                                   Matrix. Der R?ckgabewert der Mathode 
%                                   ist dann lediglich diese Matrix.
%                                                                         
%                                   zu 2.: Die Property 
%                                   Covariance_QueryDataPoints hat den Wert
%                                   0 (obj.Covariance_QueryDataPoints = 0).
%                                   Die Kovarianz zwischen Daten- und 
%                                   Sch?tzpunkten wird somit aus den
%                                   bekannten Kovarianzen zwischen den
%                                   Datenpunkt interpoliert. Der 
%                                   R?ckgabewert ist dann die Matrix mit
%                                   den interpolierten Werten f?r die 
%                                   Kovarianz zwischen Daten- und 
%                                   Sch?tzpunkten
%                                  
%                               Ben?tigte Parameter: 
%                                   obj: Die Instanz der Klasse
%                                   CovarianceMatrix mit ihren Properties.
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

    
    properties(GetAccess= public,SetAccess=protected)
        CovarianceDataDataPoints = [];
        CovarianceQueryDataPoints = [];
    end
    
    methods
        %Konstruktor
        function obj = CovarianceMatrix(covarianceDataDataPoints, ...
                    covarianceQueryDataPoints)
            
            obj.CovarianceDataDataPoints = covarianceDataDataPoints;
            obj.CovarianceQueryDataPoints = covarianceQueryDataPoints;           
        end        
     
        function [var] = getVarianz(obj, Xd, Yd, Xq, Yq)
            
                   
            % Check, ob Kovarianz zwischen Daten- und Sch?tzpunkten
            % unbekannt
            if obj.CovarianceQueryDataPoints == 0    
                
                %Initialisierung der Matrix, in welcher die Kovarianzwerte
                %zwischen Daten- und Sch?tzpunkten gespeichert werden. 
                %b ist ein variabler Vektor, in welchem die Kovarianzen 
                %zwischengespeichert werden.
                obj.CovarianceQueryDataPoints = zeros(size(Xd, 1), ...
                    size(Xq, 1));
                b = zeros(length(Xd), 1);

                %Interpolation der Kovarianz zwischen allen Daten- und
                %Sch?tzpunkten.
                for i = 1:size(Xq, 1)        
                    for j = 1:size(Xd, 1)
                        covarianceData = ...
                            obj.CovarianceDataDataPoints(:,j);

                        estimateCovQueryDataPoints = ...
                            scatteredInterpolant(Xd, Yd, covarianceData);
                        estimateCovQueryDataPoints.Method = 'natural';
                        estimateCovQueryDataPoints.ExtrapolationMethod = ...
                            'linear';

                        b(j) = estimateCovQueryDataPoints(Xq(i), Yq(i));             
                    end

                    obj.CovarianceQueryDataPoints(:,i) = b;
                end 

                var = obj.CovarianceQueryDataPoints; 
                
            else
                var = obj.CovarianceQueryDataPoints;
                
            end
            
        end              
    end
end

