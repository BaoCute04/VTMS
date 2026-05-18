USE vtms;

ALTER TABLE bangdau
    ADD COLUMN thoigianbatdau DATE NULL AFTER mota,
    ADD COLUMN thoigianketthuc DATE NULL AFTER thoigianbatdau;

UPDATE bangdau bd
JOIN giaidau gd ON gd.idgiaidau = bd.idgiaidau
SET
    bd.thoigianbatdau = COALESCE(bd.thoigianbatdau, gd.thoigianbatdau),
    bd.thoigianketthuc = COALESCE(bd.thoigianketthuc, gd.thoigianketthuc);
