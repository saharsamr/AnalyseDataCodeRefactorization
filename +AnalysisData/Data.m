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
