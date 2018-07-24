classdef Util
    methods (Static)
        function indices = find_all (container, key)
            indices = find(cellfun(@(x) ~isempty(x), ...
                           strfind(container, key) ...
                       )) ...
            ;
        end

        function result = do_exist (container, key)
            result = ~isempty(Utils.Util.find_all(container, key));
        end

        function result = find_last (container, key)
            result = find(cellfun(@(x) ~isempty(x), ...
                         strfind(container, key) ...
                 ), 1, 'last' ...
            );
         end

         function result = substr2double (string, delimeter, diff_index)
             result = str2double(string(strfind(string, delimeter)+diff_index : end));
         end
    end
end
