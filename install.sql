

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


