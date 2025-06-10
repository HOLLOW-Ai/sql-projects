USE amazon;

SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
;

CREATE TABLE silver.amazon_purchases (
	order_date NVARCHAR(255) NOT NULL,
	purchase_price_per_unit NVARCHAR(255) NOT NULL,
	quantity INT NULL,
	shipping_address_state NVARCHAR(2) NULL,
	title NVARCHAR(2000) NULL,
	product_code NVARCHAR(255) NULL,
	category NVARCHAR(255) NULL,
	response_id NVARCHAR(255) NOT NULL
);

/*
 This is 1m rows plz dont remove TOP
*/
SELECT TOP (1000)
	  TRY_CAST(order_date AS DATE) AS order_date
	, TRY_CAST(purchase_price_per_unit AS DECIMAL(10, 2)) AS purchase_price_per_unit
	, TRY_CAST(TRY_CAST(quantity AS NUMERIC) AS INT) AS quantity
	, shipping_address_state -- Change to NVARCHAR(2)
	, title
	, asin_isbn_product_code
	, category
	, response_id
FROM bronze.amazon_purchases
;

SELECT MAX(LEN(title)), MAX(LEN(asin_isbn_product_code)), MAX(LEN(category)), MAX(LEN(response_id))
FROM bronze.amazon_purchases


-- Records got smushed here somehow
SELECT TOP (10) *, LEN(title)
FROM bronze.amazon_purchases
ORDER BY LEN(title) DESC

/*
Mrs. Wages Mixed Pickling Spice Seasoning (1.75 shaker bottle) grocery Mrs. Wages 
B00CB7MJIG 1 gl_beauty 2013-04-11 00:00:00 PERSONAL_FRAGRANCE Ganesha's Garden Soapstone Box Solid Perfume - India scent miscellaneous Ganesha's Garden 
B08B61FF9Y 1 gl_home 2020-06-15 00:00:00 ABIS_HOME LimBridge Christmas Mini Stockings, 24 Packs 7 inches Glitter Golden Star Print with Plush Cuff, Classic Stocking Decorations for Whole Family, White and Golden unknown_binding LimBridge 
B003BQBV3A 1 gl_toy 2010-03-10 00:00:00 MINIATURE_TOY_FURNISHING Dollhouse Miniature Croquet Set toy Aztec Imports, Inc. 
B002W09PRA 1 gl_beauty 2009-11-07 00:00:00 TOPICAL_HAIR_REGROWTH_TREATMENT Bio 3 Anagen Therapy Rejuvenating Conditioner miscellaneous Anagen 
1929628552 1 gl_book 2010-02-18 00:00:00 ABIS_BOOK Time For Torah hardcover Hachai Publishing 
B015KVBQ10 1 gl_drugstore 2015-09-19 00:00:00 INCENSE 40G Pure Sandal Wood Paste -Cools Mind- Beauty India Chandan Tika- Aromatherapy-religious hindu puja use -meditation kitchen Hari Darshan 
B015S3HEQG 1 gl_shoes 2016-01-15 00:00:00 SHOES Wilson Women's KAOS Blue Iris/Navy/Pink Athletic Shoe shoes WILSON 
B08SJVMYJM 1 gl_pc 2021-01-09 00:00:00 TABLET_COMPUTER MEBERRY Tablet 10.1 Inch Android 10.0 : 5G WI-FI | 1.6 GHz | Octa-Core Ultra-Fast Tablets - 4GB RAM+64GB ROM | Google Certified | FHD Display | Face ID | Bluetooth Keyboard | Mouse and More - Black unknown_binding MEBERRY 
B001AT1XNS 1 gl_toy 2008-06-06 00:00:00 GREETING_CARD Minnie Mouse Invitations, 8ct toy Hallmark 
B006WC0XIY 1 gl_shoes 2012-01-11 00:00:00 SHOES NIKE [487785-400] Mens Footscape Free Mens Shoes Treasure Blue/Black-Cool Grey. apparel Nike 
B01IG1YVUO 1 gl_shoes 2016-09-15 00:00:00 BOOT HUNTER Original Refined Dark Sole Chelsea Boots Black 8 shoes HUNTER 
B000VYJMZE 1 gl_home_improvement 2007-09-12 00:00:00 CORD_MANAGEMENT_COVER Legrand V718 Raceway Metallic V700 System External Elbow Fitting, Ivory miscellaneous Wiremold 
B01HNPCEJ4 1 gl_shoes 2016-06-28 00:00:00 SLIPPER UGG Men's Ascot, Black Suede 7 Wide unknown_binding UGG 
B013RHAMX2 1 gl_shoes 2015-08-11 00:00:00 SHOES PUMA Suede Classic Woven Womens (Solange Knowles Colab) in Snapdragon/Team Gold by, 6.5 shoes PUMA 
B001AWP65Q 1 gl_automotive 2008-06-09 00:00:00 POWERSPORTS_VEHICLE_PART Modquad Thumb Throttle Lever Pocket for Honda TRX 400EX 450R Modquad 
B01HIF6FI0 1 gl_shoes 2016-10-07 00:00:00 SHOES OLUKAI Pehuea Women's Slip On Sneakers, Casual Everyday Shoes with Drop-in Heel & Breathable Mesh Design, Lightweight & All-Day Comfort apparel OLUKAI 
B00IFD9XWU 1 gl_beauty 2014-02-13 00:00:00 SHAVING_AGENT Edge Sensitive Skin Shaving Gel Twin Pack, 2 x 198g health_and_beauty Schick 
B00G3NFYYK 1 gl_electronics 2013-10-22 00:00:00 REMOTE_CONTROL Mitsubishi E12E83426 Room Air Conditioner Remote Control Genuine Original Equipment Manufacturer (OEM) part consumer_electronics Mitsubishi Electric 
B08934BRSL 1 gl_softlines_private_label 2020-05-23 00:00:00 EARRING Milacolato 3Pairs Sterling Silver Ear Cuff for Women Helix Cartilage Cuff Adjustable Fashion Earrings for Women Non-pierced Clip On Cubic Zirconia Small Hoop Earrings, Gold jewelry Manufacturer Accelerator MILACOLATO 
B01MSYTNRM 1 gl_shoes 2017-08-24 00:00:00 BOOT Sorel Women's Dacie Lace Leather Boots with Faux Fur ΓÇæ Curry (9.5) shoes Sorel 
B07RJS7R86 1 gl_wine 2019-05-06 00:00:00 BEER Austin Beerworks, IPA Hazy Invisible Hand, 6pk, 12 Fl Oz Cans unknown_binding Austin Beerworks 
B081VW3FR3 1 gl_apparel 2019-11-22 00:00:00 SHIRT Marky G Toddler Baby Girls Soft Cotton Basic Layering T-Shirts Tops Shorts Sleeve Crewneck, 2 Pack Black/Aqua apparel Marky G Apparel 
B01J2V368K 1 gl_shoes 2017-02-14 00:00:00 SHOES Walking Cradles Joy White Cashmere 10.5 M (B) shoes Walking Cradles 
B01D3D2OUO 1 gl_shoes 2016-09-08 00:00:00 BOOT Laredo Men Bennett 7454 Boot shoes Laredo 
B08KXDW7RK 1 gl_apparel 2020-10-09 00:00:00 PANTS Kotii Women's Soft Ankle Length Leggings High Waist Full Length Leggings unknown_binding Kotii 
B07FZLQK37 1 gl_grocery 2018-07-28 00:00:00 PASTRY Tart Fruit 3.75 Inch, 8 Ounce grocery BAKERY 
B08CRHTPYF 1 gl_shoes 2020-07-10 00:00:00 BOOT Dacomfy Mens Casual Shoes Leather Chukka Boots Hand Stitching Loafers Classic Fashion Oxford Dress Boots Comfy Walking Shoes Driving Traveling Brown 46 apparel Dacomfy 
B0868LQ7GM 1 gl_shoes 2020-03-23 00:00:00 CORRECTIVE_EYEGLASSES Eyekepper 4 Pack Stylish Eyeglasses Women - Oversized Square Eyewears Black Eyekepper 
B003J8LIQ0 1 gl_beauty 2010-04-25 00:00:00 SKIN_MOISTURIZER Niven Morgan ΓÇô Gold ΓÇô Body Lotion health_and_beauty Niven Morgan 
B07GDTDFJ9 1 gl_outdoors 2018-08-13 00:00:00 SUNGLASSES Ray-Ban RB3183 Sunglasses For Men (Black/Grey Polarized, 63) apparel Ray-Ban 
B00T4NIJJ8 1 gl_drugstore 2015-02-03 00:00:00 HEALTH_PERSONAL_CARE 4 Inch Self Adhesive Medical Bandage Wrap Sport Tape (Black Bean) (24 Pack) Strong Elastic Self Adherent Cohesive First Aid Sport Flex Rolls for Wrist Ankle Knee Sprains and Swelling health_and_beauty Prairie Horse Supply 
B00O5SU5SK 771770 gl_apparel 2015-06-08 00:00:00 SOCKS Gold Toe Big Boys' 3 Pack Argyle/plaid Dress Crew, Black Argyle/Black Jersey/Black Plaid, Large apparel GoldToe 
B002BAHFBE 771770 gl_tools 2015-05-11 00:00:00 ROTARY_TOOL Dremel 300-1/24 300 Series Variable-Speed Rotary Tool Kit by Dremel home_improvement DREMEL 
B001WAKUDO 771770 gl_drugstore 2015-09-11 00:00:00 BEAUTY Davines Defining Wonder Wax, 3.3-Ounce Jars health_and_beauty Davines 
B006SNUVPC 771770 gl_kitchen 2015-05-10 00:00:00 DRINKING_CUP BigMouth Inc Prescription Pill Bottle Drink Kooler, Keeps Drinks Cold, Perfect Funny Gag Gift kitchen BigMouth Inc 
B000KNNBWG 771770 gl_office_product 2015-11-05 00:00:00 ART_MEDIA_PAPER Clearprint Design Vellum Rolls no. 1000H 36 in. x 5 yd. roll miscellaneous Clearprint 
B00IWTP0ME 771770 gl_watch 2015-05-10 00:00:00 WATCH Rip Curl Reloj, Azul/Patchwork, Digital watch Rip Curl 
B00073FKIW 7 gl_toy 2013-09-23 00:00:00 TOY_FIGURE McFarlane NHL Action Figures Series 9: Pavel Datsyuk Red Jersey Variant toy McFarlane 
B001WAKUDO 7 gl_beauty 2010-12-01 00:00:00 BEAUTY Davines Defining Wonder Wax , 3.3-Ounce Jars health_and_beauty Davines 
B075FTK6YJ 7 gl_beauty 2017-12-23 00:00:00 NAIL_POLISH essie, nail polish, blue, blue-tiful horizon, 13.5ml health_and_beauty essie 
B000WNCEQS 7 gl_toy 2012-12-20 00:00:00 ART_CRAFT_KIT 1/35 MM German infantry attack team set 35 196 toy Tamiya 
B0006O2JAY 1 gl_beauty 2004-11-19 00:00:00 CANDLE Diptyque Freesia Candle 6.5oz candle health_and_beauty Diptyque 
B00DBL13TM 1 gl_apparel 2014-03-19 00:00:00 SOCKS Nike Elite Running Cushion No-Show Tab Socks White/Wolf Grey/Wolf Grey, 14.0-16.0 sports_apparel Nike 
B001T5ABY0 1 gl_camera 2009-02-14 00:00:00 CAMERA_FILM Olympus Infinity Stylus Zoom 35-70mm DLX 35mm Film Camera Outfit Black consumer_electronics Olympus 
B006YTTDM2 1 gl_biss 2013-11-05 00:00:00 DRILL_BITS C.K Metal Drill Bit 9mm home_improvement C.K 
B007MKFE48 1 gl_pc 2012-04-04 00:00:00 SYSTEM_POWER_DEVICE Power Supply - 240W pc HP 
B0078S9HRE 1 gl_apparel 2012-02-13 00:00:00 SHIRT Dr Who Vote No on Daleks Mens Tee, Heather Red, (XX-Large) apparel Ripple Junction 
B01F4RS1YU 1 gl_pc 2016-05-04 00:00:00 SCREEN_PROTECTOR Cellularline Shockproof Glass Screen Protector for Samsung Galaxy J1 (2016) accessory cellularline 
B00AIO71Y6 1 gl_beauty 2012-12-05 00:00:00 SKIN_TREATMENT_MASK MYI Gender Neutral #2 Eye Patches - Regular Size (51 Per Package) health_and_beauty MYI Occlusion Eye Patches 
B008J5LRY6 1 gl_beauty 2013-07-26 00:00:00 SKIN_CLEANING_AGENT Marc Jacobs Dot Shower Gel 150ml health_and_beauty Marc Jacobs 
B01N2WH3N2 1 gl_home 2016-12-22 00:00:00 CURTAIN ECLIPSE Blackout Curtains for Bedroom-Mallory 52 x 84" Insulated Darkening Single Panel Grommet Top Window Treatment Living Room, Smoke

For reasons unknown to me, so possibly an error made by the user when uploading there data, a bunch of their previous orders were mixed up in one row?
Considering the actual survey requests for data starting from 2018-01-01, and the erroneous row of data includes data fro 2004 somehow, it will be removed
Additionally, it is missing purchase price information
More hassle than it's really worth to try and split data for the purchase history of one individual
*/

SELECT MIN(LEN(asin_isbn_product_code)), MAX(LEN(asin_isbn_product_code))
FROM bronze.amazon_purchases; 

SELECT *
FROM bronze.amazon_purchases
WHERE order_date IS NULL

SELECT LEN(shipping_address_state), COUNT(*)
FROM bronze.amazon_purchases
GROUP BY LEN(shipping_address_state)

SELECT
	 LEFT(asin_isbn_product_code, 1)
	, COUNT(*)
FROM bronze.amazon_purchases
GROUP BY LEFT(asin_isbn_product_code, 1)

SELECT *
FROM bronze.amazon_purchases
WHERE response_id = 'R_AgtY0o0wz2sF1Dj'

SELECT MIN(TRY_CAST(order_date AS DATE))
FROM bronze.amazon_purchases

/*
Just this row is fucked up
*/
SELECT *
FROM bronze.amazon_purchases
WHERE title LIKE '%20[0-9][0-9]-[0-9][0-9]-[0-9][0-9] 00:00:00%'

SELECT title
INTO #working_split
FROM bronze.amazon_purchases
WHERE title LIKE '%20[0-9][0-9]-[0-9][0-9]-[0-9][0-9] 00:00:00%';


SELECT PATINDEX(CONCAT('%', REPLICATE('[A-Z0-9]', 5), '%'), title)
FROM #working_split;

SELECT *
FROM #working_split;

SELECT PATINDEX('%[A-Z0-9][0-9][0-9][A-Z0-9]%', title)
FROM #working_split;

SELECT SUBSTRING(title, 83, 9)
FROM #working_split
