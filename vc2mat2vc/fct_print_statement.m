function fct_print_statement(statement)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

switch statement
    case 'cleaning'
        fprintf('\nClean and prepare data ------------------------\n')
        fprintf('-----------------------------------------------\n')
        fprintf('\n \n')
        
    case 'material'
        fprintf('\nCalculate Lagrangian sum ----------------------\n')
        fprintf('-----------------------------------------------\n')
        fprintf('\n \n')
        
    case 'H'
        fprintf('\nCalculate displacement gradient tensor H ------\n')
        fprintf('-----------------------------------------------\n')
        fprintf('\n \n')
        
    case 'F'
        fprintf('\nCalculate deformation gradient tensor F -------\n')
        fprintf('-----------------------------------------------\n')
        fprintf('\n \n')
        
    case 'save'
        fprintf('\nSaving ----------------------------------------\n')
        fprintf('-----------------------------------------------\n')
        fprintf('\n \n')
        
    case 'summation'
        fprintf('\nMaterial displacement summation ---------------\n')
        fprintf('-----------------------------------------------\n')
        fprintf('\n \n')
        
    otherwise
end

end

