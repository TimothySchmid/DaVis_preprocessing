function fun_print_statement_finished(tStart)
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here

tEnd = toc(tStart);
d = datetime;
s1 = char(d);

fprintf('\n')
fprintf('-----------------------------------------------\n')
fprintf(['Wall clock time: ', num2str(round(tEnd/60,2)), ' minutes\n'])
fprintf('-----------------------------------------------\n')
fprintf(['Processing finished on: ', s1, '\n'])
fprintf('-----------------------------------------------\n')
end

