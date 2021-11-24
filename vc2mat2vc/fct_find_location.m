function location = fct_find_location(input_structure, var_str)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
location = find(ismember(input_structure.Frames{1}.ComponentNames, var_str));

if ~isempty(location)
    fprintf(['\nLocated ' var_str ' at position ' num2str(location), '\n'])
else
    fprintf(2, ['\nFind location of ' var_str, ' failed! Check with list below \n'])
    fprintf(2, '\n---------------------------------------------------\n')
    for iname = 1:length(input_structure.Frames{1}.ComponentNames)
        fprintf(2, [num2str(iname), ' ' input_structure.Frames{1}.ComponentNames{iname} '\n'])
    end
    fprintf(2, '\n---------------------------------------------------\n')
    return
end

end

