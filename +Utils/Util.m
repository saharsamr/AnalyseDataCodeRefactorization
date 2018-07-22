classdef Util
    methods (Static)
        function indices = find_all (container, key)
            indices = find(cellfun(@(x) ~isempty(x), ...
                           strfind(container, key) ...
                       )) ...
            ;
        end

        function result = do_exist (container, key)
            result = ~isempty(find_all(container, key));
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

         function result = union_all (varargin)
             if nargin == 0

             elseif nargin == 1
                 result = varargin(1);
             elseif nargin == 2
                 result = union(varargin(1), varargin(2));
             else
                 result = union(varargin(1), union_all(varargin(2:end)));
             end
         end  
    end
end
