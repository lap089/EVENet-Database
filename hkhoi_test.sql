print [dbo].isUserExisted('hkhoi@apcs.vn')
exec createRoot 'hkhoi@apcs.vn', 'Khoideptrai', null
exec createIndividual 'lqtrung@apcs.vn', 'unrepentantSlacker', null, 'Trung', null, 'Let', '1995-11-1', 1
exec follow 'hkhoi@apcs.vn', 'tqhuy@apcs.vn'
print [dbo].isFollowing ('tqhuy@apcs.vn', 'hkhoi@apcs.vn')
exec followerList 'hkhoi@apcs.vn'
exec followingList 'hkhoi@apcs.vn'
exec createLocation N'Nhà em', N'Đẹp trai', 'tada padum', 69, 96, null
exec createEvent '2015-12-24', '2015-12-25', N'Đêm thánh vô cùng', 'Christmas!', null, 'lqtrung@apcs.vn'
exec editLocation 1, 0