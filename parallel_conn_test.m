
db_name = 'constance';
db_user= 'constance';
db_password= 'constance';

nworkers = 10;
conn_cell = cell(1,nworkers);
return_cell = cell(1,nworkers);
my_parpool = parpool('local',nworkers);

for i =1:nworkers
    conn_cell{i} = database(db_name,db_user,db_password,'com.mysql.jdbc.Driver','jdbc:mysql://mysql/');
end 

%parfor i = 1:nchnunks
spmd  
    index = labindex;
    %fprintf(sprintf('Worker: %d\n', index));
    return_cell{index} = fetch(conn_cell{index}, 'select * from Session');
end

for i = 1:nworkers
    close(conn_cell{i});
end

%TODO
% what is parallel.pool.Constant --> pass array using conns?
% alternative approaches for serialization