profile on;
sim('SimulacionDataRealLaptop');
profile_info = profile('info');
profile off;

% Esto da tiempo total estimado (no exacto pero útil para comparar)
total_time = profile_info.FunctionTable(1).TotalTime;
fprintf('Simulink exec time: %.4f seconds\n', total_time);