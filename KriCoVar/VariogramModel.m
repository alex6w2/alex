classdef (Abstract) VariogramModel < Covariance
    
% "Mutterklasse" für alle Variogrammmodellklassen
    
% Da alle Variogrammmodellklassen die Eigenschaft Nugget aufweisen, wird
% diese bereits hier implementiert. Selbiges gilt für die Methode
% getVarianz()

    
    properties (GetAccess = public, SetAccess = protected)
        Nugget
    end
    
    methods (Abstract)
        getVarianz(Xd,Yd,Xq,Yq)
    end
end


