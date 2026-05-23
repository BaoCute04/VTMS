-- Chay sau vtms2.sql.
-- Muc tieu:
-- 1) Xoa tai khoan BTC tinh cu btc_hcm, btc_hn/btc_hanoi sau khi chuyen quyen so huu.
-- 2) Tao tai khoan BTC rieng cho cac don vi So VH-TT cap tinh/thanh.
-- 3) Chuan hoa HLV TDTT cap tinh/thanh va doi hinh nam 6 VDV dang hoat dong.

CREATE DATABASE IF NOT EXISTS vtms
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE vtms;

SET NAMES utf8mb4;

SET @role_btc := (SELECT idrole FROM role WHERE namerole = 'BAN_TO_CHUC' LIMIT 1);
SET @role_hlv := (SELECT idrole FROM role WHERE namerole = 'HUAN_LUYEN_VIEN' LIMIT 1);
SET @role_vdv := (SELECT idrole FROM role WHERE namerole = 'VAN_DONG_VIEN' LIMIT 1);

SET @cap_btc_tinh := (SELECT idcapbantochuc FROM capbantochuc WHERE macapbantochuc = 'TINH_THANH' LIMIT 1);
SET @cap_giai_tinh := (SELECT idcapgiaidau FROM capgiaidau WHERE macapgiaidau = 'TINH_THANH' LIMIT 1);

SET @dv_vhtt_hcm := (SELECT iddonvi FROM donvi WHERE madonvi = 'SO_VHTT_TPHCM' LIMIT 1);
SET @dv_tdtt_hcm := (SELECT iddonvi FROM donvi WHERE madonvi = 'TT_HL_TDTT_TPHCM' LIMIT 1);
SET @dv_vhtt_hn := (SELECT iddonvi FROM donvi WHERE madonvi = 'SO_VHTT_HANOI' LIMIT 1);
SET @dv_tdtt_hn := (SELECT iddonvi FROM donvi WHERE madonvi = 'TT_HL_TDTT_HANOI' LIMIT 1);

SET @kv_hcm := (SELECT idkhuvuc FROM donvi WHERE iddonvi = @dv_vhtt_hcm LIMIT 1);
SET @kv_hn := (SELECT idkhuvuc FROM donvi WHERE iddonvi = @dv_vhtt_hn LIMIT 1);

SET @btc_quocgia := (
    SELECT btc.idbantochuc
      FROM bantochuc btc
      JOIN capbantochuc cap ON cap.idcapbantochuc = btc.idcapbantochuc
     WHERE cap.macapbantochuc = 'QUOC_GIA'
       AND btc.trangthai = 'HOAT_DONG'
     ORDER BY btc.idbantochuc
     LIMIT 1
);

SET @old_btc_hcm := (
    SELECT btc.idbantochuc
      FROM bantochuc btc
      JOIN nguoidung nd ON nd.idnguoidung = btc.idnguoidung
      JOIN taikhoan tk ON tk.idtaikhoan = nd.idtaikhoan
     WHERE tk.username = 'btc_hcm'
     LIMIT 1
);

SET @old_btc_hn := (
    SELECT btc.idbantochuc
      FROM bantochuc btc
      JOIN nguoidung nd ON nd.idnguoidung = btc.idnguoidung
      JOIN taikhoan tk ON tk.idtaikhoan = nd.idtaikhoan
     WHERE tk.username IN ('btc_hn', 'btc_hanoi')
     ORDER BY btc.idbantochuc
     LIMIT 1
);

SET @pwd_btc := COALESCE(
    (SELECT password FROM taikhoan WHERE username = 'btc_quocgia' LIMIT 1),
    (SELECT password FROM taikhoan WHERE username = 'btc_hcm' LIMIT 1),
    '$2y$10$OBXJKXgj9/3ht4mUK4rQb.SuXMd6rbqObYTDGMGpVzuYSgNT5DSY.'
);

SET @pwd_hlv := COALESCE(
    (SELECT password FROM taikhoan WHERE username = 'hlv_tphcm' LIMIT 1),
    (SELECT password FROM taikhoan WHERE username = 'hlv_hanoi' LIMIT 1),
    '$2y$10$.Ca7DM1fbv0rwVoFMrMIteK1NnwD58sWAm7/KPz23riYeFTRaAzri'
);

-- 1. Tai khoan BTC moi cho don vi VH-TT cap tinh/thanh.
INSERT INTO taikhoan (username, password, email, sodienthoai, idrole, trangthai)
SELECT 'btc_vhtt_tphcm', @pwd_btc, 'btc.vhtt.tphcm@vtms.vn', '0900000103', @role_btc, 'HOAT_DONG'
 WHERE @role_btc IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM taikhoan WHERE username = 'btc_vhtt_tphcm');

UPDATE taikhoan
   SET idrole = @role_btc,
       email = 'btc.vhtt.tphcm@vtms.vn',
       sodienthoai = '0900000103',
       trangthai = 'HOAT_DONG',
       ngaycapnhat = CURRENT_TIMESTAMP
 WHERE username = 'btc_vhtt_tphcm';

SET @tk_btc_vhtt_hcm := (SELECT idtaikhoan FROM taikhoan WHERE username = 'btc_vhtt_tphcm' LIMIT 1);

INSERT INTO nguoidung (idtaikhoan, ten, hodem, gioitinh, ngaysinh, quequan, diachi, cccd)
SELECT @tk_btc_vhtt_hcm, 'VH-TT TP.HCM', 'BTC So', 'NAM', '1984-03-01',
       'Thanh pho Ho Chi Minh', 'So VH-TT Thanh pho Ho Chi Minh', '001000010003'
 WHERE @tk_btc_vhtt_hcm IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM nguoidung WHERE idtaikhoan = @tk_btc_vhtt_hcm);

UPDATE nguoidung
   SET ten = 'VH-TT TP.HCM',
       hodem = 'BTC So',
       gioitinh = 'NAM',
       ngaysinh = '1984-03-01',
       quequan = 'Thanh pho Ho Chi Minh',
       diachi = 'So VH-TT Thanh pho Ho Chi Minh',
       ngaycapnhat = CURRENT_TIMESTAMP
 WHERE idtaikhoan = @tk_btc_vhtt_hcm;

SET @nd_btc_vhtt_hcm := (SELECT idnguoidung FROM nguoidung WHERE idtaikhoan = @tk_btc_vhtt_hcm LIMIT 1);

INSERT INTO bantochuc (idnguoidung, idcapbantochuc, idkhuvucquanly, iddonvi, idbantochuccha, donvi, chucvu, trangthai)
SELECT @nd_btc_vhtt_hcm, @cap_btc_tinh, @kv_hcm, @dv_vhtt_hcm, @btc_quocgia,
       'So VH-TT Thanh pho Ho Chi Minh', 'BTC to chuc giai va xet duyet suat thi dau cap tinh/thanh', 'HOAT_DONG'
 WHERE @nd_btc_vhtt_hcm IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM bantochuc WHERE idnguoidung = @nd_btc_vhtt_hcm);

UPDATE bantochuc
   SET idcapbantochuc = @cap_btc_tinh,
       idkhuvucquanly = @kv_hcm,
       iddonvi = @dv_vhtt_hcm,
       idbantochuccha = @btc_quocgia,
       donvi = 'So VH-TT Thanh pho Ho Chi Minh',
       chucvu = 'BTC to chuc giai va xet duyet suat thi dau cap tinh/thanh',
       trangthai = 'HOAT_DONG'
 WHERE idnguoidung = @nd_btc_vhtt_hcm;

SET @btc_vhtt_hcm := (
    SELECT btc.idbantochuc
      FROM bantochuc btc
      JOIN nguoidung nd ON nd.idnguoidung = btc.idnguoidung
      JOIN taikhoan tk ON tk.idtaikhoan = nd.idtaikhoan
     WHERE tk.username = 'btc_vhtt_tphcm'
     LIMIT 1
);

INSERT INTO taikhoan (username, password, email, sodienthoai, idrole, trangthai)
SELECT 'btc_vhtt_hanoi', @pwd_btc, 'btc.vhtt.hanoi@vtms.vn', '0900000104', @role_btc, 'HOAT_DONG'
 WHERE @role_btc IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM taikhoan WHERE username = 'btc_vhtt_hanoi');

UPDATE taikhoan
   SET idrole = @role_btc,
       email = 'btc.vhtt.hanoi@vtms.vn',
       sodienthoai = '0900000104',
       trangthai = 'HOAT_DONG',
       ngaycapnhat = CURRENT_TIMESTAMP
 WHERE username = 'btc_vhtt_hanoi';

SET @tk_btc_vhtt_hn := (SELECT idtaikhoan FROM taikhoan WHERE username = 'btc_vhtt_hanoi' LIMIT 1);

INSERT INTO nguoidung (idtaikhoan, ten, hodem, gioitinh, ngaysinh, quequan, diachi, cccd)
SELECT @tk_btc_vhtt_hn, 'VH-TT Ha Noi', 'BTC So', 'NAM', '1984-04-01',
       'Thanh pho Ha Noi', 'So VH-TT Thanh pho Ha Noi', '001000010004'
 WHERE @tk_btc_vhtt_hn IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM nguoidung WHERE idtaikhoan = @tk_btc_vhtt_hn);

UPDATE nguoidung
   SET ten = 'VH-TT Ha Noi',
       hodem = 'BTC So',
       gioitinh = 'NAM',
       ngaysinh = '1984-04-01',
       quequan = 'Thanh pho Ha Noi',
       diachi = 'So VH-TT Thanh pho Ha Noi',
       ngaycapnhat = CURRENT_TIMESTAMP
 WHERE idtaikhoan = @tk_btc_vhtt_hn;

SET @nd_btc_vhtt_hn := (SELECT idnguoidung FROM nguoidung WHERE idtaikhoan = @tk_btc_vhtt_hn LIMIT 1);

INSERT INTO bantochuc (idnguoidung, idcapbantochuc, idkhuvucquanly, iddonvi, idbantochuccha, donvi, chucvu, trangthai)
SELECT @nd_btc_vhtt_hn, @cap_btc_tinh, @kv_hn, @dv_vhtt_hn, @btc_quocgia,
       'So VH-TT Thanh pho Ha Noi', 'BTC to chuc giai va xet duyet suat thi dau cap tinh/thanh', 'HOAT_DONG'
 WHERE @nd_btc_vhtt_hn IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM bantochuc WHERE idnguoidung = @nd_btc_vhtt_hn);

UPDATE bantochuc
   SET idcapbantochuc = @cap_btc_tinh,
       idkhuvucquanly = @kv_hn,
       iddonvi = @dv_vhtt_hn,
       idbantochuccha = @btc_quocgia,
       donvi = 'So VH-TT Thanh pho Ha Noi',
       chucvu = 'BTC to chuc giai va xet duyet suat thi dau cap tinh/thanh',
       trangthai = 'HOAT_DONG'
 WHERE idnguoidung = @nd_btc_vhtt_hn;

SET @btc_vhtt_hn := (
    SELECT btc.idbantochuc
      FROM bantochuc btc
      JOIN nguoidung nd ON nd.idnguoidung = btc.idnguoidung
      JOIN taikhoan tk ON tk.idtaikhoan = nd.idtaikhoan
     WHERE tk.username = 'btc_vhtt_hanoi'
     LIMIT 1
);

-- 2. Chuyen cac tham chieu tu BTC tinh cu sang BTC VH-TT moi, roi xoa tai khoan cu.
UPDATE giaidau
   SET idbantochuc = @btc_vhtt_hcm,
       ngaycapnhat = CURRENT_TIMESTAMP
 WHERE idbantochuc = @old_btc_hcm
   AND @btc_vhtt_hcm IS NOT NULL;

UPDATE giaidau
   SET idbantochuc = @btc_vhtt_hn,
       ngaycapnhat = CURRENT_TIMESTAMP
 WHERE idbantochuc = @old_btc_hn
   AND @btc_vhtt_hn IS NOT NULL;

UPDATE bantochuc
   SET idbantochuccha = @btc_vhtt_hcm
 WHERE idbantochuccha = @old_btc_hcm
   AND @btc_vhtt_hcm IS NOT NULL;

UPDATE bantochuc
   SET idbantochuccha = @btc_vhtt_hn
 WHERE idbantochuccha = @old_btc_hn
   AND @btc_vhtt_hn IS NOT NULL;

UPDATE decutucachthamgia
   SET idbantochuc_decu = @btc_vhtt_hcm,
       ngaycapnhat = CURRENT_TIMESTAMP
 WHERE idbantochuc_decu = @old_btc_hcm
   AND @btc_vhtt_hcm IS NOT NULL;

UPDATE decutucachthamgia
   SET idbantochuc_nhan = @btc_vhtt_hcm,
       ngaycapnhat = CURRENT_TIMESTAMP
 WHERE idbantochuc_nhan = @old_btc_hcm
   AND @btc_vhtt_hcm IS NOT NULL;

UPDATE decutucachthamgia
   SET idbantochuc_decu = @btc_vhtt_hn,
       ngaycapnhat = CURRENT_TIMESTAMP
 WHERE idbantochuc_decu = @old_btc_hn
   AND @btc_vhtt_hn IS NOT NULL;

UPDATE decutucachthamgia
   SET idbantochuc_nhan = @btc_vhtt_hn,
       ngaycapnhat = CURRENT_TIMESTAMP
 WHERE idbantochuc_nhan = @old_btc_hn
   AND @btc_vhtt_hn IS NOT NULL;

UPDATE taikhoan
   SET trangthai = 'TAM_KHOA',
       ngaycapnhat = CURRENT_TIMESTAMP
 WHERE username IN ('btc_hcm', 'btc_hn', 'btc_hanoi');

DELETE FROM taikhoan
 WHERE username = 'btc_hcm'
   AND @btc_vhtt_hcm IS NOT NULL;

DELETE FROM taikhoan
 WHERE username IN ('btc_hn', 'btc_hanoi')
   AND @btc_vhtt_hn IS NOT NULL;

-- 3. Chuan hoa HLV TDTT cap tinh/thanh.
INSERT INTO taikhoan (username, password, email, sodienthoai, idrole, trangthai)
SELECT 'hlv_tphcm', @pwd_hlv, 'hlv.tphcm@vtms.vn', '0900000008', @role_hlv, 'HOAT_DONG'
 WHERE @role_hlv IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM taikhoan WHERE username = 'hlv_tphcm');

UPDATE taikhoan
   SET idrole = @role_hlv,
       trangthai = 'HOAT_DONG',
       ngaycapnhat = CURRENT_TIMESTAMP
 WHERE username = 'hlv_tphcm';

SET @tk_hlv_hcm := (SELECT idtaikhoan FROM taikhoan WHERE username = 'hlv_tphcm' LIMIT 1);

INSERT INTO nguoidung (idtaikhoan, ten, hodem, gioitinh, ngaysinh, quequan, diachi, cccd)
SELECT @tk_hlv_hcm, 'Doi tuyen TP.HCM', 'HLV', 'NAM', '1984-10-01',
       'Thanh pho Ho Chi Minh', 'Trung tam huan luyen va thi dau TDTT Thanh pho Ho Chi Minh', '001000000008'
 WHERE @tk_hlv_hcm IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM nguoidung WHERE idtaikhoan = @tk_hlv_hcm);

UPDATE nguoidung
   SET ten = 'Doi tuyen TP.HCM',
       hodem = 'HLV',
       gioitinh = 'NAM',
       quequan = 'Thanh pho Ho Chi Minh',
       diachi = 'Trung tam huan luyen va thi dau TDTT Thanh pho Ho Chi Minh',
       ngaycapnhat = CURRENT_TIMESTAMP
 WHERE idtaikhoan = @tk_hlv_hcm;

SET @nd_hlv_hcm := (SELECT idnguoidung FROM nguoidung WHERE idtaikhoan = @tk_hlv_hcm LIMIT 1);

INSERT INTO huanluyenvien (idnguoidung, idkhuvuccongtac, iddonvi, la_hlv_tu_nhan, donvicongtac, bangcap, kinhnghiem, trangthai)
SELECT @nd_hlv_hcm, @kv_hcm, @dv_tdtt_hcm, 0,
       'Trung tam huan luyen va thi dau TDTT Thanh pho Ho Chi Minh', 'Chung chi HLV cap tinh', 8, 'DA_XAC_NHAN'
 WHERE @nd_hlv_hcm IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM huanluyenvien WHERE idnguoidung = @nd_hlv_hcm);

UPDATE huanluyenvien
   SET idkhuvuccongtac = @kv_hcm,
       iddonvi = @dv_tdtt_hcm,
       la_hlv_tu_nhan = 0,
       donvicongtac = 'Trung tam huan luyen va thi dau TDTT Thanh pho Ho Chi Minh',
       bangcap = 'Chung chi HLV cap tinh',
       kinhnghiem = 8,
       trangthai = 'DA_XAC_NHAN'
 WHERE idnguoidung = @nd_hlv_hcm;

SET @hlv_hcm := (SELECT idhuanluyenvien FROM huanluyenvien WHERE idnguoidung = @nd_hlv_hcm LIMIT 1);

INSERT INTO taikhoan (username, password, email, sodienthoai, idrole, trangthai)
SELECT 'hlv_hanoi', @pwd_hlv, 'hlv.hanoi@vtms.vn', '0900000009', @role_hlv, 'HOAT_DONG'
 WHERE @role_hlv IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM taikhoan WHERE username = 'hlv_hanoi');

UPDATE taikhoan
   SET idrole = @role_hlv,
       trangthai = 'HOAT_DONG',
       ngaycapnhat = CURRENT_TIMESTAMP
 WHERE username = 'hlv_hanoi';

SET @tk_hlv_hn := (SELECT idtaikhoan FROM taikhoan WHERE username = 'hlv_hanoi' LIMIT 1);

INSERT INTO nguoidung (idtaikhoan, ten, hodem, gioitinh, ngaysinh, quequan, diachi, cccd)
SELECT @tk_hlv_hn, 'Doi tuyen Ha Noi', 'HLV', 'NAM', '1986-11-01',
       'Thanh pho Ha Noi', 'Trung tam huan luyen va thi dau TDTT Thanh pho Ha Noi', '001000000009'
 WHERE @tk_hlv_hn IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM nguoidung WHERE idtaikhoan = @tk_hlv_hn);

UPDATE nguoidung
   SET ten = 'Doi tuyen Ha Noi',
       hodem = 'HLV',
       gioitinh = 'NAM',
       quequan = 'Thanh pho Ha Noi',
       diachi = 'Trung tam huan luyen va thi dau TDTT Thanh pho Ha Noi',
       ngaycapnhat = CURRENT_TIMESTAMP
 WHERE idtaikhoan = @tk_hlv_hn;

SET @nd_hlv_hn := (SELECT idnguoidung FROM nguoidung WHERE idtaikhoan = @tk_hlv_hn LIMIT 1);

INSERT INTO huanluyenvien (idnguoidung, idkhuvuccongtac, iddonvi, la_hlv_tu_nhan, donvicongtac, bangcap, kinhnghiem, trangthai)
SELECT @nd_hlv_hn, @kv_hn, @dv_tdtt_hn, 0,
       'Trung tam huan luyen va thi dau TDTT Thanh pho Ha Noi', 'Chung chi HLV cap tinh', 7, 'DA_XAC_NHAN'
 WHERE @nd_hlv_hn IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM huanluyenvien WHERE idnguoidung = @nd_hlv_hn);

UPDATE huanluyenvien
   SET idkhuvuccongtac = @kv_hn,
       iddonvi = @dv_tdtt_hn,
       la_hlv_tu_nhan = 0,
       donvicongtac = 'Trung tam huan luyen va thi dau TDTT Thanh pho Ha Noi',
       bangcap = 'Chung chi HLV cap tinh',
       kinhnghiem = 7,
       trangthai = 'DA_XAC_NHAN'
 WHERE idnguoidung = @nd_hlv_hn;

SET @hlv_hn := (SELECT idhuanluyenvien FROM huanluyenvien WHERE idnguoidung = @nd_hlv_hn LIMIT 1);

-- 4. Doi bong cap tinh/thanh do HLV TDTT tinh quan ly.
INSERT INTO doibong (tendoibong, logo, idkhuvucdaidien, idcapgiaidau_duoc_tham_gia, diaphuong, mota, idhuanluyenvien, diem_xep_hang, trangthai)
SELECT 'Doi tuyen Thanh pho Ho Chi Minh', NULL, @kv_hcm, @cap_giai_tinh,
       'Thanh pho Ho Chi Minh', 'Doi bong cap tinh/thanh do HLV TDTT TP.HCM quan ly.', @hlv_hcm, 0.00, 'HOAT_DONG'
 WHERE @hlv_hcm IS NOT NULL
   AND NOT EXISTS (
       SELECT 1 FROM doibong
        WHERE tendoibong IN ('Doi tuyen Thanh pho Ho Chi Minh', 'Đội tuyển Thành phố Hồ Chí Minh')
   );

UPDATE doibong
   SET idkhuvucdaidien = @kv_hcm,
       idcapgiaidau_duoc_tham_gia = @cap_giai_tinh,
       diaphuong = 'Thanh pho Ho Chi Minh',
       mota = 'Doi bong cap tinh/thanh do HLV TDTT TP.HCM quan ly.',
       idhuanluyenvien = @hlv_hcm,
       trangthai = 'HOAT_DONG',
       ngaycapnhat = CURRENT_TIMESTAMP
 WHERE tendoibong IN ('Doi tuyen Thanh pho Ho Chi Minh', 'Đội tuyển Thành phố Hồ Chí Minh');

SET @doi_hcm := (
    SELECT iddoibong
      FROM doibong
     WHERE tendoibong IN ('Doi tuyen Thanh pho Ho Chi Minh', 'Đội tuyển Thành phố Hồ Chí Minh')
     ORDER BY iddoibong
     LIMIT 1
);

INSERT INTO doibong (tendoibong, logo, idkhuvucdaidien, idcapgiaidau_duoc_tham_gia, diaphuong, mota, idhuanluyenvien, diem_xep_hang, trangthai)
SELECT 'Doi tuyen Thanh pho Ha Noi', NULL, @kv_hn, @cap_giai_tinh,
       'Thanh pho Ha Noi', 'Doi bong cap tinh/thanh do HLV TDTT Ha Noi quan ly.', @hlv_hn, 0.00, 'HOAT_DONG'
 WHERE @hlv_hn IS NOT NULL
   AND NOT EXISTS (
       SELECT 1 FROM doibong
        WHERE tendoibong IN ('Doi tuyen Thanh pho Ha Noi', 'Đội tuyển Thành phố Hà Nội')
   );

UPDATE doibong
   SET idkhuvucdaidien = @kv_hn,
       idcapgiaidau_duoc_tham_gia = @cap_giai_tinh,
       diaphuong = 'Thanh pho Ha Noi',
       mota = 'Doi bong cap tinh/thanh do HLV TDTT Ha Noi quan ly.',
       idhuanluyenvien = @hlv_hn,
       trangthai = 'HOAT_DONG',
       ngaycapnhat = CURRENT_TIMESTAMP
 WHERE tendoibong IN ('Doi tuyen Thanh pho Ha Noi', 'Đội tuyển Thành phố Hà Nội');

SET @doi_hn := (
    SELECT iddoibong
      FROM doibong
     WHERE tendoibong IN ('Doi tuyen Thanh pho Ha Noi', 'Đội tuyển Thành phố Hà Nội')
     ORDER BY iddoibong
     LIMIT 1
);

UPDATE taikhoan
   SET idrole = @role_vdv,
       trangthai = 'HOAT_DONG',
       ngaycapnhat = CURRENT_TIMESTAMP
 WHERE idtaikhoan > 0
   AND idtaikhoan IN (
       SELECT nd.idtaikhoan
         FROM nguoidung nd
         JOIN vandongvien vdv ON vdv.idnguoidung = nd.idnguoidung
        WHERE vdv.idvandongvien IN (10031,10032,10033,10034,10035,10036,10041,10042,10043,10044,10045,10046)
 )
 LIMIT 12;

UPDATE nguoidung
   SET gioitinh = 'NAM',
       ngaycapnhat = CURRENT_TIMESTAMP
 WHERE idnguoidung > 0
   AND idnguoidung IN (
       SELECT vdv.idnguoidung
         FROM vandongvien vdv
        WHERE vdv.idvandongvien IN (10031,10032,10033,10034,10035,10036,10041,10042,10043,10044,10045,10046)
 )
 LIMIT 12;

UPDATE vandongvien
   SET trangthaidaugiai = 'DU_DIEU_KIEN'
 WHERE idvandongvien > 0
   AND idvandongvien IN (10031,10032,10033,10034,10035,10036,10041,10042,10043,10044,10045,10046)
 LIMIT 12;

UPDATE thanhviendoibong
   SET vaitro = CASE
           WHEN idvandongvien IN (10031,10041) THEN 'DOI_TRUONG'
           WHEN idvandongvien IN (10036,10046) THEN 'DU_BI'
           ELSE 'THANH_VIEN'
       END,
       trangthai = 'DANG_THAM_GIA',
       ngayroi = NULL
 WHERE (iddoibong = @doi_hcm AND idvandongvien IN (10031,10032,10033,10034,10035,10036))
    OR (iddoibong = @doi_hn AND idvandongvien IN (10041,10042,10043,10044,10045,10046));

INSERT INTO thanhviendoibong (iddoibong, idvandongvien, vaitro, trangthai, ngaythamgia)
SELECT @doi_hcm, 10031, 'DOI_TRUONG', 'DANG_THAM_GIA', '2026-01-01'
 WHERE @doi_hcm IS NOT NULL AND NOT EXISTS (SELECT 1 FROM thanhviendoibong WHERE iddoibong = @doi_hcm AND idvandongvien = 10031)
UNION ALL
SELECT @doi_hcm, 10032, 'THANH_VIEN', 'DANG_THAM_GIA', '2026-01-01'
 WHERE @doi_hcm IS NOT NULL AND NOT EXISTS (SELECT 1 FROM thanhviendoibong WHERE iddoibong = @doi_hcm AND idvandongvien = 10032)
UNION ALL
SELECT @doi_hcm, 10033, 'THANH_VIEN', 'DANG_THAM_GIA', '2026-01-01'
 WHERE @doi_hcm IS NOT NULL AND NOT EXISTS (SELECT 1 FROM thanhviendoibong WHERE iddoibong = @doi_hcm AND idvandongvien = 10033)
UNION ALL
SELECT @doi_hcm, 10034, 'THANH_VIEN', 'DANG_THAM_GIA', '2026-01-01'
 WHERE @doi_hcm IS NOT NULL AND NOT EXISTS (SELECT 1 FROM thanhviendoibong WHERE iddoibong = @doi_hcm AND idvandongvien = 10034)
UNION ALL
SELECT @doi_hcm, 10035, 'THANH_VIEN', 'DANG_THAM_GIA', '2026-01-01'
 WHERE @doi_hcm IS NOT NULL AND NOT EXISTS (SELECT 1 FROM thanhviendoibong WHERE iddoibong = @doi_hcm AND idvandongvien = 10035)
UNION ALL
SELECT @doi_hcm, 10036, 'DU_BI', 'DANG_THAM_GIA', '2026-01-01'
 WHERE @doi_hcm IS NOT NULL AND NOT EXISTS (SELECT 1 FROM thanhviendoibong WHERE iddoibong = @doi_hcm AND idvandongvien = 10036)
UNION ALL
SELECT @doi_hn, 10041, 'DOI_TRUONG', 'DANG_THAM_GIA', '2026-01-01'
 WHERE @doi_hn IS NOT NULL AND NOT EXISTS (SELECT 1 FROM thanhviendoibong WHERE iddoibong = @doi_hn AND idvandongvien = 10041)
UNION ALL
SELECT @doi_hn, 10042, 'THANH_VIEN', 'DANG_THAM_GIA', '2026-01-01'
 WHERE @doi_hn IS NOT NULL AND NOT EXISTS (SELECT 1 FROM thanhviendoibong WHERE iddoibong = @doi_hn AND idvandongvien = 10042)
UNION ALL
SELECT @doi_hn, 10043, 'THANH_VIEN', 'DANG_THAM_GIA', '2026-01-01'
 WHERE @doi_hn IS NOT NULL AND NOT EXISTS (SELECT 1 FROM thanhviendoibong WHERE iddoibong = @doi_hn AND idvandongvien = 10043)
UNION ALL
SELECT @doi_hn, 10044, 'THANH_VIEN', 'DANG_THAM_GIA', '2026-01-01'
 WHERE @doi_hn IS NOT NULL AND NOT EXISTS (SELECT 1 FROM thanhviendoibong WHERE iddoibong = @doi_hn AND idvandongvien = 10044)
UNION ALL
SELECT @doi_hn, 10045, 'THANH_VIEN', 'DANG_THAM_GIA', '2026-01-01'
 WHERE @doi_hn IS NOT NULL AND NOT EXISTS (SELECT 1 FROM thanhviendoibong WHERE iddoibong = @doi_hn AND idvandongvien = 10045)
UNION ALL
SELECT @doi_hn, 10046, 'DU_BI', 'DANG_THAM_GIA', '2026-01-01'
 WHERE @doi_hn IS NOT NULL AND NOT EXISTS (SELECT 1 FROM thanhviendoibong WHERE iddoibong = @doi_hn AND idvandongvien = 10046);

INSERT INTO doihinh (iddoibong, idgiaidau, tendoihinh, gioitinh, la_doihinh_chinh, trangthai)
SELECT @doi_hcm, NULL, 'Doi hinh nam chinh', 'NAM', 1, 'DA_CHOT'
 WHERE @doi_hcm IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM doihinh WHERE iddoibong = @doi_hcm AND gioitinh = 'NAM' AND la_doihinh_chinh = 1);

INSERT INTO doihinh (iddoibong, idgiaidau, tendoihinh, gioitinh, la_doihinh_chinh, trangthai)
SELECT @doi_hn, NULL, 'Doi hinh nam chinh', 'NAM', 1, 'DA_CHOT'
 WHERE @doi_hn IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM doihinh WHERE iddoibong = @doi_hn AND gioitinh = 'NAM' AND la_doihinh_chinh = 1);

SET @dh_hcm := (
    SELECT iddoihinh
      FROM doihinh
     WHERE iddoibong = @doi_hcm
       AND gioitinh = 'NAM'
       AND la_doihinh_chinh = 1
     ORDER BY iddoihinh
     LIMIT 1
);

SET @dh_hn := (
    SELECT iddoihinh
      FROM doihinh
     WHERE iddoibong = @doi_hn
       AND gioitinh = 'NAM'
       AND la_doihinh_chinh = 1
     ORDER BY iddoihinh
     LIMIT 1
);

UPDATE doihinh
   SET tendoihinh = 'Doi hinh nam chinh',
       gioitinh = 'NAM',
       la_doihinh_chinh = 1,
       trangthai = 'DA_CHOT',
       ngaycapnhat = CURRENT_TIMESTAMP
 WHERE iddoihinh IN (@dh_hcm, @dh_hn);

DELETE FROM chitietdoihinh
 WHERE iddoihinh IN (@dh_hcm, @dh_hn);

INSERT INTO chitietdoihinh (iddoihinh, idvandongvien, vitri, sothutu, ghichu)
SELECT @dh_hcm, 10031, 'CHU_CONG', 1, 'Chu cong' WHERE @dh_hcm IS NOT NULL
UNION ALL SELECT @dh_hcm, 10032, 'PHU_CONG', 2, 'Phu cong' WHERE @dh_hcm IS NOT NULL
UNION ALL SELECT @dh_hcm, 10033, 'CHUYEN_HAI', 3, 'Chuyen hai' WHERE @dh_hcm IS NOT NULL
UNION ALL SELECT @dh_hcm, 10034, 'DOI_CHUYEN', 4, 'Doi chuyen' WHERE @dh_hcm IS NOT NULL
UNION ALL SELECT @dh_hcm, 10035, 'LIBERO', 5, 'Libero' WHERE @dh_hcm IS NOT NULL
UNION ALL SELECT @dh_hcm, 10036, 'DOI_TRU', 6, 'Du bi' WHERE @dh_hcm IS NOT NULL
UNION ALL SELECT @dh_hn, 10041, 'CHU_CONG', 1, 'Chu cong' WHERE @dh_hn IS NOT NULL
UNION ALL SELECT @dh_hn, 10042, 'PHU_CONG', 2, 'Phu cong' WHERE @dh_hn IS NOT NULL
UNION ALL SELECT @dh_hn, 10043, 'CHUYEN_HAI', 3, 'Chuyen hai' WHERE @dh_hn IS NOT NULL
UNION ALL SELECT @dh_hn, 10044, 'DOI_CHUYEN', 4, 'Doi chuyen' WHERE @dh_hn IS NOT NULL
UNION ALL SELECT @dh_hn, 10045, 'LIBERO', 5, 'Libero' WHERE @dh_hn IS NOT NULL
UNION ALL SELECT @dh_hn, 10046, 'DOI_TRU', 6, 'Du bi' WHERE @dh_hn IS NOT NULL;

-- 5. Bao cao kiem tra nhanh sau khi chay.
SELECT
    'CHECK_OLD_BTC_DELETED' AS check_name,
    COUNT(*) AS old_account_count
  FROM taikhoan
 WHERE username IN ('btc_hcm', 'btc_hn', 'btc_hanoi');

SELECT
    'CHECK_VHTT_BTC' AS check_name,
    tk.username,
    dv.madonvi,
    dv.tendonvi,
    ldv.maloaidonvi,
    ldv.duoc_to_chuc_giai,
    cap.macapbantochuc,
    kv.capkhuvuc,
    btc.trangthai AS btc_trangthai
  FROM bantochuc btc
  JOIN nguoidung nd ON nd.idnguoidung = btc.idnguoidung
  JOIN taikhoan tk ON tk.idtaikhoan = nd.idtaikhoan
  JOIN donvi dv ON dv.iddonvi = btc.iddonvi
  JOIN loaidonvi ldv ON ldv.idloaidonvi = dv.idloaidonvi
  JOIN capbantochuc cap ON cap.idcapbantochuc = btc.idcapbantochuc
  JOIN khuvuc kv ON kv.idkhuvuc = btc.idkhuvucquanly
 WHERE tk.username IN ('btc_vhtt_tphcm', 'btc_vhtt_hanoi');

SELECT
    'CHECK_TDTT_HLV_TINH' AS check_name,
    tk.username,
    dv.madonvi,
    dv.tendonvi,
    kv.capkhuvuc AS cap_khuvuc_hlv,
    hlv.la_hlv_tu_nhan,
    hlv.trangthai AS hlv_trangthai
  FROM huanluyenvien hlv
  JOIN nguoidung nd ON nd.idnguoidung = hlv.idnguoidung
  JOIN taikhoan tk ON tk.idtaikhoan = nd.idtaikhoan
  JOIN donvi dv ON dv.iddonvi = hlv.iddonvi
  JOIN khuvuc kv ON kv.idkhuvuc = hlv.idkhuvuccongtac
 WHERE tk.username IN ('hlv_tphcm', 'hlv_hanoi');

SELECT
    'CHECK_DOIHINH_TINH' AS check_name,
    db.tendoibong,
    tk.username AS hlv_username,
    cg.macapgiaidau AS cap_duoc_tham_gia,
    COUNT(DISTINCT ctdh.idvandongvien) AS so_vdv_trong_doi_hinh,
    COUNT(DISTINCT ctdh.vitri) AS so_vai_tro,
    SUM(CASE WHEN nd_vdv.gioitinh = 'NAM' THEN 1 ELSE 0 END) AS so_vdv_nam,
    SUM(CASE WHEN tvdb.trangthai = 'DANG_THAM_GIA' THEN 1 ELSE 0 END) AS so_vdv_dang_tham_gia,
    GROUP_CONCAT(ctdh.vitri ORDER BY ctdh.sothutu SEPARATOR ', ') AS vai_tro
  FROM doibong db
  JOIN huanluyenvien hlv ON hlv.idhuanluyenvien = db.idhuanluyenvien
  JOIN nguoidung nd_hlv ON nd_hlv.idnguoidung = hlv.idnguoidung
  JOIN taikhoan tk ON tk.idtaikhoan = nd_hlv.idtaikhoan
  LEFT JOIN capgiaidau cg ON cg.idcapgiaidau = db.idcapgiaidau_duoc_tham_gia
  JOIN doihinh dh ON dh.iddoibong = db.iddoibong AND dh.gioitinh = 'NAM' AND dh.la_doihinh_chinh = 1
  JOIN chitietdoihinh ctdh ON ctdh.iddoihinh = dh.iddoihinh
  JOIN vandongvien vdv ON vdv.idvandongvien = ctdh.idvandongvien
  JOIN nguoidung nd_vdv ON nd_vdv.idnguoidung = vdv.idnguoidung
  JOIN thanhviendoibong tvdb ON tvdb.iddoibong = db.iddoibong AND tvdb.idvandongvien = vdv.idvandongvien
 WHERE db.iddoibong IN (@doi_hcm, @doi_hn)
 GROUP BY db.iddoibong, db.tendoibong, tk.username, cg.macapgiaidau;
