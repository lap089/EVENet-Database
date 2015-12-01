print [dbo].isUserExisted('hkhoi@apcs.vn')
exec createRoot 'hkhoi@apcs.vn', 'Khoideptrai', null
exec createIndividual 'lqtrung@apcs.vn', 'unrepentantSlacker', null, 'Trung', null, 'Let', '1995-11-1', 1
exec follow 'hkhoi@apcs.vn', 'tqhuy@apcs.vn'
print [dbo].isFollowing ('tqhuy@apcs.vn', 'hkhoi@apcs.vn')
exec followerList 'hkhoi@apcs.vn'
exec followingList 'hkhoi@apcs.vn'
