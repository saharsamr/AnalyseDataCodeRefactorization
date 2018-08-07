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

         function result = find_first (container, key)
             result = find(cellfun(@(x) ~isempty(x), ...
                          strfind(container, key) ...
                  ), 1 ...
             );
          end

         function result = substr2double (string, start_delimeter, start_diff_index, end_delimeter, end_diff_index)
             if nargin < 4
                 result = str2double(string(strfind(string, start_delimeter)+start_diff_index:end));
             else
                 result = str2double(string( ...
                                    strfind(string, start_delimeter)+start_diff_index ...
                                    : ...
                                    strfind(string, end_delimeter)-end_diff_index) ...
                );
            end
         end

         function result = find_all_indices_contain_some_words(container, varargin)
             result = [];
             for i = 1:nargin-1
                 indices = Utils.Util.find_all(container, varargin(i));
                 result = union(result, indices);
             end
         end
    end
end
