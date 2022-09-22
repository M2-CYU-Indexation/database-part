

create or replace type histogram is varray(256) of integer;

create table imageTable(
    imageName varchar2(100),
    image ordsys.ordimage,
    signature ordsys.ordimageSignature,
    width int,
    height int,
    grayHistogram histogram,
    redHistogram histogram,
    greenHistogram histogram,
    blueHistogram histogram,
    redRatio double precision,
    greenRatio double precision,
    blueRatio double precision,
    averageColor int,
    gradientNormMean double precision,
    outlinesMinX int,
    outlinesMinY int,
    outlinesMaxX int,
    outlinesMaxY int,
    outlinesBarycenterX int,
    outlinesBarycenterY int,
    nbOutlinePixel int,
    isRGB number(1,0)
);


declare
    i ordsys.ordimage;
    imgName varchar2(50);
    ctx RAW(400) := NULL;
    ligne imageTable%ROWTYPE;

    cursor mm is
    select * from imageTable
    for update;

    sig1 ordsys.ordimageSignature;
    sig2 ordsys.ordimageSignature;
    sim integer;
    dist float;
begin
-- insertion des images vides
for imageName in 1..500
loop
    imgName := concat(imageName, '.jpg');
    insert into imageTable(imageName, image, signature, width, height, grayHistogram, redHistogram, greenHistogram, blueHistogram, redRatio, greenRatio, blueRatio, averageColor, gradientNormMean, outlinesMinX , outlinesMinY,outlinesMaxX,outlinesMaxY,outlinesBarycenterX,outlinesBarycenterY ,nbOutlinePixel ,isRGB)
values (imgName, ordsys.ordimage.init(), ordsys.ordimageSignature.init(), null,null, null, null, null, null, null, null, null, null, null, null,null,null,null,null,null,null,null );
commit;
end loop;

-- ajout des vrais images & de la signature
for imageName in 1..500
loop
    imgName := concat(imageName, '.jpg');
    select image into i
    from imageTable
    where imageName = imgName
    for update;
    i.importFrom(ctx,'file','IMG', imgName);
    update imageTable
    set image = i
    where imageName = imgName;
    commit;
end loop;

-- regen des signatures

for ligne in mm
loop
    ligne.signature.generateSignature(ligne.image);
    update imageTable
    set signature = ligne.signature
    where current of mm;
    end loop;
    commit;

-- comparaison via oracle
select signature into sig1
    from imageTable
    where imageName = '1.jpg';
select signature into sig2
    from imageTable
    where imageName = '1.jpg';
sim := ordsys.ordimageSignature.isSimilar(sig1, sig2,
    'color = 0.5, texture = 0, shape = 0, location = 0', 10);
    dbms_output.put_line(sim);



select signature into sig1
    from imageTable
    where imageName = '1.jpg';
    select signature into sig2
    from imageTable
    where imageName = '2.jpg';
    dist := ordsys.ordimageSignature.evaluateScore(sig1, sig2, 'color = 0.5, texture = 0, shape =0, location = 0');
    dbms_output.put_line('Distance=' || dist);

end;


CREATE OR REPLACE PROCEDURE InsertImageMetaDatas
        (inImageName in String,
        inWidth in INT,
        inHeight in INT,
        inGrayHistogram in HISTOGRAM,
        inRedHistogram in HISTOGRAM,
        inBlueHistogram in HISTOGRAM,
        inGreenHistogram in HISTOGRAM,
        inRedRatio in double precision,
        inBlueRatio in double precision,
        inGreenRatio in double precision,
        inAverageColor in int,
        inGradientNormMean in double precision,
        inOutlinesMinX in int,
        inOutlinesMinY in int,
        inOutlinesMaxX in int,
        inOutlinesMaxY in int,
        inOutlinesBarycenterX in int,
        inOutlinesBarycenterY in int,
        inNbOutlinePixel in int,
        inIsRGB in number
       )
      IS

      BEGIN
            update imagetable
            set
            width = inWidth,
            height = inHeight,
            grayhistogram = inGrayHistogram,
            greenhistogram = inGreenHistogram,
            bluehistogram = inBlueHistogram,
            redhistogram = inRedHistogram,
            redratio = inRedRatio,
            greenratio = inGreenRatio,
            blueratio = inBlueRatio,
            averagecolor = inAverageColor,
            gradientnormmean = inGradientNormMean,
            outlinesminx = inOutlinesMinX,
            outlinesminy = inOutlinesMinY,
            outlinesmaxx = inOutlinesMaxX,
            outlinesmaxy = inOutlinesMaxY,
            outlinesbarycenterx = inOutlinesBarycenterX,
            outlinesbarycentery = inOutlinesBarycenterY,
            isrgb = inIsRGB
            where
            imagename = inImageName;
      END;


-- compare images using oracle

CREATE OR REPLACE FUNCTION DistanceImageOracle
           (
            imgname1 in varchar2,
            imgname2 in varchar2
           )
          RETURN double precision
          IS
            sig1 ordsys.ordimageSignature;
            sig2 ordsys.ordimageSignature;
            dist float;
          BEGIN
                select signature into sig1
                from imageTable
                where imageName = imgname1;
                select signature into sig2
                from imageTable
                where imageName = imgname2;
                dist := ordsys.ordimageSignature.evaluateScore(sig1, sig2, 'color = 0.5, texture = 0, shape =0, location = 0');
                return dist;
          END;

select imagename from imageTable where distanceimageoracle('1.jpg', imagename ) < 8;

-- compare images using metadatas


CREATE OR REPLACE FUNCTION DistanceImageMetadatas
           (
            imgname1 in varchar2,
            imgname2 in varchar2
           )
          RETURN double precision
          IS
            histo1 histogram;
            histo2 histogram;
            distHisto float;
          BEGIN
                distHisto := 0;
                select grayhistogram into histo1
                from imageTable
                where imageName = imgname1;
                select grayhistogram into histo2
                from imageTable
                where imageName = imgname2;
                for i in 0..255
                loop
                    distHisto := distHisto + POWER(histo1(i) - histo2(i), 2);
                end loop;

                distHisto := SQRT(distHisto);
                return distHisto;
          END;


select imagename from imageTable where distanceimagemetadatas('1.jpg', imagename) < 100;

-- requetes partie 5

select imageName, redRatio from imageTable where redRatio > 0.5 order by redratio;

/*
165.jpg	0,506107
322.jpg	0,512227
102.jpg	0,54185
231.jpg	0,625919
*/

select imageName, isRGB from imageTable where isRGB = 0;

/*
307.jpg	0
188.jpg	0
63.jpg	0
221.jpg	0
394.jpg	0
25.jpg	0
295.jpg	0
468.jpg	0
358.jpg	0
80.jpg	0
428.jpg	0
112.jpg	0
268.jpg	0
110.jpg	0
120.jpg	0
290.jpg	0
157.jpg	0
53.jpg	0
178.jpg	0
146.jpg	0
198.jpg	0
202.jpg	0
206.jpg	0
12.jpg	0
18.jpg	0
239.jpg	0
37.jpg	0
323.jpg	0
327.jpg	0
343.jpg	0
354.jpg	0
288.jpg	0
391.jpg	0
393.jpg	0
398.jpg	0
205.jpg	0
450.jpg	0
479.jpg	0
180.jpg	0
181.jpg	0
495.jpg	0
496.jpg	0
33.jpg	0
250.jpg	0
56.jpg	0
122.jpg	0
494.jpg	0
353.jpg	0
355.jpg	0
306.jpg	0
283.jpg	0
127.jpg	0
31.jpg	0
66.jpg	0
105.jpg	0
227.jpg	0
60.jpg	0
498.jpg	0
21.jpg	0
22.jpg	0
17.jpg	0
61.jpg	0
312.jpg	0
4.jpg	0
51.jpg	0
62.jpg	0
30.jpg	0
52.jpg	0
8.jpg	0
59.jpg	0
48.jpg	0
97.jpg	0
93.jpg	0
46.jpg	0
77.jpg	0
58.jpg	0
164.jpg	0
116.jpg	0
44.jpg	0
467.jpg	0
69.jpg	0
294.jpg	0
88.jpg	0
95.jpg	0
28.jpg	0
1.jpg	0
6.jpg	0
226.jpg	0
350.jpg	0
129.jpg	0
36.jpg	0
115.jpg	0
3.jpg	0
228.jpg	0
20.jpg	0
230.jpg	0
147.jpg	0
158.jpg	0
267.jpg	0
443.jpg	0
440.jpg	0
410.jpg	0
192.jpg	0
168.jpg	0
465.jpg	0
481.jpg	0
224.jpg	0
233.jpg	0
293.jpg	0
124.jpg	0
486.jpg	0
400.jpg	0
139.jpg	0
280.jpg	0
396.jpg	0
269.jpg	0
386.jpg	0
154.jpg	0
211.jpg	0
266.jpg	0
480.jpg	0
184.jpg	0
140.jpg	0
482.jpg	0
135.jpg	0
446.jpg	0
406.jpg	0
384.jpg	0
425.jpg	0
395.jpg	0
366.jpg	0
216.jpg	0
403.jpg	0
377.jpg	0
214.jpg	0
199.jpg	0
159.jpg	0
344.jpg	0
274.jpg	0
378.jpg	0
286.jpg	0
246.jpg	0
201.jpg	0
291.jpg	0
152.jpg	0
143.jpg	0
263.jpg	0
150.jpg	0
397.jpg	0
212.jpg	0
500.jpg	0
483.jpg	0
419.jpg	0
141.jpg	0
213.jpg	0
156.jpg	0
281.jpg	0
284.jpg	0
485.jpg	0
310.jpg	0
475.jpg	0
411.jpg	0
457.jpg	0
189.jpg	0
170.jpg	0
352.jpg	0
194.jpg	0
304.jpg	0
442.jpg	0
169.jpg	0
427.jpg	0
497.jpg	0
271.jpg	0
40.jpg	0
315.jpg	0
166.jpg	0
289.jpg	0
179.jpg	0
217.jpg	0
423.jpg	0
349.jpg	0
372.jpg	0
413.jpg	0
285.jpg	0
277.jpg	0
*/

select imageName, nboutlinepixel from imageTable where nboutlinepixel > 20000;


/*
80.jpg	24249
114.jpg	21253
408.jpg	21040
110.jpg	22773
215.jpg	23471
12.jpg	27469
484.jpg	20519
186.jpg	20273
74.jpg	26290
226.jpg	26400
241.jpg	22600
158.jpg	22915
487.jpg	23129
280.jpg	27374
418.jpg	21109
148.jpg	22468
340.jpg	23298
475.jpg	20402
170.jpg	26313
195.jpg	22441
453.jpg	21094
381.jpg	21666
*/


select imageName, outlinesbarycenterx , outlinesbarycentery, width, height from imageTable where outlinesbarycenterx < width/2 + 10 AND outlinesbarycenterx > width/2 - 10 AND outlinesbarycentery < height/2 + 10 AND outlinesbarycentery > height/2 - 10 ;


/*
221.jpg	108	124	198	253
404.jpg	151	86	300	166
80.jpg	123	97	239	209
114.jpg	129	96	258	194
408.jpg	134	86	274	182
428.jpg	93	123	198	252
149.jpg	138	87	274	182
178.jpg	132	99	269	186
206.jpg	109	116	206	242
187.jpg	109	120	224	224
12.jpg	124	102	258	193
18.jpg	109	104	224	224
245.jpg	98	119	187	235
49.jpg	125	85	239	159
82.jpg	97	62	187	128
130.jpg	123	93	247	202
26.jpg	124	100	251	199
343.jpg	140	96	273	183
288.jpg	69	65	119	119
451.jpg	97	121	200	249
479.jpg	137	105	256	195
180.jpg	99	134	187	258
250.jpg	112	121	224	224
56.jpg	91	133	183	273
359.jpg	106	114	222	225
341.jpg	112	113	224	224
252.jpg	120	84	239	160
283.jpg	137	85	278	180
105.jpg	95	133	190	262
60.jpg	114	111	224	224
22.jpg	101	117	183	239
15.jpg	111	119	216	231
17.jpg	106	76	215	148
312.jpg	134	96	251	199
106.jpg	125	95	244	204
51.jpg	128	85	274	182
62.jpg	140	97	275	182
84.jpg	111	104	224	223
30.jpg	104	132	198	253
89.jpg	136	83	274	182
24.jpg	141	86	274	182
74.jpg	103	110	207	223
23.jpg	97	132	197	254
54.jpg	129	106	258	193
48.jpg	118	100	254	197
77.jpg	117	107	224	224
58.jpg	61	59	119	119
102.jpg	141	85	274	182
107.jpg	91	142	185	270
249.jpg	93	114	187	213
116.jpg	132	86	267	187
69.jpg	107	78	229	159
243.jpg	142	90	269	185
294.jpg	169	74	339	147
95.jpg	113	112	224	224
41.jpg	117	105	220	227
109.jpg	131	85	266	188
234.jpg	110	102	229	218
70.jpg	130	92	258	193
316.jpg	92	65	187	119
7.jpg	99	58	187	129
226.jpg	125	99	249	200
350.jpg	95	99	207	207
129.jpg	132	104	249	201
9.jpg	134	93	274	182
3.jpg	118	104	250	200
43.jpg	126	107	249	200
90.jpg	130	99	274	182
230.jpg	105	109	223	224
300.jpg	111	113	224	224
204.jpg	128	91	274	182
412.jpg	132	94	267	187
147.jpg	58	60	119	119
438.jpg	122	108	236	212
275.jpg	107	108	216	231
267.jpg	114	110	247	202
433.jpg	109	110	218	229
410.jpg	100	120	200	250
168.jpg	85	142	184	272
465.jpg	130	85	269	186
487.jpg	95	121	187	239
273.jpg	132	88	258	193
233.jpg	90	118	181	232
193.jpg	134	95	258	193
331.jpg	127	93	247	184
242.jpg	97	136	194	257
124.jpg	171	75	342	146
280.jpg	103	113	213	235
452.jpg	130	87	270	185
444.jpg	187	73	381	131
162.jpg	87	54	191	107
367.jpg	133	92	259	193
236.jpg	92	111	191	239
375.jpg	134	85	272	183
380.jpg	112	116	224	224
491.jpg	124	98	245	204
324.jpg	108	106	220	227
383.jpg	133	94	258	194
395.jpg	108	67	219	145
299.jpg	98	143	187	267
208.jpg	102	122	196	255
99.jpg	129	96	267	187
403.jpg	63	56	119	119
466.jpg	66	98	127	191
499.jpg	117	97	249	200
344.jpg	64	85	119	159
148.jpg	121	105	226	221
185.jpg	128	95	268	187
265.jpg	136	100	256	195
392.jpg	140	96	267	187
378.jpg	58	95	109	177
209.jpg	136	93	274	182
132.jpg	101	119	200	250
39.jpg	76	112	158	239
259.jpg	135	98	274	182
420.jpg	99	126	210	238
374.jpg	125	105	258	193
246.jpg	53	89	108	177
421.jpg	55	81	108	178
201.jpg	119	116	224	224
409.jpg	128	85	267	187
251.jpg	95	137	192	260
376.jpg	137	88	262	191
483.jpg	63	64	119	119
131.jpg	60	66	119	119
454.jpg	95	110	175	223
248.jpg	134	97	274	182
141.jpg	87	71	179	149
322.jpg	131	87	258	193
340.jpg	91	133	197	253
325.jpg	224	50	442	113
34.jpg	103	71	215	143
339.jpg	93	112	189	206
189.jpg	139	101	269	186
365.jpg	94	122	193	259
170.jpg	125	95	250	200
373.jpg	92	78	187	140
176.jpg	60	69	119	119
282.jpg	124	90	262	191
270.jpg	76	106	159	212
442.jpg	132	98	274	182
253.jpg	101	124	210	238
363.jpg	125	92	261	192
169.jpg	36	133	67	284
315.jpg	90	138	194	258
166.jpg	141	90	276	181
334.jpg	160	73	331	151
289.jpg	127	86	266	188
436.jpg	133	88	275	182
445.jpg	110	109	223	224
203.jpg	142	91	290	172
298.jpg	136	94	283	176
145.jpg	150	79	317	158
179.jpg	117	117	224	224
453.jpg	115	111	216	231
111.jpg	135	89	267	187
247.jpg	122	98	251	199
217.jpg	124	95	248	201
423.jpg	120	98	250	200
381.jpg	159	81	311	160
349.jpg	133	91	265	189
153.jpg	92	122	187	243
285.jpg	103	128	201	249
255.jpg	98	128	199	251
402.jpg	124	103	250	200
219.jpg	104	110	210	238
*/

-- get image blob
select i.image.source.localdata from imagetable i where imagename = '1.jpg';










