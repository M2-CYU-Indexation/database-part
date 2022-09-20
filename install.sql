

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
    where nom = imgName
    for update;
    i.importFrom(ctx, ’file’, ’IMG’, imgName);
    update imageTable
    set image = i
where nom = imgName;
    commit;
end loop;
end;

--declare
    --i ordsys.ordimage;
    --name string;
    --ctx RAW(400) := NULL;
    --ligne multimedia%ROWTYPE;
    --cursor mm is
    --select * from imageTable
    --for update;
--begin
---- insertion des images vides
--for imageName in 1..500
--loop
    --name = concat(imageName, '.jpg')
    --insert into multimedia(nom, image, signature)
--values (name, ordsys.ordimage.init(), ordsys.ordimageSignature.init());
--commit;
--end loop




---- insertion d’une image, de contenu vide

---- chargement du contenu de l’image a partir du fichier
--select image into i
--from multimedia
--where nom = ’image1.jpg’
--for update;
--i.importFrom(ctx, ’file’, ’IMG’, ’image1.jpg’);
--update multimedia
--set image = i
--where nom = ’image1.jpg’;
--commit;
---- proceder de meme pour les autres images
---- generation des signatures
--for ligne in mm loop
--ligne.signature.generateSignature(ligne.image);
--update multimedia
--set signature = ligne.signature
--where current of mm;
--endloop;
--commit;
