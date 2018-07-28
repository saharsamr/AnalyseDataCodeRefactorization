%% Utils
% This class contains helping function which we may need for data extraction and
% are not related to a specific part of analyse.

    %% Find the Indecis of All Accurances
    % This funtion take two arguments, the *container* and the *key*. then will
    % search in container and return the indecis of all accurance of the key.
        function indices = find_all (container, key)
            indices = find(cellfun(@(x) ~isempty(x), ...
                           strfind(container, key) ...
                       )) ...
            ;
        end

    %% Check the Existance of a Special key
    % This function again takes the *container* and *key*, and this time, checks
    % wether there exist an accurance of that key in container or not. The output
    % of this function is a *boolean*.
        function result = do_exist (container, key)
            result = ~isempty(Utils.Util.find_all(container, key));
        end

    %% Find the Index of the Last Accurance
    % Here, the function returns the index of last accurance of the key in the
    % container passed to it as arguments.
        function result = find_last (container, key)
            result = find(cellfun(@(x) ~isempty(x), ...
                         strfind(container, key) ...
                 ), 1, 'last' ...
            );
         end

    %% Find In a String and Convert To Double
    % The functionality of this function is that it takes 3 arguments, first the
    % *string* in which it should search for the double value, seconde the
    % *deliminator* that deliminates the explanation and the value itself, third
    % the *diff index* which stands for number of characters we should pass after
    % the deliminator to retreive the double value. Finally this function will
    % parse this value to double and return.
         function result = substr2double (string, delimeter, diff_index)
             result = str2double(string(strfind(string, delimeter)+diff_index : end));
         end
