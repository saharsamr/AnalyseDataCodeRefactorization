%% The Super Class of All Data Objects
% This class is the super class of all data classes that we used in this codes.
% The common method that all of them have, is the *convert_properties_to_struct*
% method. In the end of our procedure, we will convert our *experiment* object to
% a *MATLAB Struct* to store it in a .mat file, and thus we can use it furture
% with no need of having knowledge about the procedure has been designed here.
% For this purpose, all its properties should onvert to structs to. So, we *_MUST_*
% inherite *_ANY_* data object that we need, Now or future, from this class, to
% ensure that whenever we convert the experiment instance to struct, *_ALL_* of
% other properties are going to convert properly.
% *_PLEASE NOTICE!_* that for every class we should define a function with *same*
% name which will call this function of its superclass.

classdef Data < handle

    methods (Access = public)

        function result = convert_properties_to_struct (this)
            props = properties(this);
            for i = 1:numel(props)
                property = props{i};
                try
                    [r,c] = size(this.(property));
                    if (c > 1)
                        for i = 1:numel(this.(property))
                            this.(property)(i).convert_properties_to_struct();
                        end
                        for i = 1:numel(this.(property))
                            temp(i) = struct(this.(property)(i));
                        end
                        this.(property) = struct(temp);
                    else
                        this.(property).convert_properties_to_struct();
                        this.(property) = struct(this.(property));
                    end
                catch e
                    continue;
                end
            end
        end

    end

end
