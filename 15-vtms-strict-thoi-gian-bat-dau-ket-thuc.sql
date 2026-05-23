USE vtms;

ALTER TABLE bangdau
    DROP CONSTRAINT chk_bangdau_ngay;

ALTER TABLE bangdau
    ADD CONSTRAINT chk_bangdau_ngay
    CHECK (thoigianbatdau IS NULL OR thoigianketthuc IS NULL OR thoigianketthuc > thoigianbatdau);

ALTER TABLE giaidau
    DROP CONSTRAINT chk_giaidau_thoigian;

ALTER TABLE giaidau
    ADD CONSTRAINT chk_giaidau_thoigian
    CHECK (thoigianketthuc > thoigianbatdau);
