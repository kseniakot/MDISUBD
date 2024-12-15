--////////////LOGS
select * from logs
join action on action.id = logs.action_id;
