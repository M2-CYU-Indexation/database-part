

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




