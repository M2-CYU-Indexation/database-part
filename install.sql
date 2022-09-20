

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

/*
declare
    i ordsys.ordimage;
    ctx RAW(400) := NULL;
    ligne multimedia%ROWTYPE;
    cursor mm is
    select * from imageTable
    for update;
begin
for imageName in 1..500
loop
    name = concat(imageName, '.jpg')
end loop




-- insertion d’une image, de contenu vide
insert into multimedia(nom, image, signature)
values (’image1.jpg’, ordsys.ordimage.init(), ordsys.ordimageSignature.init());
commit;
-- chargement du contenu de l’image a partir du fichier
select image into i
from multimedia
where nom = ’image1.jpg’
for update;
i.importFrom(ctx, ’file’, ’IMG’, ’image1.jpg’);
update multimedia
set image = i
where nom = ’image1.jpg’;
commit;
-- proceder de meme pour les autres images
-- generation des signatures
for ligne in mm loop
ligne.signature.generateSignature(ligne.image);
update multimedia
set signature = ligne.signature
where current of mm;
endloop;
commit;*/
