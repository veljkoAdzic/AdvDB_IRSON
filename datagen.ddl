-- Data Inserted

INSERT INTO SPORT (name) VALUES
('Football'),
('Basketball'),
('Handball'),
('Volleyball'),
('Tennis'),
('Athletics'),
('Boxing'),
('Rugby'),
('Hockey'),
('Baseball'),
('Softball'),
('Cricket'),
('Golf'),
('Cycling'),
('Weightlifting'),
('Wrestling'),
('Judo'),
('Karate'),
('Taekwondo'),
('Fencing'),
('Archery'),
('Rowing'),
('Sailing'),
('Skiing'),
('Ice Hockey'),
('Triathlon'),
('Badminton'),
('Table Tennis'),
('Squash'),
('Water Polo'),
('Gymnastics'),
('Equestrian'),
('Canoeing'),
('Curling'),
('Biathlon'),
('Polo'),
('Lacrosse'),
('Futsal'),
('Beach Volleyball'),
('Kickboxing');

INSERT INTO COUNTRY (name, abreviation) VALUES
('Afghanistan', 'AFG'), ('Albania', 'ALB'), ('Algeria', 'ALG'),
('Andorra', 'AND'), ('Angola', 'ANG'), ('Argentina', 'ARG'),
('Armenia', 'ARM'), ('Australia', 'AUS'), ('Austria', 'AUT'),
('Azerbaijan', 'AZE'), ('Bahamas', 'BAH'), ('Bahrain', 'BRN'),
('Bangladesh', 'BAN'), ('Belarus', 'BLR'), ('Belgium', 'BEL'),
('Belize', 'BLZ'), ('Benin', 'BEN'), ('Bhutan', 'BHU'),
('Bolivia', 'BOL'), ('Bosnia', 'BIH'), ('Botswana', 'BOT'),
('Brazil', 'BRA'), ('Brunei', 'BRU'), ('Bulgaria', 'BUL'),
('Burkina Faso', 'BUR'), ('Burundi', 'BDI'), ('Cambodia', 'CAM'),
('Cameroon', 'CMR'), ('Canada', 'CAN'), ('Cape Verde', 'CPV'),
('Chad', 'CHA'), ('Chile', 'CHI'), ('China', 'CHN'),
('Colombia', 'COL'), ('Comoros', 'COM'), ('Congo', 'CGO'),
('Costa Rica', 'CRC'), ('Croatia', 'CRO'), ('Cuba', 'CUB'),
('Cyprus', 'CYP'), ('Czech Republic', 'CZE'), ('Denmark', 'DEN'),
('Djibouti', 'DJI'), ('Dominican Republic', 'DOM'), ('Ecuador', 'ECU'),
('Egypt', 'EGY'), ('El Salvador', 'ESA'), ('Estonia', 'EST'),
('Ethiopia', 'ETH'), ('Fiji', 'FIJ'), ('Finland', 'FIN'),
('France', 'FRA'), ('Gabon', 'GAB'), ('Gambia', 'GAM'),
('Georgia', 'GEO'), ('Germany', 'GER'), ('Ghana', 'GHA'),
('Greece', 'GRE'), ('Guatemala', 'GUA'), ('Guinea', 'GUI'),
('Haiti', 'HAI'), ('Honduras', 'HON'), ('Hungary', 'HUN'),
('Iceland', 'ISL'), ('India', 'IND'), ('Indonesia', 'INA'),
('Iran', 'IRI'), ('Iraq', 'IRQ'), ('Ireland', 'IRL'),
('Israel', 'ISR'), ('Italy', 'ITA'), ('Jamaica', 'JAM'),
('Japan', 'JPN'), ('Jordan', 'JOR'), ('Kazakhstan', 'KAZ'),
('Kenya', 'KEN'), ('Kosovo', 'KOS'), ('Kuwait', 'KUW'),
('Kyrgyzstan', 'KGZ'), ('Laos', 'LAO'), ('Latvia', 'LAT'),
('Lebanon', 'LIB'), ('Lesotho', 'LES'), ('Liberia', 'LBR'),
('Libya', 'LBA'), ('Lithuania', 'LTU'), ('Luxembourg', 'LUX'),
('Madagascar', 'MAD'), ('Malawi', 'MAW'), ('Malaysia', 'MAS'),
('Maldives', 'MDV'), ('Mali', 'MLI'), ('Malta', 'MLT'),
('Mauritania', 'MTN'), ('Mauritius', 'MRI'), ('Mexico', 'MEX'),
('Moldova', 'MDA'), ('Monaco', 'MON'), ('Mongolia', 'MGL'),
('Montenegro', 'MNE'), ('Morocco', 'MAR'), ('Mozambique', 'MOZ'),
('Myanmar', 'MYA'), ('Namibia', 'NAM'), ('Nepal', 'NEP'),
('Netherlands', 'NED'), ('New Zealand', 'NZL'), ('Nicaragua', 'NCA'),
('Niger', 'NIG'), ('Nigeria', 'NGR'), ('North Korea', 'PRK'),
('North Macedonia', 'MKD'), ('Norway', 'NOR'), ('Oman', 'OMA'),
('Pakistan', 'PAK'), ('Palestine', 'PLE'), ('Panama', 'PAN'),
('Paraguay', 'PAR'), ('Peru', 'PER'), ('Philippines', 'PHI'),
('Poland', 'POL'), ('Portugal', 'POR'), ('Qatar', 'QAT'),
('Romania', 'ROU'), ('Russia', 'RUS'), ('Rwanda', 'RWA'),
('Saudi Arabia', 'KSA'), ('Senegal', 'SEN'), ('Serbia', 'SRB'),
('Sierra Leone', 'SLE'), ('Singapore', 'SGP'), ('Slovakia', 'SVK'),
('Slovenia', 'SLO'), ('Somalia', 'SOM'), ('South Africa', 'RSA'),
('South Korea', 'KOR'), ('South Sudan', 'SSD'), ('Spain', 'ESP'),
('Sri Lanka', 'SRI'), ('Sudan', 'SUD'), ('Suriname', 'SUR'),
('Sweden', 'SWE'), ('Switzerland', 'SUI'), ('Syria', 'SYR'),
('Taiwan', 'TPE'), ('Tajikistan', 'TJK'), ('Tanzania', 'TAN'),
('Thailand', 'THA'), ('Togo', 'TOG'), ('Trinidad', 'TTO'),
('Tunisia', 'TUN'), ('Turkey', 'TUR'), ('Turkmenistan', 'TKM'),
('Uganda', 'UGA'), ('Ukraine', 'UKR'), ('UAE', 'UAE'),
('United Kingdom', 'GBR'), ('Uruguay', 'URU'), ('USA', 'USA'),
('Uzbekistan', 'UZB'), ('Venezuela', 'VEN'), ('Vietnam', 'VIE'),
('Yemen', 'YEM'), ('Zambia', 'ZAM'), ('Zimbabwe', 'ZIM');

INSERT INTO SPONSOR (name)
SELECT DISTINCT
    prefix || ' ' || industry || ' ' || suffix || ' ' || num
FROM
    (VALUES
        ('Alpha'), ('Beta'), ('Gamma'), ('Delta'), ('Omega'),
        ('Prime'), ('Elite'), ('Pro'), ('Max'), ('Ultra'),
        ('Global'), ('Euro'), ('Trans'), ('Inter'), ('Neo'),
        ('Apex'), ('Peak'), ('Summit'), ('Core'), ('Axis'),
        ('Vega'), ('Nova'), ('Orion'), ('Atlas'), ('Titan'),
        ('Zeus'), ('Ares'), ('Hermes'), ('Apollo'), ('Hera'),
        ('Red'), ('Blue'), ('Green'), ('Black'), ('White'),
        ('Gold'), ('Silver'), ('Iron'), ('Steel'), ('Fire')
    ) AS p(prefix)
CROSS JOIN
    (VALUES
        ('Sport'), ('Tech'), ('Energy'), ('Media'), ('Finance'),
        ('Health'), ('Auto'), ('Food'), ('Travel'), ('Build'),
        ('Trade'), ('Logic'), ('Vision'), ('Power'), ('Data'),
        ('Net'), ('Air'), ('Sea'), ('Land'), ('Sky'),
        ('Fit'), ('Run'), ('Play'), ('Win'), ('Race'),
        ('Move'), ('Drive'), ('Boost'), ('Flex'), ('Gear')
    ) AS i(industry)
CROSS JOIN
    (VALUES
        ('Group'), ('Corp'), ('Ltd'), ('Inc'), ('Co'),
        ('Hub'), ('Lab'), ('Plus'), ('One'), ('Pro')
    ) AS s(suffix)
CROSS JOIN
    (VALUES
        ('1'),('2'),('3'),('4'),('5'),
        ('6'),('7'),('8'),('9'),('10')
    ) AS n(num)
WHERE length(prefix || ' ' || industry || ' ' || suffix || ' ' || num) <= 30
LIMIT 10000;

INSERT INTO SPORT_CATEGORY
  (name, sport_id, gender, duration_minutes, specification,
   team_capacity, points_per_win, points_per_draw, points_per_losing)
VALUES
('Men''s Football – 11-a-side',         1,'M',90,'Standard 11-a-side outdoor',          11,3,1,0),
('Women''s Football – 11-a-side',       1,'F',90,'Standard 11-a-side outdoor',          11,3,1,0),
('Men''s Football – Futsal',            1,'M',40,'5-a-side indoor variant',               5,3,1,0),
('Women''s Football – Futsal',          1,'F',40,'5-a-side indoor variant',               5,3,1,0),
('Men''s Football – Beach Soccer',      1,'M',36,'3×12-min periods, sand pitch',          5,3,1,0),
('Women''s Football – Beach Soccer',    1,'F',36,'3×12-min periods, sand pitch',          5,3,1,0),
('Men''s Football – Under-21',          1,'M',90,'Youth Olympic / U21 tournament',       11,3,1,0),
('Women''s Football – Under-20',        1,'F',90,'FIFA Women''s World Youth',            11,3,1,0),
('Men''s Basketball – 5-on-5',         2,'M',40,'FIBA regulation 4×10 min quarters',    5,3,0,1),
('Women''s Basketball – 5-on-5',       2,'F',40,'FIBA regulation 4×10 min quarters',    5,3,0,1),
('Men''s Basketball – 3×3',            2,'M',10,'FIBA 3×3, half-court',                  3,3,0,1),
('Women''s Basketball – 3×3',          2,'F',10,'FIBA 3×3, half-court',                  3,3,0,1),
('Men''s Basketball – Wheelchair',     2,'M',40,'Paralympic classification',              5,3,0,1),
('Women''s Basketball – Wheelchair',   2,'F',40,'Paralympic classification',              5,3,0,1),
('Men''s Handball – Indoor',           3,'M',60,'2×30-min halves, 7-a-side',             7,3,1,0),
('Women''s Handball – Indoor',         3,'F',60,'2×30-min halves, 7-a-side',             7,3,1,0),
('Men''s Beach Handball',              3,'M',20,'2×10-min periods, 4-a-side',             4,3,0,1),
('Women''s Beach Handball',            3,'F',20,'2×10-min periods, 4-a-side',             4,3,0,1),
('Men''s Volleyball – Indoor',         4,'M',90,'Best-of-5 sets, 6-a-side',              6,3,0,1),
('Women''s Volleyball – Indoor',       4,'F',90,'Best-of-5 sets, 6-a-side',              6,3,0,1),
('Men''s Beach Volleyball',            4,'M',45,'Best-of-3 sets, 2-a-side',              2,3,0,1),
('Women''s Beach Volleyball',          4,'F',45,'Best-of-3 sets, 2-a-side',              2,3,0,1),
('Men''s Snow Volleyball',             4,'M',40,'3-a-side on snow court',                 3,3,0,1),
('Women''s Snow Volleyball',           4,'F',40,'3-a-side on snow court',                 3,3,0,1),
('Men''s Tennis – Singles',            5,'M',180,'Best-of-5 sets (Grand Slams)',          1,3,0,1),
('Women''s Tennis – Singles',          5,'F',120,'Best-of-3 sets',                        1,3,0,1),
('Men''s Tennis – Doubles',            5,'M',120,'Best-of-3 sets',                        2,3,0,1),
('Women''s Tennis – Doubles',          5,'F',120,'Best-of-3 sets',                        2,3,0,1),
('Mixed Tennis – Doubles',             5,'M',120,'Mixed-gender doubles',                  2,3,0,1),
('Men''s Athletics – Track Sprint',    6,'M',1,'100m/200m/400m events',                  1,3,0,1),
('Women''s Athletics – Track Sprint',  6,'F',1,'100m/200m/400m events',                  1,3,0,1),
('Men''s Athletics – Middle Distance', 6,'M',4,'800m/1500m events',                       1,3,0,1),
('Women''s Athletics – Middle Distance',6,'F',4,'800m/1500m events',                      1,3,0,1),
('Men''s Athletics – Long Distance',   6,'M',30,'5000m/10000m events',                    1,3,0,1),
('Women''s Athletics – Long Distance', 6,'F',30,'5000m/10000m events',                    1,3,0,1),
('Men''s Athletics – Marathon',        6,'M',130,'Road race, 42.195 km',                  1,3,0,1),
('Women''s Athletics – Marathon',      6,'F',145,'Road race, 42.195 km',                  1,3,0,1),
('Men''s Athletics – Hurdles',         6,'M',2,'110m/400m hurdles',                       1,3,0,1),
('Women''s Athletics – Hurdles',       6,'F',2,'100m/400m hurdles',                       1,3,0,1),
('Men''s Athletics – Steeplechase',    6,'M',8,'3000m steeplechase',                      1,3,0,1),
('Women''s Athletics – Steeplechase',  6,'F',10,'3000m steeplechase',                     1,3,0,1),
('Men''s Athletics – Relay',           6,'M',1,'4×100m and 4×400m relay',                4,3,0,1),
('Women''s Athletics – Relay',         6,'F',1,'4×100m and 4×400m relay',                4,3,0,1),
('Men''s Athletics – High Jump',       6,'M',60,'Field jump event',                        1,3,0,1),
('Women''s Athletics – High Jump',     6,'F',60,'Field jump event',                        1,3,0,1),
('Men''s Athletics – Long Jump',       6,'M',60,'Field jump event',                        1,3,0,1),
('Women''s Athletics – Long Jump',     6,'F',60,'Field jump event',                        1,3,0,1),
('Men''s Athletics – Triple Jump',     6,'M',60,'Field jump event',                        1,3,0,1),
('Women''s Athletics – Triple Jump',   6,'F',60,'Field jump event',                        1,3,0,1),
('Men''s Athletics – Pole Vault',      6,'M',90,'Field vault event',                       1,3,0,1),
('Women''s Athletics – Pole Vault',    6,'F',90,'Field vault event',                       1,3,0,1),
('Men''s Athletics – Shot Put',        6,'M',60,'Throwing event',                          1,3,0,1),
('Women''s Athletics – Shot Put',      6,'F',60,'Throwing event',                          1,3,0,1),
('Men''s Athletics – Discus',          6,'M',60,'Throwing event',                          1,3,0,1),
('Women''s Athletics – Discus',        6,'F',60,'Throwing event',                          1,3,0,1),
('Men''s Athletics – Hammer',          6,'M',60,'Throwing event',                          1,3,0,1),
('Women''s Athletics – Hammer',        6,'F',60,'Throwing event',                          1,3,0,1),
('Men''s Athletics – Javelin',         6,'M',60,'Throwing event',                          1,3,0,1),
('Women''s Athletics – Javelin',       6,'F',60,'Throwing event',                          1,3,0,1),
('Men''s Athletics – Decathlon',       6,'M',600,'10 events over 2 days',                  1,3,0,1),
('Women''s Athletics – Heptathlon',    6,'F',480,'7 events over 2 days',                   1,3,0,1),
('Men''s Athletics – Race Walk 20km',  6,'M',90,'Road race walk',                          1,3,0,1),
('Women''s Athletics – Race Walk 20km',6,'F',100,'Road race walk',                         1,3,0,1),
('Men''s Boxing – Light Flyweight',    7,'M',9,'Up to 49 kg, 3×3-min rounds',             1,3,0,1),
('Men''s Boxing – Flyweight',          7,'M',9,'Up to 52 kg, 3×3-min rounds',             1,3,0,1),
('Men''s Boxing – Bantamweight',       7,'M',9,'Up to 56 kg',                              1,3,0,1),
('Men''s Boxing – Featherweight',      7,'M',9,'Up to 60 kg',                              1,3,0,1),
('Men''s Boxing – Lightweight',        7,'M',9,'Up to 64 kg',                              1,3,0,1),
('Men''s Boxing – Welterweight',       7,'M',9,'Up to 69 kg',                              1,3,0,1),
('Men''s Boxing – Middleweight',       7,'M',9,'Up to 75 kg',                              1,3,0,1),
('Men''s Boxing – Light Heavyweight',  7,'M',9,'Up to 81 kg',                              1,3,0,1),
('Men''s Boxing – Heavyweight',        7,'M',9,'Up to 91 kg',                              1,3,0,1),
('Men''s Boxing – Super Heavyweight',  7,'M',9,'Over 91 kg',                               1,3,0,1),
('Women''s Boxing – Flyweight',        7,'F',9,'Up to 50 kg, 3×3-min rounds',             1,3,0,1),
('Women''s Boxing – Lightweight',      7,'F',9,'Up to 60 kg',                              1,3,0,1),
('Women''s Boxing – Welterweight',     7,'F',9,'Up to 66 kg',                              1,3,0,1),
('Women''s Boxing – Middleweight',     7,'F',9,'Up to 75 kg',                              1,3,0,1),
('Women''s Boxing – Heavyweight',      7,'F',9,'Up to 81 kg',                              1,3,0,1),
('Men''s Rugby Union – 15s',           8,'M',80,'2×40-min halves, 15-a-side',            15,4,2,0),
('Women''s Rugby Union – 15s',         8,'F',80,'2×40-min halves, 15-a-side',            15,4,2,0),
('Men''s Rugby Sevens',                8,'M',14,'2×7-min halves, 7-a-side',               7,4,2,0),
('Women''s Rugby Sevens',              8,'F',14,'2×7-min halves, 7-a-side',               7,4,2,0),
('Men''s Rugby League',               8,'M',80,'2×40-min halves, 13-a-side',            13,2,1,0),
('Women''s Rugby League',             8,'F',80,'2×40-min halves, 13-a-side',            13,2,1,0),
('Men''s Field Hockey',                9,'M',60,'4×15-min quarters, 11-a-side',          11,3,1,0),
('Women''s Field Hockey',              9,'F',60,'4×15-min quarters, 11-a-side',          11,3,1,0),
('Men''s Baseball',                   10,'M',180,'9 innings, standard rules',              9,2,0,1),
('Women''s Baseball',                 10,'F',150,'9 innings, women''s rules',              9,2,0,1),
('Men''s Softball – Slow Pitch',      11,'M',60,'7 innings slow pitch',                   9,2,0,1),
('Women''s Softball – Fast Pitch',    11,'F',60,'7 innings fast pitch',                   9,2,0,1),
('Mixed Softball – Slow Pitch',       11,'M',60,'Co-ed, mixed gender roster',             9,2,0,1),
('Men''s Cricket – Test Match',       12,'M',450,'5-day match, 11-a-side',               11,1,1,0),
('Women''s Cricket – Test Match',     12,'F',450,'5-day women''s test',                  11,1,1,0),
('Men''s Cricket – ODI',              12,'M',480,'50-over one-day international',         11,2,1,0),
('Women''s Cricket – ODI',            12,'F',480,'50-over one-day international',         11,2,1,0),
('Men''s Cricket – T20',              12,'M',80,'20-over format',                         11,2,0,1),
('Women''s Cricket – T20',            12,'F',80,'20-over format',                         11,2,0,1),
('Men''s Golf – Stroke Play',         13,'M',240,'72-hole stroke play tournament',         1,3,0,1),
('Women''s Golf – Stroke Play',       13,'F',240,'72-hole stroke play tournament',         1,3,0,1),
('Men''s Golf – Match Play',          13,'M',240,'Hole-by-hole competition',               1,3,0,1),
('Women''s Golf – Match Play',        13,'F',240,'Hole-by-hole competition',               1,3,0,1),
('Men''s Golf – Team Ryder Cup',      13,'M',240,'Foursomes/fourballs, 12-man teams',     12,2,1,0),
('Women''s Golf – Solheim Cup',       13,'F',240,'Foursomes/fourballs, 12-woman teams',   12,2,1,0),
('Men''s Cycling – Road Race',        14,'M',300,'Mass-start road race',                   1,3,0,1),
('Women''s Cycling – Road Race',      14,'F',240,'Mass-start road race',                   1,3,0,1),
('Men''s Cycling – Time Trial',       14,'M',60,'Individual time trial',                   1,3,0,1),
('Women''s Cycling – Time Trial',     14,'F',45,'Individual time trial',                   1,3,0,1),
('Men''s Cycling – Track Sprint',     14,'M',4,'Track sprint / keirin',                    1,3,0,1),
('Women''s Cycling – Track Sprint',   14,'F',4,'Track sprint / keirin',                    1,3,0,1),
('Men''s Cycling – Track Endurance',  14,'M',50,'Points race / omnium',                    1,3,0,1),
('Women''s Cycling – Track Endurance',14,'F',50,'Points race / omnium',                    1,3,0,1),
('Men''s Cycling – Mountain Bike XC', 14,'M',90,'Cross-country off-road',                  1,3,0,1),
('Women''s Cycling – Mountain Bike XC',14,'F',75,'Cross-country off-road',                 1,3,0,1),
('Men''s Cycling – BMX Racing',       14,'M',1,'Sprint elimination format',                1,3,0,1),
('Women''s Cycling – BMX Racing',     14,'F',1,'Sprint elimination format',                1,3,0,1),
('Men''s Cycling – Team Pursuit',     14,'M',4,'4-km team pursuit, track',                 4,3,0,1),
('Women''s Cycling – Team Pursuit',   14,'F',4,'4-km team pursuit, track',                 4,3,0,1),
('Men''s Weightlifting – 61 kg',      15,'M',30,'Snatch + clean & jerk combined',          1,3,0,1),
('Men''s Weightlifting – 73 kg',      15,'M',30,'Snatch + clean & jerk combined',          1,3,0,1),
('Men''s Weightlifting – 89 kg',      15,'M',30,'Snatch + clean & jerk combined',          1,3,0,1),
('Men''s Weightlifting – 102 kg',     15,'M',30,'Snatch + clean & jerk combined',          1,3,0,1),
('Men''s Weightlifting – 109 kg',     15,'M',30,'Snatch + clean & jerk combined',          1,3,0,1),
('Men''s Weightlifting – 109+ kg',    15,'M',30,'Unlimited class',                          1,3,0,1),
('Women''s Weightlifting – 49 kg',    15,'F',30,'Snatch + clean & jerk combined',          1,3,0,1),
('Women''s Weightlifting – 59 kg',    15,'F',30,'Snatch + clean & jerk combined',          1,3,0,1),
('Women''s Weightlifting – 71 kg',    15,'F',30,'Snatch + clean & jerk combined',          1,3,0,1),
('Women''s Weightlifting – 87 kg',    15,'F',30,'Snatch + clean & jerk combined',          1,3,0,1),
('Women''s Weightlifting – 87+ kg',   15,'F',30,'Unlimited class',                          1,3,0,1),
('Men''s Wrestling – Freestyle 57 kg',16,'M',6,'3+3 minutes, two periods',                1,3,0,1),
('Men''s Wrestling – Freestyle 65 kg',16,'M',6,'Freestyle rules',                          1,3,0,1),
('Men''s Wrestling – Freestyle 74 kg',16,'M',6,'Freestyle rules',                          1,3,0,1),
('Men''s Wrestling – Freestyle 86 kg',16,'M',6,'Freestyle rules',                          1,3,0,1),
('Men''s Wrestling – Freestyle 97 kg',16,'M',6,'Freestyle rules',                          1,3,0,1),
('Men''s Wrestling – Freestyle 125 kg',16,'M',6,'Freestyle rules',                         1,3,0,1),
('Men''s Wrestling – Greco-Roman 60 kg',16,'M',6,'Greco-Roman rules',                      1,3,0,1),
('Men''s Wrestling – Greco-Roman 77 kg',16,'M',6,'Greco-Roman rules',                      1,3,0,1),
('Men''s Wrestling – Greco-Roman 130 kg',16,'M',6,'Greco-Roman rules',                     1,3,0,1),
('Women''s Wrestling – Freestyle 50 kg',16,'F',6,'Freestyle rules',                        1,3,0,1),
('Women''s Wrestling – Freestyle 57 kg',16,'F',6,'Freestyle rules',                        1,3,0,1),
('Women''s Wrestling – Freestyle 68 kg',16,'F',6,'Freestyle rules',                        1,3,0,1),
('Women''s Wrestling – Freestyle 76 kg',16,'F',6,'Freestyle rules',                        1,3,0,1),
('Men''s Judo – Extra Lightweight',   17,'M',4,'Up to 60 kg, Olympic mat',                1,3,0,1),
('Men''s Judo – Half Lightweight',    17,'M',4,'Up to 66 kg',                              1,3,0,1),
('Men''s Judo – Lightweight',         17,'M',4,'Up to 73 kg',                              1,3,0,1),
('Men''s Judo – Half Middleweight',   17,'M',4,'Up to 81 kg',                              1,3,0,1),
('Men''s Judo – Middleweight',        17,'M',4,'Up to 90 kg',                              1,3,0,1),
('Men''s Judo – Half Heavyweight',    17,'M',4,'Up to 100 kg',                             1,3,0,1),
('Men''s Judo – Heavyweight',         17,'M',4,'Over 100 kg',                              1,3,0,1),
('Women''s Judo – Extra Lightweight', 17,'F',4,'Up to 48 kg',                              1,3,0,1),
('Women''s Judo – Half Lightweight',  17,'F',4,'Up to 52 kg',                              1,3,0,1),
('Women''s Judo – Lightweight',       17,'F',4,'Up to 57 kg',                              1,3,0,1),
('Women''s Judo – Half Middleweight', 17,'F',4,'Up to 63 kg',                              1,3,0,1),
('Women''s Judo – Middleweight',      17,'F',4,'Up to 70 kg',                              1,3,0,1),
('Women''s Judo – Half Heavyweight',  17,'F',4,'Up to 78 kg',                              1,3,0,1),
('Women''s Judo – Heavyweight',       17,'F',4,'Over 78 kg',                               1,3,0,1),
('Mixed Judo – Team Event',           17,'M',4,'3M+3F per team, alternating bouts',        6,3,0,1),
('Men''s Karate – Kata Individual',   18,'M',5,'Solo performance judged',                  1,3,0,1),
('Women''s Karate – Kata Individual', 18,'F',5,'Solo performance judged',                  1,3,0,1),
('Men''s Karate – Kata Team',         18,'M',5,'Team synchronised kata',                   3,3,0,1),
('Women''s Karate – Kata Team',       18,'F',5,'Team synchronised kata',                   3,3,0,1),
('Men''s Karate – Kumite 60 kg',      18,'M',3,'Sparring under 60 kg',                     1,3,0,1),
('Men''s Karate – Kumite 75 kg',      18,'M',3,'Sparring under 75 kg',                     1,3,0,1),
('Men''s Karate – Kumite 75+ kg',     18,'M',3,'Sparring over 75 kg',                      1,3,0,1),
('Women''s Karate – Kumite 55 kg',    18,'F',3,'Sparring under 55 kg',                     1,3,0,1),
('Women''s Karate – Kumite 61 kg',    18,'F',3,'Sparring under 61 kg',                     1,3,0,1),
('Women''s Karate – Kumite 61+ kg',   18,'F',3,'Sparring over 61 kg',                      1,3,0,1),
('Men''s Taekwondo – 58 kg',          19,'M',9,'3×3-min rounds',                           1,3,0,1),
('Men''s Taekwondo – 68 kg',          19,'M',9,'3×3-min rounds',                           1,3,0,1),
('Men''s Taekwondo – 80 kg',          19,'M',9,'3×3-min rounds',                           1,3,0,1),
('Men''s Taekwondo – 80+ kg',         19,'M',9,'Heavyweight division',                      1,3,0,1),
('Women''s Taekwondo – 49 kg',        19,'F',9,'3×3-min rounds',                           1,3,0,1),
('Women''s Taekwondo – 57 kg',        19,'F',9,'3×3-min rounds',                           1,3,0,1),
('Women''s Taekwondo – 67 kg',        19,'F',9,'3×3-min rounds',                           1,3,0,1),
('Women''s Taekwondo – 67+ kg',       19,'F',9,'Heavyweight division',                      1,3,0,1),
('Men''s Fencing – Foil Individual',  20,'M',9,'3×3-min periods',                          1,3,0,1),
('Women''s Fencing – Foil Individual',20,'F',9,'3×3-min periods',                          1,3,0,1),
('Men''s Fencing – Épée Individual',  20,'M',9,'3×3-min periods',                          1,3,0,1),
('Women''s Fencing – Épée Individual',20,'F',9,'3×3-min periods',                          1,3,0,1),
('Men''s Fencing – Sabre Individual', 20,'M',9,'3×3-min periods',                          1,3,0,1),
('Women''s Fencing – Sabre Individual',20,'F',9,'3×3-min periods',                         1,3,0,1),
('Men''s Fencing – Foil Team',        20,'M',27,'3-fencer relay, 9 bouts',                 3,3,0,1),
('Women''s Fencing – Foil Team',      20,'F',27,'3-fencer relay, 9 bouts',                 3,3,0,1),
('Men''s Fencing – Épée Team',        20,'M',27,'3-fencer relay',                           3,3,0,1),
('Women''s Fencing – Épée Team',      20,'F',27,'3-fencer relay',                           3,3,0,1),
('Men''s Fencing – Sabre Team',       20,'M',27,'3-fencer relay',                           3,3,0,1),
('Women''s Fencing – Sabre Team',     20,'F',27,'3-fencer relay',                           3,3,0,1),
('Men''s Archery – Recurve Individual',21,'M',90,'70 m elimination + final',               1,3,0,1),
('Women''s Archery – Recurve Individual',21,'F',90,'70 m elimination + final',             1,3,0,1),
('Men''s Archery – Recurve Team',     21,'M',60,'3-archer team, 18 ends',                  3,3,0,1),
('Women''s Archery – Recurve Team',   21,'F',60,'3-archer team, 18 ends',                  3,3,0,1),
('Mixed Archery – Recurve Team',      21,'M',60,'1M+1F mixed team',                        2,3,0,1),
('Men''s Archery – Compound Individual',21,'M',60,'50 m, compound bow',                    1,3,0,1),
('Women''s Archery – Compound Individual',21,'F',60,'50 m, compound bow',                  1,3,0,1),
('Men''s Rowing – Single Sculls',     22,'M',8,'2000 m course',                            1,3,0,1),
('Women''s Rowing – Single Sculls',   22,'F',8,'2000 m course',                            1,3,0,1),
('Men''s Rowing – Double Sculls',     22,'M',7,'2000 m course',                            2,3,0,1),
('Women''s Rowing – Double Sculls',   22,'F',7,'2000 m course',                            2,3,0,1),
('Men''s Rowing – Quadruple Sculls',  22,'M',6,'2000 m course',                            4,3,0,1),
('Women''s Rowing – Quadruple Sculls',22,'F',6,'2000 m course',                            4,3,0,1),
('Men''s Rowing – Coxless Pair',      22,'M',7,'2000 m course',                            2,3,0,1),
('Women''s Rowing – Coxless Pair',    22,'F',7,'2000 m course',                            2,3,0,1),
('Men''s Rowing – Coxless Four',      22,'M',6,'2000 m course',                            4,3,0,1),
('Women''s Rowing – Coxless Four',    22,'F',6,'2000 m course',                            4,3,0,1),
('Men''s Rowing – Eight with Cox',    22,'M',5,'2000 m course, coxswain included',         9,3,0,1),
('Women''s Rowing – Eight with Cox',  22,'F',6,'2000 m course, coxswain included',         9,3,0,1),
('Mixed Rowing – Adaptive Single',    22,'M',8,'Paralympic AS category',                   1,3,0,1),
('Men''s Sailing – Laser/ILCA 7',     23,'M',90,'Dinghy single-handed',                    1,3,0,1),
('Women''s Sailing – Laser/ILCA 6',   23,'F',80,'Dinghy single-handed',                    1,3,0,1),
('Men''s Sailing – Finn',             23,'M',90,'Heavy-weather single-handed dinghy',       1,3,0,1),
('Mixed Sailing – 470',               23,'M',90,'Two-person dinghy',                        2,3,0,1),
('Mixed Sailing – Nacra 17 Foiling',  23,'M',60,'Mixed catamaran foiler',                   2,3,0,1),
('Men''s Sailing – 49er Skiff',       23,'M',60,'Double-handed high-performance',           2,3,0,1),
('Women''s Sailing – 49erFX Skiff',   23,'F',60,'Double-handed high-performance',           2,3,0,1),
('Mixed Sailing – RS:X Windsurfer',   23,'M',60,'Windsurfer class',                         1,3,0,1),
('Men''s Alpine Skiing – Downhill',   24,'M',2,'Speed event, single run',                  1,3,0,1),
('Women''s Alpine Skiing – Downhill', 24,'F',2,'Speed event, single run',                  1,3,0,1),
('Men''s Alpine Skiing – Slalom',     24,'M',3,'Technical event, 2 runs combined',          1,3,0,1),
('Women''s Alpine Skiing – Slalom',   24,'F',3,'Technical event, 2 runs combined',          1,3,0,1),
('Men''s Alpine Skiing – Giant Slalom',24,'M',4,'Technical event, 2 runs',                  1,3,0,1),
('Women''s Alpine Skiing – Giant Slalom',24,'F',4,'Technical event, 2 runs',                1,3,0,1),
('Men''s Alpine Skiing – Super-G',    24,'M',2,'Speed + technique combined',                1,3,0,1),
('Women''s Alpine Skiing – Super-G',  24,'F',2,'Speed + technique combined',                1,3,0,1),
('Men''s Alpine Skiing – Combined',   24,'M',5,'Downhill + slalom combined',                1,3,0,1),
('Women''s Alpine Skiing – Combined', 24,'F',5,'Downhill + slalom combined',                1,3,0,1),
('Men''s Freestyle Skiing – Moguls',  24,'M',2,'Mogul field scoring',                       1,3,0,1),
('Women''s Freestyle Skiing – Moguls',24,'F',2,'Mogul field scoring',                       1,3,0,1),
('Men''s Freestyle Skiing – Aerials', 24,'M',2,'Jump scoring',                              1,3,0,1),
('Women''s Freestyle Skiing – Aerials',24,'F',2,'Jump scoring',                             1,3,0,1),
('Men''s Ski Cross',                  24,'M',1,'Head-to-head course elimination',            1,3,0,1),
('Women''s Ski Cross',                24,'F',1,'Head-to-head course elimination',            1,3,0,1),
('Men''s Cross-Country Skiing – 50km',24,'M',120,'Classical/freestyle mass start',           1,3,0,1),
('Women''s Cross-Country – 30km',     24,'F',90,'Classical/freestyle mass start',            1,3,0,1),
('Men''s Ski Jumping – Large Hill',   24,'M',60,'Points for distance + style',              1,3,0,1),
('Women''s Ski Jumping – Normal Hill',24,'F',60,'Points for distance + style',              1,3,0,1),
('Men''s Ice Hockey',                 25,'M',60,'3×20-min periods, 6-a-side',              6,3,0,1),
('Women''s Ice Hockey',               25,'F',60,'3×20-min periods, 6-a-side',              6,3,0,1),
('Men''s Triathlon – Standard',       26,'M',120,'1.5km swim / 40km bike / 10km run',      1,3,0,1),
('Women''s Triathlon – Standard',     26,'F',130,'1.5km swim / 40km bike / 10km run',      1,3,0,1),
('Men''s Triathlon – Sprint',         26,'M',55,'750m / 20km / 5km',                       1,3,0,1),
('Women''s Triathlon – Sprint',       26,'F',60,'750m / 20km / 5km',                       1,3,0,1),
('Mixed Triathlon – Relay',           26,'M',80,'2M+2F, each leg sprint distance',          4,3,0,1),
('Men''s Badminton – Singles',        27,'M',60,'Best-of-3 games to 21',                   1,3,0,1),
('Women''s Badminton – Singles',      27,'F',60,'Best-of-3 games to 21',                   1,3,0,1),
('Men''s Badminton – Doubles',        27,'M',60,'Pairs, best-of-3',                         2,3,0,1),
('Women''s Badminton – Doubles',      27,'F',60,'Pairs, best-of-3',                         2,3,0,1),
('Mixed Badminton – Doubles',         27,'M',60,'One of each gender per pair',              2,3,0,1),
('Men''s Table Tennis – Singles',     28,'M',60,'Best-of-7 games to 11',                   1,3,0,1),
('Women''s Table Tennis – Singles',   28,'F',60,'Best-of-7 games to 11',                   1,3,0,1),
('Men''s Table Tennis – Doubles',     28,'M',60,'Pairs, best-of-5',                         2,3,0,1),
('Women''s Table Tennis – Doubles',   28,'F',60,'Pairs, best-of-5',                         2,3,0,1),
('Mixed Table Tennis – Doubles',      28,'M',60,'Mixed-gender pairs',                       2,3,0,1),
('Men''s Table Tennis – Team',        28,'M',90,'3-player team, 5 singles matches',         3,3,0,1),
('Women''s Table Tennis – Team',      28,'F',90,'3-player team, 5 singles matches',         3,3,0,1),
('Men''s Squash – Singles',           29,'M',60,'Best-of-5 games, PSA rules',               1,3,0,1),
('Women''s Squash – Singles',         29,'F',60,'Best-of-5 games, PSA rules',               1,3,0,1),
('Men''s Squash – Doubles',           29,'M',60,'Pairs, hardball or softball',               2,3,0,1),
('Women''s Squash – Doubles',         29,'F',60,'Pairs',                                     2,3,0,1),
('Mixed Squash – Doubles',            29,'M',60,'Mixed-gender pairs',                        2,3,0,1),
('Men''s Water Polo',                 30,'M',32,'4×8-min periods, 7-a-side',                7,3,0,1),
('Women''s Water Polo',               30,'F',32,'4×8-min periods, 7-a-side',                7,3,0,1),
('Men''s Artistic – All-Around',      31,'M',120,'6 apparatus individual',                  1,3,0,1),
('Women''s Artistic – All-Around',    31,'F',90,'4 apparatus individual',                   1,3,0,1),
('Men''s Artistic – Team',            31,'M',180,'Team combined score, 6 apparatus',        5,3,0,1),
('Women''s Artistic – Team',          31,'F',120,'Team combined score, 4 apparatus',        5,3,0,1),
('Men''s Artistic – Floor Exercise',  31,'M',30,'Floor apparatus final',                    1,3,0,1),
('Men''s Artistic – Pommel Horse',    31,'M',30,'Pommel horse apparatus final',              1,3,0,1),
('Men''s Artistic – Rings',           31,'M',30,'Rings apparatus final',                    1,3,0,1),
('Men''s Artistic – Vault',           31,'M',30,'Vault apparatus final',                    1,3,0,1),
('Men''s Artistic – Parallel Bars',   31,'M',30,'Parallel bars apparatus final',            1,3,0,1),
('Men''s Artistic – High Bar',        31,'M',30,'High bar apparatus final',                 1,3,0,1),
('Women''s Artistic – Vault',         31,'F',30,'Vault apparatus final',                    1,3,0,1),
('Women''s Artistic – Uneven Bars',   31,'F',30,'Uneven bars apparatus final',              1,3,0,1),
('Women''s Artistic – Balance Beam',  31,'F',30,'Balance beam apparatus final',             1,3,0,1),
('Women''s Artistic – Floor Exercise',31,'F',30,'Floor exercise apparatus final',           1,3,0,1),
('Men''s Rhythmic – Group',           31,'M',90,'5-person group, hoops/clubs/ribbons',      5,3,0,1),
('Women''s Rhythmic – Individual',    31,'F',60,'Individual routine, scored',               1,3,0,1),
('Women''s Rhythmic – Group',         31,'F',90,'5-person group',                           5,3,0,1),
('Men''s Trampoline – Individual',    31,'M',10,'10 skill routine',                          1,3,0,1),
('Women''s Trampoline – Individual',  31,'F',10,'10 skill routine',                          1,3,0,1),
('Men''s Acrobatic – Team',           31,'M',25,'Partnership/group acrobatics',              3,3,0,1),
('Women''s Acrobatic – Team',         31,'F',25,'Partnership/group acrobatics',              3,3,0,1),
('Men''s Equestrian – Dressage Ind.',  32,'M',30,'Grand Prix Freestyle',                    1,3,0,1),
('Women''s Equestrian – Dressage Ind.',32,'F',30,'Grand Prix Freestyle',                    1,3,0,1),
('Mixed Equestrian – Dressage Team',  32,'M',120,'3-pair team combined',                   3,3,0,1),
('Men''s Equestrian – Jumping Ind.',  32,'M',90,'Show jumping clear round',                 1,3,0,1),
('Women''s Equestrian – Jumping Ind.',32,'F',90,'Show jumping clear round',                 1,3,0,1),
('Mixed Equestrian – Jumping Team',   32,'M',120,'3-pair team',                             3,3,0,1),
('Men''s Equestrian – Eventing Ind.', 32,'M',540,'Dressage + cross-country + jumping',      1,3,0,1),
('Women''s Equestrian – Eventing Ind.',32,'F',540,'Dressage + cross-country + jumping',     1,3,0,1),
('Mixed Equestrian – Eventing Team',  32,'M',540,'3-pair team eventing',                    3,3,0,1),
('Men''s Canoe Sprint – K1 1000m',    33,'M',4,'Kayak single, 1000 m',                     1,3,0,1),
('Women''s Canoe Sprint – K1 500m',   33,'F',2,'Kayak single, 500 m',                      1,3,0,1),
('Men''s Canoe Sprint – K2 1000m',    33,'M',4,'Kayak double, 1000 m',                     2,3,0,1),
('Women''s Canoe Sprint – K2 500m',   33,'F',2,'Kayak double, 500 m',                      2,3,0,1),
('Men''s Canoe Sprint – K4 500m',     33,'M',2,'Kayak four, 500 m',                        4,3,0,1),
('Women''s Canoe Sprint – K4 500m',   33,'F',2,'Kayak four, 500 m',                        4,3,0,1),
('Men''s Canoe Sprint – C1 1000m',    33,'M',5,'Canoe single, 1000 m',                     1,3,0,1),
('Women''s Canoe Sprint – C1 200m',   33,'F',1,'Canoe single, 200 m',                      1,3,0,1),
('Men''s Canoe Slalom – K1',          33,'M',3,'Whitewater kayak slalom',                   1,3,0,1),
('Women''s Canoe Slalom – K1',        33,'F',3,'Whitewater kayak slalom',                   1,3,0,1),
('Men''s Canoe Slalom – C1',          33,'M',3,'Whitewater canoe slalom',                   1,3,0,1),
('Women''s Canoe Slalom – C1',        33,'F',3,'Whitewater canoe slalom',                   1,3,0,1),
('Mixed Canoe Slalom – C2',           33,'M',3,'Mixed-gender tandem canoe',                 2,3,0,1),
('Men''s Curling',                    34,'M',150,'10 ends, 4-person team',                  4,2,1,0),
('Women''s Curling',                  34,'F',150,'10 ends, 4-person team',                  4,2,1,0),
('Mixed Doubles Curling',             34,'M',75,'5 ends, 1M+1F per team',                   2,2,1,0),
('Men''s Biathlon – Sprint 10km',     35,'M',30,'Ski + 2 shooting stages',                  1,3,0,1),
('Women''s Biathlon – Sprint 7.5km',  35,'F',25,'Ski + 2 shooting stages',                  1,3,0,1),
('Men''s Biathlon – Pursuit 12.5km',  35,'M',36,'Ski + 4 shooting stages',                  1,3,0,1),
('Women''s Biathlon – Pursuit 10km',  35,'F',30,'Ski + 4 shooting stages',                  1,3,0,1),
('Men''s Biathlon – Individual 20km', 35,'M',60,'Classic individual, 4 shooting stages',     1,3,0,1),
('Women''s Biathlon – Individual 15km',35,'F',50,'Classic individual, 4 shooting stages',    1,3,0,1),
('Men''s Biathlon – Mass Start 15km', 35,'M',40,'Mass start, 4 shooting stages',             1,3,0,1),
('Women''s Biathlon – Mass Start 12.5km',35,'F',36,'Mass start, 4 shooting stages',          1,3,0,1),
('Mixed Biathlon – Relay 4×6km',      35,'M',80,'2M+2F relay teams',                        4,3,0,1),
('Men''s Polo – Outdoor',             36,'M',105,'7 chukkers × 7+2 min',                    4,3,1,0),
('Men''s Polo – Arena Polo',          36,'M',42,'6 chukkers × 7 min, indoor',               3,3,1,0),
('Women''s Polo – Outdoor',           36,'F',105,'7 chukkers, women''s tournament',          4,3,1,0),
('Men''s Lacrosse – Field',           37,'M',60,'4×15-min quarters, 10-a-side',            10,3,1,0),
('Women''s Lacrosse – Field',         37,'F',60,'4×15-min quarters, 12-a-side',            12,3,1,0),
('Men''s Lacrosse – Box',             37,'M',45,'3×15-min periods, 6-a-side',               6,3,0,1),
('Women''s Lacrosse – Box',           37,'F',45,'3×15-min periods, 6-a-side',               6,3,0,1),
('Men''s Futsal',                     38,'M',40,'2×20-min halves, 5-a-side',                5,3,1,0),
('Women''s Futsal',                   38,'F',40,'2×20-min halves, 5-a-side',                5,3,1,0),
('Men''s Beach Volleyball',           39,'M',45,'Best-of-3 sets, pairs',                    2,3,0,1),
('Women''s Beach Volleyball',         39,'F',45,'Best-of-3 sets, pairs',                    2,3,0,1),
('Mixed Beach Volleyball',            39,'M',45,'1M+1F per team',                           2,3,0,1),
('Men''s Kickboxing – Point Fighting',40,'M',9,'3×3-min rounds',                            1,3,0,1),
('Women''s Kickboxing – Point Fighting',40,'F',9,'3×3-min rounds',                          1,3,0,1),
('Men''s Kickboxing – Light Contact', 40,'M',9,'3×3-min rounds, controlled contact',        1,3,0,1),
('Women''s Kickboxing – Light Contact',40,'F',9,'3×3-min rounds, controlled contact',       1,3,0,1),
('Men''s Kickboxing – Full Contact',  40,'M',9,'3×3-min rounds, unlimited contact',         1,3,0,1),
('Women''s Kickboxing – Full Contact',40,'F',9,'3×3-min rounds, unlimited contact',         1,3,0,1),
('Men''s Kickboxing – Low Kick',      40,'M',9,'Full contact + low kicks',                   1,3,0,1),
('Women''s Kickboxing – Low Kick',    40,'F',9,'Full contact + low kicks',                   1,3,0,1),
('Men''s Kickboxing – K1 Rules',      40,'M',9,'Knees + kicks + punches, 3×3 min',          1,3,0,1),
('Women''s Kickboxing – K1 Rules',    40,'F',9,'Knees + kicks + punches, 3×3 min',          1,3,0,1);

-- TODO Fix non local support
-- COPY temp_male_names (id, name)
-- FROM 'C:/Users/Lenovo/Desktop/Fakultet-Ja/Fakultet/NapredniBazi/boy_names_2024.csv'
-- DELIMITER ','
-- CSV HEADER;
--
-- COPY temp_female_names (id, name)
-- FROM 'C:/Users/Lenovo/Desktop/Fakultet-Ja/Fakultet/NapredniBazi/girl_names_2024.csv'
-- DELIMITER ','
-- CSV HEADER;
--
-- COPY temp_surnames (surname)
-- FROM 'C:\Users\Lenovo\Desktop\Fakultet-Ja\Fakultet\NapredniBazi\surnames.txt'
-- DELIMITER ','
-- CSV HEADER;


WITH male_names AS (
    SELECT name, row_number() OVER (ORDER BY random()) AS rn
    FROM temp_male_names
),
surnames AS (
    SELECT surname, row_number() OVER (ORDER BY random()) AS rn
    FROM temp_surnames
)
INSERT INTO PERSON (ssn, first_name, last_name, date_of_birth, gender, country_id)
SELECT
    to_char(data.date_of_birth, 'DDMM')||
    to_char(extract(year from data.date_of_birth)::integer % 1000, 'FM009')||
    '4'||
    to_char((1 + floor(random()*8))::int, 'FM9') ||
    '0'||
    to_char(floor(random()*100)::int, 'FM09') as ssn,
    data.first_name,
    data.last_name,
    data.date_of_birth,
    data.gender,
    data.country_id
FROM (
    SELECT
        mn.name as first_name,
        s.surname as last_name,
        (now() - interval '70 years' * random())::date as date_of_birth,
        'M'as gender,
        (floor(random() * 160) + 1)::int as country_id
    FROM male_names mn
        CROSS JOIN surnames s
    LIMIT 500000
) as data
ON CONFLICT (ssn) DO NOTHING;

WITH female_names AS (
    SELECT name, row_number() OVER (ORDER BY random()) AS rn
    FROM temp_female_names
),
surnames AS (
    SELECT surname, row_number() OVER (ORDER BY random()) AS rn
    FROM temp_surnames
)
INSERT INTO PERSON (ssn, first_name, last_name, date_of_birth, gender, country_id)
SELECT
    to_char(data.date_of_birth, 'DDMM')||
    to_char(extract(year from data.date_of_birth)::integer % 1000, 'FM009')||
    '4'||
    to_char((1 + floor(random()*8))::int, 'FM9') ||
    '5'||
    to_char(floor(random()*100)::int, 'FM09') as ssn,
    data.first_name,
    data.last_name,
    data.date_of_birth,
    data.gender,
    data.country_id
FROM (
    SELECT
        mn.name as first_name,
        s.surname as last_name,
        (now() - interval '70 years' * random())::date as date_of_birth,
        'F'as gender,
        (floor(random() * 160) + 1)::int as country_id
    FROM female_names mn
        CROSS JOIN surnames s
    LIMIT 500000
) as data
ON CONFLICT (ssn) DO NOTHING;

--

INSERT INTO FEDERATION (sport_id, name)
SELECT
    s.id as sport_id,
    s.name || ' Federation of ' || c.name as name
FROM SPORT s
    cross join COUNTRY c
WHERE length(s.name || ' Federation of ' || c.name) <=50
ON CONFLICT (name) DO NOTHING;

--

INSERT INTO FEDERATION (sport_id, name)
SELECT id as sport_id,
       'International ' || name || ' Federation' AS name
FROM SPORT
ON CONFLICT (name) Do NOTHING;

INSERT INTO INTERNATIONAL_FEDERATION (id)
SELECT id
FROM FEDERATION
WHERE name LIKE 'International%';

--

INSERT INTO NATIONAL_FEDERATION (id, country_id, international_federation_id)
SELECT f.id,
       c.id,
       inf.id
FROM FEDERATION f
    join SPORT s on s.id = f.sport_id
    join COUNTRY c on f.name = s.name || ' Federation of ' || c.name
    join FEDERATION ifF on ifF.name = 'International ' || s.name || ' Federation'
    join INTERNATIONAL_FEDERATION inf on inf.id = ifF.id
ON CONFLICT DO NOTHING;

--

INSERT INTO SPORT_CLUB (federation_id, name, is_national_representation, country_id)
select f.id as federation_id,
       'National ' || s.name || ' Team of ' || c.name as name,
       TRUE as is_national_representation,
       c.id as country_id
from NATIONAL_FEDERATION nf
    join FEDERATION f on nf.id=f.id
    join SPORT s on s.id=f.sport_id
    join COUNTRY c on nf.country_id=c.id
WHERE length('National ' || s.name || ' Team of ' || c.name) <= 40
ON CONFLICT DO NOTHING;



CREATE TABLE IF NOT EXISTS temp_clubs_names (
    id      bigserial primary key,
    name text
);

-- TODO Fix no nlocal issue
-- COPY temp_clubs_names (name)
-- FROM 'C:\Users\Lenovo\Desktop\Fakultet-Ja\Fakultet\NapredniBazi\clubs.txt'
-- DELIMITER ','
-- CSV HEADER;

INSERT INTO SPORT_CLUB (federation_id, name, is_national_representation, country_id)
SELECT federation_id, name, is_national_representation, country_id
FROM (
    SELECT
        nf.id as federation_id,
        tcn.name as name,
        FALSE as is_national_representation,
        nf.country_id as country_id
    FROM (
        SELECT name, row_number() OVER (ORDER BY random()) as rn
        FROM temp_clubs_names
        WHERE length(name) <= 40
    ) as tcn
    JOIN (
        SELECT
            nf.id,
            nf.country_id,
            row_number() OVER (ORDER BY random()) AS rn
        FROM NATIONAL_FEDERATION nf
    ) as nf ON nf.rn = ((tcn.rn - 1) % (SELECT COUNT(*) FROM NATIONAL_FEDERATION) + 1) -- to help with put federations again on start
    LIMIT 1000000
) as data
ON CONFLICT (name, country_id) DO NOTHING;


--

INSERT INTO CLUB_FEDERATION (federation_id, club_id, start_date, end_date)
SELECT sc.federation_id,
       sc.id as club_id,
       (now() - interval '50 years' * random())::date as start_date,
        CASE
            WHEN random() < 0.3 THEN NULL
            ELSE (now() + interval '10 year' * random())::date
        END as end_date
from SPORT_CLUB sc
ON CONFLICT (federation_id, club_id) DO NOTHING;

--

INSERT INTO REGION (name, part_of_country)
VALUES
  ('Nordic', FALSE), ('Balkans', FALSE), ('Maghreb', FALSE),
  ('Benelux', FALSE), ('Cono_sur', FALSE), ('Gcc', FALSE),
  ('Asean', FALSE), ('Visegrad', FALSE), ('Baltic', FALSE),
  ('Andean', FALSE), ('Ecowas', FALSE), ('Eac', FALSE),
  ('Levant', FALSE), ('Steppe', FALSE), ('Alpine', FALSE),
  ('Caribbean', FALSE), ('Anzac', FALSE), ('Saarc', FALSE),
  ('Melanesia', FALSE), ('Caucasus', FALSE), ('Central_america', FALSE),
  ('Iberia', FALSE), ('Nile_valley', FALSE),
  ('Cascadia', TRUE), ('Great_lakes', TRUE)
;
-- UNIONALL

INSERT INTO REGION (name, part_of_country)
    SELECT c.name || '_North', TRUE FROM COUNTRY c
    UNION ALL
    SELECT c.name || '_South', TRUE FROM COUNTRY c
    UNION ALL
    SELECT c.name || '_East',  TRUE FROM COUNTRY c
    UNION ALL
    SELECT c.name || '_West',  TRUE FROM COUNTRY c;


--

INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id
FROM COUNTRY c
JOIN REGION r ON r.name IN (
  c.name || '_North',
  c.name || '_South',
  c.name || '_East',
  c.name || '_West'
);

INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Nordic'
  AND c.name IN ('Norway','Sweden','Finland','Denmark','Iceland');

INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Balkans'
  AND c.name IN ('Serbia','Croatia','Bosnia','Slovenia','Montenegro',
                 'Kosovo','Albania','North Macedonia','Bulgaria','Romania','Greece');

INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Maghreb'
  AND c.name IN ('Morocco','Algeria','Tunisia','Libya','Mauritania');

INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Benelux'
  AND c.name IN ('Belgium','Netherlands','Luxembourg');

INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Cono_sur'
  AND c.name IN ('Argentina','Chile','Uruguay','Paraguay','Brazil');

INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Gcc'
  AND c.name IN ('Saudi Arabia','UAE','Kuwait','Qatar','Bahrain','Oman');

INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Asean'
  AND c.name IN ('Thailand','Vietnam','Indonesia','Malaysia','Philippines',
                 'Singapore','Myanmar','Cambodia','Laos','Brunei');

INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Visegrad'
  AND c.name IN ('Poland','Czech Republic','Slovakia','Hungary');

INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Baltic'
  AND c.name IN ('Estonia','Latvia','Lithuania');

INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Andean'
  AND c.name IN ('Colombia','Venezuela','Ecuador','Peru','Bolivia');

INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Ecowas'
  AND c.name IN ('Nigeria','Ghana','Senegal','Mali','Burkina Faso','Guinea',
                 'Benin','Niger','Togo','Sierra Leone','Liberia','Gambia',
                 'Cape Verde','Mauritania');

INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Eac'
  AND c.name IN ('Kenya','Tanzania','Uganda','Rwanda','Burundi','South Sudan');

INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Levant'
  AND c.name IN ('Lebanon','Syria','Jordan','Israel','Palestine','Iraq');

INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Steppe'
  AND c.name IN ('Kazakhstan','Kyrgyzstan','Tajikistan','Turkmenistan',
                 'Uzbekistan','Mongolia');

INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Alpine'
  AND c.name IN ('Switzerland','Austria','Slovenia');

INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Caribbean'
  AND c.name IN ('Cuba','Jamaica','Haiti','Dominican Republic','Trinidad','Bahamas');

INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Anzac'
  AND c.name IN ('Australia','New Zealand');

INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Saarc'
  AND c.name IN ('India','Pakistan','Bangladesh','Nepal','Sri Lanka',
                 'Bhutan','Maldives','Afghanistan');

INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Melanesia'
  AND c.name IN ('Fiji');

INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Caucasus'
  AND c.name IN ('Georgia','Armenia','Azerbaijan');

INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Central_america'
  AND c.name IN ('Guatemala','Belize','El Salvador','Honduras',
                 'Nicaragua','Costa Rica','Panama');

INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Iberia'
  AND c.name IN ('Spain','Portugal','Andorra');

INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Nile_valley'
  AND c.name IN ('Egypt','Sudan','South Sudan','Ethiopia','Uganda');

INSERT INTO COMPETITION_TYPE (type_label) VALUES
-- League formats
('National League'),
('Regional League'),
('Premier League'),
('First Division'),
('Second Division'),
('Third Division'),
('Youth League'),
('Reserve League'),
('Amateur League'),
('Semi-Professional League'),
-- Cup formats
('National Cup'),
('Regional Cup'),
('Super Cup'),
('League Cup'),
('Charity Cup'),
('Youth Cup'),
('knockout Cup'),
-- Tournament formats
('Round Robin Tournament'),
('Single Elimination Tournament'),
('Double Elimination Tournament'),
('Group Stage Tournament'),
('International Tournament'),
('Invitational Tournament'),
('Youth Tournament'),
('Indoor Tournament'),
('Outdoor Tournament'),
-- International formats
('World Championship'),
('Continental Championship'),
('European Championship'),
('Olympic Qualification Tournament'),
('Friendly International'),
('International Friendly Tournament'),
--Other
('Exhibition Match'),
('All Star Game'),
('Playoff Series'),
('Promotion Playoff'),
('Relegation Playoff');


INSERT INTO SEASON (national_league_id, start_date, end_date)
select nl.id as national_league_id,
       (nl.date_started + (interval '1 year' * sesonNumber)):: date as start_date,
       (nl.date_started + ((interval '1 year' *sesonNumber)+interval '10 months'))::date as end_date
from NATIONAL_LEAGUE nl
cross join generate_series(0, 999) as sesonNumber
where (nl.date_started + (interval '1 year' * sesonNumber))::date >= nl.date_started
        and (nl.date_started + (interval '1 year' * sesonNumber))::date < now()::date
        and (Case
            when nl.date_disbanded is not null
            then (nl.date_started + (interval '1 year' * sesonNumber))::date <= nl.date_disbanded
            else True End
            );

INSERT INTO REFEREE(ssn, federation_id, sport_category_id)
SELECT p.ssn as ssn,
       f.id as federation_id,
       sc.id as sport_category_id
from PERSON p cross join FEDERATION f cross join SPORT_CATEGORY sc
order by random()
limit 500000;

--
WITH name_cte AS (
    SELECT
        p1 || p2 || ' ' || s AS name
    FROM (
        VALUES
            ('Sport'), ('Riverside'), ('Colonial'), ('National'), ('Central'), ('Olympic'),
            ('Greenfield'), ('Mountain'), ('Lakeside'), ('City'), ('Victory'), ('Heritage'),
            ('Liberty'), ('Sunset'), ('Eastside'), ('West End'), ('North Park'), ('South Gate'),
            ('Alpha'), ('Golden Arch'), ('Springfield'), ('Mountain Side'), ('Sea Bay'),
            ('Flounder'), ('John Doe'), ('Mary Jay'), ('Simon Petrikov'), ('Jane Sandansi')
    ) AS sufix(p1)
    CROSS JOIN (
        VALUES
            (' Hall'), (' Grounds'), (' Stripe'), (' Kingson''s'), (' Calling'), (''),
            (' Fright'), (' Pirate'), (' Comb')
    ) AS midfix(p2)
    CROSS JOIN (
        VALUES
            ('Field'), ('Stadium'), ('Track'), ('Ring'), ('Arena'), ('Court'), ('Grounds'),
            ('Complex'), ('Park'), ('Center'), ('Dome'), ('Pitch'), ('Plaza')
    ) AS suffixes(s)
    ORDER BY random()
),
address_cte AS (
    SELECT p1 || ' ' || p2 || ' ' || s || ' No.' || random(1, 100)::int4 as name
    FROM (
        VALUES
        ('Main'), ('Mane'), ('Nikola'), ('Somber'), ('Dreamy'), ('Second'),
        ('Calvin'), ('Jenny'), ('Maria'), ('Loiter'), ('Tornado'), ('Big'),
        ('Small'), ('Central'), ('Outer'), ('Piggy'), ('Bronze'), ('San'),
        ('Tourist'), ('Los'), ('Part'), ('Ginger'), ('Mary'), ('Drury'),
        ('Cactus'), ('Palm'), ('Secret'), ('Jimmy'), ('Tim'), ('Magnus'),
        ('Third'), ('Fifth'), ('Prime'), ('Alternative'), ('Void'), ('Summer')
    )  first_name(p1)
    CROSS JOIN (
        VALUES
        ('Way'), ('Branch'), ('Tesla'), ('Carbon'), ('Stoker'), ('Shore'), ('Bettle'),
        ('Bench'), ('Static'), ('Quarter'), ('Third'), ('Jay'), ('Parrot'), ('Gofer'),
        ('Single'), ('Band'), ('Gain'), ('Tribe'), ('Sting'), ('Silver'), ('Gold')
    ) second_name(p2)
    CROSS JOIN (
        VALUES
        ('Street'), ('Road'), ('Boulevard'), ('Alley'), ('Path'), ('Walk'), ('Lane'),
        ('Park')
    ) sufix(s)
    ORDER BY random()
)
INSERT INTO location (country_id, name, capacity, address)
    SELECT c.id as country_id,
           loc_data.name as name,
           random(2, 500)::int4 * 100 as capacity,
           loc_data.adr as address
    FROM (
        SELECT
            id,
            floor(random(2, 30)) as loc_count
        FROM country
     ) as c
    CROSS JOIN LATERAL (
        SELECT
            name_cte.name as name,
            address_t.name as adr
        FROM name_cte
        CROSS JOIN
            (SELECT * FROM address_cte ORDER BY random() LIMIT c.loc_count*3) as address_t
        ORDER BY random()
        LIMIT c.loc_count
    ) as loc_data
ON CONFLICT (country_id, name) DO NOTHING;
;


-- Remove temporary tables
DO $$
DECLARE t text;
BEGIN
    FOR t in (
        SELECT table_schema || '.' || table_name
        FROM information_schema.tables
        WHERE table_type = 'BASE TABLE'
            AND table_schema NOT IN ('pg_catalog', 'information_schema')
            AND table_name LIKE 'temp_%'
        ORDER BY table_schema, table_name
    )
    LOOP
        EXECUTE 'DROP TABLE ' || t;
    END LOOP;
END;
$$;