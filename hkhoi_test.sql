exec createIndividual 'lqtrung@apcs.vn', 'Thisguysucks', null, 'Son', 'Xuan', 'Trinh', '1995-01-01', 1

select * from [User]
exec createEvent '2015-12-24', '2015-12-25', 'Holy Night', 'Christmas', 1, 'txson@apcs.vn'
exec invite 1, 'tqhuy@apcs.vn'
exec listInvitedEvents 'hkhoi@apcs.vn', 1
select * from UserEventAttendants
